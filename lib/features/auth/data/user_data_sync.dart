import 'dart:async';

import '../../clients/data/data.dart';
import 'auth_service.dart';

/// Connects the repositories to the signed-in user: on sign-in each one
/// attaches its Firestore store for that uid, on sign-out it detaches and
/// empties so nothing leaks to the next account.
class UserDataSync {
  UserDataSync({
    required this.auth,
    required this.clients,
    ClientsStore Function(String uid)? clientsStore,
  }) : _clientsStore = clientsStore ?? FirestoreClientsStore.new;

  final AuthService auth;
  final ClientsRepository clients;
  final ClientsStore Function(String uid) _clientsStore;

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
      clients.detachStore();
    } else {
      clients.attachStore(_clientsStore(user.uid));
    }
  }

  void dispose() => _subscription?.cancel();
}
