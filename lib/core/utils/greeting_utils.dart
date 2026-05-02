// Time-of-day and name helpers for personalized greetings (e.g. Home header).

import '../../l10n/app_localizations.dart';

/// Localized greeting for the current time-of-day bucket.
String localizedGreetingPhrase(AppLocalizations l10n, [DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour >= 5 && hour < 12) {
    return l10n.greetingGoodMorning;
  }
  if (hour >= 12 && hour < 17) {
    return l10n.greetingGoodAfternoon;
  }
  if (hour >= 17 && hour < 22) {
    return l10n.greetingGoodEvening;
  }
  return l10n.greetingGoodNight;
}

/// First whitespace-separated token of [fullName] for short greetings.
String firstNameFromFullName(String fullName, String emptyFallback) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) {
    return emptyFallback;
  }
  final parts = trimmed.split(' ');
  for (final part in parts) {
    if (part.isNotEmpty) {
      return part;
    }
  }
  return emptyFallback;
}
