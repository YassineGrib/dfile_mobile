import 'package:flutter/foundation.dart';

import 'friend_tx_type.dart';

/// A debt transaction between the user and a friend per `docs/design/SPEC.md`.
@immutable
class FriendTransaction {
  const FriendTransaction({
    required this.id,
    required this.friendId,
    required this.type,
    required this.direction,
    required this.amount,
    this.paidAmount = 0.0,
    required this.description,
    this.dueDate,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? date;

  /// Unique transaction identifier (e.g. `tx1`).
  final String id;

  /// Foreign key referencing the associated [Friend.id].
  final String friendId;

  /// Nature of transaction: money loan, service, or shared cost.
  final FriendTxType type;

  /// Direction of transaction: lent (owed to me) or borrowed (I owe).
  final FriendTxDirection direction;

  /// Original principal transaction amount in DZD.
  final double amount;

  /// Total amount settled/repaid towards this transaction to date.
  final double paidAmount;

  /// Transaction description or reason (e.g. `Cash via BaridiMob`).
  final String description;

  /// Optional due date for settlement.
  final DateTime? dueDate;

  /// Effective date of the transaction.
  final DateTime date;

  /// System creation timestamp.
  final DateTime createdAt;

  /// Derived remaining balance outstanding on this transaction.
  double get remaining {
    final double diff = amount - paidAmount;
    return diff <= 0.0 ? 0.0 : diff;
  }

  /// Derived settlement status:
  /// - `settled` when `paidAmount >= amount`
  /// - `partial` when `0 < paidAmount < amount`
  /// - `pending` when `paidAmount == 0`
  FriendTxStatus get status {
    if (paidAmount >= amount) {
      return FriendTxStatus.settled;
    }
    if (paidAmount > 0.0) {
      return FriendTxStatus.partial;
    }
    return FriendTxStatus.pending;
  }

  /// True when this transaction is fully paid.
  bool get isSettled => status == FriendTxStatus.settled;

  /// Creates a copy of this [FriendTransaction] with the given fields replaced.
  FriendTransaction copyWith({
    String? id,
    String? friendId,
    FriendTxType? type,
    FriendTxDirection? direction,
    double? amount,
    double? paidAmount,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return FriendTransaction(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendTransaction &&
        other.id == id &&
        other.friendId == friendId &&
        other.type == type &&
        other.direction == direction &&
        other.amount == amount &&
        other.paidAmount == paidAmount &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        friendId,
        type,
        direction,
        amount,
        paidAmount,
        description,
        dueDate,
        date,
        createdAt,
      );

  @override
  String toString() =>
      'FriendTransaction(id: $id, friendId: $friendId, type: ${type.name}, direction: ${direction.name}, amount: $amount, paid: $paidAmount, remaining: $remaining, status: ${status.name}, date: $date)';
}

/// A settlement payment record applied against a [FriendTransaction] per `docs/design/SPEC.md`.
@immutable
class FriendSettlement {
  const FriendSettlement({
    required this.id,
    required this.transactionId,
    required this.friendId,
    required this.amount,
    required this.method,
    this.notes = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? date;

  /// Unique settlement identifier (e.g. `set1`).
  final String id;

  /// Foreign key referencing the associated [FriendTransaction.id].
  final String transactionId;

  /// Foreign key referencing the associated [Friend.id].
  final String friendId;

  /// Partial or full settlement payment amount in DZD.
  final double amount;

  /// Payment channel used (BaridiMob, Cash, Bank, Offset).
  final FriendSettleMethod method;

  /// Optional free-form notes (required when method is Offset).
  final String notes;

  /// Effective date of the settlement payment.
  final DateTime date;

  /// System creation timestamp.
  final DateTime createdAt;

  /// Creates a copy of this [FriendSettlement] with the given fields replaced.
  FriendSettlement copyWith({
    String? id,
    String? transactionId,
    String? friendId,
    double? amount,
    FriendSettleMethod? method,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return FriendSettlement(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      friendId: friendId ?? this.friendId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendSettlement &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.friendId == friendId &&
        other.amount == amount &&
        other.method == method &&
        other.notes == notes &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        transactionId,
        friendId,
        amount,
        method,
        notes,
        date,
        createdAt,
      );

  @override
  String toString() =>
      'FriendSettlement(id: $id, transactionId: $transactionId, friendId: $friendId, amount: $amount, method: ${method.name}, date: $date)';
}
