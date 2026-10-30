import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../projects/data/project.dart';
import 'expense.dart';
import 'expenses_store.dart';

/// In-memory repository managing business expenses and statistics per `docs/design/SPEC.md`.
class ExpensesRepository extends ChangeNotifier {
  ExpensesRepository({List<Expense>? initialExpenses})
    : _expenses = List<Expense>.of(initialExpenses ?? _createInitialExpenses());

  final List<Expense> _expenses;
  ExpensesStore? _store;
  StreamSubscription<List<Expense>>? _subscription;
  bool _loading = false;
  Object? _syncError;

  /// True until the first snapshot of an attached store arrives.
  bool get isLoading => _loading;

  /// Last store error (read or write), if any.
  Object? get syncError => _syncError;

  bool get isAttached => _store != null;

  /// Switches to [store] as the source of truth: demo data is dropped and the
  /// list follows the snapshots.
  void attachStore(ExpensesStore store) {
    _subscription?.cancel();
    _store = store;
    _expenses.clear();
    _loading = true;
    _syncError = null;
    notifyListeners();
    _subscription = store.watch().listen(
      (List<Expense> remote) {
        _expenses
          ..clear()
          ..addAll(remote);
        _loading = false;
        _syncError = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _syncError = error;
        notifyListeners();
      },
    );
  }

  /// Stops following the store and empties the list (sign-out).
  void detachStore() {
    _subscription?.cancel();
    _subscription = null;
    _store = null;
    _loading = false;
    _syncError = null;
    _expenses.clear();
    notifyListeners();
  }

  /// Deletes this user's expenses from the store (before the account goes).
  Future<void> deleteRemoteData() async => _store?.deleteAll();

