/// Centralised user-facing strings for the record payment screen (PY9..PY12).
abstract final class RecordPaymentStrings {
  // Title & Header
  static const String title = 'Record payment';
  static const String subtitle = 'Record a client deposit';

  // Form Fields
  static const String payingClientLabel = 'Paying client *';
  static const String selectClientPlaceholder = 'Select client';
  static const String linkedProjectLabel = 'Linked project *';
  static const String selectProjectPlaceholder = 'Select project';
  static const String amountLabel = 'Amount received (DZD) *';
  static const String amountPlaceholder = '50,000';
  static const String fullChip = '100% full';
  static const String paymentMethodLabel = 'Payment method';
  static const String paymentTypeLabel = 'Payment type';
  static const String dateReceivedLabel = 'Date received';
  static const String referenceLabel = 'Transaction ID / slip ref (optional)';
  static const String referencePlaceholder =
      'e.g. TXN-928471 or BaridiMob #39281';
  static const String notesLabel = 'Notes (optional)';
  static const String notesPlaceholder = 'Add notes about this payment...';

  // Buttons & Actions
  static const String cancel = 'Cancel';
  static const String recordPaymentAction = 'Record payment';

  // Validation Errors
  static const String amountError =
      'Please enter a valid amount greater than zero';
  static const String clientRequiredError = 'Please select a client';
  static const String projectRequiredError = 'Please select a project';

  // Bottom Sheets & Pickers
  static const String selectClientTitle = 'Select client';
  static const String selectProjectTitle = 'Select project';
  static String projectsOfClient(String clientName) =>
      'Projects of $clientName';
  static const String confirmProject = 'Confirm project';
  static const String noProjectsForClient = 'No projects found for this client';
  static const String selectPaymentTypeTitle = 'Select payment type';

  // Badges & Statuses
  static const String cleared = 'Cleared';
  static String due(String formattedAmount) => 'Due $formattedAmount';

  // Toasts
  static const String paymentRecordedToast = 'Payment recorded';
}
