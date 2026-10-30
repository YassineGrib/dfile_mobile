/// String constants for security and notifications settings screens (Agent C) per `docs/design/SPEC.md`.
abstract final class SettingsSecurityStrings {
  // Security screen (ST8)
  static const String securityTitle = 'Security';
  static const String numericPinLock = 'Numeric PIN lock';
  static const String numericPinSubtitle = 'Protect the app with a 4-digit code';
  static const String changePin = 'Change PIN';
  static const String fingerprintUnlock = 'Fingerprint unlock';
  static const String fingerprintSubtitle = 'Use your phone fingerprint or face';
  static const String notAvailableInDemoToast = 'Not available in the demo';
  static const String activeSessions = 'Active sessions';
  static const String activeSessionsSubtitle = 'Devices signed in to this workspace';
  static const String terminateOtherSessions = 'Terminate other sessions';
  static const String loggedOutOtherSessionsToast = 'Logged out other sessions.';
  static const String pinLockDisabledToast = 'PIN lock disabled';

  // PIN bottom sheet (ST9)
  static const String choosePinTitle = 'Choose a 4-digit PIN';
  static const String changePinTitle = 'Change PIN';
  static const String pinSheetSubtitle = 'You will use it to unlock Dfile';
  static const String savePin = 'Save PIN';
  static const String pinSavedToast = 'PIN saved';

  // Notifications screen (ST11)
  static const String notificationsTitle = 'Notifications';
  static const String pushNotificationAlerts = 'Push notification alerts';
  static const String pushNotificationSubtitle = 'Allow Dfile to send alerts';
  static const String whatToNotifySection = 'WHAT TO NOTIFY';
  static const String projectDeadlines = 'Project deadlines';
  static const String projectDeadlinesSubtitle = 'Warn when less than 3 days remain';
  static const String paymentReminders = 'Payment reminders';
  static const String paymentRemindersSubtitle = 'Unpaid balances past their due date';
  static const String taskUpdates = 'Task updates';
  static const String taskUpdatesSubtitle = 'Comments and changes on tasks';
  static const String notificationPreferencesSavedToast =
      'Notification preferences saved';
  static const String changesSavedAutomatically =
      'Changes are saved automatically.';
}
