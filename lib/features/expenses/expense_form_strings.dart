/// User-facing strings for the expense form screen per `docs/design/SPEC.md` (EX9..EX13).
abstract final class ExpenseFormStrings {
  // Titles & subtitles
  static const String recordTitle = 'Record expense';
  static const String recordSubtitle = 'Log what your work costs you';
  static const String editTitle = 'Edit expense';
  static const String editSubtitle = 'Update the cost details';

  // Actions
  static const String recordExpenseAction = 'Record expense';
  static const String saveChangesAction = 'Save changes';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String backToExpenses = 'Back to expenses';

  // Form field labels & placeholders
  static const String amountLabel = 'Amount (DZD) *';
  static const String amountPlaceholder = '0';
  static const String dzdChip = 'DZD';
  static const String categoryLabel = 'Category *';
  static const String descriptionLabel = 'Description / item *';
  static const String descriptionPlaceholder = 'e.g. Monthly Figma Pro plan';
  static const String linkedProjectLabel = 'Linked project (optional)';
  static const String generalBusinessCost = 'General business cost';
  static const String paymentMethodLabel = 'Payment method';
  static const String transactionDateLabel = 'Transaction date *';
  static const String invoiceRefLabel = 'Invoice / voucher ref';
  static const String invoiceRefPlaceholder = 'e.g. INV-802';
  static const String notesLabel = 'Notes (optional)';
  static const String notesPlaceholder = 'e.g. Additional details...';

  // Project picker sheet
  static const String linkProjectSheetTitle = 'Link to a project';
  static const String linkProjectSheetSubtitle =
      'Optional: attach this cost to a project';
  static const String notLinkedSubtitle = 'Not linked to any project';

  // Validation errors
  static const String amountError =
      'Please enter a valid amount greater than zero';
  static const String descriptionError = 'Please describe the expense';

  // Not found
  static const String expenseNotFound = 'Expense not found';

  // Toasts
  static const String expenseRecordedToast = 'Expense recorded';
  static const String changesSavedToast = 'Changes saved';
}
