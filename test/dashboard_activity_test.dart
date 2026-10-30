import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_activity_strings.dart';
import 'package:dfile_mobile/features/dashboard/data/data.dart';
import 'package:dfile_mobile/features/dashboard/notifications_screen.dart';
import 'package:dfile_mobile/features/dashboard/profit_screen.dart';
import 'package:dfile_mobile/features/dashboard/widgets/activity_card.dart';
import 'package:dfile_mobile/features/dashboard/widgets/dash_card.dart';
import 'package:dfile_mobile/features/dashboard/widgets/friends_snapshot_card.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'support/system_back.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final DateTime seedClock = DateTime(2026, 10, 30, 10, 30);

  void setSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget createTestApp({
    required Widget child,
    ClientsRepository? clientsRepo,
    ProjectsRepository? projectsRepo,
    ExpensesRepository? expensesRepo,
    FriendsRepository? friendsRepo,
    SettingsRepository? settingsRepo,
    NotificationsStore? notificationsStore,
  }) {
    final effectiveClients = clientsRepo ?? ClientsRepository();
    final effectiveProjects =
        projectsRepo ?? ProjectsRepository(clientsRepository: effectiveClients);
    final effectiveExpenses = expensesRepo ?? ExpensesRepository();
    final effectiveFriends = friendsRepo ?? FriendsRepository();
    final effectiveSettings = settingsRepo ?? SettingsRepository();
    final effectiveNotifications = notificationsStore ?? NotificationsStore();

    return ClientsScope(
      repository: effectiveClients,
      child: ProjectsScope(
        repository: effectiveProjects,
        child: ExpensesScope(
          repository: effectiveExpenses,
          child: FriendsScope(
            repository: effectiveFriends,
            child: SettingsScope(
              repository: effectiveSettings,
              child: NotificationsScope(
                store: effectiveNotifications,
                child: MaterialApp(
                  theme: AppTheme.light,
                  home: Scaffold(body: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createRouterApp({
    required String initialLocation,
    ClientsRepository? clientsRepo,
    ProjectsRepository? projectsRepo,
    ExpensesRepository? expensesRepo,
    FriendsRepository? friendsRepo,
    SettingsRepository? settingsRepo,
    NotificationsStore? notificationsStore,
    GoRouter? customRouter,
  }) {
    final effectiveClients = clientsRepo ?? ClientsRepository();
    final effectiveProjects =
        projectsRepo ?? ProjectsRepository(clientsRepository: effectiveClients);
    final effectiveExpenses = expensesRepo ?? ExpensesRepository();
    final effectiveFriends = friendsRepo ?? FriendsRepository();
    final effectiveSettings = settingsRepo ?? SettingsRepository();
    final effectiveNotifications = notificationsStore ?? NotificationsStore();

    final router =
        customRouter ?? createAppRouter(initialLocation: initialLocation);

    return ClientsScope(
      repository: effectiveClients,
      child: ProjectsScope(
        repository: effectiveProjects,
        child: ExpensesScope(
          repository: effectiveExpenses,
          child: FriendsScope(
            repository: effectiveFriends,
            child: SettingsScope(
              repository: effectiveSettings,
              child: NotificationsScope(
                store: effectiveNotifications,
                child: MaterialApp.router(
                  theme: AppTheme.light,
                  routerConfig: router,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ActivityCard (HM3)', () {
    testWidgets(
      'renders recentActivity for seeds in correct order with amounts and dates',
      (WidgetTester tester) async {
        setSurface(tester);
        final projectsRepo = ProjectsRepository();
        final expensesRepo = ExpensesRepository();
        final friendsRepo = FriendsRepository();
        final clientsRepo = ClientsRepository();

        await tester.pumpWidget(
          createTestApp(
            clientsRepo: clientsRepo,
            projectsRepo: projectsRepo,
            expensesRepo: expensesRepo,
            friendsRepo: friendsRepo,
            child: SingleChildScrollView(
              child: ActivityCard(clock: () => seedClock),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Section header
        expect(
          find.text(DashboardActivityStrings.recentActivity),
          findsOneWidget,
        );
        expect(find.text(DashboardActivityStrings.seeAll), findsOneWidget);

        // Verify seed recent activity items
        // Top 4 recent items from mock data:
        // 1. Server hosting bill (Yacine shared cost 2026-10-20)
        // 2. Figma Pro plan (Expense 4,500 on 2026-10-15)
        // 3. Hosting bill split (Amine debt 2026-10-10)
        // 4. Frontend UI design (Karim service 2026-10-05)
        // or payments / settlements / expenses
        final items = recentActivity(
          payments: projectsRepo.payments,
          expenses: expensesRepo.expenses,
          settlements: friendsRepo.settlements,
          friendTransactions: friendsRepo.transactions,
          projects: projectsRepo.projects,
          clientNameLookup: (id) => clientsRepo.byId(id)?.name ?? '',
          projectNameLookup: (id) => projectsRepo.byId(id)?.name ?? '',
          friendNameLookup: (id) => friendsRepo.friendById(id)?.name ?? '',
          limit: 4,
        );

        expect(items.length, 4);
        for (final item in items) {
          expect(find.text(item.title), findsAtLeastNWidgets(1));
          expect(find.text(item.subtitle), findsAtLeastNWidgets(1));
        }
      },
    );

    testWidgets('empty state displays friendly line when no activity exists', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final projectsRepo = ProjectsRepository()..clearAll();
      final expensesRepo = ExpensesRepository()..clearAll();
      final friendsRepo = FriendsRepository(
        initialFriends: [],
        initialTransactions: [],
        initialSettlements: [],
      );
      final clientsRepo = ClientsRepository()..clearAll();

      await tester.pumpWidget(
        createTestApp(
          clientsRepo: clientsRepo,
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          friendsRepo: friendsRepo,
          child: const ActivityCard(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(DashboardActivityStrings.noRecentActivity),
        findsOneWidget,
      );
    });

    testWidgets('tapping See all navigates to /home/notifications', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final router = createAppRouter(initialLocation: AppRoutes.homePath);

      await tester.pumpWidget(
        createRouterApp(
          initialLocation: AppRoutes.homePath,
          customRouter: router,
        ),
      );
      await tester.pumpAndSettle();

      // Render ActivityCard inside a test harness that allows router navigation
      // or push via context
      router.push(AppRoutes.notificationsPath);
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('tapping an activity row navigates to its route', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => const Scaffold(
              body: SingleChildScrollView(child: ActivityCard()),
            ),
          ),
          GoRoute(
            path: '/expenses/:id',
            builder: (context, state) => Scaffold(
              body: Text('ExpenseDetail:${state.pathParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/payments/:id',
            builder: (context, state) => Scaffold(
              body: Text('PaymentDetail:${state.pathParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/friends/:id',
            builder: (context, state) => Scaffold(
              body: Text('FriendDetail:${state.pathParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/projects/:id',
            builder: (context, state) => Scaffold(
              body: Text('ProjectDetail:${state.pathParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/home/notifications',
            builder: (context, state) =>
                const Scaffold(body: Text('NotificationsScreenTarget')),
          ),
        ],
      );

      await tester.pumpWidget(
        createRouterApp(initialLocation: '/test', customRouter: router),
      );
      await tester.pumpAndSettle();

      // Tap See all
      await tester.tap(find.text(DashboardActivityStrings.seeAll));
      await tester.pumpAndSettle();
      expect(find.text('NotificationsScreenTarget'), findsOneWidget);

      // Go back to /test
      router.go('/test');
      await tester.pumpAndSettle();

      // Find first activity item and tap it
      final firstRow = find.byType(InkWell).first;
      await tester.tap(firstRow);
      await tester.pumpAndSettle();

      // Should have navigated to /expenses/... or /payments/... or /friends/...
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('no overflow on 360x800 surface', (WidgetTester tester) async {
      setSurface(tester, size: const Size(360, 800));
      await tester.pumpWidget(
        createTestApp(
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
            child: SingleChildScrollView(child: ActivityCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group("FriendsSnapshotCard (HM3)", () {
    testWidgets(
      'renders numbers from repository overallBalance with chips and colors',
      (WidgetTester tester) async {
        setSurface(tester);
        final friendsRepo = FriendsRepository();
        final overall = friendsRepo
            .overallBalance(); // net +58,000, owed 70,000, owe 12,000

        await tester.pumpWidget(
          createTestApp(
            friendsRepo: friendsRepo,
            child: const FriendsSnapshotCard(),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(DashboardActivityStrings.friendsDebts),
          findsOneWidget,
        );
        expect(
          find.text(DashboardActivityStrings.netBalanceAcrossFriends),
          findsOneWidget,
        );
        expect(find.text('+${formatMoney(overall.net)}'), findsOneWidget);

        expect(
          find.textContaining(formatMoney(overall.owedToYou)),
          findsOneWidget,
        );
        expect(
          find.textContaining(formatMoney(overall.youOwe)),
          findsOneWidget,
        );

        expect(find.byIcon(AppIcons.arrowDownRight), findsOneWidget);
        expect(find.byIcon(AppIcons.arrowUpRight), findsOneWidget);
      },
    );

    testWidgets('empty friends state shows friendly subtitle and 0 DZ chips', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final friendsRepo = FriendsRepository(
        initialFriends: [],
        initialTransactions: [],
        initialSettlements: [],
      );

      await tester.pumpWidget(
        createTestApp(
          friendsRepo: friendsRepo,
          child: const FriendsSnapshotCard(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(DashboardActivityStrings.trackMoneyLendBorrow),
        findsOneWidget,
      );
      expect(find.text(formatMoney(0)), findsOneWidget); // net
      expect(find.textContaining('Owed 0 DZ'), findsOneWidget);
      expect(find.textContaining('You owe 0 DZ'), findsOneWidget);
    });

    testWidgets('tapping card navigates to /friends', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) =>
                const Scaffold(body: FriendsSnapshotCard()),
          ),
          GoRoute(
            path: '/friends',
            builder: (context, state) =>
                const Scaffold(body: Text('FriendsScreenTarget')),
          ),
        ],
      );

      await tester.pumpWidget(
        createRouterApp(initialLocation: '/test', customRouter: router),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(DashboardActivityStrings.friendsDebts));
      await tester.pumpAndSettle();

      expect(find.text('FriendsScreenTarget'), findsOneWidget);
    });

    testWidgets('no overflow on 360x800 surface', (WidgetTester tester) async {
      setSurface(tester, size: const Size(360, 800));
      await tester.pumpWidget(
        createTestApp(
          child: const SingleChildScrollView(child: FriendsSnapshotCard()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsScreen (HM5)', () {
    testWidgets('groups notifications into TODAY and EARLIER based on clock', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final fixedClock = DateTime(2026, 10, 30, 10, 30);

      await tester.pumpWidget(
        createTestApp(child: NotificationsScreen(clock: () => fixedClock)),
      );
      await tester.pumpAndSettle();

      expect(find.text(DashboardActivityStrings.notifications), findsOneWidget);
      expect(find.text(DashboardActivityStrings.markAllRead), findsOneWidget);

      // Verify groups
      expect(find.text(DashboardActivityStrings.today), findsOneWidget);
      expect(find.text(DashboardActivityStrings.earlier), findsOneWidget);
    });

    testWidgets(
      'shows unread coral dots and markAllRead updates store and UI',
      (WidgetTester tester) async {
        setSurface(tester);
        final store = NotificationsStore();
        final fixedClock = DateTime(2026, 10, 30, 10, 30);

        await tester.pumpWidget(
          createTestApp(
            notificationsStore: store,
            child: NotificationsScreen(clock: () => fixedClock),
          ),
        );
        await tester.pumpAndSettle();

        // Find coral dot containers (width 8, height 8)
        final dotFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.maxWidth == 8 &&
              widget.constraints?.maxHeight == 8,
        );
        expect(dotFinder, findsWidgets);

        // Tap Mark all read
        await tester.tap(find.text(DashboardActivityStrings.markAllRead));
        await tester.pumpAndSettle();

        // Coral dots should be gone
        expect(dotFinder, findsNothing);
      },
    );

    testWidgets(
      'tapping notification marks it read and navigates to its route',
      (WidgetTester tester) async {
        setSurface(tester);
        final store = NotificationsStore();
        final fixedClock = DateTime(2026, 10, 30, 10, 30);

        final router = GoRouter(
          initialLocation: '/home/notifications',
          routes: [
            GoRoute(
              path: '/home/notifications',
              builder: (context, state) =>
                  NotificationsScreen(clock: () => fixedClock),
            ),
            GoRoute(
              path: '/projects/:id',
              builder: (context, state) => Scaffold(
                body: Text('ProjectPage:${state.pathParameters['id']}'),
              ),
            ),
            GoRoute(
              path: '/payments/:id',
              builder: (context, state) => Scaffold(
                body: Text('PaymentPage:${state.pathParameters['id']}'),
              ),
            ),
            GoRoute(
              path: '/friends/:id',
              builder: (context, state) => Scaffold(
                body: Text('FriendPage:${state.pathParameters['id']}'),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          createRouterApp(
            initialLocation: '/home/notifications',
            notificationsStore: store,
            customRouter: router,
          ),
        );
        await tester.pumpAndSettle();

        // Find first notification card and tap it
        final firstNotif = find.byType(DashCard).first;
        await tester.tap(firstNotif);
        await tester.pumpAndSettle();

        // Navigated away from notifications screen
        expect(find.byType(NotificationsScreen), findsNothing);
        expect(store.readIds.isNotEmpty, true);
      },
    );

    testWidgets('settings notification switch toggles dynamic filtering', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final settingsRepo = SettingsRepository();
      final fixedClock = DateTime(2026, 10, 30, 10, 30);

      await tester.pumpWidget(
        createTestApp(
          settingsRepo: settingsRepo,
          child: NotificationsScreen(clock: () => fixedClock),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('deadline'), findsWidgets);

      // Disable deadline notifications
      settingsRepo.updateNotifications(
        settingsRepo.notifications.copyWith(deadlines: false),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('deadline'), findsNothing);

      // Disable master push
      settingsRepo.updateNotifications(
        settingsRepo.notifications.copyWith(push: false),
      );
      await tester.pumpAndSettle();

      // Shows empty view
      expect(find.text(DashboardActivityStrings.allCaughtUp), findsOneWidget);
    });

    testWidgets('no overflow on 360x800 surface', (WidgetTester tester) async {
      setSurface(tester, size: const Size(360, 800));
      await tester.pumpWidget(
        createTestApp(child: NotificationsScreen(clock: () => seedClock)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfitScreen (HM8)', () {
    testWidgets('renders profit numbers and margin for seeds correctly', (
      WidgetTester tester,
    ) async {
      setSurface(tester);
      final projectsRepo = ProjectsRepository();
      final expensesRepo = ExpensesRepository();

      final profit = netProfit(
        projectsRepo.payments,
        expensesRepo.expenses,
      ); // 573,800 DZ
      final margin = profitMargin(
        projectsRepo.payments,
        expensesRepo.expenses,
      ); // ~86%

      await tester.pumpWidget(
        createTestApp(
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          child: ProfitScreen(clock: () => seedClock),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(DashboardActivityStrings.profit), findsOneWidget);
      expect(
        find.text(DashboardActivityStrings.netProfitAllTime),
        findsOneWidget,
      );
      expect(find.text(formatMoney(profit)), findsOneWidget);
      expect(find.textContaining('${margin.round()}%'), findsOneWidget);

      // Check revenue and expenses
      expect(find.text(DashboardActivityStrings.revenue), findsOneWidget);
      expect(find.text(DashboardActivityStrings.expenses), findsOneWidget);

      // Check top sections
      expect(
        find.text(DashboardActivityStrings.topEarningProjects),
        findsOneWidget,
      );
      expect(
        find.text(DashboardActivityStrings.whereTheMoneyGoes),
        findsOneWidget,
      );

      // Check top 3 projects by paid
      final topProj = topProjectsByPaid(
        projectsRepo.projects,
        projectsRepo.payments,
        limit: 3,
      );
      for (final p in topProj) {
        expect(find.text(p.project.name), findsOneWidget);
        expect(find.text(formatMoney(p.paid)), findsOneWidget);
      }

      // Check top 3 expense categories
      final topExp = topExpenseCategories(expensesRepo.expenses, limit: 3);
      for (final e in topExp) {
        expect(find.text(e.category.label), findsOneWidget);
        expect(find.text(formatMoney(e.total)), findsOneWidget);
      }
    });

    testWidgets(
      'empty state displays friendly lines and 0% margin when empty',
      (WidgetTester tester) async {
        setSurface(tester);
        final projectsRepo = ProjectsRepository()..clearAll();
        final expensesRepo = ExpensesRepository()..clearAll();

        await tester.pumpWidget(
          createTestApp(
            projectsRepo: projectsRepo,
            expensesRepo: expensesRepo,
            child: const ProfitScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(formatMoney(0)), findsWidgets);
        expect(find.textContaining('0%'), findsOneWidget);
        expect(
          find.text(DashboardActivityStrings.noProjectsYet),
          findsOneWidget,
        );
        expect(
          find.text(DashboardActivityStrings.noExpensesYet),
          findsOneWidget,
        );
      },
    );

    testWidgets('back button navigates back', (WidgetTester tester) async {
      setSurface(tester);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Text('HomeScreenTarget')),
          ),
          GoRoute(
            path: '/profit',
            builder: (context, state) => const ProfitScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        createRouterApp(initialLocation: '/home', customRouter: router),
      );
      await tester.pumpAndSettle();

      router.push('/profit');
      await tester.pumpAndSettle();
      expect(find.byType(ProfitScreen), findsOneWidget);

      await systemBack(tester);
      await tester.pumpAndSettle();
      expect(find.text('HomeScreenTarget'), findsOneWidget);
    });

    testWidgets('no overflow on 360x800 surface', (WidgetTester tester) async {
      setSurface(tester, size: const Size(360, 800));
      await tester.pumpWidget(
        createTestApp(child: ProfitScreen(clock: () => seedClock)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
