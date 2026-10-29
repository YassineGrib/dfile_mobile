import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/auth/verify_code_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/clients/add_client_screen.dart';
import '../../features/clients/client_detail_screen.dart';
import '../../features/clients/clients_list_screen.dart';
import '../../features/clients/edit_client_screen.dart';

/// Named route identifiers and paths for every screen in `docs/design/SPEC.md`.
abstract final class AppRoutes {
  static const String welcomeName = 'welcome';
  static const String welcomePath = '/welcome';

  static const String onboardingName = 'onboarding';
  static const String onboardingPath = '/onboarding';

  static const String signInName = 'sign-in';
  static const String signInPath = '/sign-in';

  static const String signUpName = 'sign-up';
  static const String signUpPath = '/sign-up';

  static const String forgotPasswordName = 'forgot-password';
  static const String forgotPasswordPath = '/forgot-password';

  static const String verifyCodeName = 'verify-code';
  static const String verifyCodePath = '/verify-code';

  static const String clientsName = 'clients';
  static const String clientsPath = '/clients';

  static const String addClientName = 'add-client';
  static const String addClientPath = '/clients/new';

  static const String clientDetailName = 'client-detail';
  static const String clientDetailPath = '/clients/:id';

  static const String editClientName = 'edit-client';
  static const String editClientPath = '/clients/:id/edit';
}

/// Builds a fresh [GoRouter] configured with all application routes.
GoRouter createAppRouter({String initialLocation = AppRoutes.welcomePath}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.welcomePath,
        name: AppRoutes.welcomeName,
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboardingName,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signInPath,
        name: AppRoutes.signInName,
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUpPath,
        name: AppRoutes.signUpName,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPasswordName,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyCodePath,
        name: AppRoutes.verifyCodeName,
        builder: (BuildContext context, GoRouterState state) =>
            const VerifyCodeScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientsPath,
        name: AppRoutes.clientsName,
        builder: (BuildContext context, GoRouterState state) =>
            const ClientsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addClientPath,
        name: AppRoutes.addClientName,
        builder: (BuildContext context, GoRouterState state) =>
            const AddClientScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientDetailPath,
        name: AppRoutes.clientDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            ClientDetailScreen(
              clientId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.editClientPath,
        name: AppRoutes.editClientName,
        builder: (BuildContext context, GoRouterState state) =>
            EditClientScreen(
              clientId: state.pathParameters['id'] ?? '',
            ),
      ),
    ],
  );
}

/// Default singleton router used by [DfileApp].
final GoRouter appRouter = createAppRouter();
