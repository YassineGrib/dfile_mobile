import '../../core/format.dart';
import 'data/friend_tx_type.dart';

/// Centralised user-facing display strings for the friend transaction detail,
/// delete confirm sheet, and settlement sheet per `docs/design/SPEC.md` (FD10, FD13, FD15).
abstract final class TransactionDetailStrings {
  // Top bar & generic
  static const String title = 'Transaction';
  static const String back = 'Back';
  static const String moreOptions = 'More options';
  static const String cancel = 'Cancel';

  // Transaction Not Found Screen
  static const String transactionNotFound = 'Transaction not found';
  static const String backToFriends = 'Back to Friends';

  // FD10 Detail Card
  static const String paid = 'Paid';
  static const String remaining = 'Remaining';
  static const String date = 'Date';
  static const String dueDate = 'Due date';
  static const String emptyDash = '—';
  static const String settled = 'Settled';

  // Settlements section
  static String settlementsCount(int count) => 'Settlements ($count)';
  static const String noSettlementsYet = 'No settlements yet';

  // FD10 Bottom Action Bar
  static const String delete = 'Delete';
  static const String settlePayment = 'Settle payment';

  // FD15 Delete Transaction Confirm Sheet
  static const String deleteTransactionTitle = 'Delete transaction';
  static const String deleteTransactionSubtitle = 'This action cannot be undone';
  static const String confirmDelete = 'Confirm delete';

  /// Primary warning text naming description, amount, and friend.
  static String deleteWarningTransaction(
    String description,
    num amount,
    String friendName,
  ) =>
      'You are about to delete "$description" of ${formatMoney(amount)} with $friendName.';

  /// Sentence about settlements being removed and balance recalculation.
  static String deleteWarningSettlements(int settlementCount, [String pronoun = 'his']) {
    if (settlementCount == 1) {
      return 'Its 1 settlement will be removed and $pronoun balance recalculated.';
    }
    return 'Its $settlementCount settlements will be removed and $pronoun balance recalculated.';
  }

  // FD15 Toast
  static const String transactionDeletedToast =
      'Transaction deleted successfully';

  // FD13 Settle Sheet
  static const String recordSettlementTitle = 'Record settlement';

  static String settleWithSubtitle(String friendName, String description) =>
      'With: $friendName • $description';

  // Settle summary card
  static const String total = 'Total';
  static const String summaryPaid = 'Paid';
  static const String summaryRemaining = 'Remaining';

  // Settle amount input
  static const String settlementAmountLabel = 'Settlement amount (DZD) *';
  static const String settlementAmountPlaceholder = '0';
  static const String full100Percent = '100% full';

  // Settle amount errors
  static const String errorValidAmount =
      'Please enter a valid settlement amount';
  static const String errorExceedsRemaining =
      'Amount exceeds the remaining balance';

  // Settle methods
  static const String settlementMethodLabel = 'Settlement method *';
  static const String methodBaridiMob = 'BaridiMob';
  static const String methodCash = 'Cash';
  static const String methodOffset = 'Offset';
  static const String methodBank = 'Bank';

  // Settle notes input
  static const String notesOptionalLabel = 'Settlement notes (optional)';
  static const String notesOffsetRequiredLabel = 'Offset service details *';
  static const String notesPlaceholder = 'e.g. Transferred via BaridiMob';
  static const String notesOffsetPlaceholder = 'e.g. Web design consultation service';
  static const String errorDescribeServiceOffset =
      'Please describe the service offset';

  // Settle date input
  static const String settlementDateLabel = 'Settlement date';

  // Settle action buttons
  static const String confirmSettlement = 'Confirm settlement';

  // FD14 Toast
  static const String settlementRecordedToast = 'Settlement recorded';

  // Subtitle in detail card: "<friend> • <type>"
  static String detailSubtitle(String friendName, FriendTxType type) =>
      '$friendName • ${type.label}';
}
