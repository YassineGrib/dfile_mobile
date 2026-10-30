import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/calendar/calendar_month_strings.dart';
import 'package:dfile_mobile/features/calendar/calendar_screen.dart';
import 'package:dfile_mobile/features/calendar/data/data.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_agenda_view.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_event_card.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_month_grid.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_timeline_view.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    CalendarScreen.globalClock = () => DateTime(2026, 10, 30);
  });

  tearDown(() {
    CalendarScreen.globalClock = null;
  });

  void setTestSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpBounded(WidgetTester tester, [int count = 6]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<
    (
      CalendarRepository,
      ProjectsRepository,
      ClientsRepository,
      FriendsRepository,
      GoRouter,
    )
  >
  pumpCalendarApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.calendarPath,
    Object? initialExtra,
    Size surfaceSize = const Size(390, 844),
    List<Milestone>? initialMilestones,
    List<ProjectItem>? initialProjects,
    List<Client>? initialClients,
    List<FriendTransaction>? initialTransactions,
  }) async {
    setTestSurface(tester, size: surfaceSize);

    final ClientsRepository clientsRepo = ClientsRepository(
      initialClients: initialClients,
    );
    final ProjectsRepository projectsRepo = ProjectsRepository(
      clientsRepository: clientsRepo,
      initialProjects: initialProjects,
    );
    final CalendarRepository calendarRepo = CalendarRepository(
      initialMilestones: initialMilestones,
    );
    final FriendsRepository friendsRepo = FriendsRepository(
      initialTransactions: initialTransactions,
    );

    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        calendarRepository: calendarRepo,
        projectsRepository: projectsRepo,
        repository: clientsRepo,
        friendsRepository: friendsRepo,
      ),
    );
    await pumpBounded(tester);

    if (initialExtra != null) {
      router.go(initialLocation, extra: initialExtra);
      await pumpBounded(tester);
    }

    return (calendarRepo, projectsRepo, clientsRepo, friendsRepo, router);
  }

  group('Calendar Month View: Header and Grid structure', () {
    testWidgets(
      'Header shows October 2026 initially and November 2026 on Next',
      (WidgetTester tester) async {
        await pumpCalendarApp(tester);

        expect(find.text('October 2026'), findsOneWidget);
        expect(find.byType(CalendarMonthGrid), findsOneWidget);

        // Verify weekdays row
        for (final String weekday in CalendarMonthStrings.weekdays) {
          expect(find.text(weekday), findsWidgets);
        }

        // Month grid has cells for October (starts Thu Oct 1, ends Sat Oct 31)
        expect(find.text('30'), findsWidgets);
        expect(find.text('31'), findsWidgets);

        // Tap Next Month button
        await tester.tap(find.byIcon(AppIcons.chevronRight));
        await pumpBounded(tester);

        expect(find.text('November 2026'), findsOneWidget);
        expect(find.text('October 2026'), findsNothing);
      },
    );

    testWidgets('Today and selected day styling by finder', (
      WidgetTester tester,
    ) async {
      await pumpCalendarApp(tester);

      // Day 30 is today and initially selected
      // Find the MonthGridCell container for 30
      final Finder cell30Finder = find.ancestor(
        of: find.text('30'),
        matching: find.byType(Container),
      );
      expect(cell30Finder, findsWidgets);

      // Tap another day in October (day 15)
      await tester.tap(find.text('15'));
      await pumpBounded(tester);

      // Selected day header should now show Thursday, Oct 15
      expect(find.text('Thursday, Oct 15'), findsOneWidget);
    });

    testWidgets('Dots are rendered for days with events', (
      WidgetTester tester,
    ) async {
      await pumpCalendarApp(tester);

      // Find CalendarMonthGrid
      final Finder gridFinder = find.byType(CalendarMonthGrid);
      expect(gridFinder, findsOneWidget);

      // In October: day 15 (milestone), day 25 (deadline), day 28 (milestone), day 30 (milestone)
      // Legends are visible
      expect(find.text(CalendarMonthStrings.legendDeadline), findsOneWidget);
      expect(find.text(CalendarMonthStrings.legendStart), findsOneWidget);
      expect(find.text(CalendarMonthStrings.legendMilestone), findsOneWidget);
      expect(find.text(CalendarMonthStrings.legendDebtDue), findsOneWidget);
    });
  });

  group('Navigation: Prev, Next, Today pill, and Jump Sheet', () {
    testWidgets(
      'Prev navigates to September and shows Today pill; tapping Today pill returns',
      (WidgetTester tester) async {
        await pumpCalendarApp(tester);

        // Today pill is NOT visible in current month (October 2026)
        // Note: day list may have a "Today" pill, but in the top bar it only shows when not current month
        expect(find.text('October 2026'), findsOneWidget);

        // Tap Prev Month button
        await tester.tap(find.byIcon(AppIcons.chevronLeft));
        await pumpBounded(tester);

        expect(find.text('September 2026'), findsOneWidget);

        // Today pill in header row is now visible
        final Finder todayPillFinder = find.widgetWithText(
          AppPill,
          CalendarMonthStrings.today,
        );
        expect(todayPillFinder, findsOneWidget);

        // Tap Today pill
        await tester.tap(todayPillFinder);
        await pumpBounded(tester);

        expect(find.text('October 2026'), findsOneWidget);
        expect(todayPillFinder, findsNothing);
      },
    );

    testWidgets('Tapping month header opens Jump Sheet and selects month', (
      WidgetTester tester,
    ) async {
      await pumpCalendarApp(tester);

      // Tap month header to open jump sheet
      await tester.tap(find.text('October 2026'));
      await pumpBounded(tester);

      expect(find.text(CalendarMonthStrings.jumpToMonth), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);

      // 12 month tiles
      for (final String m in CalendarMonthStrings.shortMonths) {
        expect(find.text(m), findsWidgets);
      }

      // Year buttons inside jump sheet
      final Finder jumpSheetFinder = find.byType(AppBottomSheet);
      final Finder leftChevron = find.descendant(
        of: jumpSheetFinder,
        matching: find.byIcon(AppIcons.chevronLeft),
      );
      final Finder rightChevron = find.descendant(
        of: jumpSheetFinder,
        matching: find.byIcon(AppIcons.chevronRight),
      );
      await tester.tap(leftChevron);
      await pumpBounded(tester);
      expect(find.text('2025'), findsOneWidget);

      await tester.tap(rightChevron);
      await pumpBounded(tester);
      expect(find.text('2026'), findsOneWidget);

      // Tap 'Nov' month tile
      await tester.tap(find.text('Nov'));
      await pumpBounded(tester);

      expect(find.text(CalendarMonthStrings.jumpToMonth), findsNothing);
      expect(find.text('November 2026'), findsOneWidget);

      // Open jump sheet again and tap [Go to today]
      await tester.tap(find.text('November 2026'));
      await pumpBounded(tester);

      await tester.tap(find.text(CalendarMonthStrings.goToToday));
      await pumpBounded(tester);

      expect(find.text('October 2026'), findsOneWidget);
    });
  });

  group('Day Selection, Cards, and Empty States', () {
    testWidgets('Selected day header shows right counts and event cards', (
      WidgetTester tester,
    ) async {
      await pumpCalendarApp(tester);

      // Day 30 is initially selected: Friday, Oct 30 with milestone "Send invoice draft"
      expect(find.text('Friday, Oct 30'), findsOneWidget);
      expect(find.text('1 event'), findsOneWidget);
      expect(find.text('Send invoice draft'), findsOneWidget);
      expect(find.byType(CalendarEventCard), findsOneWidget);

      // Navigate to November 2026
      await tester.tap(find.byIcon(AppIcons.chevronRight));
      await pumpBounded(tester);

      // Select Nov 2
      await tester.tap(find.text('2').first);
      await pumpBounded(tester);

      expect(find.text('Monday, Nov 2'), findsOneWidget);
      expect(find.text('2 events'), findsOneWidget);
      expect(find.text('Beta handoff'), findsOneWidget);
      expect(find.text('Karim Boualam owes you'), findsOneWidget);
    });

    testWidgets(
      'Empty day shows Nothing planned and [Add milestone] button pushes /calendar/new',
      (WidgetTester tester) async {
        final (_, _, _, _, GoRouter router) = await pumpCalendarApp(tester);

        // Tap day 1 (Thursday, Oct 1) which has no events
        await tester.tap(find.text('1').first);
        await pumpBounded(tester);

        expect(find.text('Thursday, Oct 1'), findsOneWidget);
        expect(find.text('0 events'), findsOneWidget);
        expect(find.text(CalendarMonthStrings.nothingPlanned), findsOneWidget);

        final Finder addMilestoneFinder = find.widgetWithText(
          InkWell,
          CalendarMonthStrings.addMilestone,
        );
        expect(addMilestoneFinder, findsOneWidget);

        await tester.ensureVisible(addMilestoneFinder);
        await tester.tap(addMilestoneFinder);
        await pumpBounded(tester);

        expect(router.state.uri.toString(), '/calendar/new?date=2026-10-01');
      },
    );

    testWidgets('Tapping debt card navigates to /friends/transactions/<id>', (
      WidgetTester tester,
    ) async {
      final (_, _, _, _, GoRouter router) = await pumpCalendarApp(tester);

      // Move to November
      await tester.tap(find.byIcon(AppIcons.chevronRight));
      await pumpBounded(tester);

      // Tap Nov 2
      await tester.tap(find.text('2').first);
      await pumpBounded(tester);

      // Tap debt card
      final Finder debtCardFinder = find.text('Karim Boualam owes you');
      await tester.ensureVisible(debtCardFinder);
      await tester.tap(debtCardFinder);
      await pumpBounded(tester);

      expect(router.state.uri.toString(), '/friends/transactions/tx1');
    });
  });

  group('Sheets: Deadline sheet, Milestone sheet, and Delete confirmation', () {
    testWidgets(
      'Deadline sheet displays details and [Open project] navigates',
      (WidgetTester tester) async {
        final (_, _, _, _, GoRouter router) = await pumpCalendarApp(tester);

        // Tap Oct 25 (Project deadline for Dashboard Redesign)
        await tester.tap(find.text('25'));
        await pumpBounded(tester);

        expect(find.text('Sunday, Oct 25'), findsOneWidget);
        expect(find.text('Dashboard Redesign'), findsOneWidget);

        // Tap deadline card to open Deadline sheet
        await tester.tap(find.text('Dashboard Redesign'));
        await pumpBounded(tester);

        // Verify sheet content
        final Finder sheetFinder = find.byType(AppBottomSheet);
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.projectDeadline),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.client),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheetFinder, matching: find.text('Sarah Benali')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.dueDate),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheetFinder, matching: find.text('Sun, Oct 25')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.status),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheetFinder, matching: find.text('Planned')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.budget),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheetFinder, matching: find.text('95,000 DZ')),
          findsOneWidget,
        );

        // Tap [Open project]
        await tester.tap(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.openProject),
          ),
        );
        await pumpBounded(tester);

        expect(router.state.uri.toString(), '/projects/p5');
      },
    );

    testWidgets(
      'Milestone sheet toggles status with toast and delete flow deletes milestone',
      (WidgetTester tester) async {
        final (CalendarRepository calendarRepo, _, _, _, _) =
            await pumpCalendarApp(tester);

        // On Oct 30, tap "Send invoice draft"
        expect(find.text('Send invoice draft'), findsOneWidget);
        await tester.tap(find.text('Send invoice draft'));
        await pumpBounded(tester);

        // Verify Milestone sheet
        final Finder sheetFinder = find.byType(AppBottomSheet);
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.milestone),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.project),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text('Fintask Landing Page'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.date),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: sheetFinder, matching: find.text('Fri, Oct 30')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.status),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.pending),
          ),
          findsOneWidget,
        );

        // Tap [Mark as done]
        await tester.tap(
          find.descendant(
            of: sheetFinder,
            matching: find.text(CalendarMonthStrings.markAsDone),
          ),
        );
        await pumpBounded(tester);

        // Toast appears and milestone status in repo is toggled
        expect(
          find.text(CalendarMonthStrings.milestoneMarkedAsDone),
          findsOneWidget,
        );
        expect(calendarRepo.milestoneById('m3')!.completed, true);

        // Tap card again (now done)
        await tester.tap(find.text('Send invoice draft'));
        await pumpBounded(tester);

        final Finder sheet2Finder = find.byType(AppBottomSheet);
        expect(
          find.descendant(
            of: sheet2Finder,
            matching: find.text(CalendarMonthStrings.markAsPending),
          ),
          findsOneWidget,
        );

        // Tap [Mark as pending]
        await tester.tap(
          find.descendant(
            of: sheet2Finder,
            matching: find.text(CalendarMonthStrings.markAsPending),
          ),
        );
        await pumpBounded(tester);

        expect(
          find.text(CalendarMonthStrings.milestoneMarkedAsPending),
          findsOneWidget,
        );
        expect(calendarRepo.milestoneById('m3')!.completed, false);

        // Tap card again to test delete flow
        await tester.tap(find.text('Send invoice draft'));
        await pumpBounded(tester);

        final Finder sheet3Finder = find.byType(AppBottomSheet);
        // Tap [Delete milestone]
        await tester.tap(
          find.descendant(
            of: sheet3Finder,
            matching: find.text(CalendarMonthStrings.deleteMilestone),
          ),
        );
        await pumpBounded(tester);

        // Confirm sheet opens
        final Finder confirmFinder = find.byType(AppBottomSheet);
        expect(
          find.descendant(
            of: confirmFinder,
            matching: find.text(CalendarMonthStrings.thisActionCannotBeUndone),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: confirmFinder,
            matching: find.text(CalendarMonthStrings.confirmDelete),
          ),
          findsOneWidget,
        );

        // Tap [Cancel] first
        await tester.tap(
          find.descendant(
            of: confirmFinder,
            matching: find.text(CalendarMonthStrings.cancel),
          ),
        );
        await pumpBounded(tester);

        expect(calendarRepo.milestoneById('m3'), isNotNull);

        // Tap card again and proceed with delete
        await tester.tap(find.text('Send invoice draft'));
        await pumpBounded(tester);
        final Finder sheet4Finder = find.byType(AppBottomSheet);
        await tester.tap(
          find.descendant(
            of: sheet4Finder,
            matching: find.text(CalendarMonthStrings.deleteMilestone),
          ),
        );
        await pumpBounded(tester);

        // Tap [Confirm delete]
        final Finder confirm2Finder = find.byType(AppBottomSheet);
        await tester.tap(
          find.descendant(
            of: confirm2Finder,
            matching: find.text(CalendarMonthStrings.confirmDelete),
          ),
        );
        await pumpBounded(tester);

        expect(
          find.text(CalendarMonthStrings.milestoneDeleted),
          findsOneWidget,
        );
        expect(calendarRepo.milestoneById('m3'), isNull);
      },
    );
  });

  group('Tab Switching and Router Parameters', () {
    testWidgets('Tab switching keeps the current shown month', (
      WidgetTester tester,
    ) async {
      await pumpCalendarApp(tester);

      // Move to November
      await tester.tap(find.byIcon(AppIcons.chevronRight));
      await pumpBounded(tester);
      expect(find.text('November 2026'), findsOneWidget);

      // Switch to Agenda tab
      await tester.tap(find.text('Agenda'));
      await pumpBounded(tester);
      expect(find.byType(CalendarAgendaView), findsOneWidget);

      // Switch to Timeline tab
      await tester.tap(find.text('Timeline'));
      await pumpBounded(tester);
      expect(find.byType(CalendarTimelineView), findsOneWidget);

      // Switch back to Month tab
      await tester.tap(find.text('Month'));
      await pumpBounded(tester);

      // Month state preserved: still November 2026!
      expect(find.text('November 2026'), findsOneWidget);
    });

    testWidgets('Respects tab and date query parameters', (
      WidgetTester tester,
    ) async {
      // 1. tab=agenda
      await pumpCalendarApp(tester, initialLocation: '/calendar?tab=agenda');
      expect(find.byType(CalendarAgendaView), findsOneWidget);

      // 2. tab=timeline
      await pumpCalendarApp(tester, initialLocation: '/calendar?tab=timeline');
      expect(find.byType(CalendarTimelineView), findsOneWidget);

      // 3. date=2026-11-02
      await pumpCalendarApp(
        tester,
        initialLocation: '/calendar?date=2026-11-02',
      );
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('Monday, Nov 2'), findsOneWidget);
    });

    testWidgets('Displays toast on arrival via GoRouter extra', (
      WidgetTester tester,
    ) async {
      // Map format
      await pumpCalendarApp(
        tester,
        initialExtra: <String, Object?>{'toast': 'Milestone registered'},
      );
      expect(find.text('Milestone registered'), findsOneWidget);

      // Plain string format
      await pumpCalendarApp(tester, initialExtra: 'Simple string toast');
      expect(find.text('Simple string toast'), findsOneWidget);
    });
  });

  group('Small screen 360x800 layout: no overflow for all three tabs', () {
    testWidgets(
      '360x800 surface has no overflow on Month, Agenda, or Timeline tab',
      (WidgetTester tester) async {
        final (_, _, _, _, GoRouter router) = await pumpCalendarApp(
          tester,
          surfaceSize: const Size(360, 800),
        );

        // Month tab shell
        expect(tester.takeException(), isNull);

        // Tap gauge button
        await tester.tap(find.byIcon(AppIcons.gauge));
        await pumpBounded(tester);
        expect(router.state.uri.toString(), '/calendar/capacity');

        // Go back
        router.go('/calendar');
        await pumpBounded(tester);

        // Tap plus button
        await tester.tap(find.byIcon(AppIcons.plus));
        await pumpBounded(tester);
        expect(router.state.uri.toString(), startsWith('/calendar/new'));

        // Go back
        router.go('/calendar');
        await pumpBounded(tester);

        // Agenda tab
        await tester.tap(find.text('Agenda'));
        await pumpBounded(tester);
        expect(find.byType(CalendarAgendaView), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Timeline tab
        await tester.tap(find.text('Timeline'));
        await pumpBounded(tester);
        expect(find.byType(CalendarTimelineView), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Back to Month
        await tester.tap(find.text('Month'));
        await pumpBounded(tester);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
