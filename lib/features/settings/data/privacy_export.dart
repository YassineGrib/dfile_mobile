import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../clients/data/data.dart';
import '../../expenses/data/data.dart';
import '../../friends/data/data.dart';
import '../../projects/data/data.dart';
import 'settings_repository.dart';
import 'settings_scope.dart';

/// Builds a pretty-printed JSON export of all user and ledger records across
/// the application repositories and copies it to the clipboard.
abstract final class PrivacyDataExporter {
  /// Builds a formatted JSON string representing all data across the five repositories.
  static String buildExportJson({
    required ClientsRepository clientsRepo,
    required ProjectsRepository projectsRepo,
    required ExpensesRepository expensesRepo,
    required FriendsRepository friendsRepo,
    required SettingsRepository settingsRepo,
  }) {
    final Map<String, Object?> exportMap = <String, Object?>{
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': <String, Object?>{
        'name': settingsRepo.profile.name,
        'designation': settingsRepo.profile.designation,
        'email': settingsRepo.profile.email,
        'phone': settingsRepo.profile.phone,
        'address': settingsRepo.profile.address,
      },
      'categories': settingsRepo.categories,
      'clients': clientsRepo.clients.map((Client c) {
        return <String, Object?>{
          'id': c.id,
          'name': c.name,
          'email': c.email,
          'phone': c.phone,
          'address': c.address,
          'notes': c.notes,
          'linkedin': c.linkedin,
          'twitter': c.twitter,
          'github': c.github,
          'website': c.website,
          'createdAt': c.createdAt.toIso8601String(),
          'avatarColorIndex': c.avatarColorIndex,
          'budget': c.budget,
        };
      }).toList(),
      'projects': projectsRepo.projects.map((ProjectItem p) {
        return <String, Object?>{
          'id': p.id,
          'name': p.name,
          'clientId': p.clientId,
          'category': p.category,
          'description': p.description,
          'status': p.status.label,
          'progress': p.progress,
          'price': p.price,
          'startDate': p.startDate.toIso8601String(),
          'endDate': p.endDate?.toIso8601String(),
          'createdAt': p.createdAt.toIso8601String(),
        };
      }).toList(),
      'tasks': projectsRepo.tasks.map((ProjectTask t) {
        return <String, Object?>{
          'id': t.id,
          'projectId': t.projectId,
          'name': t.name,
          'due': t.due?.toIso8601String(),
          'status': t.status.label,
        };
      }).toList(),
      'payments': projectsRepo.payments.map((ProjectPayment pay) {
        return <String, Object?>{
          'id': pay.id,
          'projectId': pay.projectId,
          'clientId': pay.clientId,
          'date': pay.date.toIso8601String(),
          'reference': pay.reference,
          'amount': pay.amount,
          'type': pay.type.name,
          'method': pay.method.name,
          'notes': pay.notes,
        };
      }).toList(),
      'expenses': expensesRepo.expenses.map((Expense e) {
        return <String, Object?>{
          'id': e.id,
          'description': e.description,
          'category': e.category.label,
          'projectId': e.projectId,
          'amount': e.amount,
          'method': e.method.name,
          'reference': e.reference,
          'notes': e.notes,
          'date': e.date.toIso8601String(),
        };
      }).toList(),
      'friends': friendsRepo.rawFriends.map((Friend f) {
        return <String, Object?>{
          'id': f.id,
          'name': f.name,
          'phone': f.phone,
          'notes': f.notes,
          'createdAt': f.createdAt.toIso8601String(),
          'avatarColorIndex': f.avatarColorIndex,
        };
      }).toList(),
      'friendTransactions': friendsRepo.transactions.map((FriendTransaction t) {
        return <String, Object?>{
          'id': t.id,
          'friendId': t.friendId,
          'type': t.type.name,
          'direction': t.direction.name,
          'amount': t.amount,
          'paidAmount': t.paidAmount,
          'description': t.description,
          'dueDate': t.dueDate?.toIso8601String(),
          'date': t.date.toIso8601String(),
        };
      }).toList(),
      'friendSettlements': friendsRepo.settlements.map((FriendSettlement s) {
        return <String, Object?>{
          'id': s.id,
          'transactionId': s.transactionId,
          'friendId': s.friendId,
          'amount': s.amount,
          'method': s.method.name,
          'notes': s.notes,
          'date': s.date.toIso8601String(),
        };
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Copies the generated JSON export to the system clipboard from [context].
  static Future<String> copyToClipboard(BuildContext context) async {
    final ClientsRepository clientsRepo = ClientsScope.of(
      context,
      listen: false,
    );
    final ProjectsRepository projectsRepo = ProjectsScope.of(
      context,
      listen: false,
    );
    final ExpensesRepository expensesRepo = ExpensesScope.of(
      context,
      listen: false,
    );
    final FriendsRepository friendsRepo = FriendsScope.of(
      context,
      listen: false,
    );
    final SettingsRepository settingsRepo = SettingsScope.of(
      context,
      listen: false,
    );

    final String jsonString = buildExportJson(
      clientsRepo: clientsRepo,
      projectsRepo: projectsRepo,
      expensesRepo: expensesRepo,
      friendsRepo: friendsRepo,
      settingsRepo: settingsRepo,
    );

    await Clipboard.setData(ClipboardData(text: jsonString));
    return jsonString;
  }
}
