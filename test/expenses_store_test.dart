import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';

Future<void> settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Expense sample(String id, {String? projectId}) => Expense(
  id: id,
  description: 'Figma',
  category: ExpenseCategory.softwareTools,
  amount: 4500,
  projectId: projectId,
  method: PaymentMethod.ccp,
  reference: 'INV-1',
  notes: 'note',
  date: DateTime(2026, 10, 15),
  createdAt: DateTime(2026, 10, 15, 9),
);

void main() {
  group('expense document mapping', () {
    test('uses the web field names', () {
      final Map<String, Object?> map = expenseToMap(
        sample('e1', projectId: 'p1'),
      );
      expect(map['amount'], 4500);
      expect(map['category'], 'Software/Tools');
      expect(map['project_id'], 'p1');
      expect(map['payment_method'], 'ccp');
      expect(map['reference_number'], 'INV-1');
      expect(map['expense_date'], '2026-10-15');
    });

    test('round-trips', () {
      final Expense back = expenseFromMap(
        'e1',
        expenseToMap(sample('e1', projectId: 'p1')),
      );
      expect(back.description, 'Figma');
      expect(back.category, ExpenseCategory.softwareTools);
      expect(back.projectId, 'p1');
      expect(back.method, PaymentMethod.ccp);
      expect(back.date, DateTime(2026, 10, 15));
      expect(back.notes, 'note');
    });

    test('a general expense has no project link', () {
      final Map<String, Object?> map = expenseToMap(sample('e2'));
      expect(map['project_id'], isA<FieldValue>());
      final Expense back = expenseFromMap('e2', <String, Object?>{
        'amount': 100,
        'category': 'Equipment',
        'expense_date': '2026-09-01',
      });
      expect(back.isProjectLinked, isFalse);
      expect(back.category, ExpenseCategory.equipment);
      expect(back.reference, '');
    });

    test('unknown category and method fall back', () {
      final Expense e = expenseFromMap('x', <String, Object?>{
        'amount': 5,
        'category': 'Coffee',
        'payment_method': 'crypto',
        'expense_date': '2026-09-01',
      });
      expect(e.category, ExpenseCategory.others);
      expect(e.method, PaymentMethod.cash);
    });
  });

  group('ExpensesRepository with a store', () {
    test('replaces demo data and loads', () async {
      final ExpensesRepository repo = ExpensesRepository();
      expect(repo.expenses, isNotEmpty);
      final FakeExpensesStore store = FakeExpensesStore(<Expense>[
        sample('s1'),
      ]);

      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();

      expect(repo.isLoading, isFalse);
      expect(repo.expenses.map((Expense e) => e.id), <String>['s1']);
      expect(repo.expenseStats().total, 4500);
    });

    test('writes through add, update and delete', () async {
      final ExpensesRepository repo = ExpensesRepository();
      final FakeExpensesStore store = FakeExpensesStore();
      repo.attachStore(store);
      await settle();

      repo.add(sample('s2'));
      repo.update(sample('s2').copyWith(amount: 5000));
      await settle();
      expect(store.log, <String>['save:s2', 'save:s2']);
      expect(repo.byId('s2')!.amount, 5000);

      repo.delete('s2');
      await settle();
      expect(store.log.last, 'delete:s2');
      expect(repo.expenses, isEmpty);
    });

    test('detach empties the list and stops writing', () async {
      final ExpensesRepository repo = ExpensesRepository();
      final FakeExpensesStore store = FakeExpensesStore(<Expense>[
        sample('s1'),
      ]);
      repo.attachStore(store);
      await settle();

      repo.detachStore();
      expect(repo.expenses, isEmpty);
      repo.add(sample('s3'));
      await settle();
      expect(store.log, isEmpty);
    });
  });
}
