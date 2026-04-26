import 'package:intl/intl.dart';

/// Turkish lira formatting extension for [double].
///
/// Usage:
///   1234.5.formatted          → "₺ 1.234,50"
///   1234.5.formattedCompact   → "₺ 1.234"
extension CurrencyFormatting on double {
  static final _fullFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺ ',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺ ',
    decimalDigits: 0,
  );

  /// Full format with 2 decimal places — e.g. "₺ 10.500,75"
  String get formatted => _fullFormatter.format(this);

  /// Compact format without decimals — e.g. "₺ 10.500"
  String get formattedCompact => _compactFormatter.format(this);
}
