/// Tab identifiers for the main Calendar screen per `docs/design/SPEC.md` (CL1-CL5).
library;

/// Calendar tab options for switching between Month, Agenda, and Timeline views.
enum CalendarTab {
  month('Month', 'month'),
  agenda('Agenda', 'agenda'),
  timeline('Timeline', 'timeline');

  const CalendarTab(this.label, this.id);

  /// User-facing tab label.
  final String label;

  /// Route/query identifier.
  final String id;

  /// Parses a string representation into a [CalendarTab], defaulting to [month].
  static CalendarTab fromString(String? value) {
    if (value == null) return CalendarTab.month;
    final String trimmed = value.trim().toLowerCase();
    for (final CalendarTab tab in CalendarTab.values) {
      if (tab.name.toLowerCase() == trimmed ||
          tab.id.toLowerCase() == trimmed ||
          tab.label.toLowerCase() == trimmed) {
        return tab;
      }
    }
    return CalendarTab.month;
  }
}
