import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';

Future<void> settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

ProjectItem project(
  String id, {
  String clientId = 'c1',
  ProjectStatus status = ProjectStatus.inProgress,
  int progress = 40,
}) => ProjectItem(
  id: id,
  name: 'Project $id',
  category: 'Web',
  clientId: clientId,
  price: 1000,
  status: status,
  progress: progress,
  startDate: DateTime(2026, 9, 1),
  endDate: DateTime(2026, 11, 1),
  createdAt: DateTime(2026, 9, 1),
);

Client client(String id) =>
    Client(id: id, name: 'Client $id', createdAt: DateTime(2026, 1, 1));

void main() {
  group('document mapping', () {
    test('project round-trips with the web field names', () {
      final Map<String, Object?> map = projectToMap(project('p1'));
      expect(map['price_dzd'], 1000);
      expect(map['client_id'], 'c1');
      expect(map['status'], 'In Progress');
      expect(map['progress_percentage'], 40);
      expect(map['start_date'], '2026-09-01');
      expect(map['end_date'], '2026-11-01');

      final ProjectItem back = projectFromMap('p1', map);
      expect(back.name, 'Project p1');
      expect(back.status, ProjectStatus.inProgress);
      expect(back.endDate, DateTime(2026, 11, 1));
    });

    test('reads a sparse web document', () {
      final ProjectItem p = projectFromMap('proj_9', <String, Object?>{
        'name': 'From web',
        'status': 'Completed',
        'progress_percentage': 30,
        'price_dzd': 250000,
        'created_at': '2026-05-02',
      });
      expect(p.id, 'proj_9');
      expect(p.progress, 100); // completed forces 100
      expect(p.startDate, DateTime(2026, 5, 2)); // falls back to created_at
      expect(p.endDate, isNull);
      expect(p.price, 250000);
    });

    test('unknown status falls back to planned', () {
      final ProjectItem p = projectFromMap('x', <String, Object?>{
        'name': 'N',
        'status': 'Weird',
      });
      expect(p.status, ProjectStatus.planned);
    });

    test('task mapping', () {
      final ProjectTask t = ProjectTask(
        id: 't1',
        projectId: 'p1',
        name: 'Design',
        due: DateTime(2026, 10, 5),
        status: TaskStatus.inProgress,
      );
      final Map<String, Object?> map = taskToMap(t, create: true);
      expect(map['project_id'], 'p1');
      expect(map['status'], 'In Progress');
      expect(map['due_date'], '2026-10-05');
      expect(map.containsKey('created_at'), isTrue);
      expect(taskToMap(t).containsKey('created_at'), isFalse);
      expect(taskFromMap('t1', map).due, DateTime(2026, 10, 5));
    });
  });

  group('ProjectsRepository with a store', () {
    late ClientsRepository clients;
    late ProjectsRepository repo;

    setUp(() {
      clients = ClientsRepository(initialClients: <Client>[client('c1')]);
      repo = ProjectsRepository(clientsRepository: clients);
    });

    test('replaces demo data with the store and loads', () async {
      final FakeProjectsStore store = FakeProjectsStore(
        projects: <ProjectItem>[project('p1')],
        tasks: <ProjectTask>[
          const ProjectTask(id: 't1', projectId: 'p1', name: 'A'),
        ],
      );
      expect(repo.projects, isNotEmpty);

      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();

      expect(repo.isLoading, isFalse);
      expect(repo.projects.map((ProjectItem p) => p.id), <String>['p1']);
      expect(repo.tasksOf('p1'), hasLength(1));
      expect(repo.allPayments, isEmpty);
      // The client got its embedded project list from the snapshot.
      expect(clients.byId('c1')!.projects.single.name, 'Project p1');
    });

    test('writes through add, update, status, tasks and delete', () async {
      final FakeProjectsStore store = FakeProjectsStore();
      repo.attachStore(store);
      await settle();

      repo.add(
        project('p2'),
        tasks: const <ProjectTask>[
          ProjectTask(id: 't9', projectId: 'p2', name: 'First'),
        ],
      );
      repo.update(project('p2').copyWith(name: 'Renamed'));
      repo.changeStatus('p2', ProjectStatus.completed);
      repo.toggleTask('t9');
      final ProjectTask added = repo.addTask('p2', 'Second');
      await settle();

      expect(store.log, contains('saveProject:p2'));
      expect(store.log, contains('saveTask:t9:new'));
      expect(store.log, contains('saveTask:t9'));
      expect(store.log, contains('saveTask:${added.id}:new'));
      expect(added.id, startsWith('tsk_'));
      expect(repo.byId('p2')!.status, ProjectStatus.completed);
      expect(repo.byId('p2')!.progress, 100);

      repo.delete('p2');
      await settle();
      expect(store.log, contains('deleteProject:p2'));
      expect(store.log, contains('deleteTask:t9'));
      expect(repo.projects, isEmpty);
    });

    test('derived client updates do not write the client', () async {
      final FakeClientsStore clientStore = FakeClientsStore(<Client>[
        client('c1'),
      ]);
      clients.attachStore(clientStore);
      repo.attachStore(FakeProjectsStore());
      await settle();

      repo.add(project('p3'));
      await settle();

      expect(clientStore.log, isEmpty);
      expect(clients.byId('c1')!.projects, hasLength(1));
    });

    test('detach empties everything and stops writing', () async {
      final FakeProjectsStore store = FakeProjectsStore(
        projects: <ProjectItem>[project('p1')],
      );
      repo.attachStore(store);
      await settle();

      repo.detachStore();
      expect(repo.projects, isEmpty);
      repo.add(project('p4'));
      await settle();
      expect(store.log, isEmpty);
    });
  });
}
