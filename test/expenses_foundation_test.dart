import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/expenses/expense_detail_screen.dart';
import 'package:dfile_mobile/features/expenses/expense_form_screen.dart';
import 'package:dfile_mobile/features/expenses/expense_strings.dart';
import 'package:dfile_mobile/features/expenses/expenses_list_screen.dart';
import 'package:dfile_mobile/features/more/more_strings.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Expense Enums & Labels', () {
    test('ExpenseCategory enum defines storage, full, and short labels', () {
      expect(ExpenseCategory.values, <ExpenseCategory>[
        ExpenseCategory.softwareTools,
        ExpenseCategory.hostingServices,
        ExpenseCategory.marketing,
        ExpenseCategory.equipment,
        ExpenseCategory.others,
      ]);

      expect(ExpenseCategory.softwareTools.storageName, 'Software/Tools');
      expect(ExpenseCategory.softwareTools.fullLabel, 'Software/Tools');
      expect(ExpenseCategory.softwareTools.shortLabel, 'Software');
      expect(ExpenseCategory.softwareTools.label, 'Software/Tools');

      expect(ExpenseCategory.hostingServices.storageName, 'Hosting/Services');
      expect(ExpenseCategory.hostingServices.fullLabel, 'Hosting/Services');
      expect(ExpenseCategory.hostingServices.shortLabel, 'Hosting');
      expect(ExpenseCategory.hostingServices.label, 'Hosting/Services');

      expect(ExpenseCategory.marketing.storageName, 'Marketing');
      expect(ExpenseCategory.marketing.fullLabel, 'Marketing');
      expect(ExpenseCategory.marketing.shortLabel, 'Marketing');

      expect(ExpenseCategory.equipment.storageName, 'Equipment');
      expect(ExpenseCategory.equipment.fullLabel, 'Equipment');
      expect(ExpenseCategory.equipment.shortLabel, 'Equipment');

      expect(ExpenseCategory.others.storageName, 'Others');
      expect(ExpenseCategory.others.fullLabel, 'Others');
      expect(ExpenseCategory.others.shortLabel, 'Others');

      expect(
        ExpenseCategory.tryParse('Software/Tools'),
        ExpenseCategory.softwareTools,
      );
      expect(
        ExpenseCategory.tryParse('Hosting'),
        ExpenseCategory.hostingServices,
      );
      expect(ExpenseCategory.tryParse('marketing'), ExpenseCategory.marketing);
      expect(ExpenseCategory.tryParse('unknown'), isNull);
      expect(
        ExpenseCategory.fromStorageName('Equipment'),
        ExpenseCategory.equipment,
      );
      expect(
        ExpenseCategory.fromStorageName('nonexistent'),
        ExpenseCategory.others,
      );
    });

    test(
      'ExpenseStrings provides centralised labels and reuse of payment methods',
      () {
        expect(ExpenseStrings.softwareTools, 'Software/Tools');
        expect(ExpenseStrings.hostingServices, 'Hosting/Services');
        expect(ExpenseStrings.marketing, 'Marketing');
        expect(ExpenseStrings.equipment, 'Equipment');
        expect(ExpenseStrings.others, 'Others');

        expect(ExpenseStrings.softwareShort, 'Software');
        expect(ExpenseStrings.hostingShort, 'Hosting');
        expect(ExpenseStrings.marketingShort, 'Marketing');
        expect(ExpenseStrings.equipmentShort, 'Equipment');
        expect(ExpenseStrings.othersShort, 'Others');

        expect(ExpenseStrings.baridimob, 'BaridiMob');
        expect(ExpenseStrings.ccp, 'CCP');
        expect(ExpenseStrings.bank, 'Bank wire');
        expect(ExpenseStrings.cash, 'Cash');

        expect(
          ExpenseStrings.categoryFullLabel(ExpenseCategory.softwareTools),
          'Software/Tools',
        );
        expect(
          ExpenseStrings.categoryShortLabel(ExpenseCategory.softwareTools),
          'Software',
        );
        expect(
          ExpenseStrings.categoryLabel(ExpenseCategory.marketing),
          'Marketing',
        );
        expect(
          ExpenseStrings.methodLabel(PaymentMethod.baridimob),
          'BaridiMob',
        );
        expect(ExpenseStrings.methodLabel(PaymentMethod.ccp), 'CCP');
        expect(ExpenseStrings.methodLabel(PaymentMethod.bank), 'Bank wire');
        expect(ExpenseStrings.methodLabel(PaymentMethod.cash), 'Cash');
      },
    );

    test('ExpenseLinkFilter and ExpenseSort define user-facing labels', () {
      expect(ExpenseLinkFilter.all.label, 'All');
      expect(ExpenseLinkFilter.linked.label, 'Project linked');
      expect(ExpenseLinkFilter.general.label, 'General costs');

      expect(ExpenseSort.newest.label, 'Newest first');
      expect(ExpenseSort.oldest.label, 'Oldest first');
      expect(ExpenseSort.highestAmount.label, 'Highest amount');
      expect(ExpenseSort.lowestAmount.label, 'Lowest amount');
    });
  });

  group('Expense Model & copyWith', () {
    test('Expense entity defaults and copyWith behaviour', () {
      final expense = Expense(
        id: 'exp_test',
        description: 'Design subscription',
        category: ExpenseCategory.softwareTools,
        amount: 5000.0,
        date: DateTime(2026, 10, 20),
      );

      expect(expense.projectId, isNull);
      expect(expense.isProjectLinked, isFalse);
      expect(expense.method, PaymentMethod.baridimob);
      expect(expense.reference, '');
      expect(expense.notes, '');
      expect(expense.createdAt, DateTime(2026, 10, 20));

      final linked = expense.copyWith(
        projectId: 'p1',
        reference: 'INV-99',
        notes: 'Monthly license',
        method: PaymentMethod.ccp,
      );

      expect(linked.projectId, 'p1');
      expect(linked.isProjectLinked, isTrue);
      expect(linked.reference, 'INV-99');
      expect(linked.notes, 'Monthly license');
      expect(linked.method, PaymentMethod.ccp);

      final unlinked = linked.copyWith(clearProjectId: true);
      expect(unlinked.projectId, isNull);
      expect(unlinked.isProjectLinked, isFalse);
    });
  });

  group('ExpensesRepository CRUD & Projects Association', () {
    late ExpensesRepository repo;

    setUp(() {
      repo = ExpensesRepository();
    });

    test('Loads exact 7-expense mock seed per SPEC.md', () {
      expect(repo.expenses.length, 7);

      final double total = repo.expenses.fold<double>(
        0.0,
        (sum, e) => sum + e.amount,
      );
      expect(total, 91200.0);

      // Unmodifiable check
      expect(
        () => repo.expenses.add(
          Expense(
            id: 'x',
            description: 'x',
            category: ExpenseCategory.others,
            amount: 100,
            date: DateTime(2026, 1, 1),
          ),
        ),
        throwsUnsupportedError,
      );

      // Project links
      final p1Expenses = repo.expensesOfProject('p1');
      expect(p1Expenses.length, 2);
      expect(p1Expenses.map((e) => e.id).toSet(), <String>{'exp4', 'exp6'});

      final p2Expenses = repo.expensesOfProject('p2');
      expect(p2Expenses.length, 1);
      expect(p2Expenses.first.id, 'exp3');

      expect(repo.expensesOfProject('p3'), isEmpty);
    });

    test('byId retrieves an expense by id or returns null', () {
      expect(repo.byId('exp1')?.description, 'Figma Pro plan');
      expect(repo.byId('exp3')?.amount, 12000.0);
      expect(repo.byId('nonexistent'), isNull);
    });

    test('add appends expense, notifies listeners, and increments total', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final newExpense = Expense(
        id: 'exp8',
        description: 'New domain',
        category: ExpenseCategory.hostingServices,
        amount: 2500.0,
        date: DateTime(2026, 10, 25),
      );

      repo.add(newExpense);

      expect(notifications, 1);
      expect(repo.expenses.length, 8);
      expect(repo.byId('exp8'), newExpense);
    });

    test('update modifies existing expense and notifies listeners', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final original = repo.byId('exp1')!;
      final updated = original.copyWith(
        amount: 5000.0,
        notes: 'Price increased',
      );

      final bool success = repo.update(updated);

      expect(success, isTrue);
      expect(notifications, 1);
      expect(repo.byId('exp1')?.amount, 5000.0);
      expect(repo.byId('exp1')?.notes, 'Price increased');

      final bool fail = repo.update(
        Expense(
          id: 'nonexistent',
          description: 'Nonexistent',
          category: ExpenseCategory.others,
          amount: 100,
          date: DateTime(2026, 1, 1),
        ),
      );
      expect(fail, isFalse);
      expect(notifications, 1);
    });

    test('delete removes expense, notifies listeners, and updates stats', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final bool removed = repo.delete('exp1');

      expect(removed, isTrue);
      expect(notifications, 1);
      expect(repo.expenses.length, 6);
      expect(repo.byId('exp1'), isNull);

      final bool fail = repo.delete('nonexistent');
      expect(fail, isFalse);
      expect(notifications, 1);
    });
  });

  group('ExpenseStats calculation with fixed reference date', () {
    test('Computes exact mock seed totals per SPEC.md', () {
      final repo = ExpensesRepository();
      final stats = repo.expenseStats(now: DateTime(2026, 10, 20));

      // Totals per SPEC.md:
      // Totals: 91,200 / project-linked 36,500 (3) / this month (Oct 2026) 7,700 / average 13,029
      expect(stats.total, 91200.0);
      expect(stats.projectLinked, 36500.0);
      expect(stats.projectLinkedCount, 3);
      expect(stats.thisMonth, 7700.0);
      expect(stats.average, 13029.0);
    });

    test('Computes thisMonth accurately for other months', () {
      final repo = ExpensesRepository();

      // September 2026: only exp3 (12,000 DZ)
      final sepStats = repo.expenseStats(now: DateTime(2026, 9, 1));
      expect(sepStats.thisMonth, 12000.0);

      // January 2026: 0
      final janStats = repo.expenseStats(now: DateTime(2026, 1, 1));
      expect(janStats.thisMonth, 0.0);
    });

    test('Empty repository returns zeroes', () {
      final emptyRepo = ExpensesRepository(initialExpenses: <Expense>[]);
      final stats = emptyRepo.expenseStats();

      expect(stats.total, 0.0);
      expect(stats.projectLinked, 0.0);
      expect(stats.projectLinkedCount, 0);
      expect(stats.thisMonth, 0.0);
      expect(stats.average, 0.0);
    });
  });

  group('filterExpenses helper function', () {
    late List<Expense> seed;

    setUp(() {
      seed = ExpensesRepository().expenses;
    });

    String mockProjectName(String projectId) {
      switch (projectId) {
        case 'p1':
          return 'Fintask Landing Page';
        case 'p2':
          return 'Brand Identity';
        default:
          return '';
      }
    }

    test('Matches query across description, category label, project name, reference, and notes', () {
      // Description
      final figma = filterExpenses(seed, query: 'Figma');
      expect(figma.length, 1);
      expect(figma.first.id, 'exp1');

      // Category full label
      final soft = filterExpenses(seed, query: 'Software/Tools');
      expect(soft.length, 1);
      expect(soft.first.id, 'exp1');

      // Category short label
      final host = filterExpenses(seed, query: 'Hosting');
      expect(host.length, 2);
      expect(host.map((e) => e.id).toSet(), <String>{'exp2', 'exp6'});

      // Project name via projectName resolver
      final brand = filterExpenses(
        seed,
        query: 'Brand Identity',
        projectName: mockProjectName,
      );
      expect(brand.length, 1);
      expect(brand.first.id, 'exp3');

      // Reference
      final ref = filterExpenses(seed, query: 'INV-802');
      expect(ref.length, 1);
      expect(ref.first.id, 'exp1');

      // Notes
      final notes = filterExpenses(seed, query: 'Campaign');
      expect(notes.length, 1);
      expect(notes.first.id, 'exp3');
    });

    test('Filters by category correctly', () {
      final marketing = filterExpenses(
        seed,
        category: ExpenseCategory.marketing,
      );
      expect(marketing.length, 2);
      expect(marketing.map((e) => e.id).toSet(), <String>{'exp3', 'exp4'});
    });

    test('Filters by project link status correctly', () {
      final linked = filterExpenses(seed, link: ExpenseLinkFilter.linked);
      expect(linked.length, 3);
      expect(linked.map((e) => e.id).toSet(), <String>{'exp3', 'exp4', 'exp6'});

      final general = filterExpenses(seed, link: ExpenseLinkFilter.general);
      expect(general.length, 4);
      expect(general.map((e) => e.id).toSet(), <String>{
        'exp1',
        'exp2',
        'exp5',
        'exp7',
      });

      final all = filterExpenses(seed, link: ExpenseLinkFilter.all);
      expect(all.length, 7);
    });

    test('Combines query, category, and link filters', () {
      final combined = filterExpenses(
        seed,
        query: 'Fintask',
        category: ExpenseCategory.marketing,
        link: ExpenseLinkFilter.linked,
        projectName: mockProjectName,
      );
      expect(combined.length, 1);
      expect(combined.first.id, 'exp4');
    });
  });

  group('sortExpenses helper function', () {
    late List<Expense> seed;

    setUp(() {
      seed = ExpensesRepository().expenses;
    });

    test('Sorts newest first and oldest first', () {
      final newest = sortExpenses(seed, ExpenseSort.newest);
      expect(newest.map((e) => e.id).toList(), <String>[
        'exp1',
        'exp2',
        'exp3',
        'exp4',
        'exp5',
        'exp6',
        'exp7',
      ]);

      final oldest = sortExpenses(seed, ExpenseSort.oldest);
      expect(oldest.map((e) => e.id).toList(), <String>[
        'exp7',
        'exp6',
        'exp5',
        'exp4',
        'exp3',
        'exp2',
        'exp1',
      ]);
    });

    test('Sorts highest amount and lowest amount', () {
      final highest = sortExpenses(seed, ExpenseSort.highestAmount);
      expect(highest.map((e) => e.amount).toList(), <double>[
        38000.0,
        18000.0,
        12000.0,
        9000.0,
        6500.0,
        4500.0,
        3200.0,
      ]);

      final lowest = sortExpenses(seed, ExpenseSort.lowestAmount);
      expect(
        lowest.map((e) => e.amount).toList(),
        <double>[
          3200.0,
          4500.0,
          6500.0,
          9000.0,
          12000.0,
          18000.0,
          3800.0 * 10,
        ], // 38000
      );
    });

    test('Returns fresh list without mutating input list', () {
      final copy = List<Expense>.of(seed);
      sortExpenses(seed, ExpenseSort.lowestAmount);
      expect(seed, copy);
    });
  });

  group('MoreScreen & Expenses Routes Navigation on 390x844 Surface', () {
    Future<
      (ClientsRepository, ProjectsRepository, ExpensesRepository, GoRouter)
    >
    pumpExpensesApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.morePath,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final clientsRepo = ClientsRepository();
      final projectsRepo = ProjectsRepository(clientsRepository: clientsRepo);
      final expensesRepo = ExpensesRepository();
      final router = createAppRouter(initialLocation: initialLocation);

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
      'Tapping Expenses row in More menu navigates to /expenses placeholder and back',
      (WidgetTester tester) async {
        await pumpExpensesApp(tester, initialLocation: AppRoutes.morePath);

        // Tap Expenses row
        await tester.tap(find.text(MoreStrings.expensesTitle).first);
        await tester.pumpAndSettle();

        // Verify on ExpensesListScreen placeholder
        expect(find.byType(ExpensesListScreen), findsOneWidget);
        expect(find.text('ExpensesListScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Routes /expenses/new, /expenses/:id, and /expenses/:id/edit resolve to placeholders',
      (WidgetTester tester) async {
        final (_, _, _, GoRouter router) = await pumpExpensesApp(
          tester,
          initialLocation: '${AppRoutes.newExpensePath}?projectId=p1',
        );

        // /expenses/new with query param
        expect(find.byType(ExpenseFormScreen), findsOneWidget);
        expect(find.text('ExpenseFormScreen'), findsOneWidget);

        // /expenses/:id
        router.go('/expenses/exp1');
        await tester.pumpAndSettle();
        expect(find.byType(ExpenseDetailScreen), findsOneWidget);
        expect(find.text('ExpenseDetailScreen'), findsOneWidget);

        // /expenses/:id/edit
        router.go('/expenses/exp1/edit');
        await tester.pumpAndSettle();
        expect(find.byType(ExpenseFormScreen), findsOneWidget);
        expect(find.text('ExpenseFormScreen'), findsOneWidget);
      },
    );
  });
}
