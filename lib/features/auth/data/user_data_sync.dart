import 'dart:async';

import '../../calendar/data/data.dart';
import '../../clients/data/data.dart';
import '../../expenses/data/data.dart';
import '../../friends/data/data.dart';
import '../../projects/data/data.dart';
import 'auth_service.dart';

/// Connects the repositories to the signed-in user: on sign-in each one
/// attaches its Firestore store for that uid, on sign-out it detaches and
/// empties so nothing leaks to the next account.
class UserDataSync {
  UserDataSync({
    required this.auth,
    required this.clients,
    required this.projects,
    required this.expenses,
    required this.friends,
    required this.calendar,
    ClientsStore Function(String uid)? clientsStore,
    ProjectsStore Function(String uid)? projectsStore,
    ExpensesStore Function(String uid)? expensesStore,
    FriendsStore Function(String uid)? friendsStore,
    CalendarStore Function(String uid)? calendarStore,
  }) : _clientsStore = clientsStore ?? FirestoreClientsStore.new,
       _projectsStore = projectsStore ?? FirestoreProjectsStore.new,
       _expensesStore = expensesStore ?? FirestoreExpensesStore.new,
       _friendsStore = friendsStore ?? FirestoreFriendsStore.new,
       _calendarStore = calendarStore ?? FirestoreCalendarStore.new;

  final AuthService auth;
  final ClientsRepository clients;
  final ProjectsRepository projects;
  final ExpensesRepository expenses;
  final FriendsRepository friends;
  final CalendarRepository calendar;
  final ClientsStore Function(String uid) _clientsStore;
  final ProjectsStore Function(String uid) _projectsStore;
  final ExpensesStore Function(String uid) _expensesStore;
  final FriendsStore Function(String uid) _friendsStore;
  final CalendarStore Function(String uid) _calendarStore;

  StreamSubscription<AuthUser?>? _subscription;
  String? _uid;

  void start() {
    _apply(auth.currentUser);
    _subscription = auth.authStateChanges.listen(_apply);
  }

  void _apply(AuthUser? user) {
    if (user?.uid == _uid) return;
    _uid = user?.uid;
    if (user == null) {
      calendar.detachStore();
      friends.detachStore();
      expenses.detachStore();
      projects.detachStore();
      clients.detachStore();
    } else {
      clients.attachStore(_clientsStore(user.uid));
      projects.attachStore(_projectsStore(user.uid));
      expenses.attachStore(_expensesStore(user.uid));
      friends.attachStore(_friendsStore(user.uid));
      calendar.attachStore(_calendarStore(user.uid));
    }
  }

  void dispose() => _subscription?.cancel();
}
