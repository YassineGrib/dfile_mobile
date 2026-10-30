import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/app_icons.dart';
import 'package:dfile_mobile/features/calendar/calendar_views_strings.dart';
import 'package:dfile_mobile/features/calendar/data/data.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_agenda_view.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_timeline_view.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setTestSurface(WidgetTester tester, {double width = 390, double height = 844}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpBounded(WidgetTester tester, [int count = 5]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  final DateTime testNow = DateTime(2026, 10, 30);

  group('CalendarAgendaView Tests', () {
    late ProjectsRepository projectsRepo;
    late ClientsRepository clientsRepo;
    late CalendarRepository calendarRepo;
    late FriendsRepository friendsRepo;
    late List<CalendarEvent> events;

    setUp(() {
      projectsRepo = ProjectsRepository();
      clientsRepo = ClientsRepository();
      calendarRepo = CalendarRepository();
      friendsRepo = FriendsRepository();

      events = calendarEvents(
        projects: projectsRepo.projects,
        clients: clientsRepo.clients,
        milestones: calendarRepo.milestones,
        friendTransactions: friendsRepo.transactions,
        friends: friendsRepo.friends,
        now: testNow,
        includeDebts: true,
      );
    });

    GoRouter createAgendaTestRouter(Widget child) {
      return GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: child),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => Scaffold(
              body: Text('CalendarDate:${state.uri.queryParameters['date']}'),
            ),
          ),
          GoRoute(
            path: '/friends/transactions/:id',
            builder: (context, state) => Scaffold(
              body: Text('FriendTx:${state.pathParameters['id']}'),
            ),
          ),
        ],
      );
    }

    testWidgets(
      'agenda groups, counts, order and date subtitles with clock = 2026-10-30 and seeds',
      (WidgetTester tester) async {
        setTestSurface(tester);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CalendarAgendaView(
                events: events,
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        );
        await pumpBounded(tester);

        // Group headers
        expect(find.text(CalendarViewsStrings.overdueLabel(3)), findsOneWidget);
        expect(find.text(CalendarViewsStrings.todayLabel), findsOneWidget);
        expect(find.text(CalendarViewsStrings.thisWeekLabel), findsOneWidget);
        expect(find.text(CalendarViewsStrings.laterLabel), findsOneWidget);

        // Subtitles for overdue (non-today group)
        expect(find.text('Sun, Aug 30  -  Mohamed Bachir'), findsOneWidget);
        expect(find.text('Wed, Sep 30  -  Sarah Benali'), findsOneWidget);
        expect(find.text('Sun, Oct 25  -  Sarah Benali'), findsOneWidget);

        // Subtitle for today (today group has NO date prefix)
        expect(find.text('Fintask Landing Page'), findsWidgets);

        // Subtitles for this week (non-today group)
        expect(find.text('Mon, Nov 2  -  Fintask Landing Page'), findsOneWidget);
        expect(find.text('Mon, Nov 2  -  30,000 DZ due'), findsOneWidget);

        // Subtitles for later (non-today group)
        expect(find.text('Tue, Nov 10  -  12,000 DZ due'), findsOneWidget);
        expect(find.text('Thu, Nov 12  -  Dashboard Redesign'), findsOneWidget);
        expect(find.text('Fri, Nov 20  -  25,000 DZ due'), findsOneWidget);
      },
    );

    testWidgets('taps navigate: milestone card to month view with date query', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      final GoRouter router = createAgendaTestRouter(
        CalendarAgendaView(
          events: events,
          now: testNow,
          clock: () => testNow,
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
      await pumpBounded(tester);

      // Tap "Beta handoff" card (milestone on Nov 2, 2026)
      await tester.tap(find.text('Beta handoff'));
      await pumpBounded(tester);

      expect(router.state.uri.toString(), '/calendar?date=2026-11-02');
      expect(find.text('CalendarDate:2026-11-02'), findsOneWidget);
    });

    testWidgets('taps navigate: debt card to /friends/transactions/<id>', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      final GoRouter router = createAgendaTestRouter(
        CalendarAgendaView(
          events: events,
          now: testNow,
          clock: () => testNow,
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
      await pumpBounded(tester);

      // Tap Karim Boualam debt card (tx1)
      await tester.tap(find.text('Karim Boualam owes you'));
      await pumpBounded(tester);

      expect(router.state.uri.toString(), '/friends/transactions/tx1');
      expect(find.text('FriendTx:tx1'), findsOneWidget);
    });

    testWidgets('empty state with all repositories cleared', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarAgendaView(
              events: const <CalendarEvent>[],
              now: testNow,
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(find.text(CalendarViewsStrings.emptyAgenda), findsOneWidget);
      expect(find.byIcon(AppIcons.calendarDays), findsOneWidget);
    });

    testWidgets('360x800 no-overflow for CalendarAgendaView', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester, width: 360, height: 800);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarAgendaView(
              events: events,
              now: testNow,
              clock: () => testNow,
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('CalendarTimelineView Tests', () {
    late ProjectsRepository projectsRepo;
    late ClientsRepository clientsRepo;
    late CalendarRepository calendarRepo;

    setUp(() {
      projectsRepo = ProjectsRepository();
      clientsRepo = ClientsRepository();
      calendarRepo = CalendarRepository();
    });

    GoRouter createTimelineTestRouter(Widget child) {
      return GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: child),
          ),
          GoRoute(
            path: '/calendar/capacity',
            builder: (context, state) => const Scaffold(
              body: Text('CapacityPage'),
            ),
          ),
          GoRoute(
            path: '/projects/:id',
            builder: (context, state) => Scaffold(
              body: Text('ProjectPage:${state.pathParameters['id']}'),
            ),
          ),
        ],
      );
    }

    Widget wrapWithScopes({
      required Widget child,
      ProjectsRepository? projects,
      ClientsRepository? clients,
      CalendarRepository? calendar,
    }) {
      return ProjectsScope(
        repository: projects ?? projectsRepo,
        child: ClientsScope(
          repository: clients ?? clientsRepo,
          child: CalendarScope(
            repository: calendar ?? calendarRepo,
            child: child,
          ),
        ),
      );
    }

    testWidgets('timeline pills filter between Ongoing and All (N)', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      // Ongoing is default: 3 ongoing projects shown
      expect(find.text(CalendarViewsStrings.ongoingPill), findsOneWidget);
      expect(find.text('All (5)'), findsOneWidget);
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('Brand Identity'), findsOneWidget);
      expect(find.text('Dashboard Redesign'), findsOneWidget);
      expect(find.text('Mobile App UI'), findsNothing);
      expect(find.text('Logo Pack'), findsNothing);

      // Tap "All (5)"
      await tester.tap(find.text('All (5)'));
      await pumpBounded(tester);

      // Now all 5 projects appear in the grid
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('Brand Identity'), findsOneWidget);
      expect(find.text('Dashboard Redesign'), findsOneWidget);
      expect(find.text('Mobile App UI'), findsOneWidget);
      expect(find.text('Logo Pack'), findsOneWidget);

      // Tap "Ongoing" back
      await tester.tap(find.text(CalendarViewsStrings.ongoingPill));
      await pumpBounded(tester);

      expect(find.text('Mobile App UI'), findsNothing);
      expect(find.text('Logo Pack'), findsNothing);
    });

    testWidgets('bar presence per project and chevron-left for early-starting project', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      // 3 bars present for the 3 ongoing projects
      expect(find.byType(CalendarProjectBar), findsNWidgets(3));
      expect(find.byKey(const ValueKey('project_bar_p1')), findsOneWidget);
      expect(find.byKey(const ValueKey('project_bar_p2')), findsOneWidget);
      expect(find.byKey(const ValueKey('project_bar_p5')), findsOneWidget);

      // Fintask (p1) started on July 1 (before window Aug 1), so it carries chevron-left inside
      final Finder p1Bar = find.byKey(const ValueKey('project_bar_p1'));
      expect(
        find.descendant(of: p1Bar, matching: find.byIcon(AppIcons.chevronLeft)),
        findsOneWidget,
      );
    });

    testWidgets('today line and today flag are present', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      // Red Today line spans across rows
      expect(find.byType(CalendarTodayLine), findsWidgets);
      // "Today" flag at the top of the timeline
      expect(find.text(CalendarViewsStrings.todayFlag), findsOneWidget);
      expect(find.byKey(const ValueKey('timeline_today_flag')), findsOneWidget);
    });

    testWidgets('milestone dots count matches seeds within window', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      // Ongoing projects:
      // p1 (Fintask): m3 (Oct 30) & m4 (Nov 2) -> 2 dots
      // p2 (Brand Identity): m1 (Oct 15) & m2 (Oct 28) -> 2 dots
      // p5 (Dashboard Redesign): m5 (Nov 12) -> 1 dot
      // Total milestone dots = 5
      expect(find.byType(CalendarMilestoneDot), findsNWidgets(5));
      expect(find.byKey(const ValueKey('milestone_dot_m1')), findsOneWidget);
      expect(find.byKey(const ValueKey('milestone_dot_m2')), findsOneWidget);
      expect(find.byKey(const ValueKey('milestone_dot_m3')), findsOneWidget);
      expect(find.byKey(const ValueKey('milestone_dot_m4')), findsOneWidget);
      expect(find.byKey(const ValueKey('milestone_dot_m5')), findsOneWidget);
    });

    testWidgets('capacity card displays Moderate workload and navigates on tap', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      final GoRouter router = createTimelineTestRouter(
        wrapWithScopes(
          child: CalendarTimelineView(
            now: testNow,
            clock: () => testNow,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
      await pumpBounded(tester);

      expect(find.text(CalendarViewsStrings.capacityTitle), findsOneWidget);
      expect(find.text('Moderate workload'), findsOneWidget);
      expect(find.byIcon(AppIcons.gauge), findsOneWidget);

      // Tap capacity card
      await tester.tap(find.byKey(const ValueKey('timeline_capacity_card')));
      await pumpBounded(tester);

      expect(router.state.uri.toString(), '/calendar/capacity');
      expect(find.text('CapacityPage'), findsOneWidget);
    });

    testWidgets('row tap navigates to /projects/:id', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      final GoRouter router = createTimelineTestRouter(
        wrapWithScopes(
          child: CalendarTimelineView(
            now: testNow,
            clock: () => testNow,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
      await pumpBounded(tester);

      // Tap project row "Fintask Landing Page"
      await tester.tap(find.text('Fintask Landing Page'));
      await pumpBounded(tester);

      expect(router.state.uri.toString(), '/projects/p1');
      expect(find.text('ProjectPage:p1'), findsOneWidget);
    });

    testWidgets('empty state displays friendly message when projects repository is empty', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);

      final ProjectsRepository emptyProjects = ProjectsRepository(initialProjects: []);
      final CalendarRepository emptyCalendar = CalendarRepository(initialMilestones: []);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              projects: emptyProjects,
              calendar: emptyCalendar,
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(find.text(CalendarViewsStrings.emptyTimeline), findsOneWidget);
      expect(find.text('All (0)'), findsOneWidget);
    });

    testWidgets('360x800 no-overflow for CalendarTimelineView', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester, width: 360, height: 800);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: wrapWithScopes(
              child: CalendarTimelineView(
                now: testNow,
                clock: () => testNow,
              ),
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
