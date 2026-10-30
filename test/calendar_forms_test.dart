import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/calendar/calendar_forms_strings.dart';
import 'package:dfile_mobile/features/calendar/calendar_sync_screen.dart';
import 'package:dfile_mobile/features/calendar/capacity_screen.dart';
import 'package:dfile_mobile/features/calendar/data/data.dart';
import 'package:dfile_mobile/features/calendar/milestone_form_screen.dart';
import 'package:dfile_mobile/features/calendar/widgets/calendar_forms_project_sheet.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/widgets/settings_switch.dart';
import 'package:dfile_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  void setTestSurface(
    WidgetTester tester, [
    Size size = const Size(390, 844),
  ]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpBounded(WidgetTester tester, [int count = 8]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  final DateTime testNow = DateTime(2026, 10, 30, 14, 30);

  setUp(() {
    CapacityScreen.defaultClock = () => testNow;
    CalendarSyncScreen.defaultClock = () => testNow;
    MilestoneFormScreen.defaultClock = () => testNow;
  });

  group('MilestoneFormScreen (CL8-CL10) tests', () {
    testWidgets('milestone form validation displays inline errors on save attempt',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final ProjectsRepository projRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarNewPath);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(MilestoneFormScreen), findsOneWidget);

      // Verify no errors initially
      expect(find.text(CalendarFormsStrings.projectRequiredError), findsNothing);
      expect(find.text(CalendarFormsStrings.titleRequiredError), findsNothing);
      expect(find.text(CalendarFormsStrings.dueDateRequiredError), findsNothing);

      // Tap Register milestone
      await tester.tap(find.text(CalendarFormsStrings.registerMilestone));
      await pumpBounded(tester);

      // Inline red errors are now visible
      expect(
        find.text(CalendarFormsStrings.projectRequiredError),
        findsOneWidget,
      );
      expect(find.text(CalendarFormsStrings.titleRequiredError), findsOneWidget);
      expect(
        find.text(CalendarFormsStrings.dueDateRequiredError),
        findsOneWidget,
      );

      // Nothing was added to repository
      expect(calRepo.milestones.length, 5);
    });

    testWidgets('preselects via projectId and date query parameters',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final ProjectsRepository projRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final GoRouter router = createAppRouter(
        initialLocation: '/calendar/new?projectId=p1&date=2026-10-30',
      );

      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      // p1 is 'Fintask Landing Page'
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      // Date '2026-10-30' formatted as 'Fri, Oct 30, 2026'
      expect(find.text('Fri, Oct 30, 2026'), findsOneWidget);
    });

    testWidgets('project picker sheet lists only non-Cancelled projects',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
        initialProjects: [
          ProjectItem(
            id: 'p1',
            name: 'Active Alpha',
            category: 'Design',
            clientId: 'c1',
            price: 100000,
            status: ProjectStatus.inProgress,
            progress: 50,
            startDate: DateTime(2026, 10, 1),
            createdAt: DateTime(2026, 10, 1),
          ),
          ProjectItem(
            id: 'p2',
            name: 'Cancelled Beta',
            category: 'Dev',
            clientId: 'c1',
            price: 50000,
            status: ProjectStatus.cancelled,
            progress: 0,
            startDate: DateTime(2026, 10, 1),
            createdAt: DateTime(2026, 10, 1),
          ),
        ],
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarNewPath);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      // Tap project selector to open sheet
      await tester.tap(find.text(CalendarFormsStrings.selectProjectPlaceholder));
      await pumpBounded(tester);

      expect(
        find.descendant(
          of: find.byType(CalendarFormsProjectSheetContent),
          matching: find.text(CalendarFormsStrings.selectProjectSheetTitle),
        ),
        findsOneWidget,
      );
      expect(find.text('Active Alpha'), findsOneWidget);
      expect(find.text('Cancelled Beta'), findsNothing);

      // Select 'Active Alpha' and confirm
      await tester.tap(find.text('Active Alpha'));
      await pumpBounded(tester);
      await tester.tap(find.text(CalendarFormsStrings.confirm));
      await pumpBounded(tester);

      expect(find.text('Active Alpha'), findsOneWidget);
    });

    testWidgets('successful save adds milestone and navigates to /calendar with toast',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final ProjectsRepository projRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();
      final GoRouter router = createAppRouter(
        initialLocation: '/calendar/new?projectId=p1&date=2026-11-15',
      );

      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      // Enter title
      await tester.enterText(
        find.byType(TextField).first,
        'Usability Handoff',
      );
      await pumpBounded(tester);

      // Tap Register milestone
      await tester.tap(find.text(CalendarFormsStrings.registerMilestone));
      await pumpBounded(tester, 10);

      // Milestone was saved to repo
      expect(calRepo.milestones.length, 6);
      final Milestone added = calRepo.milestones.last;
      expect(added.title, 'Usability Handoff');
      expect(added.projectId, 'p1');
      expect(added.date, DateTime(2026, 11, 15));
      expect(added.completed, false);

      // Router navigated to /calendar?date=2026-11-15
      expect(router.state.uri.path, AppRoutes.calendarPath);
      expect(router.state.uri.queryParameters['date'], '2026-11-15');
      expect(
        (router.state.extra as Map<String, Object?>?)?['toast'],
        CalendarFormsStrings.milestoneRegisteredToast,
      );
    });

    testWidgets('Cancel button and X button pop or go to /calendar',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final ProjectsRepository projRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();

      // Test Cancel button
      final GoRouter router1 = createAppRouter(
        initialLocation: AppRoutes.calendarNewPath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router1,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      await tester.tap(find.text(CalendarFormsStrings.cancel));
      await pumpBounded(tester);
      expect(router1.state.uri.path, AppRoutes.calendarPath);

      // Test X button
      final GoRouter router2 = createAppRouter(
        initialLocation: AppRoutes.calendarNewPath,
      );
      await tester.pumpWidget(
        DfileApp(
          router: router2,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      await tester.tap(find.byIcon(AppIcons.x));
      await pumpBounded(tester);
      expect(router2.state.uri.path, AppRoutes.calendarPath);
    });
  });

  group('CapacityScreen (CL11) tests', () {
    testWidgets('renders workload, slot, and progress numbers for seeds with clock = 2026-10-30',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final ProjectsRepository projRepo = ProjectsRepository();
      final SettingsRepository settingsRepo = SettingsRepository(
        initialGoogleConnected: true,
      );
      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          projectsRepository: projRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(CapacityScreen), findsOneWidget);
      expect(find.text(CalendarFormsStrings.capacityTitle), findsOneWidget);

      // 3 active projects in seeds
      expect(find.text('3 active projects'), findsOneWidget);
      expect(find.text(CalendarFormsStrings.moderateLevel), findsOneWidget);
      expect(find.text(CalendarFormsStrings.moderateSentence), findsOneWidget);

      // Next available slot in seeds is 'Available now'
      expect(find.text(CalendarFormsStrings.availableNow), findsOneWidget);

      // Active projects progress
      expect(find.text('Average 35%'), findsOneWidget);
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Brand Identity'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Dashboard Redesign'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);

      // Calendar sync row
      expect(
        find.text(CalendarFormsStrings.calendarSyncRowTitle),
        findsOneWidget,
      );
      expect(
        find.text(CalendarFormsStrings.calendarSyncConnected),
        findsOneWidget,
      );

      // Tapping sync row pushes /calendar/sync
      await tester.tap(find.text(CalendarFormsStrings.calendarSyncRowTitle));
      await pumpBounded(tester);
      expect(router.state.uri.path, AppRoutes.calendarSyncPath);
    });

    testWidgets('supports three capacity levels (1 / 3 / 5 active projects)',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final ClientsRepository clientsRepo = ClientsRepository();

      // 1 active project -> Light
      final ProjectsRepository repoLight = ProjectsRepository(
        clientsRepository: clientsRepo,
        initialProjects: [
          ProjectItem(
            id: 'p1',
            name: 'P1',
            category: 'Design',
            clientId: 'c1',
            price: 50000,
            status: ProjectStatus.inProgress,
            progress: 20,
            startDate: DateTime(2026, 10, 1),
            createdAt: DateTime(2026, 10, 1),
          ),
        ],
      );

      final GoRouter routerLight =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);
      await tester.pumpWidget(
        DfileApp(
          router: routerLight,
          projectsRepository: repoLight,
        ),
      );
      await pumpBounded(tester);

      expect(find.text('1 active project'), findsOneWidget);
      expect(find.text(CalendarFormsStrings.lightLevel), findsOneWidget);
      expect(find.text(CalendarFormsStrings.lightSentence), findsOneWidget);

      // 5 active projects -> Heavy
      final List<ProjectItem> heavyProjects = List.generate(
        5,
        (int i) => ProjectItem(
          id: 'p$i',
          name: 'Project $i',
          category: 'Dev',
          clientId: 'c1',
          price: 50000,
          status: ProjectStatus.inProgress,
          progress: 50,
          startDate: DateTime(2026, 10, 1),
          createdAt: DateTime(2026, 10, 1),
        ),
      );
      final ProjectsRepository repoHeavy = ProjectsRepository(
        clientsRepository: clientsRepo,
        initialProjects: heavyProjects,
      );

      final GoRouter routerHeavy =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);
      await tester.pumpWidget(
        DfileApp(
          router: routerHeavy,
          projectsRepository: repoHeavy,
        ),
      );
      await pumpBounded(tester);

      expect(find.text('5 active projects'), findsOneWidget);
      expect(find.text(CalendarFormsStrings.heavyLevel), findsOneWidget);
      expect(find.text(CalendarFormsStrings.heavySentence), findsOneWidget);
    });

    testWidgets('detects next available slot with future end date and displays earliest contract',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final ProjectsRepository repo = ProjectsRepository(
        initialProjects: [
          ProjectItem(
            id: 'p10',
            name: 'Mobile App Redesign',
            category: 'Mobile',
            clientId: 'c1',
            price: 150000,
            status: ProjectStatus.inProgress,
            progress: 70,
            startDate: DateTime(2026, 10, 1),
            endDate: DateTime(2026, 11, 12),
            createdAt: DateTime(2026, 10, 1),
          ),
        ],
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          projectsRepository: repo,
        ),
      );
      await pumpBounded(tester);

      expect(find.text('Nov 12, 2026'), findsOneWidget);
      expect(
        find.text('Earliest contract to free up: Mobile App Redesign'),
        findsOneWidget,
      );
    });

    testWidgets('handles empty state with 0 active projects',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final ProjectsRepository emptyRepo = ProjectsRepository(
        initialProjects: <ProjectItem>[],
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          projectsRepository: emptyRepo,
        ),
      );
      await pumpBounded(tester);

      expect(find.text(CalendarFormsStrings.noActiveProjects), findsWidgets);
      expect(find.text(CalendarFormsStrings.lightLevel), findsOneWidget);
      expect(find.text(CalendarFormsStrings.availableNow), findsOneWidget);
      expect(find.text('Average 0%'), findsOneWidget);
    });
  });

  group('CalendarSyncScreen (CL12) tests', () {
    testWidgets('renders connected state with profile email, Sync now, and formatted timestamp',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final SettingsRepository settingsRepo = SettingsRepository(
        initialGoogleConnected: true,
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarSyncPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(find.byType(CalendarSyncScreen), findsOneWidget);
      expect(find.text(CalendarFormsStrings.calendarSyncTitle), findsOneWidget);
      expect(
        find.text(CalendarFormsStrings.googleCalendarTitle),
        findsOneWidget,
      );
      expect(find.text(settingsRepo.profile.email), findsOneWidget);
      expect(find.text(CalendarFormsStrings.connected), findsOneWidget);
      expect(find.text(CalendarFormsStrings.syncNow), findsOneWidget);
      expect(find.text(CalendarFormsStrings.neverSynced), findsOneWidget);

      // Tap Sync now
      await tester.tap(find.text(CalendarFormsStrings.syncNow));
      await pumpBounded(tester);

      // Repository updated and toast displayed
      expect(calRepo.lastSynced, testNow);
      expect(find.text(CalendarFormsStrings.calendarSyncedToast), findsOneWidget);
      expect(find.text('Last synced today at 14:30'), findsOneWidget);
    });

    testWidgets('renders not-connected state with Connect in Settings button',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final SettingsRepository settingsRepo = SettingsRepository(
        initialGoogleConnected: false,
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarSyncPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(find.text(CalendarFormsStrings.notConnected), findsOneWidget);
      expect(find.text(CalendarFormsStrings.connectInSettings), findsOneWidget);

      // Tap Connect in Settings -> pushes /settings/integrations
      await tester.tap(find.text(CalendarFormsStrings.connectInSettings));
      await pumpBounded(tester);
      expect(router.state.uri.path, '/settings/integrations');
    });

    testWidgets('sync switches toggle CalendarRepository preferences and sync note is shown',
        (WidgetTester tester) async {
      setTestSurface(tester);
      final CalendarRepository calRepo = CalendarRepository();
      final SettingsRepository settingsRepo = SettingsRepository(
        initialGoogleConnected: true,
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarSyncPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(calRepo.syncDeadlines, true);
      expect(calRepo.syncMilestones, true);
      expect(calRepo.syncDebts, false);

      // Toggle Project deadlines off
      await tester.tap(find.byType(SettingsSwitch).at(0));
      await pumpBounded(tester);
      expect(calRepo.syncDeadlines, false);

      // Toggle Milestones off
      await tester.tap(find.byType(SettingsSwitch).at(1));
      await pumpBounded(tester);
      expect(calRepo.syncMilestones, false);

      // Toggle Friends' debts on
      await tester.tap(find.byType(SettingsSwitch).at(2));
      await pumpBounded(tester);
      expect(calRepo.syncDebts, true);

      // Sync note displayed
      expect(find.text(CalendarFormsStrings.syncNote), findsOneWidget);
    });
  });

  group('360x800 surface overflow tests', () {
    testWidgets('MilestoneFormScreen has no overflow on 360x800',
        (WidgetTester tester) async {
      setTestSurface(tester, const Size(360, 800));
      final CalendarRepository calRepo = CalendarRepository();
      final ProjectsRepository projRepo = ProjectsRepository();
      final ClientsRepository clientsRepo = ClientsRepository();

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarNewPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          projectsRepository: projRepo,
          repository: clientsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('CapacityScreen has no overflow on 360x800',
        (WidgetTester tester) async {
      setTestSurface(tester, const Size(360, 800));
      final ProjectsRepository projRepo = ProjectsRepository();
      final SettingsRepository settingsRepo = SettingsRepository();

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarCapacityPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          projectsRepository: projRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('CalendarSyncScreen has no overflow on 360x800',
        (WidgetTester tester) async {
      setTestSurface(tester, const Size(360, 800));
      final CalendarRepository calRepo = CalendarRepository();
      final SettingsRepository settingsRepo = SettingsRepository(
        initialGoogleConnected: true,
      );

      final GoRouter router =
          createAppRouter(initialLocation: AppRoutes.calendarSyncPath);
      await tester.pumpWidget(
        DfileApp(
          router: router,
          calendarRepository: calRepo,
          settingsRepository: settingsRepo,
        ),
      );
      await pumpBounded(tester);

      expect(tester.takeException(), isNull);
    });
  });
}
