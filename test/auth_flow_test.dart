import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/auth/auth_strings.dart';
import 'package:dfile_mobile/features/auth/forgot_password_screen.dart';
import 'package:dfile_mobile/features/auth/onboarding_screen.dart';
import 'package:dfile_mobile/features/auth/sign_in_screen.dart';
import 'package:dfile_mobile/features/auth/sign_up_screen.dart';
import 'package:dfile_mobile/features/auth/verify_code_screen.dart';
import 'package:dfile_mobile/features/auth/welcome_screen.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setTestSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets(
    'welcome -> onboarding -> sign-up navigation',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter();
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      // Starts at WelcomeScreen
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text(AuthStrings.dfile), findsOneWidget);

      // Tap [Get started]
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.getStarted));
      await tester.pumpAndSettle();

      // Navigates to OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Page 1 -> Page 2
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.next));
      await tester.pumpAndSettle();

      // Page 2 -> Page 3
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.next));
      await tester.pumpAndSettle();

      // Page 3 shows [Let's start]
      expect(find.text(AuthStrings.letsStart), findsOneWidget);
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.letsStart));
      await tester.pumpAndSettle();

      // Navigates to SignUpScreen
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(
        find.widgetWithText(PrimaryButton, AuthStrings.createAccount),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'onboarding Next advances the page and the last page shows "Let\'s start"',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.onboardingPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text(AuthStrings.onboardingTitle1), findsOneWidget);
      expect(find.text(AuthStrings.next), findsOneWidget);

      // Advance to page 2
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.next));
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.onboardingTitle2), findsOneWidget);
      expect(find.text(AuthStrings.next), findsOneWidget);

      // Advance to page 3
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.next));
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.onboardingTitle3), findsOneWidget);
      expect(find.text(AuthStrings.letsStart), findsOneWidget);
    },
  );

  testWidgets(
    'sign-in validation blocks empty input and succeeds with valid input (ends on /clients)',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.signInPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);

      // 1. Submit empty form
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.signIn));
      await tester.pumpAndSettle();

      // Blocks navigation, shows validation errors
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text(AuthStrings.emailRequired), findsOneWidget);
      expect(find.text(AuthStrings.passwordRequired), findsOneWidget);

      // 2. Submit invalid email without @
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'invalidemail');
      await tester.enterText(textFields.at(1), 'mypassword');
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.signIn));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.text(AuthStrings.emailInvalid), findsOneWidget);

      // 3. Submit valid credentials
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.signIn));
      await tester.pumpAndSettle();

      // Navigates to /clients
      expect(find.byType(ClientsListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'forgot -> OTP -> verify button enabled only after 6 digits',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router =
          createAppRouter(initialLocation: AppRoutes.forgotPasswordPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      // Empty submission is blocked
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.sendCode));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.text(AuthStrings.emailRequired), findsOneWidget);

      // Enter valid email and send code
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.sendCode));
      await tester.pumpAndSettle();

      // Navigates to VerifyCodeScreen
      expect(find.byType(VerifyCodeScreen), findsOneWidget);
      expect(find.textContaining('test@example.com'), findsOneWidget);

      // Verify button is initially disabled
      PrimaryButton verifyButton =
          tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      expect(verifyButton.onPressed, isNull);

      // Enter 5 digits
      final otpFields = find.byType(TextField);
      expect(otpFields, findsNWidgets(6));
      for (int i = 0; i < 5; i++) {
        await tester.enterText(otpFields.at(i), '$i');
        await tester.pump();
      }

      // Still disabled with 5 digits
      verifyButton =
          tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      expect(verifyButton.onPressed, isNull);

      // Enter 6th digit
      await tester.enterText(otpFields.at(5), '9');
      await tester.pump();

      // Now enabled!
      verifyButton =
          tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      expect(verifyButton.onPressed, isNotNull);

      // Tap verify -> navigates to SignInScreen
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    },
  );

  testWidgets(
    'OTP paste of 6 digits fills all boxes and enables verify button',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router =
          createAppRouter(initialLocation: AppRoutes.verifyCodePath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(VerifyCodeScreen), findsOneWidget);

      PrimaryButton verifyButton =
          tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      expect(verifyButton.onPressed, isNull);

      // Paste 6 digits into first box
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();

      // Verify button enabled
      verifyButton =
          tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, AuthStrings.verify));
      expect(verifyButton.onPressed, isNotNull);

      // Verify all 6 text fields received their digit
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    },
  );

  testWidgets(
    'OTP countdown timer decrements and displays Resend code when hitting 0',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router =
          createAppRouter(initialLocation: AppRoutes.verifyCodePath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pump();

      expect(find.textContaining('Resend in 0:30'), findsOneWidget);

      // Advance by 10 seconds
      await tester.pump(const Duration(seconds: 10));
      expect(find.textContaining('Resend in 0:20'), findsOneWidget);

      // Advance remaining 20 seconds to reach 0
      await tester.pump(const Duration(seconds: 20));
      expect(find.text(AuthStrings.resendCode), findsOneWidget);

      // Tapping Resend code restarts the timer
      await tester.tap(find.text(AuthStrings.resendCode));
      await tester.pump();
      expect(find.textContaining('Resend in 0:30'), findsOneWidget);
    },
  );

  testWidgets(
    'sign-up validation and Google continue flow to /clients',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.signUpPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);

      // 1. Submit empty
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.createAccount));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AuthStrings.nameRequired), findsOneWidget);
      expect(find.text(AuthStrings.emailRequired), findsOneWidget);
      expect(find.text(AuthStrings.passwordRequired), findsOneWidget);
      expect(find.text(AuthStrings.consentRequiredError), findsOneWidget);

      // 2. Short password (< 8 chars)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@example.com');
      await tester.enterText(textFields.at(2), 'short');
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.createAccount));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AuthStrings.passwordMinLength), findsOneWidget);

      // 3. Continue with Google requires consent first
      await tester.tap(find.widgetWithText(SecondaryButton, AuthStrings.continueWithGoogle));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AuthStrings.consentRequiredError), findsOneWidget);

      // Tick the consent checkbox
      await tester.tap(find.byKey(const Key('consent_checkbox')));
      await tester.pumpAndSettle();

      // Continue with Google now navigates to /clients
      await tester.tap(find.widgetWithText(SecondaryButton, AuthStrings.continueWithGoogle));
      await tester.pumpAndSettle();

      expect(find.byType(ClientsListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'sign-up consent links navigate to Terms and Privacy routes',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.signUpPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      // Tap Terms link
      await tester.tap(find.text(AuthStrings.terms));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), AppRoutes.settingsTermsPath);

      // Go back to sign up
      router.go(AppRoutes.signUpPath);
      await tester.pumpAndSettle();

      // Tap Privacy Policy link
      await tester.tap(find.text(AuthStrings.privacyPolicy));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), AppRoutes.settingsPrivacyPath);
    },
  );

  testWidgets(
    'sign-up full form submit with consent navigates to /clients',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.signUpPath);
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Amine Test');
      await tester.enterText(textFields.at(1), 'amine@test.dz');
      await tester.enterText(textFields.at(2), 'password123');

      // Unchecked -> blocked
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.createAccount));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text(AuthStrings.consentRequiredError), findsOneWidget);

      // Check consent
      await tester.tap(find.byKey(const Key('consent_checkbox')));
      await tester.pumpAndSettle();
      expect(find.text(AuthStrings.consentRequiredError), findsNothing);

      // Submit
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.createAccount));
      await tester.pumpAndSettle();
      expect(find.byType(ClientsListScreen), findsOneWidget);
    },
  );

  testWidgets(
    'navigation links: welcome to sign in, onboarding skip to sign in, verify change email to forgot',
    (WidgetTester tester) async {
      setTestSurface(tester);
      final router = createAppRouter();
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      // Welcome "I already have an account" -> Sign in
      await tester.tap(find.text(AuthStrings.alreadyHaveAccount));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);

      // Back to welcome
      router.go(AppRoutes.onboardingPath);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Onboarding "Skip" -> Sign in
      await tester.tap(find.text(AuthStrings.skip));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);

      // Verify code "Change email" -> Forgot password
      router.push(AppRoutes.forgotPasswordPath);
      await tester.pumpAndSettle();
      router.push(AppRoutes.verifyCodePath);
      await tester.pumpAndSettle();
      expect(find.byType(VerifyCodeScreen), findsOneWidget);

      await tester.tap(find.text(AuthStrings.changeEmail));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    },
  );
}
