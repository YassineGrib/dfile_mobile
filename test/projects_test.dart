import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/dashboard/home_screen.dart';
import 'package:dfile_mobile/features/projects/add_project_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/projects/edit_project_screen.dart';
import 'package:dfile_mobile/features/projects/project_detail_screen.dart';
import 'package:dfile_mobile/features/projects/project_strings.dart';
import 'package:dfile_mobile/features/projects/projects_list_screen.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProjectsRepository unit tests', () {
    late ClientsRepository clientsRepo;
    late ProjectsRepository repo;

    setUp(() {
      clientsRepo = ClientsRepository();
      repo = ProjectsRepository(clientsRepository: clientsRepo);
    });

    test('Initial repository loads 5 SPEC projects, Fintask tasks & payments, and derived metrics', () {
      expect(repo.projects.length, 5);
      expect(repo.byId('p1')?.name, 'Fintask Landing Page');
      expect(repo.byId('p2')?.name, 'Brand Identity');
      expect(repo.byId('p3')?.name, 'Mobile App UI');
      expect(repo.byId('p4')?.name, 'Logo Pack');
      expect(repo.byId('p5')?.name, 'Dashboard Redesign');
      expect(repo.byId('missing'), isNull);

      // Portfolio derived values
      // 450,000 + 180,000 + 320,000 + 40,000 + 95,000 = 1,085,000
      expect(repo.portfolioValue, 1085000.0);
      // (65 + 40 + 100 + 100 + 0) / 5 = 61
      expect(repo.averageProgress, 61);
      // In Progress (p1) + Waiting Client (p2) = 2
      expect(repo.activeCount, 2);

      // Fintask (p1) derived values, tasks (P6), and payments (P7)
      final ProjectItem fintask = repo.byId('p1')!;
      expect(repo.clientNameOf(fintask), 'Mohamed Bachir');
      expect(repo.paid(fintask), 245000.0);
      expect(repo.remaining(fintask), 205000.0);
      expect(repo.paidFraction(fintask), closeTo(245000.0 / 450000.0, 1e-6));

      final List<ProjectTask> fintaskTasks = repo.tasksOf('p1');
      expect(fintaskTasks.length, 4);
      expect(
        fintaskTasks
            .where((ProjectTask t) => t.status == TaskStatus.complete)
            .length,
        2,
      );

      final List<ProjectPayment> fintaskPayments = repo.paymentsOf('p1');
      expect(fintaskPayments.length, 3);
      expect(
        fintaskPayments.map((ProjectPayment p) => p.reference).toList(),
        <String>['TXN-928471', 'TXN-441872', 'CCP-5521'],
      );

      // Paid amounts for remaining SPEC projects
      expect(repo.paid(repo.byId('p2')!), 60000.0);
      expect(repo.paid(repo.byId('p3')!), 320000.0);
      expect(repo.remaining(repo.byId('p3')!), 0.0);
      expect(repo.paidFraction(repo.byId('p3')!), 1.0);
      expect(repo.paid(repo.byId('p4')!), 40000.0);
      expect(repo.paid(repo.byId('p5')!), 0.0);
      expect(repo.remaining(repo.byId('p5')!), 95000.0);
    });

    test('add, update, and delete mutate projects/tasks, keep payments, and notify listeners', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final ProjectItem added = ProjectItem(
        id: 'p_new',
        name: 'E-commerce Store',
        description: 'Storefront and checkout.',
        category: 'Development',
        clientId: 'c3',
        price: 200000.0,
        status: ProjectStatus.inProgress,
        progress: 25,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 11, 15),
        createdAt: DateTime(2026, 9, 1),
      );

      repo.add(added);
      expect(repo.projects.length, 6);
      expect(repo.byId('p_new')?.name, 'E-commerce Store');
      expect(repo.activeCount, 3);
      expect(notifications, 1);

      // Update project
      repo.update(added.copyWith(name: 'E-commerce v2', progress: 50));
      expect(repo.byId('p_new')?.name, 'E-commerce v2');
      expect(repo.byId('p_new')?.progress, 50);
      expect(notifications, 2);

      // Delete Fintask: removes project and its 4 tasks, keeps its 3 payments
      repo.delete('p1');
      expect(repo.byId('p1'), isNull);
      expect(repo.projects.length, 5);
      expect(repo.tasksOf('p1'), isEmpty);
      expect(repo.paymentsOf('p1').length, 3);
      expect(notifications, 3);
    });

    test(
      'changeStatus forces progress to 100 for Completed and Delivered only',
      () {
        expect(repo.byId('p2')?.progress, 40);

        repo.changeStatus('p2', ProjectStatus.inProgress);
        expect(repo.byId('p2')?.status, ProjectStatus.inProgress);
        expect(repo.byId('p2')?.progress, 40);

        repo.changeStatus('p2', ProjectStatus.completed);
        expect(repo.byId('p2')?.status, ProjectStatus.completed);
        expect(repo.byId('p2')?.progress, 100);

        expect(repo.byId('p5')?.progress, 0);
        repo.changeStatus('p5', ProjectStatus.delivered);
        expect(repo.byId('p5')?.status, ProjectStatus.delivered);
        expect(repo.byId('p5')?.progress, 100);

        repo.changeStatus('p1', ProjectStatus.cancelled);
        expect(repo.byId('p1')?.status, ProjectStatus.cancelled);
        expect(repo.byId('p1')?.progress, 65);
      },
    );

    test('toggleTask and addTask update checklist state', () {
      final ProjectTask first = repo.tasksOf('p1').first;
      expect(first.status, TaskStatus.complete);

      repo.toggleTask(first.id);
      expect(repo.tasksOf('p1').first.status, TaskStatus.nextUp);

      repo.toggleTask(first.id);
      expect(repo.tasksOf('p1').first.status, TaskStatus.complete);

      final ProjectTask created = repo.addTask('p1', 'QA cross-browser pass');
      expect(created.name, 'QA cross-browser pass');
      expect(created.status, TaskStatus.nextUp);
      expect(repo.tasksOf('p1').length, 5);
    });

    test('Client sync keeps embedded client projects and payments consistent across mutations', () {
      // Add new project to Nova Studio (c3)
      final ProjectItem newProj = ProjectItem(
        id: 'p_nova_2',
        name: 'Packaging Suite',
        category: 'Branding',
        clientId: 'c3',
        price: 110000.0,
        status: ProjectStatus.inProgress,
        progress: 30,
        startDate: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
      );
      repo.add(newProj);

      Client nova = clientsRepo.byId('c3')!;
      expect(
        nova.projects.map((Project p) => p.name).toList(),
        containsAll(<String>['Logo Pack', 'Packaging Suite']),
      );
      expect(clientsRepo.isActive(nova), isTrue);

      // Add payment to the new project -> syncs into Nova Studio's payments
      repo.addPayment(
        ProjectPayment(
          id: 'pay_nova_new',
          projectId: 'p_nova_2',
          date: DateTime(2026, 10, 12),
          reference: '#A199',
          amount: 55000.0,
        ),
      );
      nova = clientsRepo.byId('c3')!;
      expect(
        nova.payments.any(
          (Payment p) =>
              p.reference == '#A199' &&
              p.amount == 55000.0 &&
              p.projectId == 'p_nova_2',
        ),
        isTrue,
      );
      expect(repo.paid(repo.byId('p_nova_2')!), 55000.0);

      // Change status to Completed -> syncs embedded project status & progress
      repo.changeStatus('p_nova_2', ProjectStatus.completed);
      nova = clientsRepo.byId('c3')!;
      final Project syncedNovaProj = nova.projects.firstWhere(
        (Project p) => p.name == 'Packaging Suite',
      );
      expect(syncedNovaProj.status, 'Completed');
      expect(syncedNovaProj.progress, 100);
      expect(clientsRepo.isActive(nova), isFalse);

      // Reassign Packaging Suite from c3 to c2 (Sarah Benali)
      repo.update(repo.byId('p_nova_2')!.copyWith(clientId: 'c2'));
      nova = clientsRepo.byId('c3')!;
      final Client sarah = clientsRepo.byId('c2')!;
      expect(
        nova.projects.any((Project p) => p.name == 'Packaging Suite'),
        isFalse,
      );
      expect(
        sarah.projects.any((Project p) => p.name == 'Packaging Suite'),
        isTrue,
      );
      expect(sarah.payments.any((Payment p) => p.reference == '#A199'), isTrue);

      // Delete Packaging Suite -> removed from Sarah's projects, payment kept in ledger
      repo.delete('p_nova_2');
      final Client sarahAfterDelete = clientsRepo.byId('c2')!;
      expect(
        sarahAfterDelete.projects.any(
          (Project p) => p.name == 'Packaging Suite',
        ),
        isFalse,
      );
      expect(
        sarahAfterDelete.payments.any((Payment p) => p.reference == '#A199'),
        isTrue,
      );
    });
  });

  group('Projects UI flows on 390x844 test surface', () {
    Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpProjectsApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.projectsPath,
      Size surfaceSize = const Size(390, 844),
    }) async {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
      final GoRouter router = createAppRouter(initialLocation: initialLocation);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clientsRepo,
          projectsRepository: projectsRepo,
        ),
      );
      await tester.pumpAndSettle();
      return (clientsRepo, projectsRepo, router);
    }

    testWidgets(
      'Projects list: summary tiles, search, status pills, filter sheet, sort sheet, and + route',
      (WidgetTester tester) async {
        await pumpProjectsApp(tester);

        // Summary tiles & header
        expect(find.text('5 projects in your portfolio'), findsOneWidget);
        expect(find.text('1.0M DZ'), findsOneWidget);
        expect(find.text('61%'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsOneWidget);
        expect(find.text('Brand Identity'), findsOneWidget);

        // 1. Search by category ('Branding' -> Logo Pack)
        await tester.enterText(find.byType(TextField).first, 'Branding');
        await tester.pumpAndSettle();
        expect(find.text('Logo Pack'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsNothing);

        // Search by client ('Sarah' -> Brand Identity & Dashboard Redesign)
        await tester.enterText(find.byType(TextField).first, 'Sarah');
        await tester.pumpAndSettle();
        expect(find.text('Brand Identity'), findsOneWidget);
        expect(find.text('Dashboard Redesign'), findsOneWidget);
        expect(find.text('Logo Pack'), findsNothing);

        // Clear search
        await tester.enterText(find.byType(TextField).first, '');
        await tester.pumpAndSettle();

        // 2. Status pill: In Progress includes Waiting Client (Fintask + Brand Identity)
        await tester.tap(
          find.widgetWithText(AppPill, ProjectStrings.filterInProgress),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 projects found'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsOneWidget);
        expect(find.text('Brand Identity'), findsOneWidget);
        expect(find.text('Mobile App UI'), findsNothing);

        final Finder pillsScrollable = find.descendant(
          of: find.byKey(const Key('project-status-pills')),
          matching: find.byType(Scrollable),
        );

        // Status pill: scroll horizontally and tap Delivered -> Logo Pack only
        await tester.scrollUntilVisible(
          find.widgetWithText(AppPill, ProjectStrings.filterDelivered),
          80,
          scrollable: pillsScrollable,
        );
        await tester.tap(
          find.widgetWithText(AppPill, ProjectStrings.filterDelivered),
        );
        await tester.pumpAndSettle();
        expect(find.text('1 projects found'), findsOneWidget);
        expect(find.text('Logo Pack'), findsOneWidget);

        // Scroll back and reset pill to All
        await tester.scrollUntilVisible(
          find.widgetWithText(AppPill, ProjectStrings.filterAll),
          -80,
          scrollable: pillsScrollable,
        );
        await tester.tap(
          find.widgetWithText(AppPill, ProjectStrings.filterAll),
        );
        await tester.pumpAndSettle();

        // 3. Filter sheet: Category = Design & Client = Mohamed Bachir -> Mobile App UI only
        await tester.tap(find.text(ProjectStrings.filterAction));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.filterSheetTitle), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.widgetWithText(AppPill, 'Design'),
          ),
        );
        await tester.pump();
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.widgetWithText(AppPill, 'Mohamed Bachir'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text(ProjectStrings.applyFilters));
        await tester.pumpAndSettle();

        expect(find.text('1 projects found'), findsOneWidget);
        expect(find.text('Mobile App UI'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsNothing);

        // Open Filter sheet, Reset + Apply filters -> back to 5 projects
        await tester.tap(find.text(ProjectStrings.filterAction));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.reset));
        await tester.pump();
        await tester.tap(find.text(ProjectStrings.applyFilters));
        await tester.pumpAndSettle();
        expect(find.text('5 projects in your portfolio'), findsOneWidget);

        // 4. Sort sheet: Name (A-Z) puts Brand Identity before Fintask Landing Page
        await tester.tap(find.textContaining(ProjectStrings.sortPrefix));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.sortSheetTitle), findsOneWidget);
        await tester.tap(find.text(ProjectStrings.sortNameAZ));
        await tester.pumpAndSettle();

        expect(find.text('Sort: Name'), findsOneWidget);
        final Offset brandPos = tester.getTopLeft(find.text('Brand Identity'));
        final Offset dashboardPos = tester.getTopLeft(
          find.text('Dashboard Redesign'),
        );
        expect(brandPos.dy, lessThan(dashboardPos.dy));

        // 5. '+' button opens /projects/new placeholder
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.byType(AddProjectScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Empty state renders when no projects match and [Clear filters] restores list',
      (WidgetTester tester) async {
        await pumpProjectsApp(tester);

        await tester.enterText(
          find.byType(TextField).first,
          'nonexistent_xyz_project',
        );
        await tester.pumpAndSettle();

        expect(find.text('0 projects found'), findsOneWidget);
        expect(find.text(ProjectStrings.emptyTitle), findsOneWidget);
        expect(find.text(ProjectStrings.emptySubtitle), findsOneWidget);
        expect(find.text(ProjectStrings.clearFilters), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.clearFilters));
        await tester.pumpAndSettle();

        expect(find.text('5 projects in your portfolio'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsOneWidget);
      },
    );

    testWidgets(
      'Detail tabs switch, task toggle & add task, payment placeholder, and edit route',
      (WidgetTester tester) async {
        final (_, ProjectsRepository repo, _) = await pumpProjectsApp(tester);

        // Tap Fintask card on list -> navigates to /projects/p1
        await tester.tap(find.text('Fintask Landing Page'));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectDetailScreen), findsOneWidget);
        expect(find.text('65%'), findsOneWidget);
        expect(find.text('450,000 DZ'), findsOneWidget);
        expect(find.text('245,000 DZ'), findsOneWidget);
        expect(find.text('205,000 DZ'), findsOneWidget);
        expect(find.text('Jul 01 → Aug 30'), findsOneWidget);

        // Bottom [+ Add payment] opens payment placeholder sheet
        await tester.tap(find.text(ProjectStrings.addPaymentWithPlus));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.recordPaymentTitle), findsOneWidget);
        await tester.tap(find.text(ProjectStrings.cancel));
        await tester.pumpAndSettle();

        // Switch to Tasks tab
        await tester.tap(find.text(ProjectStrings.tabTasks));
        await tester.pumpAndSettle();

        expect(find.text('2 of 4 done'), findsOneWidget);
        expect(find.text('Wireframes approved'), findsOneWidget);
        expect(find.text('Onboarding form'), findsOneWidget);

        // Toggle 'Onboarding form' -> becomes Complete (3 of 4 done)
        await tester.tap(find.text('Onboarding form'));
        await tester.pumpAndSettle();
        expect(find.text('3 of 4 done'), findsOneWidget);

        // Add new task via bottom input + '+' button
        await tester.enterText(
          find.byType(TextField),
          'Analytics event wiring',
        );
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('3 of 5 done'), findsOneWidget);
        expect(repo.tasksOf('p1').length, 5);
        await tester.scrollUntilVisible(
          find.text('Analytics event wiring'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Analytics event wiring'), findsOneWidget);

        // Switch to Payments tab
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, 300),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.tabPayments));
        await tester.pumpAndSettle();

        expect(find.text(ProjectStrings.paidSoFar), findsOneWidget);
        expect(find.text('of 450,000 DZ'), findsOneWidget);
        expect(find.text('+100,000 DZ'), findsOneWidget);
        expect(find.text('+85,000 DZ'), findsOneWidget);
        expect(find.text('+60,000 DZ'), findsOneWidget);

        // Actions sheet -> Edit project navigates to /projects/p1/edit placeholder
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionEditProject));
        await tester.pumpAndSettle();

        expect(find.byType(EditProjectScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Change status sheet updates status and forces 100% progress on Completed',
      (WidgetTester tester) async {
        final (_, ProjectsRepository repo, _) = await pumpProjectsApp(
          tester,
          initialLocation: '/projects/p1',
        );

        expect(find.text('65%'), findsOneWidget);

        // Open Actions sheet -> Change status
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionChangeStatus));
        await tester.pumpAndSettle();

        expect(find.text(ProjectStrings.changeStatusTitle), findsOneWidget);
        expect(find.text(ProjectStrings.changeStatusNote), findsOneWidget);

        // Select Completed and tap Update status
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text('Completed'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text(ProjectStrings.updateStatus));
        await tester.pumpAndSettle();

        expect(repo.byId('p1')?.status, ProjectStatus.completed);
        expect(repo.byId('p1')?.progress, 100);
        expect(find.text('100%'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
      },
    );

    testWidgets(
      'Delete project flow confirms, deletes, and returns to /projects with toast',
      (WidgetTester tester) async {
        final (_, ProjectsRepository repo, _) = await pumpProjectsApp(tester);

        // Open Fintask from list
        await tester.tap(find.text('Fintask Landing Page'));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectDetailScreen), findsOneWidget);

        // More -> Delete project -> Confirm delete
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionDeleteProject));
        await tester.pumpAndSettle();

        expect(find.text(ProjectStrings.deleteConfirmTitle), findsOneWidget);
        expect(find.text(ProjectStrings.confirmDelete), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.confirmDelete));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectsListScreen), findsOneWidget);
        expect(find.text(ProjectStrings.projectDeletedToast), findsOneWidget);
        expect(repo.byId('p1'), isNull);
        expect(find.text('4 projects in your portfolio'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsNothing);
      },
    );

    testWidgets(
      'Unknown project ID displays friendly Project not found screen with back action',
      (WidgetTester tester) async {
        await pumpProjectsApp(
          tester,
          initialLocation: '/projects/does_not_exist',
        );

        expect(find.text(ProjectStrings.projectNotFound), findsOneWidget);
        expect(find.text(ProjectStrings.backToProjects), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.backToProjects));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectsListScreen), findsOneWidget);
      },
    );

    testWidgets('Bottom AppTabBar navigates between Projects and Clients', (
      WidgetTester tester,
    ) async {
      await pumpProjectsApp(tester, initialLocation: AppRoutes.clientsPath);

      expect(find.byType(ClientsListScreen), findsOneWidget);

      // Tap Projects tab -> /projects
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Projects'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProjectsListScreen), findsOneWidget);

      // Tap Home -> navigates to /home (HomeScreen)
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tap Projects tab -> returns to /projects
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Projects'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProjectsListScreen), findsOneWidget);

      // Tap More -> navigates to /more (MoreScreen)
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('More'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);

      // Tap Projects tab -> returns to /projects
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Projects'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProjectsListScreen), findsOneWidget);

      // Tap Clients tab -> /clients
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Clients'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ClientsListScreen), findsOneWidget);
    });

    testWidgets(
      '360x800 phone surface renders Projects list, sheets, and Project detail tabs without overflow',
      (WidgetTester tester) async {
        final (_, _, GoRouter router) = await pumpProjectsApp(
          tester,
          surfaceSize: const Size(360, 800),
        );
        expect(tester.takeException(), isNull);

        // Open Filter sheet at 360x800
        await tester.tap(find.text(ProjectStrings.filterAction));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(ProjectStrings.cancel));
        await tester.pumpAndSettle();

        // Open Sort sheet at 360x800
        await tester.tap(find.textContaining(ProjectStrings.sortPrefix));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(ProjectStrings.sortNewestFirst));
        await tester.pumpAndSettle();

        // Navigate to detail and verify Overview, Tasks, Payments, and sheets at 360x800
        router.push('/projects/p1');
        await tester.pumpAndSettle();
        expect(find.byType(ProjectDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(ProjectStrings.tabTasks));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(ProjectStrings.tabPayments));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Open Change status sheet at 360x800
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(ProjectStrings.actionChangeStatus));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