  void _write(Future<void> Function(ExpensesStore store) op) {
    final ExpensesStore? store = _store;
    if (store == null) return;
    op(store).catchError((Object error) {
      _syncError = error;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Unmodifiable view of all recorded expenses.
  List<Expense> get expenses => List<Expense>.unmodifiable(_expenses);

  /// Finds an expense by [id], returning `null` if not found.
  Expense? byId(String id) {
    for (final Expense expense in _expenses) {
      if (expense.id == id) {
        return expense;
      }
    }
    return null;
  }

  /// Returns all expenses linked to [projectId].
  List<Expense> expensesOfProject(String projectId) {
    return List<Expense>.unmodifiable(
      _expenses.where((Expense e) => e.projectId == projectId),
    );
  }

  /// Appends [expense] and notifies listeners.
  void add(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
    _write((ExpensesStore s) => s.save(expense));
  }

  /// Updates an existing expense matching [expense.id] and notifies listeners.
  ///
  /// Returns `true` if an expense was updated, or `false` if not found.
  bool update(Expense expense) {
    final int index = _expenses.indexWhere((Expense e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
      _write((ExpensesStore s) => s.save(expense));
      return true;
    }
    return false;
  }

  /// Deletes the expense with [id] and notifies listeners.
  ///
  /// Returns `true` if an expense was removed, or `false` if not found.
  bool delete(String id) {
    final int index = _expenses.indexWhere((Expense e) => e.id == id);
    if (index != -1) {
      _expenses.removeAt(index);
      notifyListeners();
      _write((ExpensesStore s) => s.delete(id));
      return true;
    }
    return false;
  }

  /// Computes summary KPIs per `docs/design/SPEC.md`:
  /// - `total`: sum of all expense amounts
  /// - `projectLinked`: sum of project-linked expense amounts
  /// - `projectLinkedCount`: count of project-linked expenses
  /// - `thisMonth`: sum of expense amounts occurring in [now]'s calendar month
  /// - `average`: round(total / count), 0 when empty
  ExpenseStats expenseStats({DateTime? now}) {
    final DateTime referenceDate = now ?? DateTime.now();
    double total = 0.0;
    double projectLinked = 0.0;
    int projectLinkedCount = 0;
    double thisMonth = 0.0;

    for (final Expense expense in _expenses) {
      total += expense.amount;
      if (expense.isProjectLinked) {
        projectLinked += expense.amount;
        projectLinkedCount++;
      }
      if (expense.date.year == referenceDate.year &&
          expense.date.month == referenceDate.month) {
        thisMonth += expense.amount;
      }
    }

    final double average = _expenses.isEmpty
        ? 0.0
        : (total / _expenses.length).roundToDouble();

    return ExpenseStats(
      total: total,
      projectLinked: projectLinked,
      projectLinkedCount: projectLinkedCount,
      thisMonth: thisMonth,
      average: average,
    );
  }

  static List<Expense> _createInitialExpenses() {
    return <Expense>[
      Expense(
        id: 'exp1',
        description: 'Figma Pro plan',
        category: ExpenseCategory.softwareTools,
        projectId: null,
        amount: 4500.0,
        method: PaymentMethod.ccp,
        reference: 'INV-802',
        notes: '',
        date: DateTime(2026, 10, 15),
      ),
      Expense(
        id: 'exp2',
        description: 'Domain renewal',
        category: ExpenseCategory.hostingServices,
        projectId: null,
        amount: 3200.0,
        method: PaymentMethod.baridimob,
        reference: 'RCPT-441',
        notes: '',
        date: DateTime(2026, 10, 3),
      ),
      Expense(
        id: 'exp3',
        description: 'Instagram ads',
        category: ExpenseCategory.marketing,
        projectId: 'p2',
        amount: 12000.0,
        method: PaymentMethod.baridimob,
        reference: 'AD-2291',
        notes: 'Campaign for the brand launch week.',
        date: DateTime(2026, 9, 20),
      ),
      Expense(
        id: 'exp4',
        description: 'Stock photos pack',
        category: ExpenseCategory.marketing,
        projectId: 'p1',
        amount: 6500.0,
        method: PaymentMethod.cash,
        reference: '',
        notes: '',
        date: DateTime(2026, 8, 11),
      ),
      Expense(
        id: 'exp5',
        description: 'Monitor 27 inch',
        category: ExpenseCategory.equipment,
        projectId: null,
        amount: 38000.0,
        method: PaymentMethod.bank,
        reference: 'INV-611',
        notes: '',
        date: DateTime(2026, 7, 2),
      ),
      Expense(
        id: 'exp6',
        description: 'VPS hosting (yearly)',
        category: ExpenseCategory.hostingServices,
        projectId: 'p1',
        amount: 18000.0,
        method: PaymentMethod.ccp,
        reference: 'VPS-330',
        notes: '',
        date: DateTime(2026, 6, 14),
      ),
      Expense(
        id: 'exp7',
        description: 'Coworking pass',
        category: ExpenseCategory.others,
        projectId: null,
        amount: 9000.0,
        method: PaymentMethod.cash,
        reference: '',
        notes: '',
        date: DateTime(2026, 5, 5),
      ),
    ];
  }

  /// Clears all recorded expenses and notifies listeners.
  void clearAll() {
    _expenses.clear();
    notifyListeners();
  }
}

/// Pure filtering function for expenses per `docs/design/SPEC.md`.
///
/// Matches [query] across description, category label, project name (resolved via [projectName]),
/// reference, and notes.
List<Expense> filterExpenses(
  List<Expense> expenses, {
  String query = '',
  ExpenseCategory? category,
  ExpenseLinkFilter link = ExpenseLinkFilter.all,
  String Function(String projectId)? projectName,
}) {
  final String normalizedQuery = query.trim().toLowerCase();

  return expenses.where((Expense expense) {
    if (category != null && expense.category != category) {
      return false;
    }

    switch (link) {
      case ExpenseLinkFilter.all:
        break;
      case ExpenseLinkFilter.linked:
        if (!expense.isProjectLinked) {
          return false;
        }
        break;
      case ExpenseLinkFilter.general:
        if (expense.isProjectLinked) {
          return false;
        }
        break;
    }

    if (normalizedQuery.isNotEmpty) {
      final bool matchesDescription = expense.description
          .toLowerCase()
          .contains(normalizedQuery);
      final bool matchesCategory =
          expense.category.fullLabel.toLowerCase().contains(normalizedQuery) ||
          expense.category.shortLabel.toLowerCase().contains(normalizedQuery) ||
          expense.category.storageName.toLowerCase().contains(normalizedQuery);
      final bool matchesProject =
          (expense.isProjectLinked && projectName != null)
          ? projectName(expense.projectId!)
                .toLowerCase()
                .contains(normalizedQuery)
          : false;
      final bool matchesReference = expense.reference.toLowerCase().contains(
        normalizedQuery,
      );
      final bool matchesNotes = expense.notes.toLowerCase().contains(
        normalizedQuery,
      );

      if (!matchesDescription &&
          !matchesCategory &&
          !matchesProject &&
          !matchesReference &&
          !matchesNotes) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// Pure sorting function for expenses per `docs/design/SPEC.md`.
List<Expense> sortExpenses(List<Expense> expenses, ExpenseSort sort) {
  final List<Expense> result = List<Expense>.of(expenses);
  switch (sort) {
    case ExpenseSort.newest:
      result.sort((Expense a, Expense b) {
        final int dateCmp = b.date.compareTo(a.date);
        if (dateCmp != 0) return dateCmp;
        return b.createdAt.compareTo(a.createdAt);
      });
      break;
    case ExpenseSort.oldest:
      result.sort((Expense a, Expense b) {
        final int dateCmp = a.date.compareTo(b.date);
        if (dateCmp != 0) return dateCmp;
        return a.createdAt.compareTo(b.createdAt);
      });
      break;
    case ExpenseSort.highestAmount:
      result.sort((Expense a, Expense b) => b.amount.compareTo(a.amount));
      break;
    case ExpenseSort.lowestAmount:
      result.sort((Expense a, Expense b) => a.amount.compareTo(b.amount));
      break;
  }
  return result;
}
