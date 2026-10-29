import 'data/friend_tx_type.dart';

/// Centralised shared strings, labels, and chip texts for friends' debts features per `docs/design/SPEC.md`.
abstract final class FriendStrings {
  // Enum labels: FriendTxType
  static const String moneyLoan = 'Money loan';
  static const String service = 'Service';
  static const String sharedCost = 'Shared cost';

  // Enum labels: FriendTxDirection
  static const String owedToMe = 'Owed to me';
  static const String iOwe = 'I owe';
  static const String lent = 'Lent';
  static const String borrowed = 'Borrowed';

  // Enum labels: FriendTxStatus
  static const String pending = 'Pending';
  static const String partial = 'Partial';
  static const String settled = 'Settled';

  // Enum labels: FriendSettleMethod
  static const String baridimob = 'BaridiMob';
  static const String cash = 'Cash';
  static const String bank = 'Bank';
  static const String offset = 'Offset';

  // Balance & Net Card labels
  static const String overallNetBalance = 'Overall net balance';
  static const String netBalance = 'Net balance';
  static const String owedToYou = 'Owed to you';
  static const String youOwe = 'You owe';
  static const String active = 'Active';
  static const String settle = 'Settle';
  static const String friendsDebts = "Friends' debts";

  // Chip labels
  static String owedAmount(String formattedMoney) => 'Owed $formattedMoney';
  static String youOweAmount(String formattedMoney) => 'You owe $formattedMoney';
  static const String settledChip = 'Settled';

  // Label resolvers
  static String typeLabel(FriendTxType type) => type.label;
  static String directionLabel(FriendTxDirection direction) => direction.label;
  static String statusLabel(FriendTxStatus status) => status.label;
  static String methodLabel(FriendSettleMethod method) => method.label;
}
