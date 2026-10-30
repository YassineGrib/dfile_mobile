import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/store_utils.dart';
import 'milestone.dart';

/// Persistence behind [CalendarRepository]: the milestones of the projects.
abstract class CalendarStore {
  Stream<List<Milestone>> watch();

  Future<void> save(Milestone milestone);

  Future<void> delete(String id);

  /// Removes every milestone (account deletion).
  Future<void> deleteAll();
}

/// Maps a milestone to the web shape (`users/{uid}/milestones/{id}`).
Map<String, Object?> milestoneToMap(Milestone m) => <String, Object?>{
  'id': m.id,
  'project_id': m.projectId,
  'title': m.title,
  'date': dateOnly(m.date),
  'completed': m.completed,
  'created_at': m.createdAt.toIso8601String(),
};

Milestone milestoneFromMap(String docId, Map<String, Object?> data) {
  final String id = textOf(data['id']).isEmpty ? docId : textOf(data['id']);
  final DateTime date = parseDate(data['date']) ?? DateTime.now();
  return Milestone(
    id: id,
    projectId: textOf(data['project_id']),
    title: textOf(data['title']),
    date: DateTime(date.year, date.month, date.day),
    completed: data['completed'] == true,
    createdAt: parseDate(data['created_at']) ?? date,
  );
}

/// Firestore-backed store for one signed-in user.
class FirestoreCalendarStore implements CalendarStore {
  FirestoreCalendarStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('milestones');

  @override
  Stream<List<Milestone>> watch() => _col.snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              milestoneFromMap(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  @override
  Future<void> save(Milestone milestone) => _col
      .doc(milestone.id)
      .set(milestoneToMap(milestone), SetOptions(merge: true));

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

/// In-memory store for tests.
class FakeCalendarStore implements CalendarStore {
  FakeCalendarStore([List<Milestone> initial = const <Milestone>[]])
    : _items = List<Milestone>.of(initial);

  final List<Milestone> _items;
  final StreamController<List<Milestone>> _controller =
      StreamController<List<Milestone>>.broadcast();
  final List<String> log = <String>[];

  @override
  Stream<List<Milestone>> watch() async* {
    yield List<Milestone>.of(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> save(Milestone milestone) async {
    log.add('save:${milestone.id}');
    final int i = _items.indexWhere((Milestone m) => m.id == milestone.id);
    if (i == -1) {
      _items.add(milestone);
    } else {
      _items[i] = milestone;
    }
    _controller.add(List<Milestone>.of(_items));
  }

  @override
  Future<void> delete(String id) async {
    log.add('delete:$id');
    _items.removeWhere((Milestone m) => m.id == id);
    _controller.add(List<Milestone>.of(_items));
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _items.clear();
    _controller.add(const <Milestone>[]);
  }
}
