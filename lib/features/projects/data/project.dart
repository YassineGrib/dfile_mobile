/// Domain models for projects, tasks, and project payments.
library;

/// Lifecycle statuses for a project per `docs/design/SPEC.md`.
enum ProjectStatus {
  planned('Planned'),
  inProgress('In Progress'),
  waitingClient('Waiting Client'),
  completed('Completed'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const ProjectStatus(this.label);

  /// User-facing status label.
  final String label;

  /// True when the project counts as active (`In Progress` or `Waiting Client`).
  bool get isActive =>
      this == ProjectStatus.inProgress || this == ProjectStatus.waitingClient;

  /// True when setting this status forces progress to 100%.
  bool get forcesFullProgress =>
      this == ProjectStatus.completed || this == ProjectStatus.delivered;
}

/// Checklist statuses for a [ProjectTask].
enum TaskStatus {
  nextUp('Next up'),
  inProgress('In Progress'),
  complete('Complete');

  const TaskStatus(this.label);

  /// User-facing task status label.
  final String label;

  bool get isComplete => this == TaskStatus.complete;
}

/// Payment methods supported by Dfile per `docs/design/SPEC.md`.
enum PaymentMethod {
  baridimob('BaridiMob'),
  ccp('CCP'),
  bank('Bank wire'),
  cash('Cash');

  const PaymentMethod(this.label);

  /// User-facing display label.
  final String label;
}

/// Payment transaction types per `docs/design/SPEC.md`.
enum PaymentType {
  advance('Advance'),
  milestone('Milestone'),
  final_('Final'),
  tip('Tip');

  const PaymentType(this.label);

  /// User-facing display label.
  final String label;

  /// Alias for [final_] to avoid Dart reserved keyword collision.
  static const PaymentType finalPayment = final_;
}

/// Derived portfolio payment statistics per `docs/design/SPEC.md`.
class PaymentStats {
  const PaymentStats({
    required this.collected,
    required this.outstanding,
    required this.thisMonth,
    required this.collectionRate,
  });

  /// Total collected revenue across all recorded payments (sum of amounts).
  final double collected;

  /// Remaining balance due across non-cancelled projects.
  final double outstanding;

  /// Total amount collected in the target calendar month.
  final double thisMonth;

  /// Collection rate percentage (0..100).
  final int collectionRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStats &&
          runtimeType == other.runtimeType &&
          collected == other.collected &&
          outstanding == other.outstanding &&
          thisMonth == other.thisMonth &&
          collectionRate == other.collectionRate;

  @override
  int get hashCode => Object.hash(
        collected,
        outstanding,
        thisMonth,
        collectionRate,
      );

  @override
  String toString() =>
      'PaymentStats(collected: $collected, outstanding: $outstanding, thisMonth: $thisMonth, collectionRate: $collectionRate)';
}

/// A portfolio project entity.
class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.clientId,
    required this.price,
    required this.status,
    required this.progress,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  }) : assert(progress >= 0 && progress <= 100, 'progress must be 0..100');

  final String id;
  final String name;
  final String description;
  final String category;
  final String clientId;
  final double price;
  final ProjectStatus status;
  final int progress;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  ProjectItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? clientId,
    double? price,
    ProjectStatus? status,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? createdAt,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      clientId: clientId ?? this.clientId,
      price: price ?? this.price,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// A checklist item belonging to a [ProjectItem].
class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.name,
    this.due,
    this.status = TaskStatus.nextUp,
  });

  final String id;
  final String projectId;
  final String name;
  final DateTime? due;
  final TaskStatus status;

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? name,
    DateTime? due,
    bool clearDue = false,
    TaskStatus? status,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      due: clearDue ? null : (due ?? this.due),
      status: status ?? this.status,
    );
  }
}

/// A payment recorded against a [ProjectItem].
class ProjectPayment {
  const ProjectPayment({
    required this.id,
    required this.projectId,
    String? clientId,
    required this.date,
    this.reference = '',
    required this.amount,
    this.type = PaymentType.milestone,
    this.method = PaymentMethod.baridimob,
    this.notes = '',
    DateTime? createdAt,
  })  : clientId = clientId ?? '',
        createdAt = createdAt ?? date;

  final String id;
  final String projectId;
  final String clientId;
  final DateTime date;
  final String reference;
  final double amount;
  final PaymentType type;
  final PaymentMethod method;
  final String notes;
  final DateTime createdAt;

  ProjectPayment copyWith({
    String? id,
    String? projectId,
    String? clientId,
    DateTime? date,
    String? reference,
    double? amount,
    PaymentType? type,
    PaymentMethod? method,
    String? notes,
    DateTime? createdAt,
  }) {
    return ProjectPayment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPayment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          projectId == other.projectId &&
          clientId == other.clientId &&
          date == other.date &&
          reference == other.reference &&
          amount == other.amount &&
          type == other.type &&
          method == other.method &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        id,
        projectId,
        clientId,
        date,
        reference,
        amount,
        type,
        method,
        notes,
      );

  @override
  String toString() =>
      'ProjectPayment(id: $id, projectId: $projectId, clientId: $clientId, date: $date, reference: $reference, amount: $amount, type: $type, method: $method, notes: $notes)';
}
