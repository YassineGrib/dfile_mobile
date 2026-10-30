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
import '../../features/expenses/expense_detail_screen.dart';
import '../../features/expenses/expense_form_screen.dart';
import '../../features/expenses/expenses_list_screen.dart';
import '../../features/friends/add_friend_screen.dart';
import '../../features/friends/data/friends_tab.dart';
import '../../features/friends/friend_statement_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/friends/transaction_detail_screen.dart';
import '../../features/friends/transaction_form_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/payments/payment_receipt_screen.dart';
import '../../features/payments/payments_list_screen.dart';
import '../../features/payments/record_payment_screen.dart';
import '../../features/projects/add_project_screen.dart';
import '../../features/projects/edit_project_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/projects_list_screen.dart';
import '../../features/settings/about_screen.dart';
import '../../features/settings/account_deleted_screen.dart';
import '../../features/settings/data_usage_screen.dart';
import '../../features/settings/delete_account_confirm_screen.dart';
import '../../features/settings/delete_account_progress_screen.dart';
import '../../features/settings/delete_account_screen.dart';
import '../../features/settings/privacy_data_screen.dart';
import '../../features/settings/categories_screen.dart';
import '../../features/settings/change_password_screen.dart';
import '../../features/settings/data/policy_kind.dart';
import '../../features/settings/edit_profile_screen.dart';
import '../../features/settings/integrations_screen.dart';
import '../../features/settings/legal_clauses_screen.dart';
import '../../features/settings/notifications_screen.dart';
import '../../features/settings/policy_screen.dart';
import '../../features/settings/preferences_screen.dart';
import '../../features/settings/security_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/support_ticket_screen.dart';

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

  static const String expensesName = 'expenses';
  static const String expensesPath = '/expenses';

  static const String newExpenseName = 'new-expense';
  static const String newExpensePath = '/expenses/new';
  static const String recordExpenseName = 'record-expense';
  static const String recordExpensePath = '/expenses/new';

  static const String expenseDetailName = 'expense-detail';
  static const String expenseDetailPath = '/expenses/:id';

  static const String editExpenseName = 'edit-expense';
  static const String editExpensePath = '/expenses/:id/edit';

  static const String friendsName = 'friends';
  static const String friendsPath = '/friends';

  static const String addFriendName = 'add-friend';
  static const String addFriendPath = '/friends/new';

  static const String newFriendTransactionName = 'new-friend-transaction';
  static const String newFriendTransactionPath = '/friends/transactions/new';

  static const String friendTransactionDetailName = 'friend-transaction-detail';
  static const String friendTransactionDetailPath = '/friends/transactions/:id';

  static const String friendStatementName = 'friend-statement';
  static const String friendStatementPath = '/friends/:id';

  static const String moreName = 'more';
  static const String morePath = '/more';

  static const String settingsName = 'settings';
  static const String settingsPath = '/settings';

  static const String settingsProfileName = 'settings-profile';
  static const String settingsProfilePath = '/settings/profile';
  static const String editProfileName = 'edit-profile';
  static const String editProfilePath = '/settings/profile';

  static const String settingsPasswordName = 'settings-password';
  static const String settingsPasswordPath = '/settings/password';
  static const String changePasswordName = 'change-password';
  static const String changePasswordPath = '/settings/password';

  static const String settingsPreferencesName = 'settings-preferences';
  static const String settingsPreferencesPath = '/settings/preferences';
  static const String preferencesName = 'preferences';
  static const String preferencesPath = '/settings/preferences';

  static const String settingsCategoriesName = 'settings-categories';
  static const String settingsCategoriesPath = '/settings/categories';
  static const String categoriesName = 'categories';
  static const String categoriesPath = '/settings/categories';

  static const String settingsLegalName = 'settings-legal';
  static const String settingsLegalPath = '/settings/legal';
  static const String legalClausesName = 'legal-clauses';
  static const String legalClausesPath = '/settings/legal';

  static const String settingsSecurityName = 'settings-security';
  static const String settingsSecurityPath = '/settings/security';
  static const String securityName = 'security';
  static const String securityPath = '/settings/security';

  static const String settingsIntegrationsName = 'settings-integrations';
  static const String settingsIntegrationsPath = '/settings/integrations';
  static const String integrationsName = 'integrations';
  static const String integrationsPath = '/settings/integrations';

  static const String settingsNotificationsName = 'settings-notifications';
  static const String settingsNotificationsPath = '/settings/notifications';
  static const String notificationsName = 'notifications';
  static const String notificationsPath = '/settings/notifications';

  static const String settingsAboutName = 'settings-about';
  static const String settingsAboutPath = '/settings/about';
  static const String aboutName = 'about';
  static const String aboutPath = '/settings/about';

  static const String settingsSupportName = 'settings-support';
  static const String settingsSupportPath = '/settings/support';
  static const String supportTicketName = 'support-ticket';
  static const String supportTicketPath = '/settings/support';

  static const String settingsPrivacyName = 'settings-privacy';
  static const String settingsPrivacyPath = '/settings/privacy';
  static const String privacyName = 'privacy';
  static const String privacyPath = '/settings/privacy';

  static const String settingsTermsName = 'settings-terms';
  static const String settingsTermsPath = '/settings/terms';
  static const String termsName = 'terms';
  static const String termsPath = '/settings/terms';

  static const String settingsPrivacyDataName = 'settings-privacy-data';
  static const String settingsPrivacyDataPath = '/settings/privacy-data';
  static const String privacyDataName = 'privacy-data';
  static const String privacyDataPath = '/settings/privacy-data';

  static const String settingsDataUsageName = 'settings-data-usage';
  static const String settingsDataUsagePath = '/settings/data-usage';
  static const String dataUsageName = 'data-usage';
  static const String dataUsagePath = '/settings/data-usage';

  static const String settingsDeleteAccountName = 'settings-delete-account';
  static const String settingsDeleteAccountPath = '/settings/delete-account';
  static const String deleteAccountName = 'delete-account';
  static const String deleteAccountPath = '/settings/delete-account';

  static const String settingsDeleteAccountConfirmName = 'settings-delete-account-confirm';
  static const String settingsDeleteAccountConfirmPath = '/settings/delete-account/confirm';
  static const String deleteAccountConfirmName = 'delete-account-confirm';
  static const String deleteAccountConfirmPath = '/settings/delete-account/confirm';

  static const String settingsDeleteAccountProgressName = 'settings-delete-account-progress';
  static const String settingsDeleteAccountProgressPath = '/settings/delete-account/progress';
  static const String deleteAccountProgressName = 'delete-account-progress';
  static const String deleteAccountProgressPath = '/settings/delete-account/progress';

  static const String accountDeletedName = 'account-deleted';
  static const String accountDeletedPath = '/account-deleted';
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
        path: AppRoutes.expensesPath,
        name: AppRoutes.expensesName,
        builder: (BuildContext context, GoRouterState state) =>
            const ExpensesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.newExpensePath,
        name: AppRoutes.newExpenseName,
        builder: (BuildContext context, GoRouterState state) =>
            ExpenseFormScreen(
              projectId: state.uri.queryParameters['projectId'],
            ),
      ),
      GoRoute(
        path: AppRoutes.editExpensePath,
        name: AppRoutes.editExpenseName,
        builder: (BuildContext context, GoRouterState state) =>
            ExpenseFormScreen(
              expenseId: state.pathParameters['id'],
            ),
      ),
      GoRoute(
        path: AppRoutes.expenseDetailPath,
        name: AppRoutes.expenseDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            ExpenseDetailScreen(
              expenseId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.friendsPath,
        name: AppRoutes.friendsName,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final String? tabQuery = state.uri.queryParameters['tab'];
          final FriendsTab initialTab = extra is FriendsTab
              ? extra
              : (tabQuery != null
                  ? FriendsTab.fromString(tabQuery)
                  : FriendsTab.friends);
          final String? initialQuery =
              state.uri.queryParameters['q'] ?? state.uri.queryParameters['query'];
          return FriendsScreen(
            initialTab: initialTab,
            initialQuery: initialQuery,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addFriendPath,
        name: AppRoutes.addFriendName,
        builder: (BuildContext context, GoRouterState state) =>
            const AddFriendScreen(),
      ),
      GoRoute(
        path: AppRoutes.newFriendTransactionPath,
        name: AppRoutes.newFriendTransactionName,
        builder: (BuildContext context, GoRouterState state) =>
            TransactionFormScreen(
              friendId: state.uri.queryParameters['friendId'],
            ),
      ),
      GoRoute(
        path: AppRoutes.friendTransactionDetailPath,
        name: AppRoutes.friendTransactionDetailName,
        builder: (BuildContext context, GoRouterState state) =>
            TransactionDetailScreen(
              transactionId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.friendStatementPath,
        name: AppRoutes.friendStatementName,
        builder: (BuildContext context, GoRouterState state) =>
            FriendStatementScreen(
              friendId: state.pathParameters['id'] ?? '',
            ),
      ),
      GoRoute(
        path: AppRoutes.morePath,
        name: AppRoutes.moreName,
        builder: (BuildContext context, GoRouterState state) =>
            const MoreScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settingsName,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsProfilePath,
        name: AppRoutes.settingsProfileName,
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPasswordPath,
        name: AppRoutes.settingsPasswordName,
        builder: (BuildContext context, GoRouterState state) =>
            const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPreferencesPath,
        name: AppRoutes.settingsPreferencesName,
        builder: (BuildContext context, GoRouterState state) =>
            const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsCategoriesPath,
        name: AppRoutes.settingsCategoriesName,
        builder: (BuildContext context, GoRouterState state) =>
            const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsLegalPath,
        name: AppRoutes.settingsLegalName,
        builder: (BuildContext context, GoRouterState state) =>
            const LegalClausesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsSecurityPath,
        name: AppRoutes.settingsSecurityName,
        builder: (BuildContext context, GoRouterState state) =>
            const SecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsIntegrationsPath,
        name: AppRoutes.settingsIntegrationsName,
        builder: (BuildContext context, GoRouterState state) =>
            const IntegrationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsNotificationsPath,
        name: AppRoutes.settingsNotificationsName,
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsAboutPath,
        name: AppRoutes.settingsAboutName,
        builder: (BuildContext context, GoRouterState state) =>
            const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsSupportPath,
        name: AppRoutes.settingsSupportName,
        builder: (BuildContext context, GoRouterState state) =>
            const SupportTicketScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacyPath,
        name: AppRoutes.settingsPrivacyName,
        builder: (BuildContext context, GoRouterState state) =>
            const PolicyScreen(kind: PolicyKind.privacy),
      ),
      GoRoute(
        path: AppRoutes.settingsTermsPath,
        name: AppRoutes.settingsTermsName,
        builder: (BuildContext context, GoRouterState state) =>
            const PolicyScreen(kind: PolicyKind.terms),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacyDataPath,
        name: AppRoutes.settingsPrivacyDataName,
        builder: (BuildContext context, GoRouterState state) =>
            const PrivacyDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDataUsagePath,
        name: AppRoutes.settingsDataUsageName,
        builder: (BuildContext context, GoRouterState state) =>
            const DataUsageScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDeleteAccountPath,
        name: AppRoutes.settingsDeleteAccountName,
        builder: (BuildContext context, GoRouterState state) =>
            const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDeleteAccountConfirmPath,
        name: AppRoutes.settingsDeleteAccountConfirmName,
        builder: (BuildContext context, GoRouterState state) =>
            const DeleteAccountConfirmScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDeleteAccountProgressPath,
        name: AppRoutes.settingsDeleteAccountProgressName,
        builder: (BuildContext context, GoRouterState state) {
          final Duration? stepDuration =
              state.extra is Duration ? (state.extra as Duration) : null;
          return DeleteAccountProgressScreen(
            stepDuration: stepDuration ?? const Duration(milliseconds: 500),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountDeletedPath,
        name: AppRoutes.accountDeletedName,
        builder: (BuildContext context, GoRouterState state) =>
            const AccountDeletedScreen(),
      ),
    ],
  );
}

/// Default singleton router used by [DfileApp].
final GoRouter appRouter = createAppRouter();
