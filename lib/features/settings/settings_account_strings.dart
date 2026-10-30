/// String constants for account settings screens (Agent A) per `docs/design/SPEC.md`.
abstract final class SettingsAccountStrings {
  // Screen Titles and Headers
  static const String editProfileTitle = 'Edit profile';
  static const String changePasswordTitle = 'Change password';
  static const String changePasswordSubtitle =
      'Choose a new password for your workspace.';

  // Profile Form Labels
  static const String displayNameLabel = 'Display name *';
  static const String designationLabel = 'Professional designation *';
  static const String businessEmailLabel = 'Business email';
  static const String verifiedPill = 'Verified';
  static const String phoneLabel = 'Mobile / phone';
  static const String addressLabel = 'Business address';
  static const String changePasswordRow = 'Change password';

  // Profile Form Validation Errors
  static const String nameRequiredError = 'Please enter your name';
  static const String designationRequiredError =
      'Please enter your designation';

  // Password Form Labels
  static const String currentPasswordLabel = 'Current password';
  static const String newPasswordLabel = 'New password';
  static const String confirmPasswordLabel = 'Confirm new password';

  // Password Visibility Toggles
  static const String showToggle = 'Show';
  static const String hideToggle = 'Hide';

  // Password Form Validation Errors
  static const String currentPasswordIncorrectError =
      'Current password is incorrect';
  static const String passwordTooShortError =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatchError = 'New passwords do not match';

  // Actions
  static const String cancel = 'Cancel';
  static const String saveDetails = 'Save details';
  static const String updatePassword = 'Update password';

  // Toast Messages
  static const String profileUpdatedToast = 'Profile updated successfully';
  static const String passwordUpdatedToast = 'Password updated successfully';
}
