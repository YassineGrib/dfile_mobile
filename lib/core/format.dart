/// Formatting utilities for currency and dates per `docs/design/SPEC.md`.
library;

/// Formats a numeric amount with comma-separated thousands (without currency suffix).
///
/// Examples:
/// - `205000` -> `'205,000'`
/// - `0` -> `'0'`
String formatAmount(num amount) {
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
  return '$sign$formatted';
}

/// Formats a monetary amount into comma-separated thousands with ' DZ' suffix.
///
/// Examples:
/// - `245000` -> `'245,000 DZ'`
/// - `0` -> `'0 DZ'`
/// - `68500` -> `'68,500 DZ'`
String formatMoney(num amount) {
  return '${formatAmount(amount)} DZ';
}

/// Formats a monetary amount into a compact summary label with ' DZ' suffix.
///
/// Examples:
/// - `1085000` -> `'1.0M DZ'`
/// - `635000` -> `'635K DZ'`
/// - `500` -> `'500 DZ'`
String formatCompactMoney(num amount) {
  final int value = amount.round();
  final int abs = value.abs();
  final String sign = value < 0 ? '-' : '';
  if (abs >= 1000000) {
    final double millions = (abs ~/ 100000) / 10.0;
    return '$sign${millions.toStringAsFixed(1)}M DZ';
  }
  if (abs >= 1000) {
    final int thousands = (abs / 1000).round();
    return '$sign${thousands}K DZ';
  }
  return '$sign$abs DZ';
}

/// Formats a [DateTime] into `YYYY-MM-DD`.
String formatDate(DateTime date) {
  final String y = date.year.toString().padLeft(4, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Formats a [DateTime] into `yyyy-MM-dd`.
String formatDateYyyyMmDd(DateTime date) => formatDate(date);

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a [DateTime] into `Mon DD` (e.g. `Jul 01`, `Aug 30`).
String formatShortDate(DateTime date) {
  final String month = _shortMonths[date.month - 1];
  final String day = date.day.toString().padLeft(2, '0');
  return '$month $day';
}

/// Formats a [DateTime] into `Mon DD, YYYY` (e.g. `Jul 01, 2026`, `Aug 30, 2026`).
String formatMediumDate(DateTime date) {
  return '${formatShortDate(date)}, ${date.year}';
}
