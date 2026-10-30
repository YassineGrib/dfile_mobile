import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dfile_mobile/core/privacy.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/theme/theme.dart';
import 'package:dfile_mobile/core/widgets/skeleton.dart';
import 'package:dfile_mobile/core/widgets/user_avatar.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/dashboard/dashboard_home_strings.dart';
import 'package:dfile_mobile/features/dashboard/data/follow_up.dart';
import 'package:dfile_mobile/features/dashboard/widgets/home_follow_up.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

Client client(String id, String name, {String phone = ''}) =>
    Client(id: id, name: name, phone: phone, createdAt: DateTime(2026, 1, 1));

ProjectItem project(
  String id,
  String clientId, {
  double price = 1000,
  ProjectStatus status = ProjectStatus.inProgress,
}) => ProjectItem(
  id: id,
  name: 'Project $id',
  category: 'Web',
  clientId: clientId,
  price: price,
  status: status,
  progress: 40,
  startDate: DateTime(2026, 9, 1),
  createdAt: DateTime(2026, 9, 1),
);

(ClientsRepository, ProjectsRepository) buildRepos() {
  final ClientsRepository clients = ClientsRepository(
    initialClients: <Client>[
      client('c1', 'Mohamed Bachir', phone: '0550 12 34 56'),
      client('c2', 'Sarah Benali'),
      client('c3', 'Paid Up'),
    ],
  );
  final ProjectsRepository projects = ProjectsRepository(
    clientsRepository: clients,
    initialProjects: <ProjectItem>[
      project('p1', 'c1'),
      project('p2', 'c2', price: 500),
      project('p3', 'c1', status: ProjectStatus.cancelled),
      project('p4', 'c3', price: 300),
    ],
    initialTasks: const <ProjectTask>[],
    initialPayments: <ProjectPayment>[
      ProjectPayment(
        id: 'pay1',
        projectId: 'p1',
        date: DateTime(2026, 10, 1),
        amount: 400,
      ),
      ProjectPayment(
        id: 'pay2',
        projectId: 'p4',
        date: DateTime(2026, 10, 2),
        amount: 300,
      ),
    ],
  );
  return (clients, projects);
}

class _NeverLoadsStore implements ClientsStore {
  @override
  Stream<List<Client>> watch() => const Stream<List<Client>>.empty();
  @override
  Future<void> save(Client client) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> deleteAll() async {}
}

