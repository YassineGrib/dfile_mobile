import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/auth/auth_strings.dart';
import 'package:dfile_mobile/features/auth/sign_in_screen.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/dashboard/cashflow_screen.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_activity_strings.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_charts_strings.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_home_strings.dart';
import 'package:dfile_mobile/features/dashboard/data/data.dart';
import 'package:dfile_mobile/features/dashboard/home_screen.dart';
import 'package:dfile_mobile/features/dashboard/notifications_screen.dart'
    as dashboard;
import 'package:dfile_mobile/features/dashboard/profit_screen.dart';
import 'package:dfile_mobile/features/dashboard/widgets/widgets.dart';
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

  void setTestSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Pure Data Functions (dashboard_stats.dart)', () {
    final DateTime fixedNow = DateTime(2026, 10, 30, 10, 30);

    test('greetingFor returns proper greeting and extracts first name', () {
      expect(greetingFor(DateTime(2026, 10, 30, 8, 0)), 'Good morning');
      expect(greetingFor(DateTime(2026, 10, 30, 14, 0)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 10, 30, 20, 0)), 'Good evening');

      expect(
        greetingFor(DateTime(2026, 10, 30, 9, 0), 'Yassine G.'),
        'Good morning, Yassine',
      );
      expect(
        greetingFor(DateTime(2026, 10, 30, 15, 0), 'Sarah Benali'),
        'Good afternoon, Sarah',
      );
      expect(
        greetingFor(DateTime(2026, 10, 30, 21, 0), 'Mohamed'),
        'Good evening, Mohamed',
      );
    });

    test('netProfit matches seed calculation (573,800 DZ)', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final double profit = netProfit(
        projectsRepo.payments,
        expensesRepo.expenses,
      );
      expect(profit, 573800.0);
    });

    test('monthFlows returns 6 months ending with now (May..Oct 2026) matching seed flows', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final List<MonthFlow> flows = monthFlows(
        fixedNow,
        months: 6,
        payments: projectsRepo.payments,
        expenses: expensesRepo.expenses,
      );

      expect(flows.length, 6);

      // Inflow: 125,000 / 320,000 / 60,000 / 0 / 0 / 60,000
      expect(flows[0].inflow, 125000.0); // May 2026
      expect(flows[1].inflow, 320000.0); // Jun 2026
      expect(flows[2].inflow, 60000.0); // Jul 2026
      expect(flows[3].inflow, 0.0); // Aug 2026
      expect(flows[4].inflow, 0.0); // Sep 2026
      expect(flows[5].inflow, 60000.0); // Oct 2026

      // Outflow: 9,000 / 18,000 / 38,000 / 6,500 / 12,000 / 7,700
      expect(flows[0].outflow, 9000.0); // May 2026
      expect(flows[1].outflow, 18000.0); // Jun 2026
      expect(flows[2].outflow, 38000.0); // Jul 2026
      expect(flows[3].outflow, 6500.0); // Aug 2026
      expect(flows[4].outflow, 12000.0); // Sep 2026
      expect(flows[5].outflow, 7700.0); // Oct 2026

      // Net
      expect(flows[0].net, 116000.0);
      expect(flows[1].net, 302000.0);
      expect(flows[2].net, 22000.0);
      expect(flows[3].net, -6500.0);
      expect(flows[4].net, -12000.0);
      expect(flows[5].net, 52300.0);
    });

    test(
      'thisMonthNet matches current month inflow minus outflow (52,300 DZ)',
      () {
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final ExpensesRepository expensesRepo = ExpensesRepository();

        final double currentNet = thisMonthNet(
          fixedNow,
          payments: projectsRepo.payments,
          expenses: expensesRepo.expenses,
        );
        expect(currentNet, 52300.0);
      },
    );

    test('yearFlows returns 12 calendar months for now.year', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final List<MonthFlow> year = yearFlows(
        fixedNow,
        payments: projectsRepo.payments,
        expenses: expensesRepo.expenses,
      );

      expect(year.length, 12);
      expect(year.first.month.month, 1);
      expect(year.last.month.month, 12);
    });

    test(
      'statusCounts counts 5 active/visible statuses and ignores Cancelled',
      () {
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final Map<ProjectStatus, int> counts = statusCounts(
          projectsRepo.projects,
        );

        expect(counts[ProjectStatus.delivered], 1);
        expect(counts[ProjectStatus.completed], 1);
        expect(counts[ProjectStatus.inProgress], 1);
        expect(counts[ProjectStatus.waitingClient], 1);
        expect(counts[ProjectStatus.planned], 1);
        expect(counts.containsKey(ProjectStatus.cancelled), false);

        // If a cancelled project is present, it must be ignored
        final List<ProjectItem> withCancelled =
            List<ProjectItem>.from(projectsRepo.projects)..add(
              ProjectItem(
                id: 'p_cancel',
                name: 'Cancelled Project',
                category: 'Design',
                clientId: 'c1',
                price: 50000.0,
                status: ProjectStatus.cancelled,
                progress: 10,
                startDate: DateTime(2026, 1, 1),
                createdAt: DateTime(2026, 1, 1),
              ),
            );
        final Map<ProjectStatus, int> countsWithCancelled = statusCounts(
          withCancelled,
        );
        expect(countsWithCancelled[ProjectStatus.cancelled], null);
      },
    );

    test('upcomingDeadlines filters completed/delivered and orders by end date ascending', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final List<DeadlineItem> deadlines = upcomingDeadlines(
        projectsRepo.projects,
        fixedNow,
      );

      // p3 (completed) and p4 (delivered) excluded
      expect(deadlines.length, 3);
      expect(deadlines[0].project.id, 'p1'); // 2026-08-30 (overdue)
      expect(deadlines[0].state, DeadlineState.overdue);
      expect(deadlines[0].daysLeft < 0, true);
      expect(deadlines[0].pillText.startsWith('Overdue'), true);

      expect(deadlines[1].project.id, 'p2'); // 2026-09-30 (overdue)
      expect(deadlines[1].state, DeadlineState.overdue);

      expect(deadlines[2].project.id, 'p5'); // 2026-10-25 (overdue -5d)
      expect(deadlines[2].state, DeadlineState.overdue);

      // Test with upcoming, today, and later deadline states
      final List<ProjectItem> customProjects = <ProjectItem>[
        ProjectItem(
          id: 'proj_today',
          name: 'Due Today',
          category: 'Design',
          clientId: 'c1',
          price: 10000.0,
          status: ProjectStatus.inProgress,
          progress: 50,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 30),
          createdAt: DateTime(2026, 10, 1),
        ),
        ProjectItem(
          id: 'proj_soon',
          name: 'Due Soon',
          category: 'Design',
          clientId: 'c1',
          price: 15000.0,
          status: ProjectStatus.inProgress,
          progress: 50,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 11, 2),
          createdAt: DateTime(2026, 10, 1),
        ),
        ProjectItem(
          id: 'proj_later',
          name: 'Due Later',
          category: 'Design',
          clientId: 'c1',
          price: 20000.0,
          status: ProjectStatus.planned,
          progress: 0,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 11, 20),
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      final List<DeadlineItem> customDeadlines = upcomingDeadlines(
        customProjects,
        fixedNow,
      );
      expect(customDeadlines[0].state, DeadlineState.soon);
      expect(customDeadlines[0].isToday, true);
      expect(customDeadlines[0].pillText, 'Today');

      expect(customDeadlines[1].state, DeadlineState.soon);
      expect(customDeadlines[1].daysLeft, 3);
      expect(customDeadlines[1].pillText, '3d left');

      expect(customDeadlines[2].state, DeadlineState.later);
      expect(customDeadlines[2].daysLeft, 21);
      expect(customDeadlines[2].pillText, '21d left');
    });

    test('topProjectsByPaid and topExpenseCategories ranking', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final List<TopProjectItem> topProjects = topProjectsByPaid(
        projectsRepo.projects,
        projectsRepo.payments,
      );
      expect(topProjects.length, 3);
      expect(topProjects.first.paid, 320000.0); // p3 Mobile App UI

      final List<TopExpenseCategoryItem> topExpenses = topExpenseCategories(
        expensesRepo.expenses,
      );
      expect(topExpenses.length, 3);
      expect(topExpenses.first.category, ExpenseCategory.equipment); // 38,000
    });

    test('profitMargin computes net/revenue percentage correctly', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final double margin = profitMargin(
        projectsRepo.payments,
        expensesRepo.expenses,
      );
      // 573,800 / 665,000 * 100 ~ 86.2857%
      expect(margin, closeTo(86.28, 0.05));

      expect(profitMargin(<ProjectPayment>[], <Expense>[]), 0.0);
    });

    test('recentActivity aggregates payments, expenses, settlements and started projects newest first', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      final List<ActivityItem> activities = recentActivity(
        payments: projectsRepo.payments,
        expenses: expensesRepo.expenses,
        settlements: friendsRepo.settlements,
        friendTransactions: friendsRepo.transactions,
        projects: projectsRepo.projects,
        limit: 10,
      );

      expect(activities.isNotEmpty, true);
      for (int i = 0; i < activities.length - 1; i++) {
        expect(
          activities[i].date.isAfter(activities[i + 1].date) ||
              activities[i].date.isAtSameMomentAs(activities[i + 1].date),
          true,
        );
      }
    });

    test(
      'newAccountSetup accurately detects brand new vs populated account',
      () {
        final ClientsRepository clientsRepo = ClientsRepository();
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final ExpensesRepository expensesRepo = ExpensesRepository();
        final FriendsRepository friendsRepo = FriendsRepository();

        final NewAccountSetup populated = newAccountSetup(
          clients: clientsRepo.clients,
          projects: projectsRepo.projects,
          payments: projectsRepo.payments,
          expenses: expensesRepo.expenses,
          friends: friendsRepo.friends,
        );
        expect(populated.isNewAccount, false);
        expect(populated.completedCount, 3);
        expect(populated.hasClient, true);
        expect(populated.hasProject, true);
        expect(populated.hasPayment, true);

        // Clear all
        clientsRepo.clearAll();
        projectsRepo.clearAll();
        expensesRepo.clearAll();
        friendsRepo.clearAll();

        final NewAccountSetup empty = newAccountSetup(
          clients: clientsRepo.clients,
          projects: projectsRepo.projects,
          payments: projectsRepo.payments,
          expenses: expensesRepo.expenses,
          friends: friendsRepo.friends,
        );
        expect(empty.isNewAccount, true);
        expect(empty.completedCount, 0);
        expect(empty.hasClient, false);
        expect(empty.hasProject, false);
        expect(empty.hasPayment, false);
      },
    );
  });

  group('Notifications derivation and store', () {
    final DateTime fixedNow = DateTime(2026, 10, 30, 10, 30);

    test('deriveNotifications respects notification switch settings', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      const NotificationPrefs allOn = NotificationPrefs(
        push: true,
        deadlines: true,
        payments: true,
        tasks: false,
      );

      final List<AppNotification> notifs = deriveNotifications(
        now: fixedNow,
        settings: allOn,
        projects: projectsRepo.projects,
        transactions: friendsRepo.transactions,
        payments: projectsRepo.payments,
      );
      expect(notifs.isNotEmpty, true);

      // When push is off -> empty
      const NotificationPrefs pushOff = NotificationPrefs(
        push: false,
        deadlines: true,
        payments: true,
        tasks: false,
      );
      expect(
        deriveNotifications(
          now: fixedNow,
          settings: pushOff,
          projects: projectsRepo.projects,
          transactions: friendsRepo.transactions,
          payments: projectsRepo.payments,
        ),
        isEmpty,
      );

      // When deadlines is off -> no deadline items
      const NotificationPrefs deadlinesOff = NotificationPrefs(
        push: true,
        deadlines: false,
        payments: true,
        tasks: false,
      );
      final List<AppNotification> noDeadlines = deriveNotifications(
        now: fixedNow,
        settings: deadlinesOff,
        projects: projectsRepo.projects,
        transactions: friendsRepo.transactions,
        payments: projectsRepo.payments,
      );
      expect(
        noDeadlines.any(
          (AppNotification n) => n.kind == AppNotificationKind.deadline,
        ),
        false,
      );

      // When payments is off -> no payment or overdue debt items
      const NotificationPrefs paymentsOff = NotificationPrefs(
        push: true,
        deadlines: true,
        payments: false,
        tasks: false,
      );
      final List<AppNotification> noPayments = deriveNotifications(
        now: fixedNow,
        settings: paymentsOff,
        projects: projectsRepo.projects,
        transactions: friendsRepo.transactions,
        payments: projectsRepo.payments,
      );
      expect(
        noPayments.any(
          (AppNotification n) => n.kind == AppNotificationKind.payment,
        ),
        false,
      );
      expect(
        noPayments.any(
          (AppNotification n) => n.kind == AppNotificationKind.overdueDebt,
        ),
        false,
      );
    });

    test('NotificationsStore manages read state, unread count, and notification scope', () {
      final NotificationsStore store = NotificationsStore();
      final AppNotification n1 = AppNotification(
        id: 'n1',
        kind: AppNotificationKind.payment,
        title: 'Title 1',
        subtitle: 'Sub 1',
        date: DateTime(2026, 10, 1),
        route: '/route1',
      );
      final AppNotification n2 = AppNotification(
        id: 'n2',
        kind: AppNotificationKind.deadline,
        title: 'Title 2',
        subtitle: 'Sub 2',
        date: DateTime(2026, 10, 2),
        route: '/route2',
      );

      expect(store.unreadCount(<AppNotification>[n1, n2]), 2);
      expect(store.isRead('n1'), false);

      store.markRead('n1');
      expect(store.isRead('n1'), true);
      expect(store.unreadCount(<AppNotification>[n1, n2]), 1);

      store.markAllRead(<String>['n1', 'n2']);
      expect(store.unreadCount(<AppNotification>[n1, n2]), 0);

      store.clear();
      expect(store.unreadCount(<AppNotification>[n1, n2]), 2);
    });
  });

  group('UI Widgets and AppTabBar', () {
    testWidgets('AppTabBar draws real Lucide icons and active seg pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            bottomNavigationBar: AppTabBar(
              currentIndex: AppTabBar.homeTabIndex,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // All 5 real Lucide icons must be present
      expect(find.byIcon(AppIcons.house), findsOneWidget);
      expect(find.byIcon(AppIcons.folderKanban), findsOneWidget);
      expect(find.byIcon(AppIcons.users), findsOneWidget);
      expect(find.byIcon(AppIcons.banknote), findsOneWidget);
      expect(find.byIcon(AppIcons.receipt), findsOneWidget);

      // Home active tab has ink text style and seg background container
      final Text homeText = tester.widget<Text>(find.text('Home'));
      expect(homeText.style?.color, AppColors.ink);
      expect(homeText.style?.fontWeight, FontWeight.w700);

      // Payments tab inactive has mute color
      final Text moreText = tester.widget<Text>(find.text('Payments'));
      expect(moreText.style?.color, AppColors.mute);
    });

    testWidgets('AppTabBar Home tab navigates to /home', (
      WidgetTester tester,
    ) async {
      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.clientsPath,
      );
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), AppRoutes.clientsPath);

      // Tap Home in AppTabBar
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), AppRoutes.homePath);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Shared Dash widgets render as designed', (
      WidgetTester tester,
    ) async {
      bool tappedAction = false;
      bool tappedCard = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const DashIconBubble(
                    icon: AppIcons.wallet,
                    background: AppColors.orangeBg,
                    foreground: AppColors.orange,
                  ),
                  DashSectionHead(
                    title: 'Upcoming deadlines',
                    onAction: () => tappedAction = true,
                  ),
                  DashCard(
                    onTap: () => tappedCard = true,
                    child: const Text('Card Content'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(AppIcons.wallet), findsOneWidget);
      expect(find.text('Upcoming deadlines'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.byIcon(AppIcons.chevronRight), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);

      await tester.tap(find.text('See all'));
      await tester.pump();
      expect(tappedAction, true);

      await tester.tap(find.text('Card Content'));
      await tester.pump();
      expect(tappedCard, true);
    });
  });

  group('Route Placeholders and Auth Navigation', () {
    testWidgets('Sign-in navigates to /home instead of /clients', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final GoRouter router = createAppRouter(
        initialLocation: AppRoutes.signInPath,
      );
      await tester.pumpWidget(DfileApp(router: router));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);

      final Finder textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'user@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.tap(find.widgetWithText(PrimaryButton, AuthStrings.signIn));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), AppRoutes.homePath);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
      'All 4 dashboard routes resolve to their screens with working back buttons',
      (WidgetTester tester) async {
        setTestSurface(tester);
        final GoRouter router = createAppRouter(
          initialLocation: AppRoutes.homePath,
        );
        await tester.pumpWidget(DfileApp(router: router));
        await tester.pumpAndSettle();

        // /home
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text(DashboardHomeStrings.quickActions), findsOneWidget);

        // /home/cashflow
        router.go(AppRoutes.cashflowPath);
        await tester.pumpAndSettle();
        expect(find.byType(CashflowScreen), findsOneWidget);
        expect(find.text(DashboardChartsStrings.cashflow), findsOneWidget);

        // /home/profit
        router.go(AppRoutes.profitPath);
        await tester.pumpAndSettle();
        expect(find.byType(ProfitScreen), findsOneWidget);
        expect(find.text(DashboardActivityStrings.profit), findsOneWidget);

        // /home/notifications
        router.go(AppRoutes.homeNotificationsPath);
        await tester.pumpAndSettle();
        expect(find.byType(dashboard.NotificationsScreen), findsOneWidget);
        expect(
          find.text(DashboardActivityStrings.notifications),
          findsOneWidget,
        );
      },
    );

    testWidgets('Card widgets render real content', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
      final ExpensesRepository expensesRepo = ExpensesRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ClientsScope(
                repository: clientsRepo,
                child: ProjectsScope(
                  repository: projectsRepo,
                  child: ExpensesScope(
                    repository: expensesRepo,
                    child: FriendsScope(
                      repository: friendsRepo,
                      child: const Column(
                        children: [
                          CashflowCard(),
                          StatusDonutCard(),
                          ActivityCard(),
                          FriendsSnapshotCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashflowCard), findsOneWidget);
      expect(find.byType(StatusDonutCard), findsOneWidget);
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.byType(FriendsSnapshotCard), findsOneWidget);

      expect(find.text(DashboardChartsStrings.cashflow), findsOneWidget);
      expect(
        find.text(DashboardChartsStrings.projectsByStatus),
        findsOneWidget,
      );
      expect(
        find.text(DashboardActivityStrings.recentActivity),
        findsOneWidget,
      );
      expect(find.text(DashboardActivityStrings.friendsDebts), findsOneWidget);
    });
  });
}
