import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'project.dart';

/// Persistence behind [ProjectsRepository]: live lists plus write operations
/// for projects and their checklist tasks.
abstract class ProjectsStore {
  Stream<List<ProjectItem>> watchProjects();

  Stream<List<ProjectTask>> watchTasks();

  Future<void> saveProject(ProjectItem project);

  Future<void> deleteProject(String id);

  /// [create] stamps `created_at` on a brand new task.
  Future<void> saveTask(ProjectTask task, {bool create = false});

  Future<void> deleteTask(String id);

  /// Removes every project and task (account deletion).
  Future<void> deleteAll();
}

String _dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parseDate(Object? v) => v is String ? DateTime.tryParse(v) : null;

String _text(Object? v) => v is String ? v : '';

ProjectStatus _statusOf(Object? v) {
  for (final ProjectStatus s in ProjectStatus.values) {
    if (s.label == v) return s;
  }
  return ProjectStatus.planned;
}

TaskStatus _taskStatusOf(Object? v) {
  for (final TaskStatus s in TaskStatus.values) {
    if (s.label == v) return s;
  }
  return TaskStatus.nextUp;
}

/// Maps a project to the web document shape (`users/{uid}/projects/{id}`).
/// An absent end date is a [FieldValue.delete] so a merge clears it.
Map<String, Object?> projectToMap(ProjectItem p) => <String, Object?>{
  'id': p.id,
  'name': p.name,
  'description': p.description,
  'category': p.category,
  'client_id': p.clientId,
  'price_dzd': p.price,
  'status': p.status.label,
  'progress_percentage': p.progress,
  'start_date': _dateOnly(p.startDate),
  'end_date': p.endDate == null ? FieldValue.delete() : _dateOnly(p.endDate!),
  'created_at': p.createdAt.toIso8601String(),
};

/// Reads a project written by the web app or by [projectToMap].
ProjectItem projectFromMap(String docId, Map<String, Object?> data) {
  final DateTime created = _parseDate(data['created_at']) ?? DateTime.now();
  final Object? price = data['price_dzd'];
  final Object? progress = data['progress_percentage'];
  final String id = _text(data['id']).isEmpty ? docId : _text(data['id']);
  final ProjectStatus status = _statusOf(data['status']);
  int pct = progress is num ? progress.round().clamp(0, 100) : 0;
  if (status.forcesFullProgress) pct = 100;
  return ProjectItem(
    id: id,
    name: _text(data['name']),
    description: _text(data['description']),
    category: _text(data['category']),
    clientId: _text(data['client_id']),
    price: price is num ? price.toDouble() : 0,
    status: status,
    progress: pct,
    startDate: _parseDate(data['start_date']) ?? created,
    endDate: _parseDate(data['end_date']),
    createdAt: created,
  );
}

/// Maps a task to the web document shape (`users/{uid}/tasks/{id}`).
Map<String, Object?> taskToMap(ProjectTask t, {bool create = false}) =>
    <String, Object?>{
      'id': t.id,
      'project_id': t.projectId,
      'name': t.name,
      'status': t.status.label,
      'due_date': t.due == null ? FieldValue.delete() : _dateOnly(t.due!),
      if (create) 'created_at': DateTime.now().toIso8601String(),
    };

ProjectTask taskFromMap(String docId, Map<String, Object?> data) {
  final String id = _text(data['id']).isEmpty ? docId : _text(data['id']);
  return ProjectTask(
    id: id,
    projectId: _text(data['project_id']),
    name: _text(data['name']),
    due: _parseDate(data['due_date']),
    status: _taskStatusOf(data['status']),
  );
}

/// Firestore-backed store for one signed-in user. Writes merge, so fields only
/// the web app knows (task labels, assignees, comments) are never wiped.
class FirestoreProjectsStore implements ProjectsStore {
  FirestoreProjectsStore(this.uid, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(uid).collection(name);

  @override
  Stream<List<ProjectItem>> watchProjects() => _col('projects').snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              projectFromMap(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  @override
  Stream<List<ProjectTask>> watchTasks() => _col('tasks').snapshots().map(
    (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              taskFromMap(d.id, Map<String, Object?>.from(d.data())),
        )
        .toList(),
  );

  @override
  Future<void> saveProject(ProjectItem project) =>
      _col('projects')
          .doc(project.id)
          .set(projectToMap(project), SetOptions(merge: true));

  @override
  Future<void> deleteProject(String id) => _col('projects').doc(id).delete();

  @override
  Future<void> saveTask(ProjectTask task, {bool create = false}) =>
      _col('tasks')
          .doc(task.id)
          .set(taskToMap(task, create: create), SetOptions(merge: true));

  @override
  Future<void> deleteTask(String id) => _col('tasks').doc(id).delete();

  @override
  Future<void> deleteAll() async {
    for (final String name in <String>['projects', 'tasks']) {
      final QuerySnapshot<Map<String, dynamic>> snap = await _col(name).get();
      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}

/// In-memory store for tests.
class FakeProjectsStore implements ProjectsStore {
  FakeProjectsStore({
    List<ProjectItem> projects = const <ProjectItem>[],
    List<ProjectTask> tasks = const <ProjectTask>[],
  }) : _projects = List<ProjectItem>.of(projects),
       _tasks = List<ProjectTask>.of(tasks);

  final List<ProjectItem> _projects;
  final List<ProjectTask> _tasks;
  final StreamController<List<ProjectItem>> _pc =
      StreamController<List<ProjectItem>>.broadcast();
  final StreamController<List<ProjectTask>> _tc =
      StreamController<List<ProjectTask>>.broadcast();
  final List<String> log = <String>[];

  @override
  Stream<List<ProjectItem>> watchProjects() async* {
    yield List<ProjectItem>.of(_projects);
    yield* _pc.stream;
  }

  @override
  Stream<List<ProjectTask>> watchTasks() async* {
    yield List<ProjectTask>.of(_tasks);
    yield* _tc.stream;
  }

  @override
  Future<void> saveProject(ProjectItem project) async {
    log.add('saveProject:${project.id}');
    final int i = _projects.indexWhere((ProjectItem p) => p.id == project.id);
    if (i == -1) {
      _projects.add(project);
    } else {
      _projects[i] = project;
    }
    _pc.add(List<ProjectItem>.of(_projects));
  }

  @override
  Future<void> deleteProject(String id) async {
    log.add('deleteProject:$id');
    _projects.removeWhere((ProjectItem p) => p.id == id);
    _pc.add(List<ProjectItem>.of(_projects));
  }

  @override
  Future<void> saveTask(ProjectTask task, {bool create = false}) async {
    log.add('saveTask:${task.id}${create ? ':new' : ''}');
    final int i = _tasks.indexWhere((ProjectTask t) => t.id == task.id);
    if (i == -1) {
      _tasks.add(task);
    } else {
      _tasks[i] = task;
    }
    _tc.add(List<ProjectTask>.of(_tasks));
  }

  @override
  Future<void> deleteTask(String id) async {
    log.add('deleteTask:$id');
    _tasks.removeWhere((ProjectTask t) => t.id == id);
    _tc.add(List<ProjectTask>.of(_tasks));
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _projects.clear();
    _tasks.clear();
    _pc.add(const <ProjectItem>[]);
    _tc.add(const <ProjectTask>[]);
  }
}
