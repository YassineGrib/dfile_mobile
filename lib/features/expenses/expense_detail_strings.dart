import '../../core/format.dart';

/// User-facing strings and text helpers for the expense detail screen per `docs/design/SPEC.md` (EX5..EX8).
abstract final class ExpenseDetailStrings {
  // Screen title & top bar
  static const String title = 'Expense';
  static const String back = 'Back';
  static const String moreOptions = 'More options';

  // Detail card
  static const String amountSpent = 'Amount spent';
  static const String category = 'Category';
  static const String project = 'Project';
  static const String method = 'Method';
  static const String date = 'Date';
  static const String reference = 'Reference';
  static const String notes = 'Notes';
  static const String emptyReferenceDash = '—';
  static const String generalCost = 'General cost';
  static const String unknownProject = 'Unknown project';

  // Bottom bar & actions
  static const String editExpense = 'Edit expense';
  static const String copyReference = 'Copy reference';
  static const String goToProject = 'Go to project';
  static const String deleteExpense = 'Delete expense';

  // Action sheet subtitle
  static String actionSheetSubtitle(num amount, DateTime date) =>
      '-${formatMoney(amount.abs())} • ${formatDate(date)}';

  // Delete confirm sheet
  static const String deleteExpenseTitle = 'Delete expense';
  static const String deleteExpenseSubtitle = 'This action cannot be undone';
  static const String deleteWarningRecalculate =
      'Your outlay totals and the project profit will be recalculated.';
  static const String confirmDelete = 'Confirm delete';
  static const String cancel = 'Cancel';

  /// Warning text describing the expense description and amount to be deleted.
  static String deleteWarningExpense(String description, num amount) =>
      'You are about to delete the expense "$description" of -${formatMoney(amount.abs())}.';

  // Toasts
  static const String copiedReferenceToast = 'Copied reference!';
  static const String noReferenceToCopyToast = 'No reference to copy';
  static const String expenseDeletedToast = 'Expense deleted successfully';

  // Not found screen
  static const String expenseNotFound = 'Expense not found';
  static const String backToExpenses = 'Back to expenses';
}
