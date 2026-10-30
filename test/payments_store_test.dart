import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';

Future<void> settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

ProjectItem project(String id, {String clientId = 'c1'}) => ProjectItem(
  id: id,
  name: 'Project $id',
  category: 'Web',
  clientId: clientId,
  price: 1000,
  status: ProjectStatus.inProgress,
  progress: 40,
  startDate: DateTime(2026, 9, 1),
  createdAt: DateTime(2026, 9, 1),
);

ProjectPayment payment(
  String id, {
  double amount = 300,
  String clientId = '',
}) => ProjectPayment(
  id: id,
  projectId: 'p1',
  clientId: clientId,
  date: DateTime(2026, 10, 2),
  reference: '#A1',
  amount: amount,
  type: PaymentType.advance,
  method: PaymentMethod.ccp,
  notes: 'first',
);

void main() {
  group('payment document mapping', () {
    test('uses the web field names and strings', () {
      final Map<String, Object?> map = paymentToMap(
        payment('pay1', clientId: 'c1'),
      );
      expect(map['project_id'], 'p1');
      expect(map['client_id'], 'c1');
      expect(map['amount'], 300);
      expect(map['payment_type'], 'advance');
      expect(map['payment_method'], 'ccp');
      expect(map['reference_number'], '#A1');
      expect(map['payment_date'], '2026-10-02');
    });

    test('round-trips', () {
      final ProjectPayment back = paymentFromMap(
        'pay1',
        paymentToMap(payment('pay1', clientId: 'c1')),
      );
      expect(back.amount, 300);
      expect(back.type, PaymentType.advance);
      expect(back.method, PaymentMethod.ccp);
      expect(back.date, DateTime(2026, 10, 2));
      expect(back.notes, 'first');
    });

    test('maps the web-only types and methods', () {
      expect(paymentTypeFromWeb('full'), PaymentType.final_);
      expect(paymentTypeFromWeb('partial'), PaymentType.milestone);
      expect(paymentTypeFromWeb('tip'), PaymentType.tip);
      expect(paymentMethodFromWeb('bank_transfer'), PaymentMethod.bank);
      expect(paymentMethodFromWeb('other'), PaymentMethod.cash);
      expect(paymentMethodFromWeb(null), PaymentMethod.cash);
    });

    test('reads a sparse web document', () {
      final ProjectPayment p = paymentFromMap('pay9', <String, Object?>{
        'project_id': 'p1',
        'amount': 12000,
        'payment_date': '2026-08-15',
      });
      expect(p.id, 'pay9');
      expect(p.amount, 12000);
      expect(p.reference, '');
      expect(p.date, DateTime(2026, 8, 15));
    });
  });

  group('ProjectsRepository payments with a store', () {
    late ClientsRepository clients;
    late ProjectsRepository repo;

    setUp(() {
      clients = ClientsRepository(
        initialClients: <Client>[
          Client(id: 'c1', name: 'Client', createdAt: DateTime(2026, 1, 1)),
        ],
      );
      repo = ProjectsRepository(clientsRepository: clients);
    });

    test('loads payments and computes paid and remaining', () async {
      final FakeProjectsStore store = FakeProjectsStore(
        projects: <ProjectItem>[project('p1')],
        payments: <ProjectPayment>[
          payment('pay1'),
          payment('pay2', amount: 200),
        ],
      );
      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();

      expect(repo.isLoading, isFalse);
      expect(repo.paymentsOf('p1'), hasLength(2));
      expect(repo.paid(repo.byId('p1')!), 500);
      expect(repo.remaining(repo.byId('p1')!), 500);
      // A missing client id is filled in from the project owner.
      expect(repo.paymentById('pay1')!.clientId, 'c1');
      expect(clients.byId('c1')!.payments, hasLength(2));
    });

    test('writes through add and delete', () async {
      final FakeProjectsStore store = FakeProjectsStore(
        projects: <ProjectItem>[project('p1')],
      );
      repo.attachStore(store);
      await settle();

      repo.addPayment(payment('pay5'));
      await settle();
      expect(store.log, contains('savePayment:pay5'));
      expect(repo.paymentsOf('p1'), hasLength(1));

      expect(repo.deletePayment('pay5'), isTrue);
      await settle();
      expect(store.log, contains('deletePayment:pay5'));
      expect(repo.paymentsOf('p1'), isEmpty);
    });

    test('detach clears payments', () async {
      final FakeProjectsStore store = FakeProjectsStore(
        projects: <ProjectItem>[project('p1')],
        payments: <ProjectPayment>[payment('pay1')],
      );
      repo.attachStore(store);
      await settle();
      repo.detachStore();
      expect(repo.allPayments, isEmpty);
    });
  });
}
