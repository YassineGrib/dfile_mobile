import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/auth/forgot_password_screen.dart';
import 'package:dfile_mobile/features/auth/onboarding_screen.dart';
import 'package:dfile_mobile/features/auth/sign_in_screen.dart';
import 'package:dfile_mobile/features/auth/sign_up_screen.dart';
import 'package:dfile_mobile/features/auth/verify_code_screen.dart';
import 'package:dfile_mobile/features/auth/welcome_screen.dart';
import 'package:dfile_mobile/features/clients/add_client_screen.dart';
import 'package:dfile_mobile/features/clients/client_detail_screen.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/features/clients/edit_client_screen.dart';
import 'package:dfile_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('DfileApp boots to the Welcome placeholder screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(DfileApp(router: createAppRouter()));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('All SPEC routes resolve to their placeholder screens', (
    WidgetTester tester,
  ) async {
    final GoRouter router = createAppRouter();
    await tester.pumpWidget(DfileApp(router: router));
    await tester.pumpAndSettle();

    Future<void> expectRoute(String path, Type screenType) async {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(screenType), findsOneWidget);
    }

    await expectRoute('/onboarding', OnboardingScreen);
    await expectRoute('/sign-in', SignInScreen);
    await expectRoute('/sign-up', SignUpScreen);
    await expectRoute('/forgot-password', ForgotPasswordScreen);
    await expectRoute('/verify-code', VerifyCodeScreen);
    await expectRoute('/clients', ClientsListScreen);
    await expectRoute('/clients/new', AddClientScreen);
    await expectRoute('/clients/c1', ClientDetailScreen);
    await expectRoute('/clients/c1/edit', EditClientScreen);
  });
}
