import 'package:flutter/widgets.dart';

import '../../calendar/data/data.dart';
import '../../clients/data/data.dart';
import '../../expenses/data/data.dart';
import '../../friends/data/data.dart';
import '../../projects/data/data.dart';
import 'settings_repository.dart';
import 'settings_scope.dart';

/// Synchronously clears all user data across all repositories from [context].
void wipeAllUserData(BuildContext context) {
  final ClientsRepository clientsRepo = ClientsScope.of(context, listen: false);
  final ProjectsRepository projectsRepo = ProjectsScope.of(
    context,
    listen: false,
  );
  final ExpensesRepository expensesRepo = ExpensesScope.of(
    context,
    listen: false,
  );
  final FriendsRepository friendsRepo = FriendsScope.of(context, listen: false);
  final SettingsRepository settingsRepo = SettingsScope.of(
    context,
    listen: false,
  );
  CalendarRepository? calendarRepo;
  try {
    calendarRepo = CalendarScope.of(context, listen: false);
  } catch (_) {}

  deleteAllUserDataFromRepositories(
    clientsRepo: clientsRepo,
    projectsRepo: projectsRepo,
    expensesRepo: expensesRepo,
    friendsRepo: friendsRepo,
    settingsRepo: settingsRepo,
    calendarRepo: calendarRepo,
  );
}

/// Clears all user data across all repositories, resetting the app to an unauthenticated
/// initial state per `docs/design/SPEC.md`.
Future<void> deleteAllUserData(BuildContext context) async {
  wipeAllUserData(context);
}

/// Pure helper executing the full wipe across all repositories.
void deleteAllUserDataFromRepositories({
  required ClientsRepository clientsRepo,
  required ProjectsRepository projectsRepo,
  required ExpensesRepository expensesRepo,
  required FriendsRepository friendsRepo,
  required SettingsRepository settingsRepo,
  CalendarRepository? calendarRepo,
}) {
  clientsRepo.clearAll();
  projectsRepo.clearAll();
  expensesRepo.clearAll();
  friendsRepo.clearAll();
  settingsRepo.clearAll();
  calendarRepo?.clearAll();
}
