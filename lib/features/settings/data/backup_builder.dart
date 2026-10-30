import 'dart:convert';

import '../../clients/data/data.dart';
import '../../expenses/data/data.dart';
import '../../friends/data/data.dart';
import '../../projects/data/data.dart';
import 'settings_repository.dart';

/// Pure function to build a pretty-printed JSON backup of the workspace per `docs/design/SPEC.md` (ST10).
String buildWorkspaceBackupJson({
  required ClientsRepository clientsRepository,
  required ProjectsRepository projectsRepository,
  required ExpensesRepository expensesRepository,
  required FriendsRepository friendsRepository,
  required SettingsRepository settingsRepository,
}) {
  final Map<String, dynamic> data = <String, dynamic>{
    'clients': clientsRepository.clients
        .map(
          (Client c) => <String, dynamic>{
            'id': c.id,
            'name': c.name,
            'email': c.email,
            'phone': c.phone,
            'address': c.address,
            'notes': c.notes,
            'createdAt': c.createdAt.toIso8601String(),
            'budget': c.budget,
            'projects': c.projects
                .map(
                  (Project p) => <String, dynamic>{
                    'id': p.id,
                    'name': p.name,
                    'status': p.status,
                    'price': p.price,
                    'progress': p.progress,
                  },
                )
                .toList(),
            'payments': c.payments
                .map(
                  (Payment pay) => <String, dynamic>{
                    'id': pay.id,
                    'projectId': pay.projectId,
                    'date': pay.date,
                    'reference': pay.reference,
                    'amount': pay.amount,
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'projects': projectsRepository.projects
        .map(
          (ProjectItem p) => <String, dynamic>{
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'category': p.category,
            'clientId': p.clientId,
            'price': p.price,
            'status': p.status.label,
            'progress': p.progress,
            'tasks': projectsRepository
                .tasksOf(p.id)
                .map(
                  (ProjectTask t) => <String, dynamic>{
                    'id': t.id,
                    'name': t.name,
                    'status': t.status.label,
                    'due': t.due?.toIso8601String(),
                  },
                )
                .toList(),
          },
        )
        .toList(),
    'payments': projectsRepository.payments
        .map(
          (ProjectPayment p) => <String, dynamic>{
            'id': p.id,
            'projectId': p.projectId,
            'clientId': p.clientId,
            'date': p.date.toIso8601String(),
            'reference': p.reference,
            'amount': p.amount,
            'type': p.type.label,
            'method': p.method.label,
            'notes': p.notes,
          },
        )
        .toList(),
    'expenses': expensesRepository.expenses
        .map(
          (Expense e) => <String, dynamic>{
            'id': e.id,
            'description': e.description,
            'category': e.category.storageName,
            'amount': e.amount,
            'projectId': e.projectId,
            'method': e.method.label,
            'reference': e.reference,
            'notes': e.notes,
            'date': e.date.toIso8601String(),
          },
        )
        .toList(),
    'friends': friendsRepository.friends
        .map(
          (Friend f) => <String, dynamic>{
            'id': f.id,
            'name': f.name,
            'phone': f.phone,
            'notes': f.notes,
            'createdAt': f.createdAt.toIso8601String(),
            'balance': f.balance?.net,
          },
        )
        .toList(),
    'settings': <String, dynamic>{
      'profile': <String, dynamic>{
        'name': settingsRepository.profile.name,
        'designation': settingsRepository.profile.designation,
        'email': settingsRepository.profile.email,
        'phone': settingsRepository.profile.phone,
        'address': settingsRepository.profile.address,
      },
      'categories': settingsRepository.categories,
      'language': settingsRepository.language.code,
    },
  };

  return const JsonEncoder.withIndent('  ').convert(data);
}
