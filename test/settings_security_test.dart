import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/notifications_screen.dart';
import 'package:dfile_mobile/features/settings/security_screen.dart';
import 'package:dfile_mobile/features/settings/settings_security_strings.dart';
import 'package:dfile_mobile/features/settings/widgets/security_pin_sheet.dart';
import 'package:dfile_mobile/features/settings/widgets/settings_switch.dart';
import 'package:dfile_mobile/features/settings/widgets/settings_toggle_row.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(SettingsRepository, GoRouter)> pumpSecurityApp(
    WidgetTester tester, {
    required String initialLocation,
    SettingsRepository? settingsRepository,
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
    final SettingsRepository settingsRepo =
        settingsRepository ?? SettingsRepository();
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

  group('Security Screen (ST8 & ST9) Tests', () {
    testWidgets(
      'PIN enable flow: switch -> sheet -> 4 digits -> saved -> switch on + Change PIN row visible',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpSecurityApp(
          tester,
          initialLocation: AppRoutes.settingsSecurityPath,
        );

        expect(find.byType(SecurityScreen), findsOneWidget);
        expect(repo.pinEnabled, isFalse);
        expect(find.text(SettingsSecurityStrings.changePin), findsNothing);

        // Tap Numeric PIN lock switch to turn it on
        final Finder pinRow = find.widgetWithText(
          SettingsToggleRow,
          SettingsSecurityStrings.numericPinLock,
        );
        final Finder pinSwitch = find.descendant(
          of: pinRow,
          matching: find.byType(SettingsSwitch),
        );
        await tester.tap(pinSwitch);
        await tester.pumpAndSettle();

        // PIN sheet is open
        expect(find.byType(SecurityPinSheet), findsOneWidget);
        expect(
          find.text(SettingsSecurityStrings.choosePinTitle),
          findsOneWidget,
        );
        expect(
          find.text(SettingsSecurityStrings.pinSheetSubtitle),
          findsOneWidget,
        );

        // Save PIN button is initially disabled
        final Finder saveBtn = find.widgetWithText(
          PrimaryButton,
          SettingsSecurityStrings.savePin,
        );
        expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNull);

        // Enter 4 digits: 1, 2, 3, 4
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('4'));
        await tester.pump();

        // Save button is now enabled
        expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);

        // Tap Save PIN
        await tester.tap(saveBtn);
        await tester.pump();

        // Toast "PIN saved" is shown
        expect(
          find.text(SettingsSecurityStrings.pinSavedToast),
          findsOneWidget,
        );
        await tester.pumpAndSettle();

        // Sheet is dismissed
        expect(find.byType(SecurityPinSheet), findsNothing);

        // Repository updated and switch is on
        expect(repo.pinEnabled, isTrue);
        expect(repo.pin, '1234');

        // "Change PIN" row is now visible
        expect(find.text(SettingsSecurityStrings.changePin), findsOneWidget);
      },
    );

    testWidgets('Closing the PIN sheet without saving keeps it off', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpSecurityApp(
        tester,
        initialLocation: AppRoutes.settingsSecurityPath,
      );

      final Finder pinRow = find.widgetWithText(
        SettingsToggleRow,
        SettingsSecurityStrings.numericPinLock,
      );
      final Finder pinSwitch = find.descendant(
        of: pinRow,
        matching: find.byType(SettingsSwitch),
      );
      await tester.tap(pinSwitch);
      await tester.pumpAndSettle();

      expect(find.byType(SecurityPinSheet), findsOneWidget);

      // Enter some digits without saving
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('6'));
      await tester.pump();

      // Dismiss the sheet via navigator pop (simulating swipe or barrier tap)
      Navigator.of(tester.element(find.byType(SecurityPinSheet))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(SecurityPinSheet), findsNothing);
      expect(repo.pinEnabled, isFalse);
      expect(repo.pin, isNull);
      expect(find.text(SettingsSecurityStrings.changePin), findsNothing);
    });

    testWidgets('Disable clears PIN and shows toast', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpSecurityApp(
        tester,
        initialLocation: AppRoutes.settingsSecurityPath,
        settingsRepository: SettingsRepository(
          initialPinEnabled: true,
          initialPin: '9876',
        ),
      );

      expect(repo.pinEnabled, isTrue);
      expect(find.text(SettingsSecurityStrings.changePin), findsOneWidget);

      // Tap switch to turn OFF
      final Finder pinRow = find.widgetWithText(
        SettingsToggleRow,
        SettingsSecurityStrings.numericPinLock,
      );
      final Finder pinSwitch = find.descendant(
        of: pinRow,
        matching: find.byType(SettingsSwitch),
      );
      await tester.tap(pinSwitch);
      await tester.pump();

      // Toast "PIN lock disabled"
      expect(
        find.text(SettingsSecurityStrings.pinLockDisabledToast),
        findsOneWidget,
      );
      await tester.pumpAndSettle();

      expect(repo.pinEnabled, isFalse);
      expect(repo.pin, isNull);
      expect(find.text(SettingsSecurityStrings.changePin), findsNothing);
    });

    testWidgets(
      'Change PIN row opens sheet with "Change PIN" title and updates PIN',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpSecurityApp(
          tester,
          initialLocation: AppRoutes.settingsSecurityPath,
          settingsRepository: SettingsRepository(
            initialPinEnabled: true,
            initialPin: '1111',
          ),
        );

        await tester.tap(find.text(SettingsSecurityStrings.changePin));
        await tester.pumpAndSettle();

        expect(find.byType(SecurityPinSheet), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SecurityPinSheet),
            matching: find.text(SettingsSecurityStrings.changePinTitle),
          ),
          findsOneWidget,
        );

        // Enter new 4-digit PIN: 2, 2, 2, 2
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.text('2'));
          await tester.pump();
        }

        final Finder saveBtn = find.widgetWithText(
          PrimaryButton,
          SettingsSecurityStrings.savePin,
        );
        await tester.tap(saveBtn);
        await tester.pump();

        expect(
          find.text(SettingsSecurityStrings.pinSavedToast),
          findsOneWidget,
        );
        await tester.pumpAndSettle();

        expect(repo.pin, '2222');
        expect(repo.pinEnabled, isTrue);
      },
    );

    testWidgets('Physical keyboard enters digits and backspace in PIN sheet', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpSecurityApp(
        tester,
        initialLocation: AppRoutes.settingsSecurityPath,
      );

      final Finder pinRow = find.widgetWithText(
        SettingsToggleRow,
        SettingsSecurityStrings.numericPinLock,
      );
      final Finder pinSwitch = find.descendant(
        of: pinRow,
        matching: find.byType(SettingsSwitch),
      );
      await tester.tap(pinSwitch);
      await tester.pumpAndSettle();

      final Finder saveBtn = find.widgetWithText(
        PrimaryButton,
        SettingsSecurityStrings.savePin,
      );

      // Send physical key digits 7, 8, 9, 0
      await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit8);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      await tester.pump();

      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);

      // Send backspace
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNull);

      // Re-enter 3
      await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
      await tester.pump();
      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);

      // Save
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.pin, '7893');
      expect(repo.pinEnabled, isTrue);
    });

    testWidgets('Backspace and the 4-digit limit in PIN sheet', (
      WidgetTester tester,
    ) async {
      await pumpSecurityApp(
        tester,
        initialLocation: AppRoutes.settingsSecurityPath,
      );

      final Finder pinRow = find.widgetWithText(
        SettingsToggleRow,
        SettingsSecurityStrings.numericPinLock,
      );
      final Finder pinSwitch = find.descendant(
        of: pinRow,
        matching: find.byType(SettingsSwitch),
      );
      await tester.tap(pinSwitch);
      await tester.pumpAndSettle();

      final Finder saveBtn = find.widgetWithText(
        PrimaryButton,
        SettingsSecurityStrings.savePin,
      );

      // Enter 4 digits: 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);

      // Extra tap on '5' is ignored (stays 4 digits)
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);

      // Tap Backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      // Now 3 digits, so Save button is disabled
      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNull);

      // Tap '9' to complete 4 digits again
      await tester.tap(find.text('9'));
      await tester.pump();
      expect(tester.widget<PrimaryButton>(saveBtn).onPressed, isNotNull);
    });

    testWidgets('Fingerprint unlock switch tap keeps it off and shows toast', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpSecurityApp(
        tester,
        initialLocation: AppRoutes.settingsSecurityPath,
      );

      final Finder fpRow = find.widgetWithText(
        SettingsToggleRow,
        SettingsSecurityStrings.fingerprintUnlock,
      );
      final Finder fpSwitch = find.descendant(
        of: fpRow,
        matching: find.byType(SettingsSwitch),
      );

      await tester.tap(fpSwitch);
      await tester.pump();

      expect(
        find.text(SettingsSecurityStrings.notAvailableInDemoToast),
        findsOneWidget,
      );
      await tester.pumpAndSettle();

      expect(repo.biometricsEnabled, isFalse);
    });

    testWidgets(
      'Terminate sessions removes other sessions, shows toast, and hides button',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpSecurityApp(
          tester,
          initialLocation: AppRoutes.settingsSecurityPath,
        );

        expect(repo.sessions.length, 2);
        expect(find.text('This phone'), findsOneWidget);
        expect(find.text('Office laptop'), findsOneWidget);
        expect(
          find.text(SettingsSecurityStrings.terminateOtherSessions),
          findsOneWidget,
        );

        // Tap Terminate other sessions
        await tester.tap(
          find.text(SettingsSecurityStrings.terminateOtherSessions),
        );
        await tester.pump();

        expect(
          find.text(SettingsSecurityStrings.loggedOutOtherSessionsToast),
          findsOneWidget,
        );
        await tester.pumpAndSettle();

        // Repository now has only 1 session
        expect(repo.sessions.length, 1);
        expect(repo.sessions.first.name, 'This phone');
        expect(find.text('This phone'), findsOneWidget);
        expect(find.text('Office laptop'), findsNothing);

        // Button is now hidden
        expect(
          find.text(SettingsSecurityStrings.terminateOtherSessions),
          findsNothing,
        );
      },
    );
  });

  group('Notifications Screen (ST11) Tests', () {
    testWidgets(
      'Notification switches update prefs, show toast, and dim/disable when push is off',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpSecurityApp(
          tester,
          initialLocation: AppRoutes.settingsNotificationsPath,
        );

        expect(find.byType(NotificationsScreen), findsOneWidget);
        expect(repo.notifications.push, isTrue);
        expect(repo.notifications.deadlines, isTrue);
        expect(repo.notifications.payments, isTrue);
        expect(repo.notifications.tasks, isFalse);

        // Toggle Task updates switch to ON
        final Finder taskRow = find.widgetWithText(
          SettingsToggleRow,
          SettingsSecurityStrings.taskUpdates,
        );
        final Finder taskSwitch = find.descendant(
          of: taskRow,
          matching: find.byType(SettingsSwitch),
        );

        await tester.tap(taskSwitch);
        await tester.pump();

        expect(
          find.text(SettingsSecurityStrings.notificationPreferencesSavedToast),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 4));
        expect(
          find.text(SettingsSecurityStrings.notificationPreferencesSavedToast),
          findsNothing,
        );

        expect(repo.notifications.tasks, isTrue);

        // Toggle Push master switch to OFF
        final Finder pushRow = find.widgetWithText(
          SettingsToggleRow,
          SettingsSecurityStrings.pushNotificationAlerts,
        );
        final Finder pushSwitch = find.descendant(
          of: pushRow,
          matching: find.byType(SettingsSwitch),
        );

        await tester.tap(pushSwitch);
        await tester.pump();

        expect(
          find.text(SettingsSecurityStrings.notificationPreferencesSavedToast),
          findsOneWidget,
        );
        await tester.pumpAndSettle();

        expect(repo.notifications.push, isFalse);

        // Sub switches should now be disabled
        final SettingsToggleRow deadlineRow = tester.widget(
          find.widgetWithText(
            SettingsToggleRow,
            SettingsSecurityStrings.projectDeadlines,
          ),
        );
        expect(deadlineRow.enabled, isFalse);

        final SettingsToggleRow paymentRow = tester.widget(
          find.widgetWithText(
            SettingsToggleRow,
            SettingsSecurityStrings.paymentReminders,
          ),
        );
        expect(paymentRow.enabled, isFalse);

        final SettingsToggleRow taskRowWidget = tester.widget(
          find.widgetWithText(
            SettingsToggleRow,
            SettingsSecurityStrings.taskUpdates,
          ),
        );
        expect(taskRowWidget.enabled, isFalse);

        // Tapping disabled switch does not change state
        await tester.tap(taskSwitch);
        await tester.pump();
        expect(repo.notifications.tasks, isTrue);
      },
    );
  });

  group('360x800 Layout & Overflow Tests', () {
    testWidgets(
      'Security screen, PIN sheet, and Notifications screen render on 360x800 without overflow',
      (WidgetTester tester) async {
        // 1. Security Screen at 360x800
        final (_, GoRouter router) = await pumpSecurityApp(
          tester,
          initialLocation: AppRoutes.settingsSecurityPath,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(SecurityScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. Open PIN sheet at 360x800
        final Finder pinRow = find.widgetWithText(
          SettingsToggleRow,
          SettingsSecurityStrings.numericPinLock,
        );
        final Finder pinSwitch = find.descendant(
          of: pinRow,
          matching: find.byType(SettingsSwitch),
        );
        await tester.tap(pinSwitch);
        await tester.pumpAndSettle();

        expect(find.byType(SecurityPinSheet), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Dismiss sheet
        Navigator.of(tester.element(find.byType(SecurityPinSheet))).pop();
        await tester.pumpAndSettle();

        // 3. Notifications Screen at 360x800
        router.go(AppRoutes.settingsNotificationsPath);
        await tester.pumpAndSettle();

        expect(find.byType(NotificationsScreen), findsOneWidget);
        expect(
          find.text(SettingsSecurityStrings.changesSavedAutomatically),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
