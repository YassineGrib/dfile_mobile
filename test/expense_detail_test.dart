import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/expenses/expense_detail_strings.dart';
import 'package:dfile_mobile/features/expenses/expense_form_screen.dart';
import 'package:dfile_mobile/features/expenses/expenses_list_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/projects/project_detail_screen.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(ExpensesRepository, ProjectsRepository, ClientsRepository, GoRouter)>
      pumpExpenseApp(
    WidgetTester tester, {
    required String initialLocation,
    Size surfaceSize = const Size(390, 844),
    ExpensesRepository? expensesRepo,
    ProjectsRepository? projectsRepo,
    ClientsRepository? clientsRepo,
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final ClientsRepository effectiveClientsRepo =
        clientsRepo ?? ClientsRepository();
    final ProjectsRepository effectiveProjectsRepo = projectsRepo ??
        ProjectsRepository(
          clientsRepository: effectiveClientsRepo,
        );
    final ExpensesRepository effectiveExpensesRepo =
        expensesRepo ?? ExpensesRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        repository: effectiveClientsRepo,
        projectsRepository: effectiveProjectsRepo,
        expensesRepository: effectiveExpensesRepo,
      ),
    );
    await tester.pumpAndSettle();
    return (
      effectiveExpensesRepo,
      effectiveProjectsRepo,
      effectiveClientsRepo,
      router
    );
  }

  group('ExpenseDetailScreen Widget Tests', () {
    testWidgets('renders values for a seeded linked expense (exp3)', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');

      // Top bar
      expect(find.text(ExpenseDetailStrings.title), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Card Header
      expect(find.text('Instagram ads'), findsOneWidget);
      expect(find.text('Marketing'), findsNWidgets(2)); // label and chip
      expect(find.text('M'), findsOneWidget); // category initial

      // Amount
      expect(find.text(ExpenseDetailStrings.amountSpent), findsOneWidget);
      expect(find.text('-12,000 DZ'), findsOneWidget);

      // Metadata rows
      expect(find.text(ExpenseDetailStrings.category), findsOneWidget);
      expect(find.text(ExpenseDetailStrings.project), findsOneWidget);
      expect(find.text('Brand Identity'), findsOneWidget);
      expect(find.text(ExpenseDetailStrings.method), findsOneWidget);
      expect(find.text('BaridiMob'), findsOneWidget);
      expect(find.text(ExpenseDetailStrings.date), findsOneWidget);
      expect(find.text('2026-09-20'), findsOneWidget);
      expect(find.text(ExpenseDetailStrings.reference), findsOneWidget);
      expect(find.text('AD-2291'), findsOneWidget);

      // Notes
      expect(find.text(ExpenseDetailStrings.notes), findsOneWidget);
      expect(
        find.text('Campaign for the brand launch week.'),
        findsOneWidget,
      );

      // Bottom bar
      expect(find.text(ExpenseDetailStrings.editExpense), findsOneWidget);
    });

    testWidgets('renders values for a seeded general expense (exp1)', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp1');

      // Top bar
      expect(find.text(ExpenseDetailStrings.title), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Card Header
      expect(find.text('Figma Pro plan'), findsOneWidget);
      expect(find.text('Software/Tools'), findsOneWidget);
      expect(find.text('Software'), findsOneWidget); // Chip shortLabel
      expect(find.text('S'), findsOneWidget); // initial

      // Amount
      expect(find.text('-4,500 DZ'), findsOneWidget);

      // Metadata rows
      expect(find.text(ExpenseDetailStrings.generalCost), findsOneWidget);
      expect(find.text('CCP'), findsOneWidget);
      expect(find.text('2026-10-15'), findsOneWidget);
      expect(find.text('INV-802'), findsOneWidget);

      // Notes should be hidden
      expect(find.text(ExpenseDetailStrings.notes), findsNothing);
    });

    testWidgets('notes shown only when present', (WidgetTester tester) async {
      // exp3 has notes
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');
      expect(find.text(ExpenseDetailStrings.notes), findsOneWidget);
      expect(
        find.text('Campaign for the brand launch week.'),
        findsOneWidget,
      );

      // exp1 has no notes
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp1');
      expect(find.text(ExpenseDetailStrings.notes), findsNothing);
    });

    testWidgets('copy reference copies to Clipboard and shows toast when present', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');

      // Open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(ExpenseDetailStrings.copyReference), findsOneWidget);
      await tester.tap(find.text(ExpenseDetailStrings.copyReference));
      await tester.pump();

      expect(
        find.text(ExpenseDetailStrings.copiedReferenceToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('copy reference on empty reference shows no reference toast', (
      WidgetTester tester,
    ) async {
      // exp4 has empty reference
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp4');

      // Check detail row displays dash
      expect(
        find.text(ExpenseDetailStrings.emptyReferenceDash),
        findsOneWidget,
      );

      // Open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(ExpenseDetailStrings.copyReference), findsOneWidget);
      await tester.tap(find.text(ExpenseDetailStrings.copyReference));
      await tester.pump();

      expect(
        find.text(ExpenseDetailStrings.noReferenceToCopyToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets(
      'go to project row is hidden for general expenses and navigates for linked ones',
      (WidgetTester tester) async {
        // General expense exp1
        await pumpExpenseApp(tester, initialLocation: '/expenses/exp1');
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        expect(find.text(ExpenseDetailStrings.goToProject), findsNothing);

        // Close sheet
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        // Linked expense exp3 (linked to p2 Brand Identity)
        await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        expect(find.text(ExpenseDetailStrings.goToProject), findsOneWidget);
        await tester.tap(find.text(ExpenseDetailStrings.goToProject));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectDetailScreen), findsOneWidget);
        expect(find.text('Brand Identity'), findsWidgets);
      },
    );

    testWidgets('edit expense from bottom bar navigates to edit route', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');

      expect(find.text(ExpenseDetailStrings.editExpense), findsOneWidget);
      await tester.tap(find.text(ExpenseDetailStrings.editExpense));
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseFormScreen), findsOneWidget);
    });

    testWidgets('edit expense from actions sheet navigates to edit route', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/exp3');

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      final Finder sheetEditButton = find.descendant(
        of: find.byType(AppBottomSheet),
        matching: find.text(ExpenseDetailStrings.editExpense),
      );
      expect(sheetEditButton, findsOneWidget);
      await tester.tap(sheetEditButton);
      await tester.pumpAndSettle();

      expect(find.byType(ExpenseFormScreen), findsOneWidget);
    });

    testWidgets(
      'delete flow removes the expense and ends on /expenses with extra toast',
      (WidgetTester tester) async {
        final (ExpensesRepository repo, _, _, _) = await pumpExpenseApp(
          tester,
          initialLocation: '/expenses/exp3',
        );

        expect(repo.byId('exp3'), isNotNull);

        // Open actions sheet
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        // Tap Delete expense -> opens delete confirm sheet
        expect(find.text(ExpenseDetailStrings.deleteExpense), findsOneWidget);
        await tester.tap(find.text(ExpenseDetailStrings.deleteExpense));
        await tester.pumpAndSettle();

        // Confirm sheet elements
        expect(
          find.text(ExpenseDetailStrings.deleteExpenseTitle),
          findsOneWidget,
        );
        expect(
          find.text(ExpenseDetailStrings.deleteExpenseSubtitle),
          findsOneWidget,
        );
        expect(
          find.text(
            ExpenseDetailStrings.deleteWarningExpense(
              'Instagram ads',
              12000,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.text(ExpenseDetailStrings.deleteWarningRecalculate),
          findsOneWidget,
        );

        // Tap Confirm delete
        await tester.tap(find.text(ExpenseDetailStrings.confirmDelete));
        await tester.pumpAndSettle();

        // Expense is deleted from repository
        expect(repo.byId('exp3'), isNull);

        // Router ended on /expenses
        expect(find.byType(ExpensesListScreen), findsOneWidget);
      },
    );

    testWidgets('unknown expense id renders friendly Expense not found screen', (
      WidgetTester tester,
    ) async {
      await pumpExpenseApp(tester, initialLocation: '/expenses/unknown_id');

      expect(find.text(ExpenseDetailStrings.expenseNotFound), findsOneWidget);
      expect(find.text(ExpenseDetailStrings.backToExpenses), findsOneWidget);

      await tester.tap(find.text(ExpenseDetailStrings.backToExpenses));
      await tester.pumpAndSettle();

      expect(find.byType(ExpensesListScreen), findsOneWidget);
    });

    testWidgets(
      '360x800 surface renders detail, actions, and delete sheet with no overflow',
      (WidgetTester tester) async {
        await pumpExpenseApp(
          tester,
          initialLocation: '/expenses/exp3',
          surfaceSize: const Size(360, 800),
        );

        expect(tester.takeException(), isNull);

        // Open Actions sheet
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Open Delete confirm sheet
        await tester.tap(find.text(ExpenseDetailStrings.deleteExpense));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Cancel out
        await tester.tap(find.text(ExpenseDetailStrings.cancel));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
