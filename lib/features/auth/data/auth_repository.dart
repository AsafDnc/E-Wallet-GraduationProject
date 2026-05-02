import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../domain/auth_user_message.dart';

/// Thrown when [AuthRepository] cannot complete an auth operation; [message] is
/// a canonical English string (see [AuthUserMessage]) for UI localization.
class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Registers a new user. Optional [firstName] / [lastName] are stored in
  /// Supabase user metadata when provided.
  Future<void> signUp(
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    if (!supabasePluginReady) {
      throw const AuthRepositoryException(AuthUserMessage.serverUnreachable);
    }

    try {
      final trimmedEmail = email.trim();
      Map<String, Object?>? data;
      final fn = firstName?.trim();
      final ln = lastName?.trim();
      if ((fn != null && fn.isNotEmpty) || (ln != null && ln.isNotEmpty)) {
        data = <String, Object?>{
          if (fn != null && fn.isNotEmpty) 'first_name': fn,
          if (ln != null && ln.isNotEmpty) 'last_name': ln,
        };
      }

      await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: data,
      );
    } on AuthException catch (e) {
      throw AuthRepositoryException(_mapAuthExceptionToEnglish(e));
    } catch (_) {
      throw const AuthRepositoryException(AuthUserMessage.somethingWrong);
    }
  }

  /// Confirms signup using the email OTP.
  Future<void> verifyOTP(String email, String otpCode) async {
    if (!supabasePluginReady) {
      throw const AuthRepositoryException(AuthUserMessage.serverUnreachable);
    }

    try {
      await _client.auth.verifyOTP(
        email: email.trim(),
        token: otpCode.trim(),
        type: OtpType.signup,
      );
    } on AuthException catch (e) {
      throw AuthRepositoryException(_mapAuthExceptionToEnglish(e));
    } catch (_) {
      throw const AuthRepositoryException(AuthUserMessage.somethingWrong);
    }
  }

  String _mapAuthExceptionToEnglish(AuthException e) {
    final raw = e.message.trim();
    if (raw.isEmpty) {
      return AuthUserMessage.requestFailed;
    }
    final lower = raw.toLowerCase();

    if (lower.contains('already registered') ||
        lower.contains('already been registered') ||
        lower.contains('user already registered')) {
      return AuthUserMessage.emailAlreadyRegistered;
    }
    if (lower.contains('email') && lower.contains('confirm')) {
      return AuthUserMessage.confirmEmailBeforeContinuing;
    }
    if (lower.contains('password') && lower.contains('least')) {
      return AuthUserMessage.passwordDoesNotMeetRequirements;
    }
    if (lower.contains('invalid') && lower.contains('email')) {
      return AuthUserMessage.enterValidEmail;
    }
    if (lower.contains('rate limit') ||
        lower.contains('too many') ||
        lower.contains('email rate limit')) {
      return AuthUserMessage.rateLimited;
    }
    if (lower.contains('otp') ||
        lower.contains('token') ||
        lower.contains('code')) {
      if (lower.contains('expired')) {
        return AuthUserMessage.otpExpired;
      }
      if (lower.contains('invalid') || lower.contains('wrong')) {
        return AuthUserMessage.invalidVerificationCode;
      }
    }
    if (lower.contains('session')) {
      return AuthUserMessage.sessionFailed;
    }

    return raw;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
