/// Domain models for clients, projects, and payments.
library;

/// A client project record.
class Project {
  const Project({
    this.id,
    required this.name,
    required this.status,
    required this.price,
    required this.progress,
  });

  final String? id;
  final String name;
  final String status;
  final double price;
  final int progress;

  bool get isActive => status == 'In Progress' || status == 'Waiting Client';

  Project copyWith({
    String? id,
    String? name,
    String? status,
    double? price,
    int? progress,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      price: price ?? this.price,
      progress: progress ?? this.progress,
    );
  }
}

/// A client payment record.
class Payment {
  const Payment({
    this.id,
    this.projectId,
    required this.date,
    required this.reference,
    required this.amount,
  });

  final String? id;
  final String? projectId;
  final String date;
  final String reference;
  final double amount;

  Payment copyWith({
    String? id,
    String? projectId,
    String? date,
    String? reference,
    double? amount,
  }) {
    return Payment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
    );
  }
}

/// A client entity.
class Client {
  const Client({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.linkedin = '',
    this.twitter = '',
    this.github = '',
    this.website = '',
    required this.createdAt,
    this.avatarColorIndex = 0,
    this.projects = const <Project>[],
    this.payments = const <Payment>[],
    this.budget,
    this.mockExpenses,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final String linkedin;
  final String twitter;
  final String github;
  final String website;
  final DateTime createdAt;
  final int avatarColorIndex;
  final List<Project> projects;
  final List<Payment> payments;
  final double? budget;
  final double? mockExpenses;

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    String? linkedin,
    String? twitter,
    String? github,
    String? website,
    DateTime? createdAt,
    int? avatarColorIndex,
    List<Project>? projects,
    List<Payment>? payments,
    double? budget,
    double? mockExpenses,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
      github: github ?? this.github,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      projects: projects ?? this.projects,
      payments: payments ?? this.payments,
      budget: budget ?? this.budget,
      mockExpenses: mockExpenses ?? this.mockExpenses,
    );
  }
}
