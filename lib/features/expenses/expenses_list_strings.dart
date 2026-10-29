/// Centralised user-facing strings for the expenses list screen per `docs/design/SPEC.md` (EX1..EX4, EX8, EX13).
abstract final class ExpensesListStrings {
  // Screen Title & Header
  static const String title = 'Expenses';
  static String expensesLogged(int count) =>
      '$count ${count == 1 ? 'expense' : 'expenses'} logged';

  // 4 KPI Tiles
  static const String totalOutlays = 'Total outlays';
  static const String projectLinked = 'Project-linked';
  static const String thisMonth = 'This month';
  static const String averageOutlay = 'Average outlay';

  // Search
  static const String searchPlaceholder =
      'Search item, project or reference...';

  // Category Filter Pills (horizontal row)
  static const String categoryAll = 'All';
  static const String categorySoftware = 'Software';
  static const String categoryHosting = 'Hosting';
  static const String categoryMarketing = 'Marketing';
  static const String categoryEquipment = 'Equipment';
  static const String categoryOthers = 'Others';

  // List Count, Filter & Sort Row
  static String expensesCount(int count) =>
      '$count ${count == 1 ? 'expense' : 'expenses'}';
  static const String filter = 'Filter';
  static const String sortPrefix = 'Sort: ';
  static const String sortShortNewest = 'Newest';
  static const String sortShortOldest = 'Oldest';
  static const String sortShortHighest = 'Highest';
  static const String sortShortLowest = 'Lowest';

  // Sort Bottom Sheet (EX3)
  static const String sortSheetTitle = 'Sort by';
  static const String sortNewestFirst = 'Newest first';
  static const String sortOldestFirst = 'Oldest first';
  static const String sortHighestAmount = 'Highest amount';
  static const String sortLowestAmount = 'Lowest amount';

  // Filter Bottom Sheet (EX4)
  static const String filterSheetTitle = 'Filter expenses';
  static const String reset = 'Reset';
  static const String filterSectionCategory = 'Category';
  static const String filterSectionProjectLink = 'Project link';
  static const String linkAll = 'All';
  static const String linkProjectLinked = 'Project linked';
  static const String linkGeneralCosts = 'General costs';
  static const String applyFilters = 'Apply filters';
  static const String cancel = 'Cancel';

  // Empty State (Zero expenses recorded, EX2)
  static const String emptyTitle = 'No expenses logged yet';
  static const String emptySubtitle =
      'Record your first expense to see what\nyour work really costs.';
  static const String recordFirstExpense = '+ Record first expense';

  // Filter Empty State (Search / Filter yields nothing)
  static const String emptyFilterTitle = 'No expenses match your filters';
  static const String emptyFilterSubtitle =
      'Try adjusting your search terms, category, or project link filters.';
  static const String clearFilters = 'Clear filters';

  // Expense Card Details
  static const String generalCost = 'General cost';
  static const String noReference = '—';

  // Toasts
  static const String expenseDeletedToast = 'Expense deleted successfully';
  static const String expenseRecordedToast = 'Expense recorded';
}
