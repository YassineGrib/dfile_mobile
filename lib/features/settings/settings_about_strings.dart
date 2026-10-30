/// String constants for integrations, about, and support settings screens (Agent D) per `docs/design/SPEC.md`.
abstract final class SettingsAboutStrings {
  // Integrations (ST10)
  static const String integrationsTitle = 'Integrations';
  static const String cloudSyncTitle = 'Cloud sync';
  static const String cloudSyncProvider = 'Firebase Cloud Firestore';
  static const String cloudConnected = 'Connected';
  static const String cloudLastSynced = 'Last synced 2 minutes ago';

  static const String googleCalendarTitle = 'Google Calendar';
  static const String googleCalendarSubtitle =
      'Sync deadlines with your calendar';
  static const String connectAccount = 'Connect account';
  static const String disconnect = 'Disconnect';
  static const String googleLinkedToast = 'Google account linked';
  static const String googleUnlinkedToast = 'Google Account unlinked.';

  static const String exportBackupTitle = 'Export and backup';
  static const String exportBackupSubtitle =
      'Clients, projects, billing and costs';
  static const String downloadBackupButton =
      'Download workspace backup (JSON)';
  static const String backupCopiedToast = 'Backup copied to clipboard';

  // About and support (ST12)
  static const String aboutTitle = 'About and support';
  static const String appName = 'Dfile';
  static const String appVersion = 'Version 1.0.0  \u2022  Build 42';
  static const String appTagline =
      'Your clients, projects and payments in one pocket-sized ledger.';
  static const String supportTicketRowTitle = 'Submit support ticket';
  static const String supportTicketRowSubtitle = 'Report a bug or sync problem';
  static const String privacyPolicyRowTitle = 'Privacy policy';
  static const String privacyPolicyRowSubtitle = 'How your data is handled';
  static const String termsConditionsRowTitle = 'Terms and conditions';
  static const String termsConditionsRowSubtitle = 'Usage terms';
  static const String signOutRowTitle = 'Sign out';

  // Sign out confirm sheet (ST14)
  static const String signOutSheetTitle = 'Sign out?';
  static const String signOutSheetSubtitle =
      'Your data stays safe in the cloud.';
  static const String signOutSheetDescription =
      'You will return to the welcome screen and need to sign in again.';
  static const String signOutConfirmButton = 'Sign out';
  static const String cancelButton = 'Cancel';

  // Support ticket (ST13)
  static const String supportTicketTitle = 'Support ticket';
  static const String supportTicketSubtitle =
      'Found a bug or a cloud sync problem? Tell us.';
  static const String subjectLabel = 'Subject';
  static const String subjectPlaceholder = 'e.g. Google Calendar sync error';
  static const String subjectRequiredError = 'Please enter a subject';
  static const String messageLabel = 'Message details';
  static const String messagePlaceholder = 'Explain what happened...';
  static const String messageRequiredError = 'Please enter a message';
  static const String submitTicketButton = 'Submit ticket';
  static const String ticketSentToast = 'Support ticket sent';

  // Policy screens (ST15)
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String privacyPolicyHeading = 'Your data, your control';
  static const String privacyStoreTitle = 'What we store';
  static const String privacyStoreBody =
      'Your clients, projects, payments and costs are stored in your private cloud workspace. Only you can read them.';
  static const String privacyNeverTitle = 'What we never do';
  static const String privacyNeverBody =
      'We do not sell your data or share it with advertisers or other users.';
  static const String privacyChoicesTitle = 'Your choices';
  static const String privacyChoicesBody =
      'You can export a full backup or delete your workspace at any time from Settings.';

  static const String termsConditionsTitle = 'Terms and Conditions';
  static const String termsConditionsHeading = 'Using Dfile';
  static const String termsLicenseTitle = 'Account and license';
  static const String termsLicenseBody =
      'Dfile grants you a personal, non-exclusive license to use the app for managing your freelance business, projects, and client ledger.';
  static const String termsContentTitle = 'Your content';
  static const String termsContentBody =
      'You retain full ownership of all clients, projects, invoices, and debt records you create. You are responsible for the accuracy of your entries.';
  static const String termsUsageTitle = 'Fair usage and limits';
  static const String termsUsageBody =
      'You agree not to abuse cloud sync services or reverse engineer proprietary components. Service is provided as-is without warranties.';

  static const String policyLastUpdated = 'Last updated October 2026';
}
