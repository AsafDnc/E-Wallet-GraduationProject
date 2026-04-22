import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  final AuthStatus status;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.success;

  /// Replaces fields with new values. Omitting [errorMessage] clears it to null.
  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(status: status ?? this.status, errorMessage: errorMessage);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  SupabaseClient get _client => ref.read(supabaseClientProvider);

  /// Synchronously checks for an existing Supabase session on startup.
  ///
  /// Never touches [Supabase.instance] until [supabasePluginReady] is true,
  /// otherwise [LoginScreen] would crash before the first frame.
  @override
  AuthState build() {
    if (!supabasePluginReady) return const AuthState();
    try {
      final hasSession = _client.auth.currentSession != null;
      return hasSession
          ? const AuthState(status: AuthStatus.success)
          : const AuthState();
    } catch (_) {
      return const AuthState();
    }
  }

  Future<void> login({required String email, required String password}) async {
    if (!supabasePluginReady) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage:
            'Unable to reach the server. Check your connection and try again.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      state = const AuthState(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (!supabasePluginReady) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage:
            'Unable to reach the server. Check your connection and try again.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: <String, String>{'first_name': firstName, 'last_name': lastName},
      );
      state = const AuthState(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    if (!supabasePluginReady) {
      state = const AuthState();
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _client.auth.signOut();
      state = const AuthState();
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Sign out failed. Please try again.',
      );
    }
  }

  void reset() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
