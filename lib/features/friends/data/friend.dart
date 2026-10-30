import 'package:flutter/foundation.dart';

/// Derived balance and activity statistics for a specific friend per `docs/design/SPEC.md`.
@immutable
class FriendBalance {
  const FriendBalance({
    required this.net,
    required this.owedToYou,
    required this.youOwe,
    required this.active,
    required this.settled,
    this.lastActivity,
  });

  /// Net balance in DZD: `owedToYou - youOwe`.
  /// Positive denotes friend owes you; negative denotes you owe friend; zero denotes settled.
  final double net;

  /// Sum of remaining amounts on transactions lent to this friend.
  final double owedToYou;

  /// Sum of remaining amounts on transactions borrowed from this friend.
  final double youOwe;

  /// Number of active (non-settled) transactions with this friend.
  final int active;

  /// Number of fully settled transactions with this friend.
  final int settled;

  /// Timestamp of the most recent transaction or settlement with this friend, if any.
  final DateTime? lastActivity;

  /// True if net balance is zero and there are no outstanding debts.
  bool get isSettled => net == 0.0 && owedToYou == 0.0 && youOwe == 0.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendBalance &&
        other.net == net &&
        other.owedToYou == owedToYou &&
        other.youOwe == youOwe &&
        other.active == active &&
        other.settled == settled &&
        other.lastActivity == lastActivity;
  }

  @override
  int get hashCode =>
      Object.hash(net, owedToYou, youOwe, active, settled, lastActivity);

  @override
  String toString() =>
      'FriendBalance(net: $net, owedToYou: $owedToYou, youOwe: $youOwe, active: $active, settled: $settled, lastActivity: $lastActivity)';
}

/// Derived portfolio-wide balance across all friends per `docs/design/SPEC.md`.
@immutable
class OverallBalance {
  const OverallBalance({
    required this.net,
    required this.owedToYou,
    required this.youOwe,
  });

  /// Net balance in DZD across all friends: `owedToYou - youOwe`.
  final double net;

  /// Total amount owed to you across all outstanding lent transactions.
  final double owedToYou;

  /// Total amount you owe across all outstanding borrowed transactions.
  final double youOwe;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OverallBalance &&
        other.net == net &&
        other.owedToYou == owedToYou &&
        other.youOwe == youOwe;
  }

  @override
  int get hashCode => Object.hash(net, owedToYou, youOwe);

  @override
  String toString() =>
      'OverallBalance(net: $net, owedToYou: $owedToYou, youOwe: $youOwe)';
}

/// A friend contact entity for debt management per `docs/design/SPEC.md`.
@immutable
class Friend {
  const Friend({
    required this.id,
    required this.name,
    this.phone = '',
    this.notes = '',
    required this.createdAt,
    this.avatarColorIndex = 0,
    this.balance,
  });

  /// Unique identifier (e.g. `fr1`).
  final String id;

  /// Friend's display name (e.g. `Karim Boualam`).
  final String name;

  /// Friend's contact phone number (e.g. `+213 550 12 34 56`).
  final String phone;

  /// Optional free-form notes.
  final String notes;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Avatar color index for palette cycling (0..3).
  final int avatarColorIndex;

  /// Optional cached or precomputed balance statistics.
  final FriendBalance? balance;

  /// Returns a copy of this [Friend] with the given fields replaced.
  Friend copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    DateTime? createdAt,
    int? avatarColorIndex,
    FriendBalance? balance,
    bool clearBalance = false,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      balance: clearBalance ? null : (balance ?? this.balance),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend &&
        other.id == id &&
        other.name == name &&
        other.phone == phone &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.avatarColorIndex == avatarColorIndex &&
        other.balance == balance;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, notes, createdAt, avatarColorIndex, balance);

  @override
  String toString() =>
      'Friend(id: $id, name: $name, phone: $phone, avatarColorIndex: $avatarColorIndex, balance: $balance)';
}
