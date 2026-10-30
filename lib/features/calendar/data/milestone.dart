import 'package:flutter/foundation.dart';

/// Milestone model per `docs/design/SPEC.md` (Calendar section).
@immutable
class Milestone {
  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.date,
    this.completed = false,
    required this.createdAt,
  });

  /// Unique identifier of the milestone (e.g. `m1`).
  final String id;

  /// Foreign key referencing the associated [ProjectItem.id].
  final String projectId;

  /// Human-readable title of the milestone.
  final String title;

  /// Due or target date of the milestone.
  final DateTime date;

  /// Whether this milestone has been marked as completed.
  final bool completed;

  /// Timestamp when the milestone was recorded.
  final DateTime createdAt;

  /// Creates a copy of this [Milestone] with replaced fields.
  Milestone copyWith({
    String? id,
    String? projectId,
    String? title,
    DateTime? date,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Milestone &&
        other.id == id &&
        other.projectId == projectId &&
        other.title == title &&
        other.date == date &&
        other.completed == completed &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, title, date, completed, createdAt);

  @override
  String toString() =>
      'Milestone(id: $id, projectId: $projectId, title: $title, date: $date, completed: $completed)';
}
