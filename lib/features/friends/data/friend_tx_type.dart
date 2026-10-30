/// Enums defining transaction nature, direction, status, and filter options
/// for Friends' Debts per `docs/design/SPEC.md`.
library;

/// Transaction type/nature for friends' debts per `docs/design/SPEC.md`.
enum FriendTxType {
  money(label: 'Money loan', code: r'$'),
  service(label: 'Service', code: 'S'),
  expense(label: 'Shared cost', code: 'C');

  const FriendTxType({required this.label, required this.code});

  /// User-facing display label (e.g. "Money loan", "Service", "Shared cost").
  final String label;

  /// Short single-character code or glyph used in avatars/icons (e.g. "$", "S", "C").
  final String code;

  /// Parses a string representation into a [FriendTxType], returning `null` if unrecognised.
  static FriendTxType? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final String trimmed = value.trim().toLowerCase();
    for (final FriendTxType type in FriendTxType.values) {
      if (type.name.toLowerCase() == trimmed ||
          type.label.toLowerCase() == trimmed) {
        return type;
      }
    }
    return null;
  }
}

/// Transaction direction for friends' debts per `docs/design/SPEC.md`.
enum FriendTxDirection {
  lent(label: 'Owed to me', chipLabel: 'Lent'),
  borrowed(label: 'I owe', chipLabel: 'Borrowed');

  const FriendTxDirection({required this.label, required this.chipLabel});

  /// User-facing descriptive label (lent = "Owed to me", borrowed = "I owe").
  final String label;

  /// Compact chip label (e.g. "Lent", "Borrowed").
  final String chipLabel;

  /// True when money, service, or cost was lent to the friend (owed to me).
  bool get isLent => this == FriendTxDirection.lent;

  /// True when money, service, or cost was borrowed from the friend (I owe).
  bool get isBorrowed => this == FriendTxDirection.borrowed;

  /// Parses a string representation into a [FriendTxDirection], returning `null` if unrecognised.
  static FriendTxDirection? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final String trimmed = value.trim().toLowerCase();
    for (final FriendTxDirection dir in FriendTxDirection.values) {
      if (dir.name.toLowerCase() == trimmed ||
          dir.label.toLowerCase() == trimmed ||
          dir.chipLabel.toLowerCase() == trimmed) {
        return dir;
      }
    }
    return null;
  }
}

/// Derived settlement status of a friend debt transaction per `docs/design/SPEC.md`.
enum FriendTxStatus {
  pending('Pending'),
  partial('Partial'),
  settled('Settled');

  const FriendTxStatus(this.label);

  /// User-facing display label.
  final String label;

  /// True when no settlement payments have been recorded yet.
  bool get isPending => this == FriendTxStatus.pending;

  /// True when some amount has been paid but remaining balance remains.
  bool get isPartial => this == FriendTxStatus.partial;

  /// True when the transaction has been fully settled.
  bool get isSettled => this == FriendTxStatus.settled;
}

/// Settlement payment methods supported for friends' debts per `docs/design/SPEC.md`.
enum FriendSettleMethod {
  baridimob('BaridiMob'),
  cash('Cash'),
  bank('Bank'),
  serviceOffset('Offset');

  const FriendSettleMethod(this.label);

  /// User-facing display label (BaridiMob, Cash, Bank, Offset).
  final String label;

  /// Parses a string representation into a [FriendSettleMethod], returning `null` if unrecognised.
  static FriendSettleMethod? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final String trimmed = value.trim().toLowerCase();
    for (final FriendSettleMethod method in FriendSettleMethod.values) {
      if (method.name.toLowerCase() == trimmed ||
          method.label.toLowerCase() == trimmed) {
        return method;
      }
    }
    return null;
  }
}

/// Filter options for friends list screen per `docs/design/SPEC.md` (FD1).
enum FriendNetFilter {
  all('All'),
  owedToMe('Owe me'),
  iOwe('I owe'),
  settled('Settled');

  const FriendNetFilter(this.label);

  /// User-facing pill label.
  final String label;
}

/// Direction filter options for transactions list per `docs/design/SPEC.md` (FD8, FD9).
enum FriendDirectionFilter {
  all('All'),
  owedToMe('Owed to me'),
  iOwe('I owe');

  const FriendDirectionFilter(this.label);

  /// User-facing display label.
  final String label;
}

/// Status filter options for transactions list per `docs/design/SPEC.md` (FD8, FD9).
enum FriendStatusFilter {
  all('All'),
  pending('Pending'),
  partial('Partial'),
  settled('Settled');

  const FriendStatusFilter(this.label);

  /// User-facing display label.
  final String label;
}

/// Nature/type filter options for transactions list per `docs/design/SPEC.md` (FD9).
enum FriendTypeFilter {
  all('All'),
  money('Money loans'),
  service('Services'),
  expense('Shared costs');

  const FriendTypeFilter(this.label);

  /// User-facing display label.
  final String label;
}
