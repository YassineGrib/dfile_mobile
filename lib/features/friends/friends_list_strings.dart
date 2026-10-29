/// Centralised user-facing display strings for the friends and transactions list screens (FD1, FD2, FD8, FD9, FD16).
abstract final class FriendsListStrings {
  // Screen Title & Header
  static const String title = "Friends' debts";
  static String friendsCount(int count) =>
      '$count ${count == 1 ? 'friend' : 'friends'}';
  static String transactionsCount(int count) =>
      '$count ${count == 1 ? 'transaction' : 'transactions'}';

  // Two-way Toggle Tabs
  static const String tabFriends = 'Friends';
  static const String tabTransactions = 'Transactions';

  // Overall Net Balance Card
  static const String overallNetBalance = 'Overall net balance';
  static const String owedToYou = 'Owed to you';
  static const String youOwe = 'You owe';

  // Search Field Placeholders
  static const String searchFriendsPlaceholder =
      'Search name, phone or notes...';
  static const String searchTransactionsPlaceholder =
      'Search friend or description...';

  // Friends Net Filter Pills (FD1)
  static const String pillAll = 'All';
  static const String pillOweMe = 'Owe me';
  static const String pillIOwe = 'I owe';
  static const String pillSettled = 'Settled';

  // Transactions Quick Pills (FD8)
  static const String txPillAll = 'All';
  static const String txPillOwedToMe = 'Owed to me';
  static const String txPillIOwe = 'I owe';
  static const String txPillSettled = 'Settled';

  // Transactions Filter Sheet (FD9)
  static const String filter = 'Filter';
  static const String filterSheetTitle = 'Filter transactions';
  static const String reset = 'Reset';
  static const String applyFilters = 'Apply filters';
  static const String cancel = 'Cancel';

  // Filter Sheet Sections
  static const String filterSectionDirection = 'Direction';
  static const String filterSectionStatus = 'Status';
  static const String filterSectionNature = 'Nature';

  // Filter Sheet Options
  static const String directionAll = 'All';
  static const String directionOwedToMe = 'Owed to me';
  static const String directionIOwe = 'I owe';

  static const String statusAll = 'All';
  static const String statusPending = 'Pending';
  static const String statusPartial = 'Partial';
  static const String statusSettled = 'Settled';

  static const String natureAll = 'All';
  static const String natureMoney = 'Money loans';
  static const String natureService = 'Services';
  static const String natureExpense = 'Shared costs';

  // Empty State - Friends (FD2)
  static const String emptyFriendsTitle = 'No friends yet';
  static const String emptyFriendsSubtitle =
      'Add your friends to track shared expenses and loans.';
  static const String addFriendButton = '+ Add friend';

  // Empty Filter State - Friends
  static const String emptyFriendsFilterTitle = 'No friends match your filters';
  static const String emptyFriendsFilterSubtitle =
      'Try adjusting your search terms or filter pills.';
  static const String clearFilters = 'Clear filters';

  // Empty State - Transactions
  static const String emptyTransactionsTitle = 'No transactions yet';
  static const String emptyTransactionsSubtitle =
      'Record debts, loans, or shared expenses with friends.';

  // Empty Filter State - Transactions
  static const String emptyTransactionsFilterTitle =
      'No transactions match your filters';
  static const String emptyTransactionsFilterSubtitle =
      'Try adjusting your search terms or filter criteria.';

  // Card Actions
  static const String settle = 'Settle';

  // Toasts
  static const String friendDeletedToast = 'Friend deleted successfully';
  static const String friendAddedToast = 'Friend added';
  static const String transactionDeletedToast =
      'Transaction deleted successfully';
  static const String transactionRecordedToast = 'Transaction recorded';
  static const String settlementRecordedToast = 'Settlement recorded';
}
