import 'package:flutter/foundation.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.length != AppPinRules.pinLength) {
        return null;
      }
      if (!RegExp(r'^\d{6}$').hasMatch(raw)) {
        return null;
      }
      return raw;
    } catch (e, st) {
      debugPrint('SharedPreferencesAppPinRepository.readPin failed: $e\n$st');
      return null;
    }
  }

  @override
  Future<void> writePin(String pin) async {
    if (!AppPinRules.isComplete(pin)) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, pin);
    } catch (e, st) {
      debugPrint('SharedPreferencesAppPinRepository.writePin failed: $e\n$st');
    }
  }

  @override
  Future<void> clearPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e, st) {
      debugPrint('SharedPreferencesAppPinRepository.clearPin failed: $e\n$st');
    }
  }
}
