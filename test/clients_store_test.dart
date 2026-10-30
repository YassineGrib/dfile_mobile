import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/auth/data/auth_service.dart';
import 'package:dfile_mobile/features/auth/data/user_data_sync.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';

Client sample(String id, {String name = 'Acme'}) => Client(
  id: id,
  name: name,
  email: 'a@acme.co',
  linkedin: '/in/acme',
  createdAt: DateTime(2026, 3, 14),
);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('document mapping', () {
    test('round-trips and uses the web app field names', () {
      final Map<String, Object?> map = clientToMap(sample('c9'));
      expect(map['id'], 'c9');
      expect(map['created_at'], DateTime(2026, 3, 14).toIso8601String());
      expect(map['social_links'], <String, String>{'linkedin': '/in/acme'});
      expect(map.containsKey('phone'), isFalse);

      final Client back = clientFromMap('c9', map);
      expect(back.name, 'Acme');
      expect(back.linkedin, '/in/acme');
      expect(back.phone, '');
      expect(back.createdAt, DateTime(2026, 3, 14));
    });

    test('reads a web document with missing optional fields', () {
      final Client c = clientFromMap('cli_1', <String, Object?>{
        'name': 'Web Client',
        'created_at': 'not a date',
      });
      expect(c.id, 'cli_1');
      expect(c.email, '');
      expect(c.avatarColorIndex, inInclusiveRange(0, 3));
    });
  });

  group('ClientsRepository with a store', () {
    test('replaces demo data with the store and writes through', () async {
      final ClientsRepository repo = ClientsRepository();
      expect(repo.clients, isNotEmpty);
      final FakeClientsStore store = FakeClientsStore(<Client>[sample('s1')]);

      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();
      expect(repo.isLoading, isFalse);
      expect(repo.clients.map((Client c) => c.id), <String>['s1']);

      repo.add(sample('s2', name: 'Two'));
      repo.update(sample('s2', name: 'Two edited'));
      repo.delete('s1');
      await settle();
      expect(store.log, <String>['save:s2', 'save:s2', 'delete:s1']);
      expect(repo.clients.single.name, 'Two edited');
    });

    test('keeps local projects and payments across snapshots', () async {
      final ClientsRepository repo = ClientsRepository();
      final FakeClientsStore store = FakeClientsStore(<Client>[sample('s1')]);
      repo.attachStore(store);
      await settle();

      repo.update(
        repo
            .byId('s1')!
            .copyWith(
              projects: const <Project>[
                Project(
                  name: 'P',
                  status: 'In Progress',
                  price: 1,
                  progress: 1,
                ),
              ],
            ),
      );
      await settle();
      expect(repo.byId('s1')!.projects, hasLength(1));
    });

    test('detach empties the list and stops writing', () async {
      final ClientsRepository repo = ClientsRepository();
      final FakeClientsStore store = FakeClientsStore(<Client>[sample('s1')]);
      repo.attachStore(store);
      await settle();

      repo.detachStore();
      expect(repo.clients, isEmpty);
      repo.add(sample('s3'));
      await settle();
      expect(store.log, isEmpty);
    });
  });

  test('UserDataSync attaches on sign-in and detaches on sign-out', () async {
    final FakeAuthService auth = FakeAuthService();
    final ClientsRepository repo = ClientsRepository();
    final List<String> uids = <String>[];
    final UserDataSync sync = UserDataSync(
      auth: auth,
      clients: repo,
      projects: ProjectsRepository(clientsRepository: repo),
      expenses: ExpensesRepository(),
      expensesStore: (String uid) => FakeExpensesStore(),
      projectsStore: (String uid) => FakeProjectsStore(),
      clientsStore: (String uid) {
        uids.add(uid);
        return FakeClientsStore(<Client>[sample('mine')]);
      },
    )..start();

    expect(repo.isAttached, isFalse);
    await auth.signInWithEmail('a@b.co', 'x');
    await settle();
    await settle();
    expect(uids, <String>['fake_uid']);
    expect(repo.clients.single.id, 'mine');

    await auth.signOut();
    await settle();
    expect(repo.isAttached, isFalse);
    expect(repo.clients, isEmpty);
    sync.dispose();
  });
}
