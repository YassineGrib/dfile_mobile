/// Centralised user-facing strings for the payments list screen (PY2..PY4).
abstract final class PaymentsListStrings {
  // Screen Title & Header
  static const String title = 'Payments';
  static String paymentsRecorded(int count) =>
      '$count ${count == 1 ? 'payment' : 'payments'} recorded';

  // 4 KPI Tiles
  static const String collected = 'Collected';
  static const String outstanding = 'Outstanding';
  static const String thisMonth = 'This month';
  static const String collectionRate = 'Collection rate';

  // Search & Filter
  static const String searchPlaceholder =
      'Search client, project or reference...';

  // Method Filter Pills
  static const String filterAll = 'All';
  static const String filterBaridimob = 'BaridiMob';
  static const String filterCcp = 'CCP';
  static const String filterBank = 'Bank';
  static const String filterCash = 'Cash';

  // List Count & Sort Row
  static String paymentsCount(int count) =>
      '$count ${count == 1 ? 'payment' : 'payments'}';
  static const String sortPrefix = 'Sort: ';
  static const String sortShortNewest = 'Newest';
  static const String sortShortOldest = 'Oldest';
  static const String sortShortHighest = 'Highest';
  static const String sortShortLowest = 'Lowest';

  // Sort Bottom Sheet (PY4)
  static const String sortSheetTitle = 'Sort by';
  static const String sortNewestFirst = 'Newest first';
  static const String sortOldestFirst = 'Oldest first';
  static const String sortHighestAmount = 'Highest amount';
  static const String sortLowestAmount = 'Lowest amount';

  // Empty State (Zero payments recorded, PY3)
  static const String emptyTitle = 'No payments logged yet';
  static const String emptySubtitle =
      'Record your first payment to track real cash flow and project balances.';
  static const String recordFirstPayment = '+ Record first payment';

  // Filter Empty State (Search / Filter yields nothing)
  static const String emptyFilterTitle = 'No payments match your filters';
  static const String emptyFilterSubtitle =
      'Try adjusting your search terms or method filters.';
  static const String clearFilters = 'Clear filters';

  // Toasts
  static const String paymentDeletedToast = 'Payment deleted successfully';
  static const String paymentRecordedToast = 'Payment recorded';
}
