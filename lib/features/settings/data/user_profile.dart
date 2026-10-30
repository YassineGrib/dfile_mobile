import 'package:flutter/foundation.dart';

/// User profile data model for settings per `docs/design/SPEC.md`.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    required this.designation,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String name;
  final String designation;
  final String email;
  final String phone;
  final String address;

  UserProfile copyWith({
    String? name,
    String? designation,
    String? email,
    String? phone,
    String? address,
  }) {
    return UserProfile(
      name: name ?? this.name,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.name == name &&
        other.designation == designation &&
        other.email == email &&
        other.phone == phone &&
        other.address == address;
  }

  @override
  int get hashCode => Object.hash(name, designation, email, phone, address);

  @override
  String toString() =>
      'UserProfile(name: $name, designation: $designation, email: $email, phone: $phone, address: $address)';
}
