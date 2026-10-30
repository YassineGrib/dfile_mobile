/// Small helpers shared by the Firestore stores.
library;

/// `yyyy-MM-dd`, the date format the web app stores.
String dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Parses an ISO date string, or null when absent or malformed.
DateTime? parseDate(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// A string field, or an empty string when absent or of another type.
String textOf(Object? v) => v is String ? v : '';

/// A number field as a double, or [fallback].
double numberOf(Object? v, [double fallback = 0]) =>
    v is num ? v.toDouble() : fallback;
