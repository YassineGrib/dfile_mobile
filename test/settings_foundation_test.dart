import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/app_icons.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/more/more_strings.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/about_screen.dart';
import 'package:dfile_mobile/features/settings/categories_screen.dart';
import 'package:dfile_mobile/features/settings/change_password_screen.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/edit_profile_screen.dart';
import 'package:dfile_mobile/features/settings/integrations_screen.dart';
import 'package:dfile_mobile/features/settings/legal_clauses_screen.dart';
import 'package:dfile_mobile/features/settings/notifications_screen.dart';
import 'package:dfile_mobile/features/settings/policy_screen.dart';
import 'package:dfile_mobile/features/settings/preferences_screen.dart';
import 'package:dfile_mobile/features/settings/privacy_data_screen.dart';
import 'package:dfile_mobile/features/settings/settings_privacy_strings.dart';
import 'package:dfile_mobile/features/settings/security_screen.dart';
import 'package:dfile_mobile/features/settings/settings_screen.dart';
import 'package:dfile_mobile/features/settings/settings_strings.dart';
import 'package:dfile_mobile/features/settings/support_ticket_screen.dart';
import 'package:dfile_mobile/features/settings/widgets/widgets.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Settings Enums, Models & SettingsRepository Tests', () {
    test('AppLanguage & AppThemeMode & PolicyKind enums have expected values', () {
      expect(AppLanguage.en.code, 'en');
      expect(AppLanguage.en.label, 'English');
      expect(AppLanguage.ar.code, 'ar');
      expect(AppLanguage.ar.label, 'العربية');
      expect(AppLanguage.fromCode('ar'), AppLanguage.ar);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.en);

      expect(AppThemeMode.light.code, 'light');
      expect(AppThemeMode.dark.code, 'dark');
      expect(AppThemeMode.system.code, 'system');
      expect(AppThemeMode.fromCode('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromCode('other'), AppThemeMode.light);

      expect(PolicyKind.privacy.name, 'privacy');
      expect(PolicyKind.terms.name, 'terms');
    });

    test('Data models copyWith, equality, hashCode, and toString behave correctly', () {
      const UserProfile p1 = UserProfile(
        name: 'Yassine',
        designation: 'Designer',
        email: 'y@d.dz',
        phone: '123',
        address: 'Algiers',
      );
      final UserProfile p2 = p1.copyWith(name: 'Yassine 2');
      expect(p2.name, 'Yassine 2');
      expect(p2.designation, 'Designer');
      expect(p1 == p1.copyWith(), isTrue);
      expect(p1.hashCode, p1.copyWith().hashCode);
      expect(p1.toString(), contains('Yassine'));

      const DeviceSession s1 = DeviceSession(
        id: '1',
        name: 'Phone',
        detail: 'Active',
        isCurrent: true,
      );
      final DeviceSession s2 = s1.copyWith(isCurrent: false);
      expect(s2.isCurrent, isFalse);
      expect(s1 == s1.copyWith(), isTrue);
      expect(s1.toString(), contains('Phone'));

      final DateTime now = DateTime.now();
      final SupportTicket t1 = SupportTicket(
        id: 't1',
        subject: 'Bug',
        message: 'Help',
        createdAt: now,
      );
      final SupportTicket t2 = t1.copyWith(subject: 'Feedback');
      expect(t2.subject, 'Feedback');
      expect(t1 == t1.copyWith(), isTrue);
      expect(t1.toString(), contains('Bug'));

      const NotificationPrefs n1 = NotificationPrefs(
        push: true,
        deadlines: true,
        payments: true,
        tasks: false,
      );
      final NotificationPrefs n2 = n1.copyWith(tasks: true);
      expect(n2.tasks, isTrue);
      expect(n1 == n1.copyWith(), isTrue);
      expect(n1.toString(), contains('push: true'));
    });

    test('SettingsRepository in-memory default state matches SPEC.md exactly', () {
      final SettingsRepository repo = SettingsRepository();

      expect(repo.profile.name, 'Yassine G.');
      expect(repo.profile.designation, 'Independent designer');
      expect(repo.profile.email, 'yassine@decabyte.dz');
      expect(repo.profile.phone, '+213 550 12 34 56');
      expect(repo.profile.address, '12 Rue Didouche Mourad, Algiers');

      expect(repo.language, AppLanguage.en);
      expect(repo.themeMode, AppThemeMode.light);

      expect(repo.categories, <String>[
        'Development',
        'Design',
        'Branding',
        'Marketing',
        'Consulting',
      ]);

      expect(repo.legalClauses, contains('1. Payment: 50% upfront'));
      expect(repo.legalClauses, contains('2. Revisions: up to two rounds'));
      expect(repo.legalClauses, contains('3. Ownership: files transfer'));

      expect(repo.pinEnabled, isFalse);
      expect(repo.pin, isNull);
      expect(repo.biometricsEnabled, isFalse);

      expect(repo.sessions.length, 2);
      expect(repo.sessions[0].name, 'This phone');
      expect(repo.sessions[0].isCurrent, isTrue);
      expect(repo.sessions[1].name, 'Office laptop');
      expect(repo.sessions[1].isCurrent, isFalse);

      expect(repo.googleConnected, isFalse);

      expect(repo.notifications.push, isTrue);
      expect(repo.notifications.deadlines, isTrue);
      expect(repo.notifications.payments, isTrue);
      expect(repo.notifications.tasks, isFalse);

      expect(repo.supportTickets, isEmpty);
      expect(repo.checkPassword('demo123'), isTrue);
      expect(repo.checkPassword('wrong'), isFalse);
    });

    test('updateProfile, setLanguage, and setThemeMode notify listeners', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      const UserProfile updated = UserProfile(
        name: 'Karim B.',
        designation: 'Architect',
        email: 'karim@decabyte.dz',
        phone: '+213 555 00 11 22',
        address: 'Oran, Algeria',
      );
      repo.updateProfile(updated);
      expect(repo.profile, updated);
      expect(notifyCount, 1);

      repo.setLanguage(AppLanguage.ar);
      expect(repo.language, AppLanguage.ar);
      expect(notifyCount, 2);

      repo.setThemeMode(AppThemeMode.dark);
      expect(repo.themeMode, AppThemeMode.dark);
      expect(notifyCount, 3);
    });

    test('addCategory rejects empty and case-insensitive duplicates, trims whitespace', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      // Empty / whitespace
      expect(repo.addCategory(''), isFalse);
      expect(repo.addCategory('   '), isFalse);
      expect(notifyCount, 0);

      // Duplicate case-insensitive
      expect(repo.addCategory('design'), isFalse);
      expect(repo.addCategory('  DESIGN  '), isFalse);
      expect(repo.addCategory('Consulting'), isFalse);
      expect(notifyCount, 0);

      // Valid new category with leading/trailing spaces
      expect(repo.addCategory('  Mobile Apps  '), isTrue);
      expect(repo.categories.contains('Mobile Apps'), isTrue);
      expect(notifyCount, 1);
    });

    test('removeCategory removes matching category case-insensitively', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      expect(repo.removeCategory('Nonexistent'), isFalse);
      expect(notifyCount, 0);

      expect(repo.removeCategory('design'), isTrue);
      expect(repo.categories.contains('Design'), isFalse);
      expect(notifyCount, 1);
    });

    test('setLegalClauses updates clauses and notifies listeners', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      repo.setLegalClauses('New custom clause text');
      expect(repo.legalClauses, 'New custom clause text');
      expect(notifyCount, 1);
    });

    test('setPin validates 4 digits and null clears PIN and disables lock', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      // Invalid PINs throw ArgumentError
      expect(() => repo.setPin('123'), throwsArgumentError);
      expect(() => repo.setPin('12345'), throwsArgumentError);
      expect(() => repo.setPin('abcd'), throwsArgumentError);
      expect(() => repo.setPin('12a4'), throwsArgumentError);
      expect(notifyCount, 0);

      // Valid PIN
      repo.setPin('4321');
      expect(repo.pin, '4321');
      expect(repo.pinEnabled, isTrue);
      expect(notifyCount, 1);

      // Null clears PIN
      repo.setPin(null);
      expect(repo.pin, isNull);
      expect(repo.pinEnabled, isFalse);
      expect(notifyCount, 2);

      // setPinEnabled(false) clears PIN
      repo.setPin('9876');
      expect(repo.pin, '9876');
      repo.setPinEnabled(false);
      expect(repo.pin, isNull);
      expect(repo.pinEnabled, isFalse);
    });

    test('setBiometrics toggles biometricsEnabled and notifies', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      repo.setBiometrics(true);
      expect(repo.biometricsEnabled, isTrue);
      expect(notifyCount, 1);

      repo.setBiometricsEnabled(false);
      expect(repo.biometricsEnabled, isFalse);
      expect(notifyCount, 2);
    });

    test('terminateOtherSessions keeps current session and removes others', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      expect(repo.sessions.length, 2);
      repo.terminateOtherSessions();
      expect(repo.sessions.length, 1);
      expect(repo.sessions.first.isCurrent, isTrue);
      expect(repo.sessions.first.name, 'This phone');
      expect(notifyCount, 1);
    });

    test('setGoogleConnected, updateNotifications, and addSupportTicket notify listeners', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      repo.setGoogleConnected(true);
      expect(repo.googleConnected, isTrue);
      expect(notifyCount, 1);

      const NotificationPrefs updatedPrefs = NotificationPrefs(
        push: false,
        deadlines: false,
        payments: false,
        tasks: false,
      );
      repo.updateNotifications(updatedPrefs);
      expect(repo.notifications.push, isFalse);
      expect(notifyCount, 2);

      final SupportTicket ticket = SupportTicket(
        id: 't-101',
        subject: 'Cannot sync',
        message: 'Sync fails on wifi',
        createdAt: DateTime.now(),
      );
      repo.addSupportTicket(ticket);
      expect(repo.supportTickets.length, 1);
      expect(repo.supportTickets.first.id, 't-101');
      expect(notifyCount, 3);
    });

    test('checkPassword and changePassword validate and update password', () {
      final SettingsRepository repo = SettingsRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      expect(repo.checkPassword('demo123'), isTrue);
      expect(repo.checkPassword('wrong123'), isFalse);

      repo.changePassword('newpass456');
      expect(notifyCount, 1);
      expect(repo.checkPassword('demo123'), isFalse);
      expect(repo.checkPassword('newpass456'), isTrue);
    });
  });

  group('Shared Widgets Tests', () {
    testWidgets('SettingsSwitch toggles value when tapped and ignores when disabled', (
      WidgetTester tester,
    ) async {
      bool switchValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SettingsSwitch(
                  value: switchValue,
                  onChanged: (bool val) {
                    setState(() => switchValue = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(switchValue, isFalse);
      await tester.tap(find.byType(SettingsSwitch));
      await tester.pumpAndSettle();
      expect(switchValue, isTrue);

      await tester.tap(find.byType(SettingsSwitch));
      await tester.pumpAndSettle();
      expect(switchValue, isFalse);

      // When disabled, tap is ignored
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSwitch(
              value: false,
              enabled: false,
              onChanged: (bool val) => switchValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SettingsSwitch));
      await tester.pumpAndSettle();
      expect(switchValue, isFalse);
    });

    testWidgets('SettingsRow renders icon, title, subtitle, value and taps', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsRow(
              iconData: AppIcons.user,
              title: 'Account Row',
              subtitle: 'Sub text',
              value: 'Active',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.user), findsOneWidget);
      expect(find.text('Account Row'), findsOneWidget);
      expect(find.text('Sub text'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(AppIcons.chevronRight), findsOneWidget);

      await tester.tap(find.text('Account Row'));
      expect(tapped, isTrue);
    });

    testWidgets('SettingsToggleRow renders title, subtitle, and switches value', (
      WidgetTester tester,
    ) async {
      bool toggleVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SettingsToggleRow(
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts',
                  value: toggleVal,
                  onChanged: (bool val) => setState(() => toggleVal = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Receive alerts'), findsOneWidget);
      expect(toggleVal, isFalse);

      await tester.tap(find.byType(SettingsSwitch));
      await tester.pumpAndSettle();
      expect(toggleVal, isTrue);
    });

    testWidgets('SettingsHeader renders title, back button, and optional right action', (
      WidgetTester tester,
    ) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsHeader(
              title: 'Test Header',
              onBack: () => backTapped = true,
              rightAction: const Text('Action'),
            ),
          ),
        ),
      );

      expect(find.text('Test Header'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backTapped, isTrue);
    });

    testWidgets('SettingsGroupCard and SettingsSectionLabel render content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsGroupCard(
              children: [
                SettingsSectionLabel('WHAT TO NOTIFY'),
                Text('Inner Child'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('WHAT TO NOTIFY'), findsOneWidget);
      expect(find.text('Inner Child'), findsOneWidget);
    });
  });

  group('Settings Hub (ST1, ST16) and Routes on 390x844 Surface', () {
    Future<(SettingsRepository, GoRouter)> pumpSettingsApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.settingsPath,
      Object? extra,
      Size surfaceSize = const Size(390, 844),
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
      await tester.pumpAndSettle();

      if (extra != null) {
        router.go(initialLocation, extra: extra);
        await tester.pumpAndSettle();
      }

      return (settingsRepo, router);
    }

    testWidgets('SettingsScreen renders ST1 hub title, profile card, 7 rows, footer, and AppTabBar', (
      WidgetTester tester,
    ) async {
      await pumpSettingsApp(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text(SettingsStrings.title), findsOneWidget);

      // Profile card
      expect(find.text('Y'), findsOneWidget);
      expect(find.text('Yassine G.'), findsOneWidget);
      expect(find.text('Independent designer'), findsOneWidget);
      expect(find.text('yassine@decabyte.dz'), findsOneWidget);

      // 7 Settings rows
      expect(find.text(SettingsStrings.accountTitle), findsOneWidget);
      expect(find.text(SettingsStrings.accountSubtitle), findsOneWidget);

      expect(find.text(SettingsStrings.preferencesTitle), findsOneWidget);
      expect(find.text(SettingsStrings.preferencesSubtitle), findsOneWidget);

      expect(find.text(SettingsStrings.securityTitle), findsOneWidget);
      expect(find.text(SettingsStrings.securitySubtitle), findsOneWidget);

      expect(find.text(SettingsStrings.integrationsTitle), findsOneWidget);
      expect(find.text(SettingsStrings.integrationsSubtitle), findsOneWidget);

      expect(find.text(SettingsStrings.notificationsTitle), findsOneWidget);
      expect(find.text(SettingsStrings.notificationsSubtitle), findsOneWidget);

      expect(find.text(SettingsPrivacyStrings.privacyDataTitle), findsOneWidget);
      expect(find.text(SettingsPrivacyStrings.privacyDataSubtitle), findsOneWidget);

      expect(find.text(SettingsStrings.aboutTitle), findsOneWidget);
      expect(find.text(SettingsStrings.aboutSubtitle), findsOneWidget);

      // Footer
      await tester.scrollUntilVisible(find.text(SettingsStrings.footer), 100);
      expect(find.text(SettingsStrings.footer), findsOneWidget);
    });

    testWidgets('Tapping profile card and 7 rows navigate to their respective placeholder routes', (
      WidgetTester tester,
    ) async {
      await pumpSettingsApp(tester);

      // Profile card -> EditProfileScreen
      await tester.tap(find.text('Yassine G.'));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Account row -> EditProfileScreen
      await tester.tap(find.text(SettingsStrings.accountTitle));
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Preferences row -> PreferencesScreen
      await tester.tap(find.text(SettingsStrings.preferencesTitle));
      await tester.pumpAndSettle();
      expect(find.byType(PreferencesScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Security row -> SecurityScreen
      await tester.tap(find.text(SettingsStrings.securityTitle));
      await tester.pumpAndSettle();
      expect(find.byType(SecurityScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Integrations row -> IntegrationsScreen
      await tester.tap(find.text(SettingsStrings.integrationsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(IntegrationsScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Scroll so lower items are comfortably above the bottom navigation bar
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();

      // Notifications row -> NotificationsScreen
      await tester.tap(find.text(SettingsStrings.notificationsTitle));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Scroll again if needed after coming back
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();

      // Privacy and data row -> PrivacyDataScreen
      await tester.tap(find.text(SettingsPrivacyStrings.privacyDataTitle));
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyDataScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Scroll again if needed after coming back
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();

      // About and support row -> AboutScreen
      await tester.tap(find.text(SettingsStrings.aboutTitle));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Other placeholder routes mount cleanly and back returns to /settings', (
      WidgetTester tester,
    ) async {
      final (_, GoRouter router) = await pumpSettingsApp(tester);

      // Password
      router.go(AppRoutes.settingsPasswordPath);
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Categories
      router.go(AppRoutes.settingsCategoriesPath);
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Legal
      router.go(AppRoutes.settingsLegalPath);
      await tester.pumpAndSettle();
      expect(find.byType(LegalClausesScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Support
      router.go(AppRoutes.settingsSupportPath);
      await tester.pumpAndSettle();
      expect(find.byType(SupportTicketScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Privacy policy
      router.go(AppRoutes.settingsPrivacyPath);
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Terms policy
      router.go(AppRoutes.settingsTermsPath);
      await tester.pumpAndSettle();
      expect(find.byType(PolicyScreen), findsOneWidget);
      expect(find.text('Terms and Conditions'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Back button on SettingsScreen falls back to /more', (
      WidgetTester tester,
    ) async {
      await pumpSettingsApp(tester, initialLocation: AppRoutes.settingsPath);

      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);
    });

    testWidgets('Toast via extra (Map with toast and plain string) displays toast on SettingsScreen', (
      WidgetTester tester,
    ) async {
      final (_, GoRouter router) = await pumpSettingsApp(tester);

      // Map extra: {'toast': 'Profile updated successfully'} (ST16)
      router.go(
        AppRoutes.settingsPath,
        extra: <String, Object?>{'toast': SettingsStrings.profileUpdatedToast},
      );
      await tester.pumpAndSettle();

      expect(find.text(SettingsStrings.profileUpdatedToast), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(SettingsStrings.profileUpdatedToast), findsNothing);

      // Plain string extra
      router.go(
        AppRoutes.settingsPath,
        extra: 'Settings saved',
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Settings saved'), findsNothing);
    });

    testWidgets('SettingsScreen on 360x800 surface renders without overflow', (
      WidgetTester tester,
    ) async {
      await pumpSettingsApp(
        tester,
        surfaceSize: const Size(360, 800),
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MoreScreen to Settings Navigation', () {
    testWidgets('Tapping Settings in MoreScreen navigates to /settings and back', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
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
      final GoRouter router = createAppRouter(initialLocation: AppRoutes.morePath);

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

      expect(find.byType(MoreScreen), findsOneWidget);
      expect(find.text(MoreStrings.settingsTitle), findsOneWidget);

      // Tap Settings
      await tester.tap(find.text(MoreStrings.settingsTitle));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      // Back returns to MoreScreen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);
    });
  });
}
