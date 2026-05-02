import 'package:intl/intl.dart';

/// Primary app currency (Turkish Lira).
const String appCurrencySymbol = '₺';

/// Symbol plus one space before numeric amounts (consistent app-wide UI).
const String appCurrencySymbolSpaced = '$appCurrencySymbol ';

/// Turkish lira formatting extension for [double].
///
/// Usage:
///   1234.5.formatted          → "₺ 1.234,50"
///   1234.5.formattedCompact   → "₺ 1.234"
///   12.5.toAppCurrency()      → "₺ 12.50" (no grouping, fixed decimals)
extension CurrencyFormatting on double {
  static final NumberFormat _fullFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: appCurrencySymbolSpaced,
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: appCurrencySymbolSpaced,
    decimalDigits: 0,
  );

  /// Full format with 2 decimal places — e.g. "₺ 10.500,75"
  String get formatted => _fullFormatter.format(this);

  /// Compact format without decimals — e.g. "₺ 10.500"
  String get formattedCompact => _compactFormatter.format(this);

  /// Plain amount with [appCurrencySymbolSpaced] and fixed decimals (no grouping).
  String toAppCurrency({int fractionDigits = 2}) =>
      '$appCurrencySymbolSpaced${toStringAsFixed(fractionDigits)}';

  /// Signed +/- with symbol, space, and fixed decimals.
  String toAppCurrencySigned({int fractionDigits = 2}) {
    final String sign = this < 0 ? '-' : '+';
    return '$sign$appCurrencySymbolSpaced${abs().toStringAsFixed(fractionDigits)}';
  }
}
