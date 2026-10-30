import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/calendar/calendar_forms_strings.dart';
import 'package:dfile_mobile/features/calendar/calendar_month_strings.dart';
import 'package:dfile_mobile/features/calendar/calendar_screen.dart';
import 'package:dfile_mobile/features/calendar/calendar_strings.dart';
import 'package:dfile_mobile/features/calendar/calendar_sync_screen.dart';
import 'package:dfile_mobile/features/calendar/calendar_views_strings.dart';
import 'package:dfile_mobile/features/calendar/capacity_screen.dart';
import 'package:dfile_mobile/features/calendar/data/data.dart';
import 'package:dfile_mobile/features/calendar/milestone_form_screen.dart';
import 'package:dfile_mobile/features/calendar/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/more/more_strings.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
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

  Future<void> pumpBounded(WidgetTester tester, [int count = 5]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('CalendarRepository tests', () {
    test('initializes with the 5 SPEC.md milestone seeds', () {
      final CalendarRepository repo = CalendarRepository();
      expect(repo.milestones.length, 5);

      final Milestone m1 = repo.milestoneById('m1')!;
      expect(m1.title, 'Moodboard sign-off');
      expect(m1.projectId, 'p2');
      expect(m1.completed, true);
      expect(m1.date, DateTime(2026, 10, 15));

      final Milestone m2 = repo.milestoneById('m2')!;
      expect(m2.title, 'Client review');
      expect(m2.projectId, 'p2');
      expect(m2.completed, true);

      final Milestone m3 = repo.milestoneById('m3')!;
      expect(m3.title, 'Send invoice draft');
      expect(m3.projectId, 'p1');
      expect(m3.completed, false);

      final Milestone m4 = repo.milestoneById('m4')!;
      expect(m4.title, 'Beta handoff');
      expect(m4.projectId, 'p1');
      expect(m4.completed, false);

      final Milestone m5 = repo.milestoneById('m5')!;
      expect(m5.title, 'Final delivery review');
      expect(m5.projectId, 'p5');
      expect(m5.completed, false);
    });

    test('addMilestone, toggleMilestone, and deleteMilestone notify listeners', () {
      final CalendarRepository repo = CalendarRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      // addMilestone
      final Milestone added = repo.addMilestone(
        Milestone(
          id: '',
          projectId: 'p1',
          title: 'QA Sign-off',
          date: DateTime(2026, 11, 5),
          completed: false,
          createdAt: DateTime(2026, 10, 30),
        ),
      );
      expect(added.id.isNotEmpty, true);
      expect(repo.milestones.length, 6);
      expect(notifyCount, 1);

      // toggleMilestone
      final bool toggled = repo.toggleMilestone(added.id);
      expect(toggled, true);
      expect(repo.milestoneById(added.id)!.completed, true);
      expect(notifyCount, 2);

      // deleteMilestone
      final bool deleted = repo.deleteMilestone(added.id);
      expect(deleted, true);
      expect(repo.milestones.length, 5);
      expect(notifyCount, 3);
    });

    test('milestonesOf returns filtered unmodifiable milestones', () {
      final CalendarRepository repo = CalendarRepository();
      final List<Milestone> p2Milestones = repo.milestonesOf('p2');
      expect(p2Milestones.length, 2);
      expect(p2Milestones.every((Milestone m) => m.projectId == 'p2'), true);

      final List<Milestone> p1Milestones = repo.milestonesOf('p1');
      expect(p1Milestones.length, 2);
      expect(p1Milestones.every((Milestone m) => m.projectId == 'p1'), true);
    });

    test('sync preferences and markSynced work and clearAll resets everything', () {
      final CalendarRepository repo = CalendarRepository();
      int notifyCount = 0;
      repo.addListener(() => notifyCount++);

      expect(repo.syncDeadlines, true);
      expect(repo.syncMilestones, true);
      expect(repo.syncDebts, false);
      expect(repo.lastSynced, null);

      final DateTime syncTime = DateTime(2026, 10, 30, 14, 30);
      repo.markSynced(syncTime);
      expect(repo.lastSynced, syncTime);
      expect(notifyCount, 1);

      repo.syncDebts = true;
      expect(repo.syncDebts, true);
      expect(notifyCount, 2);

      repo.clearAll();
      expect(repo.milestones.isEmpty, true);
      expect(repo.lastSynced, null);
      expect(repo.syncDeadlines, true);
      expect(repo.syncMilestones, true);
      expect(repo.syncDebts, false);
      expect(notifyCount, 3);
    });
  });

  group('calendarEvents pure function with seeds (now = 2026-10-30)', () {
    final DateTime now = DateTime(2026, 10, 30);

    test('calculates correct overdue deadlines, milestones, debts, and start dates', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final CalendarRepository calendarRepo = CalendarRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      final List<CalendarEvent> events = calendarEvents(
        projects: projectsRepo.projects,
        clients: clientsRepo.clients,
        milestones: calendarRepo.milestones,
        friendTransactions: friendsRepo.transactions,
        friends: friendsRepo.friends,
        now: now,
        includeDebts: true,
      );

      // Verify the three overdue deadlines:
      // Fintask Landing Page: 2026-08-30 -> 61d overdue
      final CalendarEvent fintaskDeadline = events.firstWhere(
        (CalendarEvent e) =>
            e.kind == CalendarEventKind.over && e.title == 'Fintask Landing Page',
      );
      expect(fintaskDeadline.pillText, '61d overdue');
      expect(fintaskDeadline.date, DateTime(2026, 8, 30));

      // Brand Identity: 2026-09-30 -> 30d overdue (Sep 30 to Oct 30 = 30 days)
      final CalendarEvent brandDeadline = events.firstWhere(
        (CalendarEvent e) =>
            e.kind == CalendarEventKind.over && e.title == 'Brand Identity',
      );
      expect(brandDeadline.pillText, '30d overdue');
      expect(brandDeadline.date, DateTime(2026, 9, 30));

      // Dashboard Redesign: 2026-10-25 -> 5d overdue
      final CalendarEvent dashboardDeadline = events.firstWhere(
        (CalendarEvent e) =>
            e.kind == CalendarEventKind.over &&
            e.title == 'Dashboard Redesign',
      );
      expect(dashboardDeadline.pillText, '5d overdue');
      expect(dashboardDeadline.date, DateTime(2026, 10, 25));

      // Verify completed projects have kind `done`
      final CalendarEvent mobileAppDeadline = events.firstWhere(
        (CalendarEvent e) =>
            e.title == 'Mobile App UI' && e.date == DateTime(2026, 6, 12),
      );
      expect(mobileAppDeadline.kind, CalendarEventKind.done);
      expect(mobileAppDeadline.pillText, 'Done');

      final CalendarEvent logoPackDeadline = events.firstWhere(
        (CalendarEvent e) =>
            e.title == 'Logo Pack' && e.date == DateTime(2026, 5, 20),
      );
      expect(logoPackDeadline.kind, CalendarEventKind.done);
      expect(logoPackDeadline.pillText, 'Done');

      // Verify milestones:
      // Moodboard sign-off: done
      final CalendarEvent moodboard = events.firstWhere(
        (CalendarEvent e) => e.title == 'Moodboard sign-off',
      );
      expect(moodboard.kind, CalendarEventKind.done);
      expect(moodboard.pillText, 'Done');
      expect(moodboard.date, DateTime(2026, 10, 15));

      // Client review: done
      final CalendarEvent clientRev = events.firstWhere(
        (CalendarEvent e) => e.title == 'Client review',
      );
      expect(clientRev.kind, CalendarEventKind.done);
      expect(clientRev.pillText, 'Done');
      expect(clientRev.date, DateTime(2026, 10, 28));

      // Send invoice draft: pending on today (2026-10-30) -> Due today
      final CalendarEvent sendDraft = events.firstWhere(
        (CalendarEvent e) => e.title == 'Send invoice draft',
      );
      expect(sendDraft.kind, CalendarEventKind.milestone);
      expect(sendDraft.pillText, 'Due today');
      expect(sendDraft.date, DateTime(2026, 10, 30));

      // Beta handoff: pending on 2026-11-02 -> 3d left
      final CalendarEvent betaHandoff = events.firstWhere(
        (CalendarEvent e) => e.title == 'Beta handoff',
      );
      expect(betaHandoff.kind, CalendarEventKind.milestone);
      expect(betaHandoff.pillText, '3d left');
      expect(betaHandoff.date, DateTime(2026, 11, 2));

      // Final delivery review: pending on 2026-11-12 -> 13d left
      final CalendarEvent finalReview = events.firstWhere(
        (CalendarEvent e) => e.title == 'Final delivery review',
      );
      expect(finalReview.kind, CalendarEventKind.milestone);
      expect(finalReview.pillText, '13d left');
      expect(finalReview.date, DateTime(2026, 11, 12));

      // Verify debt due events on Nov 2, Nov 10, Nov 20:
      final List<CalendarEvent> debts = events
          .where((CalendarEvent e) => e.kind == CalendarEventKind.debt)
          .toList();
      expect(debts.length, 3);

      final CalendarEvent nov2Debt = debts.firstWhere(
        (CalendarEvent e) => e.date == DateTime(2026, 11, 2),
      );
      expect(nov2Debt.title, 'Karim Boualam owes you');
      expect(nov2Debt.subtitle, '30,000 DZ due');

      final CalendarEvent nov10Debt = debts.firstWhere(
        (CalendarEvent e) => e.date == DateTime(2026, 11, 10),
      );
      expect(nov10Debt.title, 'You owe Amine Saidi');
      expect(nov10Debt.subtitle, '12,000 DZ due');

      final CalendarEvent nov20Debt = debts.firstWhere(
        (CalendarEvent e) => e.date == DateTime(2026, 11, 20),
      );
      expect(nov20Debt.title, 'Yacine Mebarki owes you');
      expect(nov20Debt.subtitle, '25,000 DZ due');

      // Verify start date events exist
      final List<CalendarEvent> starts = events
          .where((CalendarEvent e) => e.kind == CalendarEventKind.start)
          .toList();
      expect(starts.length, 5);
      expect(
        starts.any((CalendarEvent e) => e.title == 'Fintask Landing Page starts'),
        true,
      );
    });

    test('includeDebts: false excludes friend debt transactions', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final CalendarRepository calendarRepo = CalendarRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      final List<CalendarEvent> eventsWithoutDebts = calendarEvents(
        projects: projectsRepo.projects,
        milestones: calendarRepo.milestones,
        friendTransactions: friendsRepo.transactions,
        now: now,
        includeDebts: false,
      );

      expect(
        eventsWithoutDebts.any((CalendarEvent e) => e.kind == CalendarEventKind.debt),
        false,
      );
    });
  });

  group('dotsForMonth and eventsOnDay tests', () {
    final DateTime now = DateTime(2026, 10, 30);
    late List<CalendarEvent> events;

    setUp(() {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final CalendarRepository calendarRepo = CalendarRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      events = calendarEvents(
        projects: projectsRepo.projects,
        clients: clientsRepo.clients,
        milestones: calendarRepo.milestones,
        friendTransactions: friendsRepo.transactions,
        friends: friendsRepo.friends,
        now: now,
        includeDebts: true,
      );
    });

    test('dotsForMonth for October 2026', () {
      final Map<int, List<CalendarEventKind>> octDots =
          dotsForMonth(events, 2026, 10);

      // October 15: Moodboard sign-off (done)
      expect(octDots[15], contains(CalendarEventKind.done));

      // October 25: Dashboard Redesign deadline (over)
      expect(octDots[25], contains(CalendarEventKind.over));

      // October 28: Client review (done)
      expect(octDots[28], contains(CalendarEventKind.done));

      // October 30: Send invoice draft (milestone)
      expect(octDots[30], contains(CalendarEventKind.milestone));

      // Ensure all days have at most 3 dots
      for (final List<CalendarEventKind> dotList in octDots.values) {
        expect(dotList.length <= 3, true);
      }
    });

    test('dotsForMonth for November 2026', () {
      final Map<int, List<CalendarEventKind>> novDots =
          dotsForMonth(events, 2026, 11);

      // November 2: Beta handoff (milestone) + Karim debt (debt)
      expect(novDots[2], contains(CalendarEventKind.milestone));
      expect(novDots[2], contains(CalendarEventKind.debt));

      // November 10: Amine debt (debt)
      expect(novDots[10], contains(CalendarEventKind.debt));

      // November 12: Final delivery review (milestone)
      expect(novDots[12], contains(CalendarEventKind.milestone));

      // November 20: Yacine debt (debt)
      expect(novDots[20], contains(CalendarEventKind.debt));
    });

    test('eventsOnDay returns events occurring on specified day', () {
      final List<CalendarEvent> oct30Events =
          eventsOnDay(events, DateTime(2026, 10, 30));
      expect(oct30Events.length, 1);
      expect(oct30Events.first.title, 'Send invoice draft');

      final List<CalendarEvent> nov2Events =
          eventsOnDay(events, DateTime(2026, 11, 2));
      expect(nov2Events.length, 2);
      expect(
        nov2Events.map((CalendarEvent e) => e.kind),
        containsAll([CalendarEventKind.milestone, CalendarEventKind.debt]),
      );
    });
  });

  group('monthGrid calculations', () {
    test('October 2026 = 5 rows starting Thursday offset 4', () {
      final MonthGrid grid = monthGrid(2026, 10);
      expect(grid.year, 2026);
      expect(grid.month, 10);
      expect(grid.weeksCount, 5);
      expect(grid.cells.length, 35);

      // First 4 cells are from September (offset 4)
      for (int i = 0; i < 4; i++) {
        expect(grid.cells[i].inMonth, false);
        expect(grid.cells[i].date.month, 9);
      }

      // Cell 4 is October 1 (Thursday)
      expect(grid.cells[4].inMonth, true);
      expect(grid.cells[4].date, DateTime(2026, 10, 1));

      // Cell 34 is October 31
      expect(grid.cells[34].inMonth, true);
      expect(grid.cells[34].date, DateTime(2026, 10, 31));
    });

    test('November 2026 = 5 rows starting Sunday offset 0', () {
      final MonthGrid grid = monthGrid(2026, 11);
      expect(grid.weeksCount, 5);
      expect(grid.cells.length, 35);

      // Starts Sunday: cell 0 is November 1
      expect(grid.cells[0].inMonth, true);
      expect(grid.cells[0].date, DateTime(2026, 11, 1));
      expect(grid.cells[29].date, DateTime(2026, 11, 30));

      // Remaining cells are December
      for (int i = 30; i < 35; i++) {
        expect(grid.cells[i].inMonth, false);
        expect(grid.cells[i].date.month, 12);
      }
    });

    test('August 2026 = 6 rows starting Saturday offset 6', () {
      final MonthGrid grid = monthGrid(2026, 8);
      expect(grid.weeksCount, 6);
      expect(grid.cells.length, 42);

      // Offset 6 (first 6 cells from July)
      for (int i = 0; i < 6; i++) {
        expect(grid.cells[i].inMonth, false);
      }
      expect(grid.cells[6].inMonth, true);
      expect(grid.cells[6].date, DateTime(2026, 8, 1));
      expect(grid.cells[36].inMonth, true);
      expect(grid.cells[36].date, DateTime(2026, 8, 31));
    });
  });

  group('agendaGroups, timelineWindow, and capacityInfo tests', () {
    final DateTime now = DateTime(2026, 10, 30);
    late List<CalendarEvent> events;

    setUp(() {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final CalendarRepository calendarRepo = CalendarRepository();
      final FriendsRepository friendsRepo = FriendsRepository();

      events = calendarEvents(
        projects: projectsRepo.projects,
        clients: clientsRepo.clients,
        milestones: calendarRepo.milestones,
        friendTransactions: friendsRepo.transactions,
        friends: friendsRepo.friends,
        now: now,
        includeDebts: true,
      );
    });

    test('agendaGroups groups correctly into overdue, today, thisWeek, later', () {
      final AgendaGroups groups = agendaGroups(events, now);

      // Overdue: Fintask, Brand Identity, Dashboard Redesign deadlines
      expect(groups.overdue.length, 3);
      expect(
        groups.overdue.map((CalendarEvent e) => e.title),
        containsAll([
          'Fintask Landing Page',
          'Brand Identity',
          'Dashboard Redesign',
        ]),
      );

      // Today: Send invoice draft milestone
      expect(groups.today.length, 1);
      expect(groups.today.first.title, 'Send invoice draft');

      // This week (next 7 days, up to Nov 6): Beta handoff (Nov 2) & Karim debt (Nov 2)
      expect(groups.thisWeek.length, 2);
      expect(
        groups.thisWeek.map((CalendarEvent e) => e.title),
        containsAll(['Beta handoff', 'Karim Boualam owes you']),
      );

      // Later (up to 90 days): Amine debt (Nov 10), Final delivery review (Nov 12), Yacine debt (Nov 20)
      expect(groups.later.length, 3);
      expect(
        groups.later.map((CalendarEvent e) => e.title),
        containsAll([
          'You owe Amine Saidi',
          'Final delivery review',
          'Yacine Mebarki owes you',
        ]),
      );
    });

    test('timelineWindow spans 4 months starting 2 months before now', () {
      final TimelineWindow window = timelineWindow(now);
      expect(window.startDate, DateTime(2026, 8, 1));
      expect(window.endDate, DateTime(2026, 12, 1));
      expect(window.months.length, 4);
      expect(window.months[0], DateTime(2026, 8, 1));
      expect(window.months[1], DateTime(2026, 9, 1));
      expect(window.months[2], DateTime(2026, 10, 1));
      expect(window.months[3], DateTime(2026, 11, 1));

      // dayOffsetFraction
      expect(dayOffsetFraction(window, DateTime(2026, 8, 1)), 0.0);
      expect(dayOffsetFraction(window, DateTime(2026, 12, 1)), 1.0);

      final double oct30Fraction =
          dayOffsetFraction(window, DateTime(2026, 10, 30));
      expect(oct30Fraction > 0.5 && oct30Fraction < 1.0, true);
    });

    test('capacityInfo matches seeds: 3 active, moderate, avg progress 35, Available now', () {
      final ProjectsRepository projectsRepo = ProjectsRepository();
      final CapacityInfo info = capacityInfo(projectsRepo.projects, now);

      expect(info.activeCount, 3);
      expect(info.level, CapacityLevel.moderate);
      expect(info.level.label, 'Moderate');
      expect(info.level.sentence, 'Selective: you can take one more project.');
      expect(info.averageProgress, 35);
      expect(info.nextAvailableDate, isNull);
      expect(info.nextProject, isNull);
      expect(info.nextSlotLabel, 'Available now');
    });

    test('capacityInfo with future project end dates detects next available slot', () {
      final ProjectsRepository projectsRepo = ProjectsRepository(
        initialProjects: [
          ProjectItem(
            id: 'p10',
            name: 'New Platform',
            category: 'Development',
            clientId: 'c1',
            price: 200000,
            status: ProjectStatus.inProgress,
            progress: 50,
            startDate: DateTime(2026, 10, 1),
            endDate: DateTime(2026, 11, 15),
            createdAt: DateTime(2026, 10, 1),
          ),
        ],
      );

      final CapacityInfo info = capacityInfo(projectsRepo.projects, now);
      expect(info.activeCount, 1);
      expect(info.level, CapacityLevel.light);
      expect(info.nextAvailableDate, DateTime(2026, 11, 15));
      expect(info.nextProject?.name, 'New Platform');
      expect(info.nextSlotLabel, 'Nov 15, 2026');
    });
  });

  group('Shared Calendar Widgets Tests', () {
    testWidgets('CalendarEventCard renders all fields, greys done title, and handles tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      final CalendarEvent activeEvent = CalendarEvent(
        kind: CalendarEventKind.due,
        title: 'Send invoice draft',
        subtitle: 'Fintask Landing Page',
        date: DateTime(2026, 10, 30),
        pillText: 'Today',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarEventCard(
              event: activeEvent,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(find.text('Send invoice draft'), findsOneWidget);
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(AppIcons.calendarClock), findsOneWidget);

      await tester.tap(find.byType(CalendarEventCard));
      await pumpBounded(tester);
      expect(tapped, true);

      // Verify done event greys title
      final CalendarEvent doneEvent = CalendarEvent(
        kind: CalendarEventKind.done,
        title: 'Moodboard sign-off',
        subtitle: 'Brand Identity',
        date: DateTime(2026, 10, 15),
        pillText: 'Done',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarEventCard(
              event: doneEvent,
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      final Text titleText = tester.widget<Text>(find.text('Moodboard sign-off'));
      expect(titleText.style?.color, AppColors.mute);
    });

    testWidgets('CalendarSegmented renders 3 equal segments and fires onChanged', (
      WidgetTester tester,
    ) async {
      CalendarTab selected = CalendarTab.month;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return CalendarSegmented(
                  selectedTab: selected,
                  onChanged: (CalendarTab tab) {
                    setState(() {
                      selected = tab;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await pumpBounded(tester);

      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);

      // Tap Agenda
      await tester.tap(find.text('Agenda'));
      await pumpBounded(tester);
      expect(selected, CalendarTab.agenda);

      // Tap Timeline
      await tester.tap(find.text('Timeline'));
      await pumpBounded(tester);
      expect(selected, CalendarTab.timeline);
    });
  });

  group('Route Placeholders and More Screen Navigation on 390x844 Surface', () {
    testWidgets('All 4 calendar routes render their placeholders with back button', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final GoRouter router = createAppRouter(initialLocation: AppRoutes.morePath);
      await tester.pumpWidget(DfileApp(router: router));
      await pumpBounded(tester);

      // 1. /calendar
      router.go(AppRoutes.calendarPath);
      await pumpBounded(tester);
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.text('CalendarScreen'), findsWidgets);

      // Back button pops or goes to /more
      await tester.tap(find.byIcon(AppIcons.arrowLeft));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.morePath);

      // 2. /calendar/new
      router.go(AppRoutes.calendarNewPath);
      await pumpBounded(tester);
      expect(find.byType(MilestoneFormScreen), findsOneWidget);
      expect(find.text('MilestoneFormScreen'), findsWidgets);

      await tester.tap(find.byIcon(AppIcons.arrowLeft));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.morePath);

      // 3. /calendar/capacity
      router.go(AppRoutes.calendarCapacityPath);
      await pumpBounded(tester);
      expect(find.byType(CapacityScreen), findsOneWidget);
      expect(find.text('CapacityScreen'), findsWidgets);

      await tester.tap(find.byIcon(AppIcons.arrowLeft));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.morePath);

      // 4. /calendar/sync
      router.go(AppRoutes.calendarSyncPath);
      await pumpBounded(tester);
      expect(find.byType(CalendarSyncScreen), findsOneWidget);
      expect(find.text('CalendarSyncScreen'), findsWidgets);

      await tester.tap(find.byIcon(AppIcons.arrowLeft));
      await pumpBounded(tester);
      expect(router.state.uri.toString(), AppRoutes.morePath);
    });

    testWidgets('Tapping Calendar row in MoreScreen navigates to /calendar', (
      WidgetTester tester,
    ) async {
      setTestSurface(tester);
      final GoRouter router = createAppRouter(initialLocation: AppRoutes.morePath);
      await tester.pumpWidget(DfileApp(router: router));
      await pumpBounded(tester);

      expect(find.byType(MoreScreen), findsOneWidget);
      expect(find.text(MoreStrings.calendarTitle), findsOneWidget);
      expect(find.text(MoreStrings.calendarSubtitle), findsOneWidget);

      await tester.tap(find.text(MoreStrings.calendarTitle));
      await pumpBounded(tester);

      expect(router.state.uri.toString(), AppRoutes.calendarPath);
      expect(find.byType(CalendarScreen), findsOneWidget);
    });
  });

  group('String classes presence check', () {
    test('all 4 strings classes exist and can be instantiated or referenced', () {
      expect(CalendarStrings.calendar, 'Calendar');
      expect(CalendarMonthStrings, isNotNull);
      expect(CalendarViewsStrings, isNotNull);
      expect(CalendarFormsStrings, isNotNull);
    });
  });
}
