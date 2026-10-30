import 'package:flutter/foundation.dart';

/// Active device session data model per `docs/design/SPEC.md`.
@immutable
class DeviceSession {
  const DeviceSession({
    required this.id,
    required this.name,
    required this.detail,
    required this.isCurrent,
  });

  final String id;
  final String name;
  final String detail;
  final bool isCurrent;

  DeviceSession copyWith({
    String? id,
    String? name,
    String? detail,
    bool? isCurrent,
  }) {
    return DeviceSession(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceSession &&
        other.id == id &&
        other.name == name &&
        other.detail == detail &&
        other.isCurrent == isCurrent;
  }

  @override
  int get hashCode => Object.hash(id, name, detail, isCurrent);

  @override
  String toString() =>
      'DeviceSession(id: $id, name: $name, detail: $detail, isCurrent: $isCurrent)';
}
