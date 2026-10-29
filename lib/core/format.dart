/// Formatting utilities for currency and dates per `docs/design/SPEC.md`.
library;

/// Formats a monetary amount into comma-separated thousands with ' DZ' suffix.
///
/// Examples:
/// - `245000` -> `'245,000 DZ'`
/// - `0` -> `'0 DZ'`
/// - `68500` -> `'68,500 DZ'`
String formatMoney(num amount) {
  final int value = amount.round();
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  final int offset = digits.length % 3;

  if (offset > 0) {
    buffer.write(digits.substring(0, offset));
  }
  for (int i = offset; i < digits.length; i += 3) {
    if (buffer.isNotEmpty) {
      buffer.write(',');
    }
    buffer.write(digits.substring(i, i + 3));
  }

  final String formatted = buffer.toString();
  final String sign = value < 0 ? '-' : '';
  return '$sign$formatted DZ';
}

/// Formats a [DateTime] into `YYYY-MM-DD`.
String formatDate(DateTime date) {
  final String y = date.year.toString().padLeft(4, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
