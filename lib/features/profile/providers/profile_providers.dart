import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../core/network/supabase_init.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/currency_formatter.dart';

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
      return ProfileState(
        fullName: 'User',
        email: 'user@example.com',
        currency: '$appCurrencySymbol TRY',
        language: appLocaleBootstrap.languageCode == 'tr'
            ? 'Türkçe'
            : 'English',
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
      currency: '$appCurrencySymbol TRY',
      language: appLocaleBootstrap.languageCode == 'tr' ? 'Türkçe' : 'English',
    );
  }

  void updateCurrency(String currency) =>
      state = state.copyWith(currency: currency);

  void updateLanguage(String language) =>
      state = state.copyWith(language: language);

  /// Updates the displayed full name everywhere (Profile header, Home greeting, etc.).
  void updateFullName(String fullName) {
    state = state.copyWith(fullName: fullName.trim());
  }
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

// ─── Require PIN on App Launch ────────────────────────────────────────────────

class RequirePinNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

final requirePinProvider = NotifierProvider<RequirePinNotifier, bool>(
  RequirePinNotifier.new,
);

// ─── Daily Transaction Limits ─────────────────────────────────────────────────

class DailyLimitsState {
  const DailyLimitsState({this.isEnabled = false, this.limitAmount = 5000.0});

  final bool isEnabled;
  final double limitAmount;

  DailyLimitsState copyWith({bool? isEnabled, double? limitAmount}) {
    return DailyLimitsState(
      isEnabled: isEnabled ?? this.isEnabled,
      limitAmount: limitAmount ?? this.limitAmount,
    );
  }
}

class DailyLimitsNotifier extends Notifier<DailyLimitsState> {
  @override
  DailyLimitsState build() => const DailyLimitsState();

  void setEnabled(bool value) => state = state.copyWith(isEnabled: value);

  void setLimit(double amount) {
    if (amount <= 0) return;
    state = state.copyWith(limitAmount: amount);
  }
}

final dailyLimitsProvider =
    NotifierProvider<DailyLimitsNotifier, DailyLimitsState>(
      DailyLimitsNotifier.new,
    );
