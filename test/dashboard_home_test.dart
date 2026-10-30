import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_home_strings.dart';
import 'package:dfile_mobile/features/dashboard/data/data.dart';
import 'package:dfile_mobile/features/dashboard/home_screen.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_empty_view.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_hero_profit_card.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_kpi_row.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_quick_actions.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_quick_add_sheet.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_upcoming_deadlines.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setTestSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  // Helper to pump frames bounded without pumpAndSettle
  Future<void> pumpBounded(WidgetTester tester, [int count = 5]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('HomeScreen Tests (Task 9A)', () {
    testWidgets('Greeting by time with clock injection', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final SettingsRepository settings = SettingsRepository(
        initialProfile: const UserProfile(
          name: 'Yassine G.',
          designation: 'Independent designer',
          email: 'yassine@decabyte.dz',
          phone: '+213 550 12 34 56',
          address: 'Algiers',
        ),
      );
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final NotificationsStore notifs = NotificationsStore();

      // Morning test (09:00)
      final DateTime morning = DateTime(2026, 10, 30, 9, 0);
      Widget testApp(DateTime now) {
        return ClientsScope(
          repository: clients,
          child: ProjectsScope(
            repository: projects,
            child: ExpensesScope(
              repository: expenses,
              child: FriendsScope(
                repository: friends,
                child: SettingsScope(
                  repository: settings,
                  child: NotificationsScope(
                    store: notifs,
                    child: MaterialApp(home: HomeScreen(clock: () => now)),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(testApp(morning));
      await pumpBounded(tester);
      expect(find.text('Good morning, Yassine'), findsOneWidget);

      // Afternoon test (14:00)
      final DateTime afternoon = DateTime(2026, 10, 30, 14, 0);
      await tester.pumpWidget(testApp(afternoon));
      await pumpBounded(tester);
      expect(find.text('Good afternoon, Yassine'), findsOneWidget);

      // Evening test (19:00)
      final DateTime evening = DateTime(2026, 10, 30, 19, 0);
      await tester.pumpWidget(testApp(evening));
      await pumpBounded(tester);
      expect(find.text('Good evening, Yassine'), findsOneWidget);
    });

    testWidgets('Hero numbers match stats, delta chip positive and negative', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final SettingsRepository settings = SettingsRepository();
      final NotificationsStore notifs = NotificationsStore();

      final DateTime oct2026 = DateTime(2026, 10, 30, 10, 0);

      // Seed stats: 573,800 DZ all time net, +52,300 this month
      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.homePath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clients,
          projectsRepository: projects,
          expensesRepository: expenses,
          friendsRepository: friends,
          settingsRepository: settings,
          notificationsStore: notifs,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(HomeHeroProfitCard), findsOneWidget);
      expect(find.text(formatMoney(573800)), findsOneWidget);
      expect(find.text('+52,300 this month'), findsOneWidget);

      // Tap hero -> navigates to /home/profit
      await tester.tap(find.byType(HomeHeroProfitCard));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.profitPath);

      // Negative delta case: add a large expense in the current month
      expenses.add(
        Expense(
          id: 'ex_huge',
          amount: 100000.0,
          category: ExpenseCategory.softwareTools,
          description: 'Large software license',
          date: oct2026,
        ),
      );

      // Back to /home
      router.go(AppRoutes.homePath);
      await pumpBounded(tester);

      // Inflow 60,000 - outflow (7,700 + 100,000) = -47,700
      expect(find.text('-47,700 this month'), findsOneWidget);
    });

    testWidgets('KPI values match repository stats', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final SettingsRepository settings = SettingsRepository();
      final NotificationsStore notifs = NotificationsStore();

      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.homePath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clients,
          projectsRepository: projects,
          expensesRepository: expenses,
          friendsRepository: friends,
          settingsRepository: settings,
          notificationsStore: notifs,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(HomeKpiRow), findsOneWidget);
      // Active projects: 2
      expect(find.text('2'), findsOneWidget);
      // Monthly expenses: 7,700 DZ
      expect(find.text(formatMoney(7700)), findsOneWidget);
      // Pending invoices: 420,000 DZ
      expect(find.text(formatMoney(420000)), findsOneWidget);
      // Friends owe you: 58,000 DZ
      expect(find.text(formatMoney(58000), skipOffstage: false), findsWidgets);
    });

    testWidgets('Quick actions navigate to expected routes', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final SettingsRepository settings = SettingsRepository();
      final NotificationsStore notifs = NotificationsStore();

      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.homePath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clients,
          projectsRepository: projects,
          expensesRepository: expenses,
          friendsRepository: friends,
          settingsRepository: settings,
          notificationsStore: notifs,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(HomeQuickActions), findsOneWidget);

      // Record payment -> /payments/new
      await tester.tap(
        find.descendant(
          of: find.byType(HomeQuickActions),
          matching: find.text(DashboardHomeStrings.recordPayment),
        ),
      );
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.recordPaymentPath);

      router.go(AppRoutes.homePath);
      await pumpBounded(tester);

      // Add expense -> /expenses/new
      await tester.tap(
        find.descendant(
          of: find.byType(HomeQuickActions),
          matching: find.text(DashboardHomeStrings.addExpense),
        ),
      );
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.newExpensePath);

      router.go(AppRoutes.homePath);
      await pumpBounded(tester);

      // New project -> /projects/new
      await tester.tap(
        find.descendant(
          of: find.byType(HomeQuickActions),
          matching: find.text(DashboardHomeStrings.newProject),
        ),
      );
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.addProjectPath);

      router.go(AppRoutes.homePath);
      await pumpBounded(tester);

      // Add client -> /clients/new (its card sits beyond the first swipe)
      final Finder addClient = find.descendant(
        of: find.byType(HomeQuickActions),
        matching: find.text(DashboardHomeStrings.addClient),
      );
      await tester.ensureVisible(addClient);
      await pumpBounded(tester);
      await tester.tap(addClient);
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.addClientPath);
    });

    testWidgets('Quick add sheet opens on "+" button and its rows navigate', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final SettingsRepository settings = SettingsRepository();
      final NotificationsStore notifs = NotificationsStore();

      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.homePath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clients,
          projectsRepository: projects,
          expensesRepository: expenses,
          friendsRepository: friends,
          settingsRepository: settings,
          notificationsStore: notifs,
        ),
      );
      await pumpBounded(tester);

      // Tap "+" button
      await tester.tap(find.byIcon(AppIcons.plus));
      await pumpBounded(tester);

      expect(find.byType(HomeQuickAddSheet), findsOneWidget);
      expect(find.text(DashboardHomeStrings.createNew), findsOneWidget);

      // Tap "Record payment" row in sheet
      await tester.tap(find.text(DashboardHomeStrings.recordPaymentSub));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.recordPaymentPath);

      // Open sheet again for Add expense
      router.go(AppRoutes.homePath);
      await pumpBounded(tester);
      await tester.tap(find.byIcon(AppIcons.plus));
      await pumpBounded(tester);
      await tester.tap(find.text(DashboardHomeStrings.addExpenseSub));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.newExpensePath);

      // Open sheet again for New project
      router.go(AppRoutes.homePath);
      await pumpBounded(tester);
      await tester.tap(find.byIcon(AppIcons.plus));
      await pumpBounded(tester);
      await tester.tap(find.text(DashboardHomeStrings.newProjectSub));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.addProjectPath);

      // Open sheet again for Add client
      router.go(AppRoutes.homePath);
      await pumpBounded(tester);
      await tester.tap(find.byIcon(AppIcons.plus));
      await pumpBounded(tester);
      await tester.tap(find.text(DashboardHomeStrings.addClientSub));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.addClientPath);
    });

    testWidgets('Deadlines list displays states and navigates', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clients = ClientsRepository();
      final ProjectsRepository projects = ProjectsRepository(
        clientsRepository: clients,
      );
      final ExpensesRepository expenses = ExpensesRepository();
      final FriendsRepository friends = FriendsRepository();
      final SettingsRepository settings = SettingsRepository();
      final NotificationsStore notifs = NotificationsStore();

      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.homePath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clients,
          projectsRepository: projects,
          expensesRepository: expenses,
          friendsRepository: friends,
          settingsRepository: settings,
          notificationsStore: notifs,
        ),
      );
      await pumpBounded(tester);

      // The card sits below the Follow up section; scroll it into view.
      await tester.scrollUntilVisible(
        find.byType(HomeUpcomingDeadlines),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpBounded(tester);
      expect(find.byType(HomeUpcomingDeadlines), findsOneWidget);

      // Check upcoming deadline card for "Fintask Landing Page"
      Finder inDeadlines(String text) => find.descendant(
        of: find.byType(HomeUpcomingDeadlines),
        matching: find.text(text),
      );
      expect(inDeadlines('Fintask Landing Page'), findsOneWidget);
      expect(inDeadlines('Mohamed Bachir'), findsOneWidget);

      // Tap "See all" -> /projects
      await tester.tap(find.text(DashboardHomeStrings.seeAll));
      await pumpBounded(tester);
      expect(
        router.state.uri.toString(),
        '${AppRoutes.calendarPath}?tab=agenda',
      );

      // Tap deadline card -> /projects/:id
      router.go(AppRoutes.homePath);
      await pumpBounded(tester);
      await tester.tap(find.text('Fintask Landing Page'));
      await pumpBounded(tester);
      expect(router.state.uri.toString().startsWith('/projects/'), isTrue);
    });

    testWidgets(
      'Bell dot appears with unread notification and disappears after markAllRead',
      (WidgetTester tester) async {
        setTestSurface(tester);
        final ClientsRepository clients = ClientsRepository();
        final ProjectsRepository projects = ProjectsRepository(
          clientsRepository: clients,
        );
        final ExpensesRepository expenses = ExpensesRepository();
        final FriendsRepository friends = FriendsRepository();
        final SettingsRepository settings = SettingsRepository();
        final NotificationsStore notifs = NotificationsStore();

        final GoRouter router = createAppRouter(
          initialLocation: AppRoutes.homePath,
        );
        await tester.pumpWidget(
          DfileApp(
            router: router,
            repository: clients,
            projectsRepository: projects,
            expensesRepository: expenses,
            friendsRepository: friends,
            settingsRepository: settings,
            notificationsStore: notifs,
          ),
        );
        await pumpBounded(tester);

        // Verify bell button exists
        expect(find.byIcon(AppIcons.bell), findsOneWidget);

        // With default seed, there are deadline / payment notifications unread -> coral dot visible
        Finder coralDotFinder() => find.byWidgetPredicate((Widget widget) {
          return widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == AppColors.coral &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle;
        });

        expect(coralDotFinder(), findsOneWidget);

        // Tap bell button -> navigates to /home/notifications
        await tester.tap(find.byIcon(AppIcons.bell));
        await pumpBounded(tester);
        expect(router.state.uri.toString(), AppRoutes.homeNotificationsPath);

        // Mark all read in notifications store
        final List<AppNotification> items = deriveNotifications(
          now: DateTime.now(),
          settings: settings.notifications,
          projects: projects.projects,
          transactions: friends.transactions,
          payments: projects.payments,
        );
        notifs.markAllRead(items.map((e) => e.id));

        router.go(AppRoutes.homePath);
        await pumpBounded(tester);

        // Dot should be gone
        expect(coralDotFinder(), findsNothing);
      },
    );

    testWidgets(
      'Empty-home setup progress and transition to normal home after 3 steps',
      (WidgetTester tester) async {
        setTestSurface(tester);
        // Empty repositories
        final ClientsRepository clients = ClientsRepository(
          initialClients: <Client>[],
        );
        final ProjectsRepository projects = ProjectsRepository(
          clientsRepository: clients,
          initialProjects: <ProjectItem>[],
          initialPayments: <ProjectPayment>[],
        );
        final ExpensesRepository expenses = ExpensesRepository(
          initialExpenses: <Expense>[],
        );
        final FriendsRepository friends = FriendsRepository(
          initialFriends: <Friend>[],
          initialTransactions: <FriendTransaction>[],
          initialSettlements: <FriendSettlement>[],
        );
        final SettingsRepository settings = SettingsRepository();
        final NotificationsStore notifs = NotificationsStore();

        final GoRouter router = createAppRouter(
          initialLocation: AppRoutes.homePath,
        );
        await tester.pumpWidget(
          DfileApp(
            router: router,
            repository: clients,
            projectsRepository: projects,
            expensesRepository: expenses,
            friendsRepository: friends,
            settingsRepository: settings,
            notificationsStore: notifs,
          ),
        );
        await pumpBounded(tester);

        // HM7 Empty state is displayed
        expect(find.byType(HomeEmptyView), findsOneWidget);
        expect(find.text(DashboardHomeStrings.welcome), findsOneWidget);
        expect(find.text('0 of 3'), findsOneWidget);

        // Step 1: Add a client
        clients.add(
          Client(
            id: 'c_test',
            name: 'Acme Corp',
            email: 'contact@acme.dz',
            createdAt: DateTime.now(),
          ),
        );
        await pumpBounded(tester);
        expect(find.text('1 of 3'), findsOneWidget);

        // Step 2: Add a project
        projects.add(
          ProjectItem(
            id: 'p_test',
            clientId: 'c_test',
            name: 'Website Redesign',
            price: 50000,
            progress: 20,
            startDate: DateTime.now(),
            status: ProjectStatus.inProgress,
            category: 'Development',
            createdAt: DateTime.now(),
          ),
        );
        await pumpBounded(tester);
        expect(find.text('2 of 3'), findsOneWidget);

        // Step 3: Add a payment
        projects.addPayment(
          ProjectPayment(
            id: 'pm_test',
            projectId: 'p_test',
            clientId: 'c_test',
            amount: 25000,
            date: DateTime.now(),
            reference: 'Deposit',
            method: PaymentMethod.cash,
          ),
        );
        await pumpBounded(tester);

        // Now all 3 steps are complete -> Normal home is shown
        expect(find.byType(HomeEmptyView), findsNothing);
        expect(find.byType(HomeHeroProfitCard), findsOneWidget);
      },
    );

    testWidgets(
      'No overflow on 360x800 surface for both Normal Home and Empty Home',
      (WidgetTester tester) async {
        // 1. Normal Home on 360x800
        setTestSurface(tester, size: const Size(360, 800));
        final ClientsRepository clients = ClientsRepository();
        final ProjectsRepository projects = ProjectsRepository(
          clientsRepository: clients,
        );
        final ExpensesRepository expenses = ExpensesRepository();
        final FriendsRepository friends = FriendsRepository();
        final SettingsRepository settings = SettingsRepository();
        final NotificationsStore notifs = NotificationsStore();

        final GoRouter router = createAppRouter(
          initialLocation: AppRoutes.homePath,
        );
        await tester.pumpWidget(
          DfileApp(
            router: router,
            repository: clients,
            projectsRepository: projects,
            expensesRepository: expenses,
            friendsRepository: friends,
            settingsRepository: settings,
            notificationsStore: notifs,
          ),
        );
        await pumpBounded(tester);

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // 2. Empty Home on 360x800
        final ClientsRepository emptyClients = ClientsRepository(
          initialClients: <Client>[],
        );
        final ProjectsRepository emptyProjects = ProjectsRepository(
          clientsRepository: emptyClients,
          initialProjects: <ProjectItem>[],
          initialPayments: <ProjectPayment>[],
        );
        final ExpensesRepository emptyExpenses = ExpensesRepository(
          initialExpenses: <Expense>[],
        );
        final FriendsRepository emptyFriends = FriendsRepository(
          initialFriends: <Friend>[],
          initialTransactions: <FriendTransaction>[],
          initialSettlements: <FriendSettlement>[],
        );

        final GoRouter emptyRouter = createAppRouter(
          initialLocation: AppRoutes.homePath,
        );
        await tester.pumpWidget(
          DfileApp(
            router: emptyRouter,
            repository: emptyClients,
            projectsRepository: emptyProjects,
            expensesRepository: emptyExpenses,
            friendsRepository: emptyFriends,
            settingsRepository: settings,
            notificationsStore: notifs,
          ),
        );
        await pumpBounded(tester);

        expect(find.byType(HomeEmptyView), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
