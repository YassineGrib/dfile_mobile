import 'package:flutter/foundation.dart';

import '../../projects/data/project.dart';

/// Categories for business expenses per `docs/design/SPEC.md`.
enum ExpenseCategory {
  softwareTools(
    storageName: 'Software/Tools',
    fullLabel: 'Software/Tools',
    shortLabel: 'Software',
  ),
  hostingServices(
    storageName: 'Hosting/Services',
    fullLabel: 'Hosting/Services',
    shortLabel: 'Hosting',
  ),
  marketing(
    storageName: 'Marketing',
    fullLabel: 'Marketing',
    shortLabel: 'Marketing',
  ),
  equipment(
    storageName: 'Equipment',
    fullLabel: 'Equipment',
    shortLabel: 'Equipment',
  ),
  others(storageName: 'Others', fullLabel: 'Others', shortLabel: 'Others');

  const ExpenseCategory({
    required this.storageName,
    required this.fullLabel,
    required this.shortLabel,
  });

  /// Canonical storage identifier string matching `docs/design/SPEC.md`.
  final String storageName;

  /// User-facing full display label (e.g. "Software/Tools").
  final String fullLabel;

  /// User-facing compact chip/pill label (e.g. "Software").
  final String shortLabel;

  /// Default user-facing display label.
  String get label => fullLabel;

  /// Resolves an [ExpenseCategory] from its [storageName], [fullLabel], or [shortLabel],
  /// returning `null` if no match is found.
  static ExpenseCategory? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final String trimmed = value.trim();
    for (final ExpenseCategory category in ExpenseCategory.values) {
      if (category.storageName == trimmed ||
          category.fullLabel == trimmed ||
          category.shortLabel == trimmed ||
          category.name == trimmed) {
        return category;
      }
    }
    return null;
  }

  /// Resolves an [ExpenseCategory] from its [storageName], falling back to [others].
  static ExpenseCategory fromStorageName(String value) {
    return tryParse(value) ?? ExpenseCategory.others;
  }
}

/// Link filter options for the expenses list per `docs/design/SPEC.md`.
enum ExpenseLinkFilter {
  all('All'),
  linked('Project linked'),
  general('General costs');

  const ExpenseLinkFilter(this.label);

  /// User-facing display label.
  final String label;
}

/// Sort options for the expenses list per `docs/design/SPEC.md`.
enum ExpenseSort {
  newest('Newest first'),
  oldest('Oldest first'),
  highestAmount('Highest amount'),
  lowestAmount('Lowest amount');

  const ExpenseSort(this.label);

  /// User-facing display label.
  final String label;
}

/// Derived portfolio expense statistics per `docs/design/SPEC.md`.
@immutable
class ExpenseStats {
  const ExpenseStats({
    required this.total,
    required this.projectLinked,
    required this.projectLinkedCount,
    required this.thisMonth,
    required this.average,
  });

  /// Total outlay across all recorded expenses.
  final double total;

  /// Outlay of all expenses linked to a project.
  final double projectLinked;

  /// Number of expenses linked to a project.
  final int projectLinkedCount;

  /// Total outlay for expenses occurring in the current calendar month.
  final double thisMonth;

  /// Average outlay per expense (rounded to nearest integer), or 0 when empty.
  final double average;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseStats &&
        other.total == total &&
        other.projectLinked == projectLinked &&
        other.projectLinkedCount == projectLinkedCount &&
        other.thisMonth == thisMonth &&
        other.average == average;
  }

  @override
  int get hashCode =>
      Object.hash(total, projectLinked, projectLinkedCount, thisMonth, average);

  @override
  String toString() =>
      'ExpenseStats(total: $total, projectLinked: $projectLinked ($projectLinkedCount), thisMonth: $thisMonth, average: $average)';
}

/// An individual business or project expense per `docs/design/SPEC.md`.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    this.projectId,
    this.method = PaymentMethod.baridimob,
    this.reference = '',
    this.notes = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? date;

  /// Unique identifier (e.g. `exp1`).
  final String id;

  /// Expense item description (e.g. `Figma Pro plan`).
  final String description;

  /// Expense category.
  final ExpenseCategory category;

  /// Expense amount in DZD.
  final double amount;

  /// Optional foreign key to a [ProjectItem]. `null` denotes a general cost.
  final String? projectId;

  /// Payment method used to pay the expense (reuses [PaymentMethod]).
  final PaymentMethod method;

  /// Optional transaction or receipt reference (e.g. `INV-802`).
  final String reference;

  /// Optional free-form notes.
  final String notes;

  /// Effective date of the expense.
  final DateTime date;

  /// System creation timestamp.
  final DateTime createdAt;

  /// True when this expense is linked to a project rather than a general business cost.
  bool get isProjectLinked => projectId != null && projectId!.isNotEmpty;

  /// Creates a copy of this expense with the given fields replaced.
  Expense copyWith({
    String? id,
    String? description,
    ExpenseCategory? category,
    double? amount,
    String? projectId,
    bool clearProjectId = false,
    PaymentMethod? method,
    String? reference,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      method: method ?? this.method,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.description == description &&
        other.category == category &&
        other.amount == amount &&
        other.projectId == projectId &&
        other.method == method &&
        other.reference == reference &&
        other.notes == notes &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    category,
    amount,
    projectId,
    method,
    reference,
    notes,
    date,
    createdAt,
  );

  @override
  String toString() =>
      'Expense(id: $id, description: $description, category: ${category.fullLabel}, amount: $amount, projectId: $projectId, method: ${method.label}, date: $date)';
}
