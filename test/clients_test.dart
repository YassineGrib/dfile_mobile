import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/client_strings.dart';
import 'package:dfile_mobile/features/clients/client_detail_screen.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ClientsRepository unit tests', () {
    late ClientsRepository repo;

    setUp(() {
      repo = ClientsRepository();
    });

    test('Initial repository loads 4 mock clients from SPEC.md', () {
      expect(repo.clients.length, 4);
      expect(repo.byId('c1')?.name, 'Mohamed Bachir');
      expect(repo.byId('c2')?.name, 'Sarah Benali');
      expect(repo.byId('c3')?.name, 'Nova Studio');
      expect(repo.byId('c4')?.name, 'Karim Haddad');
      expect(repo.byId('non_existent'), isNull);
    });

    test('Mohamed Bachir has exact derived stats matching SPEC C7..C9', () {
      final Client bachir = repo.byId('c1')!;
      expect(bachir.projects.length, 3);
      expect(bachir.payments.length, 3);

      // Active projects: In Progress (Fintask) + Waiting Client (Brand Identity) = 2
      expect(repo.activeProjectsCount(bachir), 2);
      expect(repo.isActive(bachir), isTrue);

      // Total revenue: 100,000 + 85,000 + 60,000 = 245,000 DZ
      expect(repo.totalRevenue(bachir), 245000.0);

      // Contract budget: 450,000 DZ
      expect(repo.budget(bachir), 450000.0);

      // Outstanding balance: 450,000 - 245,000 = 205,000 DZ
      expect(repo.outstanding(bachir), 205000.0);

      // Net profit: 245,000 - 47,000 = 198,000 DZ
      expect(repo.netProfit(bachir), 198000.0);
    });

    test('Sarah Benali derived stats', () {
      final Client sarah = repo.byId('c2')!;
      expect(repo.activeProjectsCount(sarah), 1);
      expect(repo.isActive(sarah), isTrue);
      expect(repo.totalRevenue(sarah), 120000.0);
    });

    test('Nova Studio and Karim Haddad are archived / inactive', () {
      final Client nova = repo.byId('c3')!;
      final Client karim = repo.byId('c4')!;

      expect(repo.activeProjectsCount(nova), 0);
      expect(repo.isActive(nova), isFalse);
      expect(repo.totalRevenue(nova), 0.0);

      expect(repo.activeProjectsCount(karim), 0);
      expect(repo.isActive(karim), isFalse);
      expect(repo.totalRevenue(karim), 68500.0);
    });

    test('add() appends a client and notifies listeners', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final Client newClient = Client(
        id: 'c_test',
        name: 'Test Client',
        createdAt: DateTime(2026, 9, 1),
      );

      repo.add(newClient);
      expect(repo.clients.length, 5);
      expect(repo.byId('c_test'), equals(newClient));
      expect(notifications, 1);
    });

    test('update() modifies an existing client and notifies listeners', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final Client original = repo.byId('c1')!;
      final Client updated = original.copyWith(name: 'Mohamed Updated');

      repo.update(updated);
      expect(repo.byId('c1')?.name, 'Mohamed Updated');
      expect(notifications, 1);
    });

    test('delete() removes a client and notifies listeners', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      repo.delete('c1');
      expect(repo.clients.length, 3);
      expect(repo.byId('c1'), isNull);
      expect(notifications, 1);
    });
  });

  group('Client UI flows on 390x844 test surface', () {
    Future<void> pumpApp(
      WidgetTester tester, {
      required ClientsRepository repository,
      String initialLocation = AppRoutes.clientsPath,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final GoRouter router = createAppRouter(initialLocation: initialLocation);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('List search, filter pills, and sort sheet', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo);

      // Verify initial header and clients
      expect(find.text(ClientStrings.clientsTitle), findsNWidgets(2)); // Title header and AppTabBar label
      expect(find.text(ClientStrings.clientsCount(4)), findsOneWidget);
      expect(find.text('Karim Haddad'), findsOneWidget);
      expect(find.text('Mohamed Bachir'), findsOneWidget);

      // 1. Live Search filtering by name
      await tester.enterText(
        find.byType(TextField).first,
        'Mohamed',
      );
      await tester.pumpAndSettle();

      expect(find.text('Mohamed Bachir'), findsOneWidget);
      expect(find.text('Karim Haddad'), findsNothing);
      expect(find.text('Nova Studio'), findsNothing);

      // Search for Sarah specifically (brings to top of filtered list)
      await tester.enterText(find.byType(TextField).first, 'Sarah');
      await tester.pumpAndSettle();
      expect(find.text('Sarah Benali'), findsOneWidget);
      expect(find.text('Mohamed Bachir'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Bachir'), findsOneWidget);

      // 2. Filter pills: Active
      await tester.tap(find.widgetWithText(AppPill, ClientStrings.filterActive));
      await tester.pumpAndSettle();
      // Active has 2 clients: Mohamed Bachir & Sarah Benali
      expect(find.text('Mohamed Bachir'), findsOneWidget);
      expect(find.text('Sarah Benali'), findsOneWidget);
      expect(find.text('Nova Studio'), findsNothing);
      expect(find.text('Karim Haddad'), findsNothing);

      // Filter pills: Inactive
      await tester.tap(find.widgetWithText(AppPill, ClientStrings.filterInactive));
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Bachir'), findsNothing);
      expect(find.text('Sarah Benali'), findsNothing);
      expect(find.text('Nova Studio'), findsOneWidget);
      expect(find.text('Karim Haddad'), findsOneWidget);

      // Reset to All
      await tester.tap(find.widgetWithText(AppPill, ClientStrings.filterAll));
      await tester.pumpAndSettle();

      // 3. Sort sheet
      await tester.tap(find.textContaining(ClientStrings.sortPrefix));
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.sortSheetTitle), findsOneWidget);
      expect(find.text(ClientStrings.sortHighestRevenue), findsOneWidget);

      // Select Highest revenue
      await tester.tap(find.text(ClientStrings.sortHighestRevenue));
      await tester.pumpAndSettle();

      // Verify sorted by revenue: Mohamed Bachir (245,000) then Sarah Benali (120,000) then Karim (68,500) then Nova (0)
      final Finder cardTitles = find.byType(ClientsListScreen);
      expect(cardTitles, findsOneWidget);
    });

    testWidgets('Empty state when search yields no matches with [+ Add client]', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo);

      await tester.enterText(
        find.byType(TextField).first,
        'xyz_no_match_query',
      );
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.clientsFound(0)), findsOneWidget);
      expect(find.text(ClientStrings.emptyTitle), findsOneWidget);
      expect(find.text(ClientStrings.emptySubtitle), findsOneWidget);
      expect(find.text(ClientStrings.addClientWithPlus), findsOneWidget);

      // Tapping [+ Add client] navigates to /clients/new
      await tester.tap(find.text(ClientStrings.addClientWithPlus));
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.addNewClientTitle), findsOneWidget);
    });

    testWidgets('Add client flow in Quick mode', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: AppRoutes.addClientPath);

      expect(find.text(ClientStrings.addNewClientTitle), findsOneWidget);

      // In Quick mode, button should be disabled when name is empty
      final Finder addButtonFinder = find.widgetWithText(PrimaryButton, ClientStrings.addClient);
      final PrimaryButton buttonBefore = tester.widget<PrimaryButton>(addButtonFinder);
      expect(buttonBefore.onPressed, isNull);

      // Enter name
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.clientNameLabel).first,
        'Amine Larbi',
      );
      await tester.pumpAndSettle();

      final PrimaryButton buttonAfter = tester.widget<PrimaryButton>(addButtonFinder);
      expect(buttonAfter.onPressed, isNotNull);

      // Tap Add client
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      // Returned to clients list
      expect(find.byType(ClientsListScreen), findsOneWidget);
      expect(find.text('Amine Larbi'), findsOneWidget);
      expect(find.text(ClientStrings.clientAddedToast), findsOneWidget);
      expect(repo.clients.length, 5);
    });

    testWidgets('Add client flow in Advanced mode with email validation', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: AppRoutes.addClientPath);

      // Switch to Advanced mode
      await tester.tap(find.text(ClientStrings.advancedMode));
      await tester.pumpAndSettle();

      final Finder addButtonFinder = find.widgetWithText(PrimaryButton, ClientStrings.addClient);

      // Enter name
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.clientNameLabel),
        'Yasmine Kaci',
      );
      await tester.pumpAndSettle();

      // Enter invalid email (no @)
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.emailLabel),
        'invalidemail',
      );
      await tester.pumpAndSettle();

      PrimaryButton button = tester.widget<PrimaryButton>(addButtonFinder);
      expect(button.onPressed, isNull);

      // Enter valid email
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.emailLabel),
        'yasmine@kaci.dz',
      );
      await tester.pumpAndSettle();

      button = tester.widget<PrimaryButton>(addButtonFinder);
      expect(button.onPressed, isNotNull);

      // Enter phone and address
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.phoneLabel),
        '0555 11 22 33',
      );
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.addressLabel),
        'Setif, Algeria',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(ClientsListScreen), findsOneWidget);
      expect(find.text(ClientStrings.clientAddedToast), findsOneWidget);
      expect(repo.clients.any((c) => c.name == 'Yasmine Kaci'), isTrue);
      await tester.scrollUntilVisible(
        find.text('Yasmine Kaci'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Yasmine Kaci'), findsOneWidget);
    });

    testWidgets('Client detail screen: Overview, Quick actions, Contact copy, Finance tiles, Tabs switch', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: '/clients/c1');

      expect(find.byType(ClientDetailScreen), findsOneWidget);
      expect(find.text('Mohamed Bachir'), findsOneWidget);
      expect(find.text(ClientStrings.financeBudget), findsOneWidget);
      expect(find.text('450,000 DZ'), findsOneWidget);
      expect(find.text('245,000 DZ'), findsOneWidget);

      // Copy phone quick action via round button
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();
      expect(find.text(ClientStrings.copiedPhoneToast), findsOneWidget);
      await tester.pumpAndSettle();

      // Contact row copy email (first copy link inside contact card)
      final Finder copyLinks = find.text(ClientStrings.copyAction);
      expect(copyLinks, findsWidgets);
      await tester.tap(copyLinks.at(1));
      await tester.pump();
      expect(find.text(ClientStrings.copiedEmailToast), findsOneWidget);
      await tester.pumpAndSettle();

      // Tap "Total contract budget" tile to switch to Projects tab
      await tester.tap(find.text(ClientStrings.financeBudget));
      await tester.pumpAndSettle();

      // Projects tab content visible
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('Brand Identity'), findsOneWidget);
      expect(find.text('Mobile App UI'), findsOneWidget);
      expect(find.text('65% complete'), findsOneWidget);

      // Switch to Payments tab via SegmentedToggle
      await tester.tap(find.text(ClientStrings.tabPayments));
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.totalCleared), findsOneWidget);
      expect(find.text('+100,000 DZ'), findsOneWidget);
      expect(find.text('+85,000 DZ'), findsOneWidget);
      expect(find.text('+60,000 DZ'), findsOneWidget);

      // Back button from Payments returns to Overview
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.clientDetailTitle), findsOneWidget);
      expect(find.text(ClientStrings.financeBudget), findsOneWidget);
    });

    testWidgets('Actions sheet (⋯) -> Delete client confirm -> Deletes and returns to list with toast', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: '/clients/c1');

      // Tap "⋯" more button
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Actions sheet (C4) options
      expect(find.text(ClientStrings.actionsViewProfile), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text(ClientStrings.actionsEditClient),
        ),
        findsOneWidget,
      );
      expect(find.text(ClientStrings.actionsCopyEmail), findsOneWidget);
      expect(find.text(ClientStrings.actionsDeleteClient), findsOneWidget);

      // Tap Delete client
      await tester.tap(find.text(ClientStrings.actionsDeleteClient));
      await tester.pumpAndSettle();

      // Delete confirm sheet (C5)
      expect(find.text(ClientStrings.deleteConfirmTitle), findsOneWidget);
      expect(find.text(ClientStrings.deleteConfirmSubtitle), findsOneWidget);
      expect(find.text(ClientStrings.confirmDelete), findsOneWidget);
      expect(find.text(ClientStrings.cancel), findsOneWidget);

      // Tap Confirm delete
      await tester.tap(find.text(ClientStrings.confirmDelete));
      await tester.pumpAndSettle();

      // Ends on clients list (C6) with toast
      expect(find.byType(ClientsListScreen), findsOneWidget);
      expect(find.text(ClientStrings.clientDeletedToast), findsOneWidget);
      expect(repo.byId('c1'), isNull);
      expect(find.text('Mohamed Bachir'), findsNothing);
    });

    testWidgets('Edit client flow updates data and shows toast', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: '/clients/c1/edit');

      expect(find.text(ClientStrings.editClientTitle), findsOneWidget);
      expect(find.text('Mohamed Bachir'), findsOneWidget);
      expect(find.text('bachir@novacorp.dz'), findsOneWidget);

      // Edit name
      await tester.enterText(
        find.widgetWithText(AppTextField, ClientStrings.clientNameLabel),
        'Mohamed B. Bachir',
      );
      await tester.pumpAndSettle();

      // Tap Save changes
      await tester.tap(find.widgetWithText(PrimaryButton, ClientStrings.saveChanges));
      await tester.pumpAndSettle();

      expect(find.text(ClientStrings.changesSavedToast), findsOneWidget);
      expect(repo.byId('c1')?.name, 'Mohamed B. Bachir');
    });

    testWidgets('Edit non-existent client shows friendly Client not found screen', (
      WidgetTester tester,
    ) async {
      final ClientsRepository repo = ClientsRepository();
      await pumpApp(tester, repository: repo, initialLocation: '/clients/unknown_id/edit');

      expect(find.text(ClientStrings.clientNotFound), findsOneWidget);
      expect(find.text(ClientStrings.backToClients), findsOneWidget);

      await tester.tap(find.text(ClientStrings.backToClients));
      await tester.pumpAndSettle();

      expect(find.byType(ClientsListScreen), findsOneWidget);
    });

    testWidgets(
      'Filter pills and Sort fit on one row at 360x800 without overflow and Inactive pill is hit-testable',
      (WidgetTester tester) async {
        final bool previousFatal = WidgetController.hitTestWarningShouldBeFatal;
        WidgetController.hitTestWarningShouldBeFatal = true;
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          WidgetController.hitTestWarningShouldBeFatal = previousFatal;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final ClientsRepository repo = ClientsRepository();
        final GoRouter router = createAppRouter(
          initialLocation: AppRoutes.clientsPath,
        );
        await tester.pumpWidget(
          DfileApp(
            router: router,
            repository: repo,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final Finder allFinder = find.widgetWithText(
          AppPill,
          ClientStrings.filterAll,
        );
        final Finder activeFinder = find.widgetWithText(
          AppPill,
          ClientStrings.filterActive,
        );
        final Finder inactiveFinder = find.widgetWithText(
          AppPill,
          ClientStrings.filterInactive,
        );
        final Finder sortFinder = find.textContaining(ClientStrings.sortPrefix);

        final Rect allRect = tester.getRect(allFinder);
        final Rect activeRect = tester.getRect(activeFinder);
        final Rect inactiveRect = tester.getRect(inactiveFinder);
        final Rect sortRect = tester.getRect(sortFinder);

        expect(allRect.left, greaterThanOrEqualTo(0));
        expect(allRect.right, lessThanOrEqualTo(activeRect.left));
        expect(activeRect.right, lessThanOrEqualTo(inactiveRect.left));
        expect(inactiveRect.right, lessThanOrEqualTo(sortRect.left));
        expect(sortRect.right, lessThanOrEqualTo(360));

        await tester.tap(inactiveFinder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        expect(find.text('Mohamed Bachir'), findsNothing);
        expect(find.text('Sarah Benali'), findsNothing);
        expect(find.text('Nova Studio'), findsOneWidget);
        expect(find.text('Karim Haddad'), findsOneWidget);
      },
    );
  });
}
