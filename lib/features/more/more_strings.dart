/// Centralised user-facing strings for the More screen (PY1).
abstract final class MoreStrings {
  static const String title = 'More';
  static const String subtitle = 'Everything else in your workspace';

  // Workspace Card
  static const String workspaceTitle = 'Dfile workspace';
  static const String workspaceSubtitle = 'Freelancer ledger • DZD';

  // Menu Rows
  static const String paymentsTitle = 'Payments';
  static String paymentsSubtitle(String formattedAmount) =>
      '$formattedAmount collected';

  static const String expensesTitle = 'Expenses';
  static const String expensesSubtitle = 'Track what you spend';

  static const String invoicesTitle = 'Invoices';
  static const String invoicesSubtitle = 'Bill your clients';

  static const String friendsDebtsTitle = "Friends' debts";
  static const String friendsDebtsSubtitle = 'Lend and settle';

  static const String settingsTitle = 'Settings';
  static const String settingsSubtitle = 'Language, security, profile';

  // Actions & Toasts
  static const String signOut = 'Sign out';
  static const String notAvailableInDemo = 'Not available in the demo';
}
