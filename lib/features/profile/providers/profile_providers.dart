import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';

// ─── Profile State ────────────────────────────────────────────────────────────

class ProfileState {
  const ProfileState({
    required this.fullName,
    required this.email,
    required this.currency,
    required this.language,
    this.isVerified = true,
  });

  final String fullName;
  final String email;
  final String currency;
  final String language;
  final bool isVerified;

  ProfileState copyWith({
    String? fullName,
    String? email,
    String? currency,
    String? language,
    bool? isVerified,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    if (!supabasePluginReady) {
      return const ProfileState(
        fullName: 'User',
        email: 'user@example.com',
        currency: '₺ TRY',
        language: 'English / Türkçe',
      );
    }
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    final meta = user?.userMetadata;
    final firstName = meta?['first_name'] as String? ?? '';
    final lastName = meta?['last_name'] as String? ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    return ProfileState(
      fullName: fullName.isEmpty ? 'User' : fullName,
      email: user?.email ?? 'user@example.com',
      currency: '₺ TRY',
      language: 'English / Türkçe',
    );
  }

  void updateCurrency(String currency) =>
      state = state.copyWith(currency: currency);

  void updateLanguage(String language) =>
      state = state.copyWith(language: language);
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

// ─── Biometric Login Toggle ───────────────────────────────────────────────────

class BiometricNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final biometricProvider = NotifierProvider<BiometricNotifier, bool>(
  BiometricNotifier.new,
);

// ─── Notifications Toggle ────────────────────────────────────────────────────

class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, bool>(
  NotificationsNotifier.new,
);
