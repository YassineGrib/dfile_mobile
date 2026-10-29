import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/expenses/expense_form_screen.dart';
import 'package:dfile_mobile/features/expenses/expense_form_strings.dart';
import 'package:dfile_mobile/features/expenses/widgets/expense_form_select_field.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(ClientsRepository, ProjectsRepository, ExpensesRepository, GoRouter)>
      pumpExpenseFormApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.newExpensePath,
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
      tester.view.resetViewInsets();
    });

    final ClientsRepository effectiveClientsRepo =
        clientsRepo ?? ClientsRepository();
    final ProjectsRepository effectiveProjectsRepo = projectsRepo ??
        ProjectsRepository(clientsRepository: effectiveClientsRepo);
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
      effectiveClientsRepo,
      effectiveProjectsRepo,
      effectiveExpensesRepo,
      router,
    );
  }

  group('Expense Form Screen', () {
    testWidgets('validation errors (empty amount / zero / empty description)',
        (WidgetTester tester) async {
      await pumpExpenseFormApp(tester);

      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      // Initially no errors shown
      expect(find.text(ExpenseFormStrings.amountError), findsNothing);
      expect(find.text(ExpenseFormStrings.descriptionError), findsNothing);

      // Attempt to save empty form
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.recordExpenseAction,
        ),
      );
      await tester.pumpAndSettle();

      // Both errors should now appear
      expect(find.text(ExpenseFormStrings.amountError), findsOneWidget);
      expect(find.text(ExpenseFormStrings.descriptionError), findsOneWidget);

      // Amount field finder
      final Finder amountInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.amountLabel,
        ),
        matching: find.byType(TextField),
      );

      // Enter zero: error remains
      await tester.enterText(amountInput, '0');
      await tester.pumpAndSettle();
      expect(find.text(ExpenseFormStrings.amountError), findsOneWidget);

      // Enter valid amount: error clears
      await tester.enterText(amountInput, '4500');
      await tester.pumpAndSettle();
      expect(find.text(ExpenseFormStrings.amountError), findsNothing);

      // Description field finder
      final Finder descriptionInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.descriptionLabel,
        ),
        matching: find.byType(TextField),
      );

      // Description error is still present
      expect(find.text(ExpenseFormStrings.descriptionError), findsOneWidget);

      // Enter description: error clears
      await tester.enterText(descriptionInput, 'Figma Pro plan');
      await tester.pumpAndSettle();
      expect(find.text(ExpenseFormStrings.descriptionError), findsNothing);

      // Erasing description brings error back
      await tester.enterText(descriptionInput, '');
      await tester.pumpAndSettle();
      expect(find.text(ExpenseFormStrings.descriptionError), findsOneWidget);

      // Erasing amount brings error back
      await tester.enterText(amountInput, '');
      await tester.pumpAndSettle();
      expect(find.text(ExpenseFormStrings.amountError), findsOneWidget);
    });

    testWidgets('category selection updates selected category',
        (WidgetTester tester) async {
      final (_, _, ExpensesRepository expensesRepo, _) =
          await pumpExpenseFormApp(tester);

      // Enter valid amount & description
      final Finder amountInput = find.descendant(
        of: find.widgetWithText(AppTextField, ExpenseFormStrings.amountLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountInput, '12000');

      final Finder descriptionInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.descriptionLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(descriptionInput, 'Sponsored post');

      // Select Marketing category
      await tester.tap(find.text('Marketing'));
      await tester.pumpAndSettle();

      // Save expense
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.recordExpenseAction,
        ),
      );
      await tester.pumpAndSettle();

      // Check newly added expense has Marketing category
      final Expense newExpense = expensesRepo.expenses.last;
      expect(newExpense.description, 'Sponsored post');
      expect(newExpense.amount, 12000.0);
      expect(newExpense.category, ExpenseCategory.marketing);
    });

    testWidgets(
        'project sheet lists General + all projects and preselects on confirm',
        (WidgetTester tester) async {
      final (_, ProjectsRepository projectsRepo, _, _) =
          await pumpExpenseFormApp(tester);

      // Tap linked project field
      await tester.tap(
        find.widgetWithText(
          ExpenseFormSelectField,
          ExpenseFormStrings.linkedProjectLabel,
        ),
      );
      await tester.pumpAndSettle();

      // Link project sheet opens
      expect(
        find.text(ExpenseFormStrings.linkProjectSheetTitle),
        findsOneWidget,
      );
      expect(
        find.text(ExpenseFormStrings.generalBusinessCost),
        findsWidgets,
      );
      expect(
        find.text(ExpenseFormStrings.notLinkedSubtitle),
        findsOneWidget,
      );

      // Every project is listed with client name
      for (final ProjectItem project in projectsRepo.projects) {
        expect(find.text(project.name), findsOneWidget);
      }

      // Select "Brand Identity"
      await tester.tap(find.text('Brand Identity'));
      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(
        find.widgetWithText(PrimaryButton, ExpenseFormStrings.confirm),
      );
      await tester.pumpAndSettle();

      // Sheet closed, field now displays Brand Identity
      expect(find.text('Brand Identity'), findsOneWidget);
    });

    testWidgets('preselect via projectId query parameter',
        (WidgetTester tester) async {
      // p1 = Fintask Landing Page
      await pumpExpenseFormApp(
        tester,
        initialLocation: '${AppRoutes.newExpensePath}?projectId=p1',
      );

      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      // Project field should prefill with "Fintask Landing Page"
      final Finder selectField = find.widgetWithText(
        ExpenseFormSelectField,
        ExpenseFormStrings.linkedProjectLabel,
      );
      expect(
        find.descendant(
          of: selectField,
          matching: find.text('Fintask Landing Page'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'successful record adds the expense and navigates to /expenses',
        (WidgetTester tester) async {
      final (_, _, ExpensesRepository expensesRepo, _) =
          await pumpExpenseFormApp(tester);

      final int initialCount = expensesRepo.expenses.length;

      // Fill in amount
      final Finder amountInput = find.descendant(
        of: find.widgetWithText(AppTextField, ExpenseFormStrings.amountLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountInput, '3200');

      // Select Hosting category
      await tester.tap(find.text('Hosting'));
      await tester.pumpAndSettle();

      // Fill in description
      final Finder descInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.descriptionLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(descInput, 'Domain renewal test');

      // Select Bank wire method
      await tester.tap(find.text('Bank wire'));
      await tester.pumpAndSettle();

      // Fill in reference
      final Finder refInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.invoiceRefLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(refInput, 'REF-TEST-101');

      // Fill in notes
      final Finder notesInput = find.descendant(
        of: find.widgetWithText(AppTextField, ExpenseFormStrings.notesLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(notesInput, 'Test expense notes');

      // Tap Record expense
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.recordExpenseAction,
        ),
      );
      await tester.pumpAndSettle();

      // Navigation: should no longer be on ExpenseFormScreen (navigated to /expenses)
      expect(find.byType(ExpenseFormScreen), findsNothing);

      // Verify repository has added the expense
      expect(expensesRepo.expenses.length, initialCount + 1);
      final Expense added = expensesRepo.expenses.last;
      expect(added.amount, 3200.0);
      expect(added.description, 'Domain renewal test');
      expect(added.category, ExpenseCategory.hostingServices);
      expect(added.method, PaymentMethod.bank);
      expect(added.reference, 'REF-TEST-101');
      expect(added.notes, 'Test expense notes');
      expect(added.projectId, isNull);
    });

    testWidgets('edit prefill + save updates the repository',
        (WidgetTester tester) async {
      // exp1: Figma Pro plan, 4,500 DZ, Software/Tools, general cost, CCP, INV-802
      final (_, _, ExpensesRepository expensesRepo, _) =
          await pumpExpenseFormApp(
        tester,
        initialLocation: '/expenses/exp1/edit',
      );

      expect(find.byType(ExpenseFormScreen), findsOneWidget);
      expect(find.text(ExpenseFormStrings.editTitle), findsOneWidget);
      expect(find.text(ExpenseFormStrings.editSubtitle), findsOneWidget);
      expect(find.text(ExpenseFormStrings.saveChangesAction), findsOneWidget);

      // Verify prefilled values
      expect(find.text('4,500'), findsOneWidget);
      expect(find.text('Figma Pro plan'), findsOneWidget);
      expect(find.text('INV-802'), findsOneWidget);

      // Change description
      final Finder descInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          ExpenseFormStrings.descriptionLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(descInput, 'Figma Organization plan');

      // Change amount
      final Finder amountInput = find.descendant(
        of: find.widgetWithText(AppTextField, ExpenseFormStrings.amountLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountInput, '9000');

      // Change category to Equipment
      await tester.tap(find.text('Equipment'));
      await tester.pumpAndSettle();

      // Tap Save changes
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.saveChangesAction,
        ),
      );
      await tester.pumpAndSettle();

      // Verify updated in repository
      final Expense updated = expensesRepo.byId('exp1')!;
      expect(updated.description, 'Figma Organization plan');
      expect(updated.amount, 9000.0);
      expect(updated.category, ExpenseCategory.equipment);
    });

    testWidgets('edit unknown id displays friendly Expense not found screen',
        (WidgetTester tester) async {
      await pumpExpenseFormApp(
        tester,
        initialLocation: '/expenses/non_existent_exp_999/edit',
      );

      expect(find.byType(ExpenseFormScreen), findsOneWidget);
      expect(find.text(ExpenseFormStrings.expenseNotFound), findsOneWidget);
      expect(find.text(ExpenseFormStrings.backToExpenses), findsOneWidget);

      // Tap Back to expenses
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.backToExpenses,
        ),
      );
      await tester.pumpAndSettle();

      // Screen popped or navigated away
      expect(find.text(ExpenseFormStrings.expenseNotFound), findsNothing);
    });

    testWidgets('cancel and X buttons pop or fallback to /expenses',
        (WidgetTester tester) async {
      // 1. Test X close button
      await pumpExpenseFormApp(tester, initialLocation: AppRoutes.newExpensePath);
      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseFormScreen), findsNothing);

      // 2. Test Cancel button in bottom bar
      await pumpExpenseFormApp(tester, initialLocation: AppRoutes.newExpensePath);
      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      await tester.tap(
        find.widgetWithText(SecondaryButton, ExpenseFormStrings.cancel),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseFormScreen), findsNothing);
    });

    testWidgets('360x800 surface renders record and edit without overflow',
        (WidgetTester tester) async {
      // Record mode on 360x800
      await pumpExpenseFormApp(
        tester,
        initialLocation: AppRoutes.newExpensePath,
        surfaceSize: const Size(360, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      // Simulate software keyboard
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final Rect recordBtnRect = tester.getRect(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.recordExpenseAction,
        ),
      );
      expect(recordBtnRect.bottom, lessThanOrEqualTo(800 - 280));

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      // Edit mode on 360x800
      await pumpExpenseFormApp(
        tester,
        initialLocation: '/expenses/exp1/edit',
        surfaceSize: const Size(360, 800),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ExpenseFormScreen), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final Rect saveBtnRect = tester.getRect(
        find.widgetWithText(
          PrimaryButton,
          ExpenseFormStrings.saveChangesAction,
        ),
      );
      expect(saveBtnRect.bottom, lessThanOrEqualTo(800 - 280));
    });
  });
}
