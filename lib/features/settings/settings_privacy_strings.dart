/// User-facing strings for Google Play compliance and privacy flows per `docs/design/SPEC.md`.
abstract final class SettingsPrivacyStrings {
  // Hub row
  static const String privacyDataTitle = 'Privacy and data';
  static const String privacyDataSubtitle = 'Export or delete your data';

  // PS2 Privacy and data screen
  static const String dataBelongsToYouTitle = 'Your data belongs to you';
  static const String dataBelongsToYouBody =
      'Dfile stores your data locally on your device. You can export a full copy of your records at any time, review how data is handled, or permanently delete your account.';
  static const String privacyPolicyTitle = 'Privacy policy';
  static const String privacyPolicySubtitle =
      'Read our data collection and protection policy';
  static const String termsTitle = 'Terms and conditions';
  static const String termsSubtitle = 'Read our terms of service and agreement';
  static const String howWeUseDataTitle = 'How we use your data';
  static const String howWeUseDataSubtitle =
      'Clear explanation of permissions and data usage';
  static const String exportDataTitle = 'Export my data';
  static const String exportDataSubtitle =
      'Download a JSON copy of all records';
  static const String dangerZoneTitle = 'DANGER ZONE';
  static const String deleteAccountTitle = 'Delete account';
  static const String deleteAccountSubtitle =
      'Permanently delete your account and all data';
  static const String backupCopiedToast = 'Backup copied to clipboard';

  // PS10 How we use your data screen
  static const String howWeUseDataScreenTitle = 'How we use your data';
  static const String chipNeverSold = 'Never sold';
  static const String chipNoAds = 'No ads';
  static const String chipEncrypted = 'Encrypted';
  static const String chipDeletable = 'Deletable';

  static const String profileTitle = 'Profile';
  static const String profileDetails =
      'Your name, email address, phone number, and physical address.';
  static const String profileUsedFor =
      'Used for: Generating client invoices and statements.';

  static const String clientsProjectsTitle = 'Clients and projects';
  static const String clientsProjectsDetails =
      'Client contacts, project budgets, deadlines, and task lists.';
  static const String clientsProjectsUsedFor =
      'Used for: Organizing your freelance work portfolio.';

  static const String paymentsExpensesTitle = 'Payments and expenses';
  static const String paymentsExpensesDetails =
      'Payment dates, amounts, methods, references, and receipts.';
  static const String paymentsExpensesUsedFor =
      'Used for: Income tracking, tax reporting, and net cashflow.';

  static const String appSettingsTitle = 'App settings';
  static const String appSettingsDetails =
      'Preferences, categories, security PIN, and notifications.';
  static const String appSettingsUsedFor =
      'Used for: Customizing your in-app ledger experience.';

  static const String deleteAnytimeTitle = 'Delete your data any time';
  static const String deleteAnytimeInApp =
      'In app: Settings > Privacy and data > Delete account';
  static const String deleteAnytimeWeb = 'On web: decabyte.dz/delete-account';
  static const String deleteAnytimeWebUrl = 'decabyte.dz/delete-account';

  // PS3 Delete account - step 1
  static const String permanentWarningTitle = 'This is permanent';
  static const String permanentWarningBody =
      'Once deleted, your account and ledger data cannot be recovered. Make sure to download a backup if you need your records.';
  static const String whatWillBeDeletedTitle = 'What will be deleted';
  static const String itemProfile = 'Profile and sign-in';
  static const String itemClients = 'Clients and their contact details';
  static const String itemProjects = 'Projects, tasks and payments';
  static const String itemExpenses = 'Expenses';
  static const String itemFriends = 'Friends and their debts';
  static const String itemSettings = 'App settings';
  static const String noCopyKept =
      'We keep no copy of your data after deletion.';
  static const String exportFirstButton = 'Export first';
  static const String continueButton = 'Continue';

  // PS4/PS5 Delete account - confirm step
  static const String confirmDeletionTitle = 'Confirm deletion';
  static const String reasonLabel = 'Why are you leaving? (optional)';
  static const String reasonPlaceholder = 'Select a reason';
  static const String reasonSheetTitle = 'Reason for leaving';
  static const List<String> reasons = <String>[
    'Not using the app',
    'Privacy concerns',
    'Found an alternative',
    'Too complicated',
    'Other',
  ];
  static const String typeDeleteLabel = 'Type DELETE to confirm';
  static const String typeDeletePlaceholder = 'DELETE';
  static const String typeDeleteError = 'Type DELETE exactly to confirm';
  static const String passwordLabel = 'Your password';
  static const String passwordPlaceholder = 'Enter your password';
  static const String passwordError = 'Password is incorrect';
  static const String understandCheckbox =
      'I understand my account and data will be permanently deleted.';
  static const String cancelButton = 'Cancel';
  static const String deleteMyAccountButton = 'Delete my account';

  // PS6 Deleting account progress screen
  static const String deletingAccountTitle = 'Deleting account';
  static const String deletingAccountSubtitle =
      'Please wait while we erase your data...';
  static const String stepClients = 'Clients removed';
  static const String stepProjects = 'Projects and tasks removed';
  static const String stepPayments = 'Payments and expenses removed';
  static const String stepFriends = 'Friends and debts removed';
  static const String stepProfile = 'Profile and sign-in removed';

  // PS7 Account deleted screen
  static const String accountDeletedTitle = 'Your account was deleted';
  static const String accountDeletedBody =
      'All your data has been removed from this device. You can create a new workspace whenever you want.';
  static const String backToWelcomeButton = 'Back to welcome';
}
