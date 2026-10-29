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
import '../../features/projects/add_project_screen.dart';
import '../../features/projects/edit_project_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/projects_list_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/payments/payment_receipt_screen.dart';
import '../../features/payments/payments_list_screen.dart';
import '../../features/payments/record_payment_screen.dart';

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

  static const String projectsName = 'projects';
  static const String projectsPath = '/projects';

  static const String addProjectName = 'add-project';
  static const String addProjectPath = '/projects/new';

  static const String projectDetailName = 'project-detail';
  static const String projectDetailPath = '/projects/:id';

  static const String editProjectName = 'edit-project';
  static const String editProjectPath = '/projects/:id/edit';

  static const String paymentsName = 'payments';
  static const String paymentsPath = '/payments';

  static const String recordPaymentName = 'record-payment';
  static const String recordPaymentPath = '/payments/new';

  static const String paymentReceiptName = 'payment-receipt';
  static const String paymentReceiptPath = '/payments/:id';

  static const String moreName = 'more';
  static const String morePath = '/more';
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
      GoRoute(
        path: AppRoutes.projectsPath,
        name: AppRoutes.projectsName,
        builder: (BuildContext context, GoRouterState state) =>
            const ProjectsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProjectPath,
        name: AppRoutes.addProjectName,
        builder: (BuildContext context, GoRouterState state) =>
            const AddProjectScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectDetailPath,
        name: AppRoutes.projectDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            ProjectDetailScreen(
              projectId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.editProjectPath,
        name: AppRoutes.editProjectName,
        builder: (BuildContext context, GoRouterState state) =>
            EditProjectScreen(
              projectId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.paymentsPath,
        name: AppRoutes.paymentsName,
        builder: (BuildContext context, GoRouterState state) =>
            const PaymentsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordPaymentPath,
        name: AppRoutes.recordPaymentName,
        builder: (BuildContext context, GoRouterState state) =>
            RecordPaymentScreen(
              projectId: state.uri.queryParameters['projectId'],
            ),
      ),
      GoRoute(
        path: AppRoutes.paymentReceiptPath,
        name: AppRoutes.paymentReceiptName,
        builder: (BuildContext context, GoRouterState state) =>
            PaymentReceiptScreen(
              paymentId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.morePath,
        name: AppRoutes.moreName,
        builder: (BuildContext context, GoRouterState state) =>
            const MoreScreen(),
      ),
    ],
  );
}

/// Default singleton router used by [DfileApp].
final GoRouter appRouter = createAppRouter();
