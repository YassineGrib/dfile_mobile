import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'client.dart';

/// Persistence behind [ClientsRepository]: a live list plus write operations.
abstract class ClientsStore {
  Stream<List<Client>> watch();

  Future<void> save(Client client);

  Future<void> delete(String id);

  /// Removes every client (account deletion).
  Future<void> deleteAll();
}

/// Maps a client to the web app document shape (`users/{uid}/clients/{id}`).
Map<String, Object?> clientToMap(Client client) {
  final Map<String, String> social = <String, String>{
    if (client.linkedin.isNotEmpty) 'linkedin': client.linkedin,
    if (client.twitter.isNotEmpty) 'twitter': client.twitter,
    if (client.github.isNotEmpty) 'github': client.github,
    if (client.website.isNotEmpty) 'website': client.website,
  };
  return <String, Object?>{
    'id': client.id,
    'name': client.name,
    if (client.email.isNotEmpty) 'email': client.email,
    if (client.phone.isNotEmpty) 'phone': client.phone,
    if (client.address.isNotEmpty) 'address': client.address,
    if (client.notes.isNotEmpty) 'notes': client.notes,
    if (social.isNotEmpty) 'social_links': social,
    'created_at': client.createdAt.toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };
}

/// Reads a client document written by the web app or by [clientToMap].
Client clientFromMap(String docId, Map<String, Object?> data) {
  final Object? rawSocial = data['social_links'];
  final Map<String, Object?> social = rawSocial is Map
      ? Map<String, Object?>.from(rawSocial)
      : const <String, Object?>{};
  String text(Object? v) => v is String ? v : '';
  final String id = text(data['id']).isEmpty ? docId : text(data['id']);
  return Client(
    id: id,
    name: text(data['name']),
    email: text(data['email']),
    phone: text(data['phone']),
    address: text(data['address']),
    notes: text(data['notes']),
    linkedin: text(social['linkedin']),
    twitter: text(social['twitter']),
    github: text(social['github']),
    website: text(social['website']),
    createdAt: DateTime.tryParse(text(data['created_at'])) ?? DateTime.now(),
    avatarColorIndex: avatarColorFor(id),
  );
}

/// Stable avatar colour (0..3) derived from the client id.
int avatarColorFor(String id) {
  int hash = 0;
  for (final int unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash % 4;
}

/// Firestore-backed store for one signed-in user.
class FirestoreClientsStore implements ClientsStore {
  FirestoreClientsStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('clients');

  @override
  Stream<List<Client>> watch() => _col.snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              clientFromMap(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  @override
  Future<void> save(Client client) =>
      _col.doc(client.id).set(clientToMap(client));

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<void> deleteAll() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _col.get();
    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

/// In-memory store for tests; [emit] simulates a server snapshot.
class FakeClientsStore implements ClientsStore {
  FakeClientsStore([List<Client> initial = const <Client>[]])
    : _items = List<Client>.of(initial);

  final List<Client> _items;
  final StreamController<List<Client>> _controller =
      StreamController<List<Client>>.broadcast();
  final List<String> log = <String>[];

  List<Client> get items => List<Client>.unmodifiable(_items);

  @override
  Stream<List<Client>> watch() async* {
    yield List<Client>.of(_items);
    yield* _controller.stream;
  }

  void emit() => _controller.add(List<Client>.of(_items));

  @override
  Future<void> save(Client client) async {
    log.add('save:${client.id}');
    final int i = _items.indexWhere((Client c) => c.id == client.id);
    if (i == -1) {
      _items.add(client);
    } else {
      _items[i] = client;
    }
    emit();
  }

  @override
  Future<void> delete(String id) async {
    log.add('delete:$id');
    _items.removeWhere((Client c) => c.id == id);
    emit();
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _items.clear();
    emit();
  }
}
