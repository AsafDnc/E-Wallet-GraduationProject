import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists `en` / `tr` under this key.
const String kAppLocalePreferenceKey = 'app_locale_code';

/// Set from [main] after reading [SharedPreferences], before [runApp].
Locale appLocaleBootstrap = const Locale('en');

/// App-wide locale (drives [MaterialApp.router] `locale`).
final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => appLocaleBootstrap;

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kAppLocalePreferenceKey, locale.languageCode);
    } catch (_) {
      // Persistence failure should not block UI language change.
    }
  }
}
