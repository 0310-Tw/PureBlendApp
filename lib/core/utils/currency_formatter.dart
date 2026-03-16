import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatJmd(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_JM',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}