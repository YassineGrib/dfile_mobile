import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/expenses/expense_detail_screen.dart';
import 'package:dfile_mobile/features/expenses/expense_form_screen.dart';
import 'package:dfile_mobile/features/expenses/expenses_list_screen.dart';
import 'package:dfile_mobile/features/expenses/expenses_list_strings.dart';
import 'package:dfile_mobile/features/expenses/widgets/expenses_list_card.dart';
import 'package:dfile_mobile/features/expenses/widgets/expenses_list_filter_sheet.dart';
import 'package:dfile_mobile/features/expenses/widgets/expenses_list_kpis.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ExpensesListScreen tests on 390x844 surface', () {
    Future<(ClientsRepository, ProjectsRepository, ExpensesRepository, GoRouter)>
        pumpExpensesApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.expensesPath,
      Size surfaceSize = const Size(390, 844),
      List<Expense>? initialExpenses,
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
      final ExpensesRepository expensesRepo = ExpensesRepository(
        initialExpenses: initialExpenses,
      );
      final GoRouter router = createAppRouter(initialLocation: initialLocation);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clientsRepo,
          projectsRepository: projectsRepo,
          expensesRepository: expensesRepo,
        ),
      );
      await tester.pumpAndSettle();
      return (clientsRepo, projectsRepo, expensesRepo, router);
    }

    testWidgets(
      'KPI tiles, header, and count match repository expenseStats',
      (WidgetTester tester) async {
        final (_, _, expensesRepo, _) = await pumpExpensesApp(tester);
        final ExpenseStats stats = expensesRepo.expenseStats();

        // Header
        expect(find.text(ExpensesListStrings.title), findsOneWidget);
        expect(
          find.text(
            ExpensesListStrings.expensesLogged(expensesRepo.expenses.length),
          ),
          findsOneWidget,
        );

        // 4 KPI tiles
        expect(find.byType(ExpensesListKpis), findsOneWidget);
        expect(find.text(ExpensesListStrings.totalOutlays), findsOneWidget);
        expect(find.text('-91,200 DZ'), findsOneWidget);
        expect(find.text(ExpensesListStrings.projectLinked), findsOneWidget);
        expect(find.text('-36,500 DZ'), findsOneWidget);
        expect(find.text(ExpensesListStrings.thisMonth), findsOneWidget);
        expect(
          find.text(ExpensesListKpis.formatKpiAmount(stats.thisMonth)),
          findsOneWidget,
        );
        expect(find.text(ExpensesListStrings.averageOutlay), findsOneWidget);
        expect(find.text('-13,029 DZ'), findsOneWidget);

        // Count row
        expect(
          find.text(
            ExpensesListStrings.expensesCount(expensesRepo.expenses.length),
          ),
          findsOneWidget,
        );
        expect(find.text(ExpensesListStrings.filter), findsOneWidget);
        expect(find.text('Sort: Newest ▾'), findsOneWidget);

        // Expense cards rendered
        expect(find.byType(ExpensesListCard), findsWidgets);
        expect(find.text('Figma Pro plan'), findsOneWidget);
        expect(find.text('-4,500 DZ'), findsOneWidget);
        expect(find.text('General cost'), findsWidgets);

        // Scroll down to verify subsequent cards
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.text('Coworking pass'), findsOneWidget);

        // Bottom tab bar has More active
        final AppTabBar tabBar =
            tester.widget<AppTabBar>(find.byType(AppTabBar));
        expect(tabBar.currentIndex, AppTabBar.moreTabIndex);
      },
    );

    testWidgets(
      'Search filters expenses by description, category label, project name, reference, and notes (case-insensitive)',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        final Finder searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);

        // Search by description "figma"
        await tester.enterText(searchField, 'figma');
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);

        // Search by category label "software"
        await tester.enterText(searchField, 'SOFTWARE');
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);

        // Search by project name "brand identity"
        await tester.enterText(searchField, 'brand identity');
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Instagram ads'), findsOneWidget);
        expect(find.text('-12,000 DZ'), findsOneWidget);

        // Search by reference "INV-611"
        await tester.enterText(searchField, 'inv-611');
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Monitor 27 inch'), findsOneWidget);
        expect(find.text('-38,000 DZ'), findsOneWidget);

        // Search by notes "brand launch week"
        await tester.enterText(searchField, 'brand launch week');
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Instagram ads'), findsOneWidget);

        // Clear search restores all 7 expenses
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
        expect(find.text('7 expenses'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);
      },
    );

    testWidgets(
      'Category pills filter expenses correctly and horizontally scroll without error',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        final Finder pillsScrollView =
            find.byKey(const Key('expense-category-pills'));
        expect(pillsScrollView, findsOneWidget);

        // Software pill -> 1 expense
        final Finder softwarePill =
            find.widgetWithText(AppPill, ExpensesListStrings.categorySoftware);
        await tester.ensureVisible(softwarePill);
        await tester.pumpAndSettle();
        await tester.tap(softwarePill);
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);

        // Hosting pill -> 2 expenses (Domain renewal & VPS hosting)
        final Finder hostingPill =
            find.widgetWithText(AppPill, ExpensesListStrings.categoryHosting);
        await tester.ensureVisible(hostingPill);
        await tester.pumpAndSettle();
        await tester.tap(hostingPill);
        await tester.pumpAndSettle();
        expect(find.text('2 expenses'), findsOneWidget);
        expect(find.text('Domain renewal'), findsOneWidget);

        // Marketing pill -> 2 expenses (Instagram ads & Stock photos pack)
        final Finder marketingPill =
            find.widgetWithText(AppPill, ExpensesListStrings.categoryMarketing);
        await tester.ensureVisible(marketingPill);
        await tester.pumpAndSettle();
        await tester.tap(marketingPill);
        await tester.pumpAndSettle();
        expect(find.text('2 expenses'), findsOneWidget);
        expect(find.text('Instagram ads'), findsOneWidget);
        expect(find.text('Stock photos pack'), findsOneWidget);

        // Equipment pill -> 1 expense (Monitor 27 inch)
        final Finder equipmentPill =
            find.widgetWithText(AppPill, ExpensesListStrings.categoryEquipment);
        await tester.ensureVisible(equipmentPill);
        await tester.pumpAndSettle();
        await tester.tap(equipmentPill);
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Monitor 27 inch'), findsOneWidget);

        // Others pill -> 1 expense (Coworking pass)
        final Finder othersPill =
            find.widgetWithText(AppPill, ExpensesListStrings.categoryOthers);
        await tester.ensureVisible(othersPill);
        await tester.pumpAndSettle();
        await tester.tap(othersPill);
        await tester.pumpAndSettle();
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Coworking pass'), findsOneWidget);

        // All pill -> restores 7 expenses
        final Finder allPill =
            find.widgetWithText(AppPill, ExpensesListStrings.categoryAll);
        await tester.ensureVisible(allPill);
        await tester.pumpAndSettle();
        await tester.tap(allPill);
        await tester.pumpAndSettle();
        expect(find.text('7 expenses'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);
      },
    );

    testWidgets(
      'Link filter and category filter via filter sheet really apply and stay in sync with pills',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        // Tap "Filter" to open the filter bottom sheet
        await tester.tap(find.text(ExpensesListStrings.filter));
        await tester.pumpAndSettle();

        expect(find.byType(ExpensesListFilterSheet), findsOneWidget);
        expect(find.text(ExpensesListStrings.filterSheetTitle), findsOneWidget);

        // Select "Project linked" chip in sheet
        await tester.tap(
          find.descendant(
            of: find.byType(ExpensesListFilterSheet),
            matching: find.widgetWithText(
              AppPill,
              ExpensesListStrings.linkProjectLinked,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Apply filters
        await tester.tap(find.text(ExpensesListStrings.applyFilters));
        await tester.pumpAndSettle();

        // Sheet closed, 3 project-linked expenses displayed
        expect(find.byType(ExpensesListFilterSheet), findsNothing);
        expect(find.text('3 expenses'), findsOneWidget);
        expect(find.text('Instagram ads'), findsOneWidget);
        expect(find.text('Stock photos pack'), findsOneWidget);

        // Re-open filter sheet, select "General costs" in sheet
        await tester.tap(find.text(ExpensesListStrings.filter));
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(ExpensesListFilterSheet),
            matching: find.widgetWithText(
              AppPill,
              ExpensesListStrings.linkGeneralCosts,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.applyFilters));
        await tester.pumpAndSettle();

        // 4 general cost expenses displayed
        expect(find.text('4 expenses'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);
        expect(find.text('Domain renewal'), findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(find.text('Monitor 27 inch'), findsOneWidget);

        // Scroll back up so Filter button is in view before re-opening sheet
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ExpensesListStrings.filter));
        await tester.pumpAndSettle();

        // Hosting category in sheet + General costs -> Domain renewal (1 expense)
        await tester.tap(
          find.descendant(
            of: find.byType(ExpensesListFilterSheet),
            matching: find.widgetWithText(
              AppPill,
              ExpensesListStrings.categoryHosting,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.applyFilters));
        await tester.pumpAndSettle();

        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Domain renewal'), findsOneWidget);

        // Verify the horizontal pill row is in sync: Hosting pill is selected
        final AppPill hostingPill = tester.widget<AppPill>(
          find.descendant(
            of: find.byKey(const Key('expense-category-pills')),
            matching: find.widgetWithText(
              AppPill,
              ExpensesListStrings.categoryHosting,
            ),
          ),
        );
        expect(hostingPill.selected, isTrue);

        // Re-open sheet, tap Reset, then Apply filters
        await tester.ensureVisible(find.text(ExpensesListStrings.filter));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ExpensesListStrings.filter));
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.reset));
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.applyFilters));
        await tester.pumpAndSettle();

        // Restored to all 7 expenses
        expect(find.text('7 expenses'), findsOneWidget);
      },
    );

    testWidgets(
      'Sort sheet applies each sort order: newest, oldest, highest, lowest amount',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        // Default order: Newest first (Figma Pro plan, 2026-10-15 is first)
        List<ExpensesListCard> cards = tester
            .widgetList<ExpensesListCard>(find.byType(ExpensesListCard))
            .toList();
        expect(cards.first.expense.date, DateTime(2026, 10, 15));
        expect(cards.first.expense.description, 'Figma Pro plan');

        // Open sort sheet and select Oldest first
        await tester.tap(find.text('Sort: Newest ▾'));
        await tester.pumpAndSettle();
        expect(find.text(ExpensesListStrings.sortSheetTitle), findsOneWidget);

        await tester.tap(find.text(ExpensesListStrings.sortOldestFirst));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Oldest ▾'), findsOneWidget);

        cards = tester
            .widgetList<ExpensesListCard>(find.byType(ExpensesListCard))
            .toList();
        expect(cards.first.expense.date, DateTime(2026, 5, 5));
        expect(cards.first.expense.description, 'Coworking pass');

        // Open sort sheet and select Highest amount
        await tester.tap(find.text('Sort: Oldest ▾'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.sortHighestAmount));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Highest ▾'), findsOneWidget);

        cards = tester
            .widgetList<ExpensesListCard>(find.byType(ExpensesListCard))
            .toList();
        expect(cards.first.expense.amount, 38000.0);
        expect(cards.first.expense.description, 'Monitor 27 inch');

        // Open sort sheet and select Lowest amount
        await tester.tap(find.text('Sort: Highest ▾'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(ExpensesListStrings.sortLowestAmount));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Lowest ▾'), findsOneWidget);

        cards = tester
            .widgetList<ExpensesListCard>(find.byType(ExpensesListCard))
            .toList();
        expect(cards.first.expense.amount, 3200.0);
        expect(cards.first.expense.description, 'Domain renewal');
      },
    );

    testWidgets(
      'Empty state (zero expenses recorded) matches EX2 and navigates to /expenses/new',
      (WidgetTester tester) async {
        final (_, _, expensesRepo, _) = await pumpExpensesApp(
          tester,
          initialExpenses: <Expense>[],
        );
        final ExpenseStats stats = expensesRepo.expenseStats();

        // Header shows 0 expenses logged
        expect(
          find.text(ExpensesListStrings.expensesLogged(0)),
          findsOneWidget,
        );

        // KPIs show 0 DZ
        expect(find.text('0 DZ'), findsNWidgets(4));
        expect(stats.total, 0.0);

        // Count row
        expect(find.text('0 expenses'), findsOneWidget);

        // Empty card & button per EX2
        expect(find.text(ExpensesListStrings.emptyTitle), findsOneWidget);
        expect(find.text(ExpensesListStrings.emptySubtitle), findsOneWidget);
        expect(
          find.text(ExpensesListStrings.recordFirstExpense),
          findsOneWidget,
        );
        expect(find.byType(ExpensesListCard), findsNothing);

        // Scroll down to tap [+ Record first expense]
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ExpensesListStrings.recordFirstExpense));
        await tester.pumpAndSettle();

        expect(find.byType(ExpenseFormScreen), findsOneWidget);
        expect(find.text('ExpenseFormScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Filter empty state shows friendly message and [Clear filters] resets search, category, and link filters',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        final Finder searchField = find.byType(TextField);
        await tester.enterText(searchField, 'nonexistent_expense_query');
        await tester.pumpAndSettle();

        // Empty filter state
        expect(find.text(ExpensesListStrings.emptyFilterTitle), findsOneWidget);
        expect(
          find.text(ExpensesListStrings.emptyFilterSubtitle),
          findsOneWidget,
        );
        expect(find.text(ExpensesListStrings.clearFilters), findsOneWidget);
        expect(find.byType(ExpensesListCard), findsNothing);

        // Scroll down to tap [Clear filters]
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ExpensesListStrings.clearFilters));
        await tester.pumpAndSettle();

        // List is restored
        expect(find.text('7 expenses'), findsOneWidget);
        expect(find.text('Figma Pro plan'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping an expense card pushes detail route /expenses/:id (placeholder)',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        // Tap the first card (Figma Pro plan)
        await tester.tap(find.byType(ExpensesListCard).first);
        await tester.pumpAndSettle();

        expect(find.byType(ExpenseDetailScreen), findsOneWidget);
        expect(find.text('ExpenseDetailScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping "+" in header navigates to form route /expenses/new (placeholder)',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        // The "+" round icon button is in the header
        final Finder addButton =
            find.widgetWithIcon(RoundIconButton, Icons.add);
        expect(addButton, findsOneWidget);

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(find.byType(ExpenseFormScreen), findsOneWidget);
        expect(find.text('ExpenseFormScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Back button pops or navigates to /more fallback when stack cannot pop',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester);

        // Back button is the BackButton inside RoundIconButton
        final Finder backButton = find.byType(BackButton);
        expect(backButton, findsOneWidget);

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(find.byType(MoreScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Toast via GoRouterState.extra works for both Map and plain String payloads',
      (WidgetTester tester) async {
        final (_, _, _, GoRouter router) = await pumpExpensesApp(tester);

        // Navigating with Map payload: {'toast': 'Expense deleted successfully'}
        router.go(
          AppRoutes.expensesPath,
          extra: <String, Object?>{
            'toast': ExpensesListStrings.expenseDeletedToast,
          },
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.text(ExpensesListStrings.expenseDeletedToast),
          findsOneWidget,
        );

        // Wait for toast duration to auto-dismiss
        await tester.pump(const Duration(seconds: 4));
        expect(
          find.text(ExpensesListStrings.expenseDeletedToast),
          findsNothing,
        );

        // Navigating with plain String payload: 'Expense recorded'
        router.go(
          AppRoutes.expensesPath,
          extra: ExpensesListStrings.expenseRecordedToast,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.text(ExpensesListStrings.expenseRecordedToast),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 4));
        expect(
          find.text(ExpensesListStrings.expenseRecordedToast),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Renders on 360x800 surface without any layout overflow',
      (WidgetTester tester) async {
        // Populated list on 360x800
        await pumpExpensesApp(
          tester,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(ExpensesListScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll down to ensure all cards render without overflow
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Also test empty state on 360x800
        await pumpExpensesApp(
          tester,
          surfaceSize: const Size(360, 800),
          initialExpenses: <Expense>[],
        );
        expect(find.text(ExpensesListStrings.emptyTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
