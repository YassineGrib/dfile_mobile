/// Tab identifiers for the main Friends screen per `docs/design/SPEC.md` (FD1, FD8).
library;

/// FriendsDebt tab options for switching between friends overview and transactions list.
enum FriendsTab {
  friends('Friends'),
  transactions('Transactions');

  const FriendsTab(this.label);

  /// User-facing tab label.
  final String label;

  /// Parses a string representation into a [FriendsTab], defaulting to [friends].
  static FriendsTab fromString(String? value) {
    if (value == null) return FriendsTab.friends;
    final String trimmed = value.trim().toLowerCase();
    for (final FriendsTab tab in FriendsTab.values) {
      if (tab.name.toLowerCase() == trimmed ||
          tab.label.toLowerCase() == trimmed) {
        return tab;
      }
    }
    return FriendsTab.friends;
  }
}
