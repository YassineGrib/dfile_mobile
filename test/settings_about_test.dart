import 'dart:convert';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/about_screen.dart';
import 'package:dfile_mobile/features/settings/data/backup_builder.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/integrations_screen.dart';
import 'package:dfile_mobile/features/settings/policy_screen.dart';
import 'package:dfile_mobile/features/settings/settings_about_strings.dart';
import 'package:dfile_mobile/features/settings/support_ticket_screen.dart';
import 'package:dfile_mobile/features/settings/widgets/about_sign_out_sheet.dart';
import 'package:dfile_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Backup Builder Unit Tests', () {
    test('buildWorkspaceBackupJson produces pretty-printed JSON with expected keys, client name, and payment amount', () {
      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
      final ExpensesRepository expensesRepo = ExpensesRepository();
      final FriendsRepository friendsRepo = FriendsRepository();
      final SettingsRepository settingsRepo = SettingsRepository();

      final String jsonString = buildWorkspaceBackupJson(
        clientsRepository: clientsRepo,
        projectsRepository: projectsRepo,
        expensesRepository: expensesRepo,
        friendsRepository: friendsRepo,
        settingsRepository: settingsRepo,
      );

      // Check it decodes properly
      final dynamic decoded = jsonDecode(jsonString);
      expect(decoded, isA<Map<String, dynamic>>());
      final Map<String, dynamic> map = decoded as Map<String, dynamic>;

      // Verify top-level keys
      expect(map.containsKey('clients'), isTrue);
      expect(map.containsKey('projects'), isTrue);
      expect(map.containsKey('payments'), isTrue);
      expect(map.containsKey('expenses'), isTrue);
      expect(map.containsKey('friends'), isTrue);
      expect(map.containsKey('settings'), isTrue);

      // Verify settings nested keys
      final dynamic settingsMap = map['settings'];
      expect(settingsMap, isA<Map<String, dynamic>>());
      final Map<String, dynamic> settings = settingsMap as Map<String, dynamic>;
      expect(settings.containsKey('profile'), isTrue);
      expect(settings.containsKey('categories'), isTrue);
      expect(settings.containsKey('language'), isTrue);

      // Verify client name appears (e.g. Sarah Benali)
      expect(jsonString, contains('Sarah Benali'));

      // Verify payment amount appears (e.g. 60000)
      expect(jsonString, contains('60000'));
    });
  });

  group('Settings About & Integrations UI Tests', () {
    Future<(SettingsRepository, GoRouter)> pumpAboutApp(
      WidgetTester tester, {
      required String initialLocation,
      Size surfaceSize = const Size(390, 844),
    }) async {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
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
      await tester.pumpAndSettle();

      return (settingsRepo, router);
    }

    testWidgets('Integrations (ST10) Google Calendar toggle and toasts', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpAboutApp(
        tester,
        initialLocation: AppRoutes.settingsIntegrationsPath,
      );

      expect(find.byType(IntegrationsScreen), findsOneWidget);
      expect(repo.googleConnected, isFalse);
      expect(find.text(SettingsAboutStrings.connectAccount), findsOneWidget);
      expect(find.text(SettingsAboutStrings.disconnect), findsNothing);

      // Tap [Connect account]
      await tester.tap(find.text(SettingsAboutStrings.connectAccount));
      await tester.pumpAndSettle();

      expect(repo.googleConnected, isTrue);
      expect(find.text(SettingsAboutStrings.googleLinkedToast), findsOneWidget);
      expect(find.text(SettingsAboutStrings.disconnect), findsOneWidget);
      expect(find.text(SettingsAboutStrings.connectAccount), findsNothing);

      // Tap [Disconnect]
      await tester.tap(find.text(SettingsAboutStrings.disconnect));
      await tester.pumpAndSettle();

      expect(repo.googleConnected, isFalse);
      expect(
        find.text(SettingsAboutStrings.googleUnlinkedToast),
        findsOneWidget,
      );
      expect(find.text(SettingsAboutStrings.connectAccount), findsOneWidget);
      expect(find.text(SettingsAboutStrings.disconnect), findsNothing);
    });

    testWidgets(
      'Integrations (ST10) Download backup copies JSON to clipboard and toasts',
      (WidgetTester tester) async {
        String? clipboardText;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              clipboardText =
                  (methodCall.arguments as Map<dynamic, dynamic>)['text']
                      as String?;
              return null;
            }
            if (methodCall.method == 'Clipboard.getData') {
              return <String, dynamic>{'text': clipboardText};
            }
            return null;
          },
        );

        await pumpAboutApp(
          tester,
          initialLocation: AppRoutes.settingsIntegrationsPath,
        );

        // Tap [Download workspace backup (JSON)]
        await tester.tap(find.text(SettingsAboutStrings.downloadBackupButton));
        await tester.pump();

        // Check toast
        expect(
          find.text(SettingsAboutStrings.backupCopiedToast),
          findsOneWidget,
        );

        // Check clipboard content
        expect(clipboardText, isNotNull);
        final String text = clipboardText!;
        expect(text, contains('clients'));
        expect(text, contains('projects'));
        expect(text, contains('payments'));
        expect(text, contains('Sarah Benali'));
        expect(text, contains('60000'));

        final ClipboardData? data = await Clipboard.getData(
          Clipboard.kTextPlain,
        );
        expect(data, isNotNull);
        expect(data!.text, isNotNull);
        expect(data.text, contains('clients'));
        expect(data.text, contains('Sarah Benali'));
        expect(data.text, contains('60000'));
      },
    );

    testWidgets(
      'About (ST12) rows navigate to Support, Privacy, Terms and back',
      (WidgetTester tester) async {
        await pumpAboutApp(
          tester,
          initialLocation: AppRoutes.settingsAboutPath,
        );

        expect(find.byType(AboutScreen), findsOneWidget);
        expect(find.text(SettingsAboutStrings.appName), findsOneWidget);
        expect(find.text(SettingsAboutStrings.appVersion), findsOneWidget);
        expect(find.text(SettingsAboutStrings.appTagline), findsOneWidget);

        // 1. Submit support ticket -> /settings/support
        await tester.tap(find.text(SettingsAboutStrings.supportTicketRowTitle));
        await tester.pumpAndSettle();
        expect(find.byType(SupportTicketScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(AboutScreen), findsOneWidget);

        // 2. Privacy policy -> /settings/privacy
        await tester.tap(find.text(SettingsAboutStrings.privacyPolicyRowTitle));
        await tester.pumpAndSettle();
        expect(find.byType(PolicyScreen), findsOneWidget);
        expect(
          find.text(SettingsAboutStrings.privacyPolicyHeading),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(AboutScreen), findsOneWidget);

        // 3. Terms and conditions -> /settings/terms
        await tester.tap(
          find.text(SettingsAboutStrings.termsConditionsRowTitle),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PolicyScreen), findsOneWidget);
        expect(
          find.text(SettingsAboutStrings.termsConditionsHeading),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(AboutScreen), findsOneWidget);
      },
    );

    testWidgets(
      'About (ST12, ST14) Sign out confirm sheet Cancel stays and Confirm goes to welcome',
      (WidgetTester tester) async {
        await pumpAboutApp(
          tester,
          initialLocation: AppRoutes.settingsAboutPath,
        );

        // Tap [Sign out] row
        await tester.tap(find.text(SettingsAboutStrings.signOutRowTitle));
        await tester.pumpAndSettle();

        // Sheet is visible
        expect(find.byType(AboutSignOutSheetContent), findsOneWidget);
        expect(
          find.text(SettingsAboutStrings.signOutSheetTitle),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAboutStrings.signOutSheetSubtitle),
          findsOneWidget,
        );

        // Tap [Cancel]
        await tester.tap(find.text(SettingsAboutStrings.cancelButton));
        await tester.pumpAndSettle();

        // Sheet dismissed, still on AboutScreen
        expect(find.byType(AboutSignOutSheetContent), findsNothing);
        expect(find.byType(AboutScreen), findsOneWidget);

        // Tap [Sign out] row again
        await tester.tap(find.text(SettingsAboutStrings.signOutRowTitle));
        await tester.pumpAndSettle();
        expect(find.byType(AboutSignOutSheetContent), findsOneWidget);

        // Tap confirm [Sign out]
        await tester.tap(
          find.descendant(
            of: find.byType(AboutSignOutSheetContent),
            matching: find.text(SettingsAboutStrings.signOutConfirmButton),
          ),
        );
        await tester.pumpAndSettle();

        // Navigated to /welcome screen
        expect(find.byType(AboutScreen), findsNothing);
      },
    );

    testWidgets(
      'Support ticket (ST13) validation, save, navigation, and toast',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpAboutApp(
          tester,
          initialLocation: AppRoutes.settingsSupportPath,
        );

        expect(find.byType(SupportTicketScreen), findsOneWidget);
        expect(repo.supportTickets, isEmpty);

        // Tap [Submit ticket] without filling fields
        await tester.tap(find.text(SettingsAboutStrings.submitTicketButton));
        await tester.pumpAndSettle();

        // Inline errors appear
        expect(
          find.text(SettingsAboutStrings.subjectRequiredError),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAboutStrings.messageRequiredError),
          findsOneWidget,
        );
        expect(repo.supportTickets, isEmpty);

        // Enter subject only
        await tester.enterText(
          find.widgetWithText(
            TextField,
            SettingsAboutStrings.subjectPlaceholder,
          ),
          'Google Calendar sync error',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(SettingsAboutStrings.submitTicketButton));
        await tester.pumpAndSettle();

        expect(
          find.text(SettingsAboutStrings.subjectRequiredError),
          findsNothing,
        );
        expect(
          find.text(SettingsAboutStrings.messageRequiredError),
          findsOneWidget,
        );
        expect(repo.supportTickets, isEmpty);

        // Enter message details
        await tester.enterText(
          find.widgetWithText(
            TextField,
            SettingsAboutStrings.messagePlaceholder,
          ),
          'Calendar deadlines do not sync over mobile network.',
        );
        await tester.pumpAndSettle();

        // Submit valid ticket
        await tester.tap(find.text(SettingsAboutStrings.submitTicketButton));
        await tester.pumpAndSettle();

        // Ticket is recorded in repository
        expect(repo.supportTickets.length, 1);
        final SupportTicket ticket = repo.supportTickets.first;
        expect(ticket.subject, 'Google Calendar sync error');
        expect(
          ticket.message,
          'Calendar deadlines do not sync over mobile network.',
        );

        // Toast is shown
        expect(find.text(SettingsAboutStrings.ticketSentToast), findsOneWidget);
      },
    );

    testWidgets('Both policy pages (ST15) render full content properly', (
      WidgetTester tester,
    ) async {
      // 1. Privacy policy
      final (_, GoRouter router) = await pumpAboutApp(
        tester,
        initialLocation: AppRoutes.settingsPrivacyPath,
      );

      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(
        find.text(SettingsAboutStrings.privacyPolicyTitle),
        findsOneWidget,
      );
      expect(
        find.text(SettingsAboutStrings.privacyPolicyHeading),
        findsOneWidget,
      );
      expect(find.text(SettingsAboutStrings.privacyStoreTitle), findsOneWidget);
      expect(find.text(SettingsAboutStrings.privacyStoreBody), findsOneWidget);
      expect(find.text(SettingsAboutStrings.privacyNeverTitle), findsOneWidget);
      expect(find.text(SettingsAboutStrings.privacyNeverBody), findsOneWidget);
      expect(
        find.text(SettingsAboutStrings.privacyChoicesTitle),
        findsOneWidget,
      );
      expect(
        find.text(SettingsAboutStrings.privacyChoicesBody),
        findsOneWidget,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text(SettingsAboutStrings.policyLastUpdated), findsOneWidget);

      // 2. Terms and conditions
      router.go(AppRoutes.settingsTermsPath);
      await tester.pumpAndSettle();

      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(
        find.text(SettingsAboutStrings.termsConditionsTitle),
        findsOneWidget,
      );
      expect(
        find.text(SettingsAboutStrings.termsConditionsHeading),
        findsOneWidget,
      );
      expect(find.text(SettingsAboutStrings.termsLicenseTitle), findsOneWidget);
      expect(find.text(SettingsAboutStrings.termsLicenseBody), findsOneWidget);
      expect(find.text(SettingsAboutStrings.termsContentTitle), findsOneWidget);
      expect(find.text(SettingsAboutStrings.termsContentBody), findsOneWidget);
      expect(find.text(SettingsAboutStrings.termsUsageTitle), findsOneWidget);
      expect(find.text(SettingsAboutStrings.termsUsageBody), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text(SettingsAboutStrings.policyLastUpdated), findsOneWidget);
    });

    testWidgets('360x800 surface renders all screens without overflow', (
      WidgetTester tester,
    ) async {
      // 1. Integrations on 360x800
      final (_, GoRouter router) = await pumpAboutApp(
        tester,
        initialLocation: AppRoutes.settingsIntegrationsPath,
        surfaceSize: const Size(360, 800),
      );
      expect(find.byType(IntegrationsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. About on 360x800
      router.go(AppRoutes.settingsAboutPath);
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Sign out sheet on 360x800
      await tester.tap(find.text(SettingsAboutStrings.signOutRowTitle));
      await tester.pumpAndSettle();
      expect(find.byType(AboutSignOutSheetContent), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(SettingsAboutStrings.cancelButton));
      await tester.pumpAndSettle();

      // 4. Support ticket on 360x800
      router.go(AppRoutes.settingsSupportPath);
      await tester.pumpAndSettle();
      expect(find.byType(SupportTicketScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 5. Privacy on 360x800
      router.go(AppRoutes.settingsPrivacyPath);
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 6. Terms on 360x800
      router.go(AppRoutes.settingsTermsPath);
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
