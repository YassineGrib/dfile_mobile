/// Centralised user-facing display strings for the friend statement screen and action sheets (FD3..FD6).
abstract final class FriendStatementStrings {
  // Screen & Top Bar (FD3)
  static const String title = 'Statement';
  static const String back = 'Back';
  static const String moreOptions = 'More options';
  static const String netBalance = 'Net balance';

  // Stat Tiles (FD3)
  static const String owedToYou = 'Owed to you';
  static const String youOwe = 'You owe';
  static const String active = 'Active';
  static const String settled = 'Settled';

  // Section & List (FD3)
  static const String transactionHistory = 'Transaction history';
  static const String addTransactionShort = '+ Add';
  static const String noTransactions =
      'No transactions recorded with this friend yet.';

  // Not Found State
  static const String friendNotFound = 'Friend not found';
  static const String backToFriends = 'Back to friends';

  // Actions Sheet (FD4)
  static const String addTransaction = 'Add transaction';
  static const String copyPhoneNumber = 'Copy phone number';
  static const String openTransactions = 'Open transactions';
  static const String deleteFriend = 'Delete friend';

  // Delete Confirm Sheet (FD5)
  static const String deleteFriendTitle = 'Delete friend';
  static const String deleteFriendSubtitle = 'This action cannot be undone';
  static String deleteConfirmFriendName(String friendName) =>
      'You are about to delete "$friendName" from your friends.';
  static String deleteConfirmActiveWarning(int activeCount) =>
      'All of his transactions and settlements ($activeCount active) will be permanently removed.';
  static const String confirmDelete = 'Confirm delete';
  static const String cancel = 'Cancel';

  // Toasts
  static const String copiedPhoneToast = 'Copied phone!';
  static const String noPhoneNumberToast = 'No phone number';
  static const String friendDeletedToast = 'Friend deleted successfully';
}
