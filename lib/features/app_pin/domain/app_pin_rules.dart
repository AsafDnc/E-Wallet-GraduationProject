/// Pure rules for 6-digit app PIN quality hints (non-blocking for navigation).
abstract final class AppPinRules {
  static const int pinLength = 6;

  static bool isComplete(String digits) =>
      digits.length == pinLength && RegExp(r'^\d{6}$').hasMatch(digits);

  /// e.g. 123456 or 654321 (ascending/descending steps of 1).
  static bool hasStrictSequentialRun(String six) {
    if (six.length != pinLength) return false;
    var asc = true;
    var desc = true;
    for (var i = 0; i < pinLength - 1; i++) {
      final a = int.parse(six[i]);
      final b = int.parse(six[i + 1]);
      if (b != a + 1) asc = false;
      if (b != a - 1) desc = false;
    }
    return asc || desc;
  }

  static bool isAllSameDigit(String six) {
    if (six.length != pinLength) return false;
    return six.split('').toSet().length == 1;
  }
}
