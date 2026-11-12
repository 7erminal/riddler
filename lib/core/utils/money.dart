import 'package:intl/intl.dart';

/// Helpers for presenting money / numbers in a consistent, brand-aware way.
class Money {
  Money._();

  /// Symbol used across the storefront.
  static const String symbol = 'GH₵';

  /// e.g. GH₵ 249.00
  static String format(double value) =>
      '$symbol ${_price.format(value)}';

  /// e.g. GH₵ 249
  static String formatCompact(double value) =>
      '$symbol ${_priceCompact.format(value)}';

  /// e.g. GH₵ 1.2k for big dashboard numbers.
  static String formatBig(double value) {
    if (value >= 1000000) {
      return '$symbol ${_million.format(value / 1000000)}m';
    }
    if (value >= 1000) {
      return '$symbol ${_thousand.format(value / 1000)}k';
    }
    return '$symbol ${_price.format(value)}';
  }

  /// e.g. 4.6
  static String rating(double value) => value.toStringAsFixed(1);

  static String intWithCommas(int value) => _int.format(value);

  static String percent(double value) =>
      '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)}%';

  static final NumberFormat _price = NumberFormat.currency(
    name: 'GHS',
    symbol: '',
    decimalDigits: 2,
  );

  static final NumberFormat _priceCompact = NumberFormat('#,##0');
  static final NumberFormat _int = NumberFormat('#,##0');
  static final NumberFormat _million = NumberFormat('#,##0.0');
  static final NumberFormat _thousand = NumberFormat('#,##0.0');
}
