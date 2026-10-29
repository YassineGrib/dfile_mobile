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
    required this.date,
    required this.reference,
    required this.amount,
  });

  final String id;
  final String projectId;
  final DateTime date;
  final String reference;
  final double amount;

  ProjectPayment copyWith({
    String? id,
    String? projectId,
    DateTime? date,
    String? reference,
    double? amount,
  }) {
    return ProjectPayment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
    );
  }
}
