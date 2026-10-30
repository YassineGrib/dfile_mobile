import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../projects/data/projects_store.dart'
    show paymentMethodFromWeb, paymentMethodToWeb;
import 'expense.dart';

/// Persistence behind [ExpensesRepository]: a live list plus write operations.
abstract class ExpensesStore {
  Stream<List<Expense>> watch();

  Future<void> save(Expense expense);

  Future<void> delete(String id);

  /// Removes every expense (account deletion).
  Future<void> deleteAll();
}

String _dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parseDate(Object? v) => v is String ? DateTime.tryParse(v) : null;

String _text(Object? v) => v is String ? v : '';

Object _textOrDelete(String v) => v.isEmpty ? FieldValue.delete() : v;

/// Maps an expense to the web document shape (`users/{uid}/expenses/{id}`).
Map<String, Object?> expenseToMap(Expense e) => <String, Object?>{
  'id': e.id,
  'amount': e.amount,
  'category': e.category.storageName,
  'description': e.description,
  'project_id': e.isProjectLinked ? e.projectId : FieldValue.delete(),
  'payment_method': paymentMethodToWeb(e.method),
  'reference_number': _textOrDelete(e.reference),
  'notes': _textOrDelete(e.notes),
  'expense_date': _dateOnly(e.date),
  'created_at': e.createdAt.toIso8601String(),
};

/// Reads an expense written by the web app or by [expenseToMap].
Expense expenseFromMap(String docId, Map<String, Object?> data) {
  final DateTime date =
      _parseDate(data['expense_date']) ??
      _parseDate(data['created_at']) ??
      DateTime.now();
  final Object? amount = data['amount'];
  final String id = _text(data['id']).isEmpty ? docId : _text(data['id']);
  final String project = _text(data['project_id']);
  return Expense(
    id: id,
    description: _text(data['description']),
    category: ExpenseCategory.fromStorageName(_text(data['category'])),
    amount: amount is num ? amount.toDouble() : 0,
    projectId: project.isEmpty ? null : project,
    method: paymentMethodFromWeb(data['payment_method']),
    reference: _text(data['reference_number']),
    notes: _text(data['notes']),
    date: date,
    createdAt: _parseDate(data['created_at']) ?? date,
  );
}

/// Firestore-backed store for one signed-in user. Writes merge, so fields only
/// the web app knows are never wiped.
class FirestoreExpensesStore implements ExpensesStore {
  FirestoreExpensesStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('expenses');

  @override
  Stream<List<Expense>> watch() => _col.snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              expenseFromMap(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  @override
  Future<void> save(Expense expense) =>
      _col.doc(expense.id).set(expenseToMap(expense), SetOptions(merge: true));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<void> deleteAll() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _col.get();
    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

/// In-memory store for tests.
class FakeExpensesStore implements ExpensesStore {
  FakeExpensesStore([List<Expense> initial = const <Expense>[]])
    : _items = List<Expense>.of(initial);

  final List<Expense> _items;
  final StreamController<List<Expense>> _controller =
      StreamController<List<Expense>>.broadcast();
  final List<String> log = <String>[];

  @override
  Stream<List<Expense>> watch() async* {
    yield List<Expense>.of(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> save(Expense expense) async {
    log.add('save:${expense.id}');
    final int i = _items.indexWhere((Expense e) => e.id == expense.id);
    if (i == -1) {
      _items.add(expense);
    } else {
      _items[i] = expense;
    }
    _controller.add(List<Expense>.of(_items));
  }

  @override
  Future<void> delete(String id) async {
    log.add('delete:$id');
    _items.removeWhere((Expense e) => e.id == id);
    _controller.add(List<Expense>.of(_items));
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _items.clear();
    _controller.add(const <Expense>[]);
  }
}
