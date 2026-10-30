import 'package:flutter/foundation.dart';

/// Notification preferences model per `docs/design/SPEC.md`.
@immutable
class NotificationPrefs {
  const NotificationPrefs({
    required this.push,
    required this.deadlines,
    required this.payments,
    required this.tasks,
  });

  final bool push;
  final bool deadlines;
  final bool payments;
  final bool tasks;

  NotificationPrefs copyWith({
    bool? push,
    bool? deadlines,
    bool? payments,
    bool? tasks,
  }) {
    return NotificationPrefs(
      push: push ?? this.push,
      deadlines: deadlines ?? this.deadlines,
      payments: payments ?? this.payments,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPrefs &&
        other.push == push &&
        other.deadlines == deadlines &&
        other.payments == payments &&
        other.tasks == tasks;
  }

  @override
  int get hashCode => Object.hash(push, deadlines, payments, tasks);

  @override
  String toString() =>
      'NotificationPrefs(push: $push, deadlines: $deadlines, payments: $payments, tasks: $tasks)';
}
