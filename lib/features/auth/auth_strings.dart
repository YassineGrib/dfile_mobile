/// Centralised strings for the authentication feature.
abstract final class AuthStrings {
  // Screen names / placeholder compatibility
  static const String welcome = 'Welcome';
  static const String onboarding = 'Onboarding';
  static const String signIn = 'Sign in';
  static const String signUp = 'Sign up';
  static const String forgotPassword = 'Forgot password';
  static const String verifyCode = 'Verify code';

  // 1. Welcome screen
  static const String dfile = 'Dfile';
  static const String welcomeSubtitle =
      'Your clients, projects and payments in one pocket-sized ledger.';
  static const String getStarted = 'Get started';
  static const String alreadyHaveAccount = 'I already have an account';

  // 2, 3, 4. Onboarding screen
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String letsStart = "Let's start";
  static const String onboardingTitle1 = 'Know every client';
  static const String onboardingSubtitle1 =
      'Keep contacts, projects and notes together, so nothing slips.';
  static const String onboardingTitle2 = 'Get paid, on time';
  static const String onboardingSubtitle2 =
      'Track payments in DZD, send invoices, and see who owes what.';
  static const String onboardingTitle3 = "Friends' debts, settled";
  static const String onboardingSubtitle3 =
      'A simple ledger for money and favours lent or borrowed.';

  // 5. Sign in screen
  static const String welcomeBack = 'Welcome back';
  static const String signInSubtitle =
      'Sign in to continue to your workspace.';
  static const String emailLabel = 'Email';
  static const String emailPlaceholder = 'you@example.com';
  static const String passwordLabel = 'Password';
  static const String passwordPlaceholder = '••••••••';
  static const String forgotPasswordLink = 'Forgot password?';
  static const String orDivider = 'or';
  static const String continueWithGoogle = 'Continue with Google';
  static const String newHere = 'New here?';
  static const String createAccountLink = 'Create an account';

  // 6. Sign up screen
  static const String createAccount = 'Create account';
  static const String signUpSubtitle =
      'Start managing your freelance work.';
  static const String fullNameLabel = 'Full name';
  static const String fullNamePlaceholder = 'Your name';
  static const String passwordSignUpPlaceholder = 'At least 8 characters';
  static const String alreadyHaveAccountPrompt = 'Already have an account?';
  static const String signInLink = 'Sign in';

  // 7. Forgot password screen
  static const String forgotPasswordTitle = 'Forgot password?';
  static const String forgotPasswordSubtitle =
      'Enter the email on your account and we will send you a 6-digit code.';
  static const String sendCode = 'Send code';
  static const String backToSignIn = 'Back to sign in';

  // 8. Verify code (OTP) screen
  static const String checkYourEmail = 'Check your email';
  static const String verifySubtitlePrefix = 'We sent a 6-digit code to\n';
  static const String verifySubtitleSuffix = '. Enter it below.';
  static const String didNotGetIt = 'Did not get it?';
  static const String resendIn = 'Resend in ';
  static const String resendCode = 'Resend code';
  static const String verify = 'Verify';
  static const String changeEmail = 'Change email';

  // Validation errors
  static const String nameRequired = 'Please enter your name';
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Email must contain @';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordMinLength =
      'Password must be at least 8 characters';

  // Sign up consent
  static const String consentAgreePrefix = 'I agree to the ';
  static const String terms = 'Terms';
  static const String and = ' and ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String consentRequiredError =
      'Please accept the Terms and Privacy Policy to continue';
}