void main() {
  group('follow-up logic', () {
    test('lists unpaid clients, largest balance first, ignoring cancelled', () {
      final (ClientsRepository clients, ProjectsRepository projects) =
          buildRepos();
      final List<FollowUp> items = followUps(
        projects: projects,
        clients: clients.clients,
      );
      expect(items.map((FollowUp f) => f.client.id), <String>['c1', 'c2']);
      expect(items[0].outstanding, 600);
      expect(items[1].outstanding, 500);
      expect(items[0].projectNames, <String>['Project p1']);
    });

    test('respects the limit', () {
      final (ClientsRepository clients, ProjectsRepository projects) =
          buildRepos();
      expect(
        followUps(projects: projects, clients: clients.clients, limit: 1),
        hasLength(1),
      );
    });

    test('whatsapp numbers get the Algerian country code', () {
      expect(whatsappNumber('0550 12 34 56'), '213550123456');
      expect(whatsappNumber('+213 550 12 34 56'), '213550123456');
      expect(whatsappNumber('00213550123456'), '213550123456');
      expect(whatsappNumber(''), isNull);
      expect(whatsappNumber('abc'), isNull);
    });

    test('the reminder names the client, amount and project', () {
      final (ClientsRepository clients, ProjectsRepository projects) =
          buildRepos();
      final FollowUp first = followUps(
        projects: projects,
        clients: clients.clients,
      ).first;
      final String message = reminderMessage(first);
      expect(message, contains('Hello Mohamed'));
      expect(message, contains('600'));
      expect(message, contains('"Project p1"'));
      final Uri uri = whatsappUri(first)!;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/213550123456');
      expect(uri.queryParameters['text'], message);
    });

    test('a client without a phone has no link', () {
      final (ClientsRepository clients, ProjectsRepository projects) =
          buildRepos();
      final FollowUp sarah = followUps(
        projects: projects,
        clients: clients.clients,
      ).last;
      expect(whatsappUri(sarah), isNull);
    });
  });

  testWidgets(
    'the Follow up card reminds on WhatsApp and explains a missing phone',
    (WidgetTester tester) async {
      final (ClientsRepository clients, ProjectsRepository projects) =
          buildRepos();
      final List<Uri> opened = <Uri>[];
      final Future<bool> Function(Uri) previous = openExternalLink;
      openExternalLink = (Uri uri) async {
        opened.add(uri);
        return true;
      };
      addTearDown(() => openExternalLink = previous);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ClientsScope(
            repository: clients,
            child: ProjectsScope(
              repository: projects,
              child: const Scaffold(
                body: SingleChildScrollView(child: HomeFollowUp()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(DashboardHomeStrings.followUp), findsOneWidget);
      expect(find.byType(UserAvatar), findsNWidgets(2));
      expect(find.text('Paid Up'), findsNothing);
      expect(find.textContaining('600'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Remind Mohamed Bachir'));
      await tester.pump();
      expect(opened, hasLength(1));
      expect(opened.single.host, 'wa.me');

      await tester.tap(find.bySemanticsLabel('Remind Sarah Benali'));
      await tester.pump();
      expect(opened, hasLength(1));
      expect(find.text(DashboardHomeStrings.followUpNoPhone), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    },
  );

  testWidgets('the Follow up card is empty when everyone has paid', (
    WidgetTester tester,
  ) async {
    final ClientsRepository clients = ClientsRepository(
      initialClients: <Client>[client('c1', 'A')],
    );
    final ProjectsRepository projects = ProjectsRepository(
      clientsRepository: clients,
      initialProjects: <ProjectItem>[],
      initialTasks: const <ProjectTask>[],
      initialPayments: const <ProjectPayment>[],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ClientsScope(
          repository: clients,
          child: ProjectsScope(
            repository: projects,
            child: const Scaffold(body: HomeFollowUp()),
          ),
        ),
      ),
    );
    expect(find.text(DashboardHomeStrings.followUp), findsNothing);
  });

  group('hide amounts', () {
    test('toggles and remembers the choice', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final PrivacyMode first = await PrivacyMode.load();
      expect(first.hidden, isFalse);
      first.toggle();
      expect(first.hidden, isTrue);
      await Future<void>.delayed(Duration.zero);

      final PrivacyMode second = await PrivacyMode.load();
      expect(second.hidden, isTrue);
    });

    testWidgets('shown() masks amounts only while hidden', (
      WidgetTester tester,
    ) async {
      final PrivacyMode mode = PrivacyMode();
      late BuildContext captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: PrivacyScope(
            mode: mode,
            child: Builder(
              builder: (BuildContext context) {
                captured = context;
                return Text(PrivacyScope.shown(context, '1,000 DZ'));
              },
            ),
          ),
        ),
      );
      expect(find.text('1,000 DZ'), findsOneWidget);
      mode.toggle();
      await tester.pump();
      expect(find.text(PrivacyMode.mask), findsOneWidget);
      expect(PrivacyScope.shown(captured, 'x'), PrivacyMode.mask);
    });
  });

  testWidgets(
    'a list shows skeleton cards while it loads, not an empty state',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final ClientsRepository clients = ClientsRepository()
        ..attachStore(_NeverLoadsStore());
      await tester.pumpWidget(
        DfileApp(
          repository: clients,
          router: createAppRouter(initialLocation: AppRoutes.clientsPath),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(clients.isLoading, isTrue);
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.text('No clients yet'), findsNothing);
    },
  );
}
