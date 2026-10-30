import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/app_icons.dart';
import 'package:dfile_mobile/features/dashboard/cashflow_screen.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_charts_strings.dart';
import 'package:dfile_mobile/features/dashboard/data/data.dart';
import 'package:dfile_mobile/features/dashboard/widgets/cashflow_card.dart';
import 'package:dfile_mobile/features/dashboard/widgets/chart_cashflow_chart.dart';
import 'package:dfile_mobile/features/dashboard/widgets/status_donut_card.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final DateTime fixedNow = DateTime(2026, 10, 30);

  void setTestSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildScopedApp({
    required Widget child,
    ProjectsRepository? projectsRepo,
    ExpensesRepository? expensesRepo,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.bg,
        body: ProjectsScope(
          repository: projectsRepo ?? ProjectsRepository(),
          child: ExpensesScope(
            repository: expensesRepo ?? ExpensesRepository(),
            child: child,
          ),
        ),
      ),
    );
  }

  group('CashflowChart Widget', () {
    testWidgets(
      'chart renders for 6 months without exceptions and displays month labels',
      (WidgetTester tester) async {
        setTestSurface(tester);

        final List<MonthFlow> sixMonthFlows = <MonthFlow>[
          MonthFlow(
            month: DateTime(2026, 5, 1),
            inflow: 125000,
            outflow: 9000,
            net: 116000,
          ),
          MonthFlow(
            month: DateTime(2026, 6, 1),
            inflow: 320000,
            outflow: 18000,
            net: 302000,
          ),
          MonthFlow(
            month: DateTime(2026, 7, 1),
            inflow: 60000,
            outflow: 38000,
            net: 22000,
          ),
          MonthFlow(
            month: DateTime(2026, 8, 1),
            inflow: 0,
            outflow: 6500,
            net: -6500,
          ),
          MonthFlow(
            month: DateTime(2026, 9, 1),
            inflow: 0,
            outflow: 12000,
            net: -12000,
          ),
          MonthFlow(
            month: DateTime(2026, 10, 1),
            inflow: 60000,
            outflow: 7700,
            net: 52300,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: CashflowChart(flows: sixMonthFlows),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CashflowChart), findsOneWidget);
        expect(find.text('May'), findsOneWidget);
        expect(find.text('Jun'), findsOneWidget);
        expect(find.text('Jul'), findsOneWidget);
        expect(find.text('Aug'), findsOneWidget);
        expect(find.text('Sep'), findsOneWidget);
        expect(find.text('Oct'), findsOneWidget);
      },
    );

    testWidgets(
      'chart renders for 12 months without exceptions and labels stay readable',
      (WidgetTester tester) async {
        setTestSurface(tester, size: const Size(360, 800));

        final List<MonthFlow> twelveMonthFlows = List<MonthFlow>.generate(12, (
          int i,
        ) {
          return MonthFlow(
            month: DateTime(2026, i + 1, 1),
            inflow: (i == 5) ? 320000.0 : ((i % 2 == 0) ? 50000.0 : 0.0),
            outflow: 10000.0,
            net: (i == 5) ? 310000.0 : 40000.0,
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: CashflowChart(flows: twelveMonthFlows),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CashflowChart), findsOneWidget);
        expect(find.text('Jan'), findsOneWidget);
        expect(find.text('Dec'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'chart renders for empty data without exceptions (flat line and friendly line)',
      (WidgetTester tester) async {
        setTestSurface(tester);

        final List<MonthFlow> zeroFlows = List<MonthFlow>.generate(6, (int i) {
          return MonthFlow(
            month: DateTime(2026, i + 1, 1),
            inflow: 0.0,
            outflow: 0.0,
            net: 0.0,
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: CashflowChart(flows: zeroFlows),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CashflowChart), findsOneWidget);
        expect(
          find.text(DashboardChartsStrings.noCashMovement),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'best month bubble text "+320,000" renders above best inflow month',
      (WidgetTester tester) async {
        setTestSurface(tester);

        final List<MonthFlow> flows = <MonthFlow>[
          MonthFlow(
            month: DateTime(2026, 5, 1),
            inflow: 125000,
            outflow: 9000,
            net: 116000,
          ),
          MonthFlow(
            month: DateTime(2026, 6, 1),
            inflow: 320000,
            outflow: 18000,
            net: 302000,
          ),
          MonthFlow(
            month: DateTime(2026, 7, 1),
            inflow: 60000,
            outflow: 38000,
            net: 22000,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: CashflowChart(flows: flows),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('+320,000'), findsOneWidget);
      },
    );
  });

  group('CashflowCard Widget', () {
    testWidgets(
      'renders title, toggle, 6-month legend totals, and hint on 390x844',
      (WidgetTester tester) async {
        setTestSurface(tester);
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final ExpensesRepository expensesRepo = ExpensesRepository();

        await tester.pumpWidget(
          buildScopedApp(
            projectsRepo: projectsRepo,
            expensesRepo: expensesRepo,
            child: SingleChildScrollView(
              child: CashflowCard(clock: () => fixedNow),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(DashboardChartsStrings.cashflow), findsOneWidget);
        expect(find.text(DashboardChartsStrings.sixMonths), findsOneWidget);
        expect(find.text(DashboardChartsStrings.year), findsOneWidget);

        // Inflow: 565,000, Outflow: 91,200, Net: 473,800
        expect(find.text('565,000'), findsOneWidget);
        expect(find.text('91,200'), findsOneWidget);
        expect(find.text('473,800'), findsOneWidget);

        expect(
          find.text(DashboardChartsStrings.tapToSeeEveryMonth),
          findsOneWidget,
        );
        expect(find.byIcon(AppIcons.chevronRight), findsOneWidget);
      },
    );

    testWidgets('the card toggle switches the totals between 6 mo and Year', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          child: SingleChildScrollView(
            child: CashflowCard(clock: () => fixedNow),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial 6-month total: 565,000
      expect(find.text('565,000'), findsOneWidget);

      // Switch to Year
      await tester.tap(find.text(DashboardChartsStrings.year));
      await tester.pumpAndSettle();

      // Year total includes April (+100k) -> 665,000
      expect(find.text('665,000'), findsOneWidget);

      // Switch back to 6 mo
      await tester.tap(find.text(DashboardChartsStrings.sixMonths));
      await tester.pumpAndSettle();

      expect(find.text('565,000'), findsOneWidget);
    });

    testWidgets('tapping the card opens /home/cashflow', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      final GoRouter router = GoRouter(
        initialLocation: '/home',
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (BuildContext context, GoRouterState state) {
              return Scaffold(
                body: SingleChildScrollView(
                  child: CashflowCard(clock: () => fixedNow),
                ),
              );
            },
          ),
          GoRoute(
            path: '/home/cashflow',
            builder: (BuildContext context, GoRouterState state) {
              return CashflowScreen(clock: () => fixedNow);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProjectsScope(
          repository: projectsRepo,
          child: ExpensesScope(
            repository: expensesRepo,
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CashflowCard), findsOneWidget);

      // Tap on card title
      await tester.tap(find.text(DashboardChartsStrings.cashflow));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/home/cashflow');
      expect(find.byType(CashflowScreen), findsOneWidget);
    });

    testWidgets('CashflowCard has no overflow on 360x800 surface', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester, size: const Size(360, 800));
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          child: SingleChildScrollView(
            child: CashflowCard(clock: () => fixedNow),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('StatusDonutCard Widget', () {
    testWidgets(
      'donut counts render total in center and legend items with counts',
      (WidgetTester tester) async {
        setTestSurface(tester);
        final ProjectsRepository projectsRepo = ProjectsRepository();

        await tester.pumpWidget(
          buildScopedApp(
            projectsRepo: projectsRepo,
            child: SingleChildScrollView(
              child: StatusDonutCard(clock: () => fixedNow),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(DashboardChartsStrings.projectsByStatus),
          findsOneWidget,
        );
        expect(find.text('5'), findsOneWidget);
        expect(find.text(DashboardChartsStrings.projects), findsOneWidget);

        expect(find.text(DashboardChartsStrings.delivered), findsOneWidget);
        expect(find.text(DashboardChartsStrings.completed), findsOneWidget);
        expect(find.text(DashboardChartsStrings.inProgress), findsOneWidget);
        expect(find.text(DashboardChartsStrings.waitingClient), findsOneWidget);
        expect(find.text(DashboardChartsStrings.planned), findsOneWidget);

        // Each count is 1 in seed data
        expect(find.text('1'), findsNWidgets(5));
      },
    );

    testWidgets('empty line is displayed when no projects exist', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ProjectsRepository emptyRepo = ProjectsRepository(
        initialProjects: const <ProjectItem>[],
        initialTasks: const <ProjectTask>[],
        initialPayments: const <ProjectPayment>[],
      );

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: emptyRepo,
          child: SingleChildScrollView(
            child: StatusDonutCard(clock: () => fixedNow),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(DashboardChartsStrings.projectsByStatus),
        findsOneWidget,
      );
      expect(find.text(DashboardChartsStrings.noProjectsYet), findsOneWidget);
      expect(find.text(DashboardChartsStrings.projects), findsNothing);
    });

    testWidgets('StatusDonutCard has no overflow on 360x800 surface', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester, size: const Size(360, 800));
      final ProjectsRepository projectsRepo = ProjectsRepository();

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: projectsRepo,
          child: SingleChildScrollView(
            child: StatusDonutCard(clock: () => fixedNow),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('CashflowScreen Widget', () {
    testWidgets(
      'renders back, title, toggle, chart card, headers, and month rows with right numbers',
      (WidgetTester tester) async {
        setTestSurface(tester);
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final ExpensesRepository expensesRepo = ExpensesRepository();

        await tester.pumpWidget(
          buildScopedApp(
            projectsRepo: projectsRepo,
            expensesRepo: expensesRepo,
            child: CashflowScreen(clock: () => fixedNow),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(DashboardChartsStrings.cashflow), findsOneWidget);
        expect(find.byIcon(AppIcons.arrowLeft), findsOneWidget);
        expect(find.text(DashboardChartsStrings.lastSixMonths), findsOneWidget);
        expect(find.text(DashboardChartsStrings.thisYear), findsOneWidget);
        expect(find.text(DashboardChartsStrings.monthByMonth), findsOneWidget);
        expect(find.text(DashboardChartsStrings.inHeader), findsOneWidget);
        expect(find.text(DashboardChartsStrings.outHeader), findsOneWidget);
        expect(find.text(DashboardChartsStrings.netHeader), findsWidgets);

        // Verify month rows from seed data (newest first)
        expect(find.text('Oct 2026'), findsOneWidget);
        expect(find.text('+60k'), findsWidgets);
        expect(find.text('-7.7k'), findsOneWidget);
        expect(find.text('+52.3k'), findsOneWidget);

        expect(find.text('Sep 2026'), findsOneWidget);
        expect(find.text('-12k'), findsWidgets);

        expect(find.text('Aug 2026'), findsOneWidget);
        expect(find.text('-6.5k'), findsWidgets);

        expect(find.text('Jul 2026'), findsOneWidget);
        expect(find.text('-38k'), findsOneWidget);
        expect(find.text('+22k'), findsOneWidget);

        expect(find.text('Jun 2026'), findsOneWidget);
        expect(find.text('+320k'), findsOneWidget);
        expect(find.text('-18k'), findsOneWidget);
        expect(find.text('+302k'), findsOneWidget);

        expect(find.text('May 2026'), findsOneWidget);
        expect(find.text('+125k'), findsOneWidget);
        expect(find.text('-9k'), findsOneWidget);
        expect(find.text('+116k'), findsOneWidget);
      },
    );

    testWidgets('screen toggle switches between Last 6 months and This year', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          child: CashflowScreen(clock: () => fixedNow),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to This year
      await tester.tap(find.text(DashboardChartsStrings.thisYear));
      await tester.pumpAndSettle();

      // April 2026 is visible in This year
      expect(find.text('Apr 2026'), findsOneWidget);
      expect(find.text('+100k'), findsWidgets);
    });

    testWidgets('tapping a month row does nothing and causes no crash', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ExpensesRepository expensesRepo = ExpensesRepository();

      await tester.pumpWidget(
        buildScopedApp(
          projectsRepo: projectsRepo,
          expensesRepo: expensesRepo,
          child: CashflowScreen(clock: () => fixedNow),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jun 2026'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'CashflowScreen has no overflow on 360x800 surface and scrolls',
      (WidgetTester tester) async {
        setTestSurface(tester, size: const Size(360, 800));
        final ProjectsRepository projectsRepo = ProjectsRepository();
        final ExpensesRepository expensesRepo = ExpensesRepository();

        await tester.pumpWidget(
          buildScopedApp(
            projectsRepo: projectsRepo,
            expensesRepo: expensesRepo,
            child: CashflowScreen(clock: () => fixedNow),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Drag to scroll
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
