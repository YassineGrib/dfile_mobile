import 'package:flutter/foundation.dart';

/// Support ticket model per `docs/design/SPEC.md`.
@immutable
class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String subject;
  final String message;
  final DateTime createdAt;

  SupportTicket copyWith({
    String? id,
    String? subject,
    String? message,
    DateTime? createdAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupportTicket &&
        other.id == id &&
        other.subject == subject &&
        other.message == message &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, subject, message, createdAt);

  @override
  String toString() =>
      'SupportTicket(id: $id, subject: $subject, message: $message, createdAt: $createdAt)';
}
