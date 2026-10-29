/// Centralised user-facing strings and helpers for the payment receipt screen (PY5..PY8).
abstract final class PaymentReceiptStrings {
  // Screen title & top bar
  static const String title = 'Payment receipt';
  static const String back = 'Back';
  static const String moreOptions = 'More options';

  // Receipt Card
  static const String officialReceipt = 'Official payment receipt';
  static const String amountReceived = 'Amount received';
  static const String client = 'Client';
  static const String project = 'Project';
  static const String method = 'Method';
  static const String reference = 'Reference';
  static const String date = 'Date';
  static const String projectBudget = 'Project budget';
  static const String paidToDate = 'Paid to date';
  static const String remaining = 'Remaining';
  static const String cleared = 'Cleared';
  static const String notes = 'Notes';
  static const String emptyReferenceDash = '—';

  // Actions
  static const String shareReceipt = 'Share receipt';
  static const String copyReference = 'Copy reference';
  static const String goToProject = 'Go to project';
  static const String deletePayment = 'Delete payment';

  // Delete confirm sheet
  static const String deletePaymentTitle = 'Delete payment';
  static const String deletePaymentSubtitle = 'This action cannot be undone';
  static const String confirmDelete = 'Confirm delete';
  static const String cancel = 'Cancel';

  /// Warning text describing the payment amount and client to be deleted.
  static String deleteWarningAmountClient(
    String amountFormatted,
    String clientName,
  ) =>
      'You are about to delete a payment of +$amountFormatted DZ from $clientName.';

  /// Warning sentence about budget, paid, remaining, and revenue recalculation.
  static const String deleteWarningRecalculate =
      'The project paid and remaining amounts, and the client revenue, will be recalculated.';

  // Toasts
  static const String demoNotAvailable = 'Not available in the demo';
  static const String copiedReferenceToast = 'Copied reference!';
  static const String noReferenceToCopyToast = 'No reference to copy';
  static const String paymentDeletedToast = 'Payment deleted successfully';

  // Not found
  static const String paymentNotFound = 'Payment not found';
  static const String backToPayments = 'Back to payments';

  // Fallbacks
  static const String unknownClient = 'Unknown client';
  static const String unknownProject = 'Unknown project';

  /// Resolves the user-facing display label for the payment type pill, e.g. "Advance payment".
  static String typePaymentLabel(String typeLabel) => '$typeLabel payment';

  /// Derives receipt code from [id], e.g. "PAY-2041".
  static String receiptCode(String id) {
    final RegExp digitsRegex = RegExp(r'\d+');
    final Match? match = digitsRegex.firstMatch(id);
    if (match != null) {
      final int? val = int.tryParse(match.group(0)!);
      if (val != null) {
        if (val < 100) {
          return 'PAY-${2040 + val}';
        }
        return 'PAY-$val';
      }
    }
    final int hash = (id.hashCode.abs() % 9000) + 1000;
    return 'PAY-$hash';
  }
}
