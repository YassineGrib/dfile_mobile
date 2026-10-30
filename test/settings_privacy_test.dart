import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/account_deleted_screen.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/data_usage_screen.dart';
import 'package:dfile_mobile/features/settings/delete_account_confirm_screen.dart';
import 'package:dfile_mobile/features/settings/delete_account_progress_screen.dart';
import 'package:dfile_mobile/features/settings/delete_account_screen.dart';
import 'package:dfile_mobile/features/settings/policy_screen.dart';
import 'package:dfile_mobile/features/settings/privacy_data_screen.dart';
import 'package:dfile_mobile/features/settings/settings_privacy_strings.dart';
import 'package:dfile_mobile/features/settings/widgets/privacy_danger_button.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  String? clipboardContent;

  setUp(() {
    clipboardContent = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardContent = (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
        return null;
      }
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboardContent};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<(ClientsRepository, ProjectsRepository, ExpensesRepository, FriendsRepository, SettingsRepository, GoRouter)>
      pumpTestApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.settingsPrivacyDataPath,
    Size surfaceSize = const Size(390, 844),
    bool settle = true,
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ClientsRepository clientsRepo = ClientsRepository();
    final ProjectsRepository projectsRepo =
        ProjectsRepository(clientsRepository: clientsRepo);
    final ExpensesRepository expensesRepo = ExpensesRepository();
    final FriendsRepository friendsRepo = FriendsRepository();
    final SettingsRepository settingsRepo = SettingsRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        repository: clientsRepo,
        projectsRepository: projectsRepo,
        expensesRepository: expensesRepo,
        friendsRepository: friendsRepo,
        settingsRepository: settingsRepo,
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }

    return (
      clientsRepo,
      projectsRepo,
      expensesRepo,
      friendsRepo,
      settingsRepo,
      router,
    );
  }

  group('Privacy Centre (PS2) & Export Data Tests', () {
    testWidgets('PrivacyDataScreen renders intro card, all action rows, and danger zone', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester);

      expect(find.byType(PrivacyDataScreen), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.privacyDataTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.dataBelongsToYouTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.dataBelongsToYouBody), findsOneWidget);

      expect(find.text(SettingsPrivacyStrings.privacyPolicyTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.termsTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.howWeUseDataTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.exportDataTitle), findsOneWidget);

      // Scroll to danger zone
      await tester.scrollUntilVisible(find.text(SettingsPrivacyStrings.dangerZoneTitle), 150);
      expect(find.text(SettingsPrivacyStrings.dangerZoneTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.deleteAccountTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.deleteAccountSubtitle), findsOneWidget);
    });

    testWidgets('PrivacyDataScreen rows navigate to their respective routes', (
      WidgetTester tester,
    ) async {
      final (_, _, _, _, _, GoRouter router) = await pumpTestApp(tester);

      // Privacy policy -> /settings/privacy
      await tester.tap(find.text(SettingsPrivacyStrings.privacyPolicyTitle));
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsPrivacyPath);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyDataScreen), findsOneWidget);

      // Terms -> /settings/terms
      await tester.tap(find.text(SettingsPrivacyStrings.termsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsTermsPath);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyDataScreen), findsOneWidget);

      // How we use your data -> /settings/data-usage
      await tester.tap(find.text(SettingsPrivacyStrings.howWeUseDataTitle));
      await tester.pumpAndSettle();
      expect(find.byType(DataUsageScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsDataUsagePath);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyDataScreen), findsOneWidget);

      // Scroll and tap Delete account -> /settings/delete-account
      await tester.scrollUntilVisible(find.text(SettingsPrivacyStrings.deleteAccountTitle), 150);
      await tester.tap(find.text(SettingsPrivacyStrings.deleteAccountTitle));
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsDeleteAccountPath);
    });

    testWidgets('Export my data copies JSON containing known client name to clipboard and shows toast', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester);

      await tester.tap(find.text(SettingsPrivacyStrings.exportDataTitle));
      await tester.pumpAndSettle();

      // Check toast
      expect(find.text(SettingsPrivacyStrings.backupCopiedToast), findsOneWidget);

      // Check clipboard content
      expect(clipboardContent, isNotNull);
      expect(clipboardContent, contains('Mohamed Bachir'));
      expect(clipboardContent, contains('Fintask Landing Page'));
      expect(clipboardContent, contains('Yassine G.'));
    });
  });

  group('Delete Account Step 1 (PS3) Tests', () {
    testWidgets('DeleteAccountScreen renders warning, deletion items, and handles actions', (
      WidgetTester tester,
    ) async {
      final (_, _, _, _, _, GoRouter router) = await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountPath,
      );

      expect(find.byType(DeleteAccountScreen), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.permanentWarningTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.whatWillBeDeletedTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemProfile), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemClients), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemProjects), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemExpenses), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemFriends), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.itemSettings), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.noCopyKept), findsOneWidget);

      // [Export first] copies JSON, shows toast, and stays on screen
      await tester.tap(find.widgetWithText(SecondaryButton, SettingsPrivacyStrings.exportFirstButton));
      await tester.pumpAndSettle();
      expect(find.text(SettingsPrivacyStrings.backupCopiedToast), findsOneWidget);
      expect(clipboardContent, contains('Mohamed Bachir'));
      expect(find.byType(DeleteAccountScreen), findsOneWidget);

      // [Continue] -> navigates to confirm screen
      await tester.tap(find.widgetWithText(PrivacyDangerButton, SettingsPrivacyStrings.continueButton));
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountConfirmScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsDeleteAccountConfirmPath);
    });
  });

  group('Delete Account Confirm Step (PS4/PS5) Tests', () {
    testWidgets('Reason sheet, DELETE check, password check, checkbox gate, and cancel', (
      WidgetTester tester,
    ) async {
      final (_, _, _, _, _, GoRouter router) = await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountConfirmPath,
      );

      expect(find.byType(DeleteAccountConfirmScreen), findsOneWidget);

      // Reason selection sheet
      await tester.tap(find.text(SettingsPrivacyStrings.reasonPlaceholder));
      await tester.pumpAndSettle();
      expect(find.text(SettingsPrivacyStrings.reasonSheetTitle), findsOneWidget);
      expect(find.text('Privacy concerns'), findsOneWidget);
      await tester.tap(find.text('Privacy concerns'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy concerns'), findsOneWidget);

      // Checkbox gate: Delete button is dimmed/disabled before ticking checkbox
      PrivacyDangerButton deleteBtn =
          tester.widget<PrivacyDangerButton>(find.byType(PrivacyDangerButton));
      expect(deleteBtn.onPressed, isNull);

      // Tick checkbox
      await tester.tap(find.text(SettingsPrivacyStrings.understandCheckbox));
      await tester.pumpAndSettle();
      deleteBtn = tester.widget<PrivacyDangerButton>(find.byType(PrivacyDangerButton));
      expect(deleteBtn.onPressed, isNotNull);

      // Submit with invalid DELETE text and invalid password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'delete'); // lowercase, invalid
      await tester.enterText(textFields.at(1), 'wrongpass');
      await tester.tap(find.byType(PrivacyDangerButton));
      await tester.pumpAndSettle();

      expect(find.text(SettingsPrivacyStrings.typeDeleteError), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.passwordError), findsOneWidget);
      expect(find.byType(DeleteAccountConfirmScreen), findsOneWidget);

      // Fix DELETE text to exact 'DELETE'
      await tester.enterText(textFields.at(0), 'DELETE');
      await tester.tap(find.byType(PrivacyDangerButton));
      await tester.pumpAndSettle();

      expect(find.text(SettingsPrivacyStrings.typeDeleteError), findsNothing);
      expect(find.text(SettingsPrivacyStrings.passwordError), findsOneWidget);

      // Fix password to 'demo123'
      await tester.enterText(textFields.at(1), 'demo123');
      await tester.tap(find.byType(PrivacyDangerButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Navigates to progress screen
      expect(find.byType(DeleteAccountProgressScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.settingsDeleteAccountProgressPath);
    });

    testWidgets('Cancel button on confirm screen pops back', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountPath,
      );

      await tester.tap(find.widgetWithText(PrivacyDangerButton, SettingsPrivacyStrings.continueButton));
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountConfirmScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(SecondaryButton, SettingsPrivacyStrings.cancelButton));
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountScreen), findsOneWidget);
    });
  });

  group('Delete Progress & Full Deletion Run (PS6/PS7)', () {
    testWidgets('Full staged deletion run clears all 5 repositories and ends on /account-deleted', (
      WidgetTester tester,
    ) async {
      final (
        ClientsRepository clientsRepo,
        ProjectsRepository projectsRepo,
        ExpensesRepository expensesRepo,
        FriendsRepository friendsRepo,
        SettingsRepository settingsRepo,
        GoRouter router,
      ) = await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountProgressPath,
        settle: false,
      );

      // Verify repositories initial state is non-empty
      expect(clientsRepo.clients.isNotEmpty, isTrue);
      expect(projectsRepo.projects.isNotEmpty, isTrue);
      expect(expensesRepo.expenses.isNotEmpty, isTrue);
      expect(friendsRepo.rawFriends.isNotEmpty, isTrue);

      // Modify some settings to verify reset later
      settingsRepo.setPin('1234');
      settingsRepo.setGoogleConnected(true);
      expect(settingsRepo.pinEnabled, isTrue);
      expect(settingsRepo.googleConnected, isTrue);

      expect(find.byType(DeleteAccountProgressScreen), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.deletingAccountTitle), findsOneWidget);

      // Verify PopScope cannot pop during progress
      final PopScope popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      // Advance through the staged ticks (5 steps * 500ms = 2500ms)
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 600));
      }
      await tester.pumpAndSettle();

      // Should land on AccountDeletedScreen
      expect(find.byType(AccountDeletedScreen), findsOneWidget);
      expect(router.state.uri.toString(), AppRoutes.accountDeletedPath);
      expect(find.text(SettingsPrivacyStrings.accountDeletedTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.accountDeletedBody), findsOneWidget);

      // Check all repositories are completely empty / reset
      expect(clientsRepo.clients, isEmpty);
      expect(projectsRepo.projects, isEmpty);
      expect(projectsRepo.tasks, isEmpty);
      expect(projectsRepo.payments, isEmpty);
      expect(expensesRepo.expenses, isEmpty);
      expect(friendsRepo.rawFriends, isEmpty);
      expect(friendsRepo.transactions, isEmpty);
      expect(friendsRepo.settlements, isEmpty);

      expect(settingsRepo.pinEnabled, isFalse);
      expect(settingsRepo.pin, isNull);
      expect(settingsRepo.sessions, isEmpty);
      expect(settingsRepo.googleConnected, isFalse);
      expect(settingsRepo.profile.name, SettingsRepository.defaultProfile.name);
      expect(settingsRepo.categories, SettingsRepository.defaultCategories);

      // Tap [Back to welcome] -> /welcome
      await tester.tap(find.widgetWithText(PrimaryButton, SettingsPrivacyStrings.backToWelcomeButton));
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), AppRoutes.welcomePath);

      // Navigating back to /clients shows an empty list
      router.go(AppRoutes.clientsPath);
      await tester.pumpAndSettle();
      expect(find.byType(ClientsListScreen), findsOneWidget);
      expect(find.text('0 clients in your workspace'), findsOneWidget);
    });
  });

  group('Data Usage Screen (PS10) Tests', () {
    testWidgets('DataUsageScreen renders transparency chips, category cards, and delete anytime info', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDataUsagePath,
      );

      expect(find.byType(DataUsageScreen), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.howWeUseDataScreenTitle), findsOneWidget);

      // Chips
      expect(find.text(SettingsPrivacyStrings.chipNeverSold), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.chipNoAds), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.chipEncrypted), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.chipDeletable), findsOneWidget);

      // Cards
      expect(find.text(SettingsPrivacyStrings.profileTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.profileUsedFor), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.clientsProjectsTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.clientsProjectsUsedFor), findsOneWidget);

      // Scroll for the remaining cards
      await tester.scrollUntilVisible(find.text(SettingsPrivacyStrings.paymentsExpensesTitle), 150);
      expect(find.text(SettingsPrivacyStrings.paymentsExpensesTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.paymentsExpensesUsedFor), findsOneWidget);

      await tester.scrollUntilVisible(find.text(SettingsPrivacyStrings.appSettingsTitle), 150);
      expect(find.text(SettingsPrivacyStrings.appSettingsTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.appSettingsUsedFor), findsOneWidget);

      // Delete anytime
      await tester.scrollUntilVisible(find.text(SettingsPrivacyStrings.deleteAnytimeTitle), 150);
      expect(find.text(SettingsPrivacyStrings.deleteAnytimeTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.deleteAnytimeInApp), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.deleteAnytimeWeb), findsOneWidget);
    });
  });

  group('360x800 Phone Surface Tests (No Overflow)', () {
    const Size smallSurface = Size(360, 800);

    testWidgets('PrivacyDataScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsPrivacyDataPath,
        surfaceSize: smallSurface,
      );
      expect(find.byType(PrivacyDataScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DataUsageScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDataUsagePath,
        surfaceSize: smallSurface,
      );
      expect(find.byType(DataUsageScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeleteAccountScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountPath,
        surfaceSize: smallSurface,
      );
      expect(find.byType(DeleteAccountScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeleteAccountConfirmScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountConfirmPath,
        surfaceSize: smallSurface,
      );
      expect(find.byType(DeleteAccountConfirmScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeleteAccountProgressScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.settingsDeleteAccountProgressPath,
        surfaceSize: smallSurface,
        settle: false,
      );
      expect(find.byType(DeleteAccountProgressScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AccountDeletedScreen on 360x800 renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        initialLocation: AppRoutes.accountDeletedPath,
        surfaceSize: smallSurface,
      );
      expect(find.byType(AccountDeletedScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
