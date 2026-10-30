import 'data/friend_tx_type.dart';

/// Centralised user-facing display strings for friend creation and transaction recording form screens (FD7, FD11, FD12).
abstract final class FriendFormsStrings {
  // Add Friend (FD7)
  static const String addFriendTitle = 'Add new friend';
  static const String addFriendSubtitle = 'Track mutual debts and favors';
  static const String friendNameLabel = 'Friend name *';
  static const String friendNamePlaceholder = 'e.g. Karim Boualam';
  static const String friendNameError = 'Please enter the friend name';
  static const String phoneLabel = 'Phone / WhatsApp (optional)';
  static const String phonePlaceholder = '+213 550 00 00 00';
  static const String notesLabel = 'Notes / context (optional)';
  static const String notesPlaceholder =
      'Colleague, childhood friend, developer partner...';
  static const String cancel = 'Cancel';
  static const String saveFriend = 'Save friend';
  static const String friendAddedToast = 'Friend added';

  // Record Transaction (FD11, FD12)
  static const String recordTransactionTitle = 'Record transaction';
  static const String recordTransactionSubtitle =
      'Track a loan, favor or shared cost';
  static const String friendLabel = 'Friend *';
  static const String newFriendLink = '+ New friend';
  static const String selectFriendPlaceholder = 'Select a friend';
  static const String selectFriendError = 'Please select a friend';
  static const String selectFriendSheetTitle = 'Select a friend';
  static const String noFriendsFound = 'No friends found';

  static const String directionLabel = 'Direction *';
  static const String owedToMeLabel = 'Owed to me';
  static const String owedToMeSubtitle = 'I lent money or a service';
  static const String iOweLabel = 'I owe';
  static const String iOweSubtitle = 'I borrowed or received';

  static const String natureLabel = 'Nature *';
  static const String natureMoney = 'Money loan';
  static const String natureService = 'Service';
  static const String natureSharedCost = 'Shared cost';

  static const String amountLabel = 'Total amount (DZD) *';
  static const String amountPlaceholder = '50,000';
  static const String amountError =
      'Please enter a valid amount greater than 0';

  static const String descriptionLabel = 'Description & details *';
  static const String descriptionError = 'Please enter a description';
  static const String descriptionPlaceholderMoney = 'e.g. Cash via BaridiMob';
  static const String descriptionPlaceholderService = 'e.g. Frontend UI design';
  static const String descriptionPlaceholderSharedCost =
      'e.g. Paid his annual server hosting bill';

  static const String dateLabel = 'Date';
  static const String dueDateLabel = 'Due date (optional)';
  static const String pickDatePlaceholder = 'Pick a date';
  static const String dueDateBeforeDateError =
      'Due date cannot be before the transaction date';

  static const String saveTransaction = 'Save transaction';
  static const String transactionRecordedToast = 'Transaction recorded';

  /// Resolves the context-specific placeholder for the description field per nature.
  static String descriptionPlaceholder(FriendTxType type) {
    switch (type) {
      case FriendTxType.money:
        return descriptionPlaceholderMoney;
      case FriendTxType.service:
        return descriptionPlaceholderService;
      case FriendTxType.expense:
        return descriptionPlaceholderSharedCost;
    }
  }
}
