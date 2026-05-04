import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_pin_rules.dart';

/// Local persistence for the 6-digit app PIN (not Supabase auth password).
abstract class AppPinRepository {
  Future<String?> readPin();

  Future<void> writePin(String pin);

  Future<void> clearPin();
}

class SharedPreferencesAppPinRepository implements AppPinRepository {
  SharedPreferencesAppPinRepository();

  static const _key = 'app_pin_six_digits_v1';

  @override
  Future<String?> readPin() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.length != AppPinRules.pinLength) {
      return null;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
      return null;
    }
    return raw;
  }

  @override
  Future<void> writePin(String pin) async {
    if (!AppPinRules.isComplete(pin)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, pin);
  }

  @override
  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
