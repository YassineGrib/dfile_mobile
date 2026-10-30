import 'dart:async';

import '../../clients/data/data.dart';
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
    ClientsStore Function(String uid)? clientsStore,
    ProjectsStore Function(String uid)? projectsStore,
  }) : _clientsStore = clientsStore ?? FirestoreClientsStore.new,
       _projectsStore = projectsStore ?? FirestoreProjectsStore.new;

  final AuthService auth;
  final ClientsRepository clients;
  final ProjectsRepository projects;
  final ClientsStore Function(String uid) _clientsStore;
  final ProjectsStore Function(String uid) _projectsStore;

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
      projects.detachStore();
      clients.detachStore();
    } else {
      clients.attachStore(_clientsStore(user.uid));
      projects.attachStore(_projectsStore(user.uid));
    }
  }

  void dispose() => _subscription?.cancel();
}
