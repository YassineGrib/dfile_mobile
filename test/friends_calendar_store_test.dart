import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/calendar/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';

Future<void> settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Friend friend(String id) => Friend(
  id: id,
  name: 'Friend $id',
  phone: '0550',
  createdAt: DateTime(2026, 5, 1),
);

FriendTransaction tx(String id, String friendId, {double paid = 0}) =>
    FriendTransaction(
      id: id,
      friendId: friendId,
      type: FriendTxType.money,
      direction: FriendTxDirection.lent,
      amount: 10000,
      paidAmount: paid,
      description: 'Loan',
      dueDate: DateTime(2026, 11, 20),
      date: DateTime(2026, 10, 1),
    );

FriendSettlement settlement(String id, String txId, String friendId) =>
    FriendSettlement(
      id: id,
      transactionId: txId,
      friendId: friendId,
      amount: 2000,
      method: FriendSettleMethod.bank,
      date: DateTime(2026, 10, 5),
    );

void main() {
  group('friends document mapping', () {
    test('friend', () {
      final Map<String, Object?> map = friendToMap(friend('f1'));
      expect(map['name'], 'Friend f1');
      expect(map['phone'], '0550');
      final Friend back = friendFromMap('f1', map);
      expect(back.phone, '0550');
      expect(back.avatarColorIndex, inInclusiveRange(0, 3));
    });

    test('transaction uses web strings and a derived status', () {
      final Map<String, Object?> map = friendTransactionToMap(
        tx('t1', 'f1', paid: 4000),
      );
      expect(map['type'], 'money');
      expect(map['direction'], 'lent');
      expect(map['friend_id'], 'f1');
      expect(map['paid_amount'], 4000);
      expect(map['status'], 'partially_paid');
      expect(map['due_date'], '2026-11-20');
      expect(
        friendTransactionToMap(tx('t2', 'f1', paid: 10000))['status'],
        'settled',
      );
      final FriendTransaction back = friendTransactionFromMap('t1', map);
      expect(back.paidAmount, 4000);
      expect(back.dueDate, DateTime(2026, 11, 20));
    });

    test('settlement methods map to and from the web', () {
      expect(settleMethodToWeb(FriendSettleMethod.bank), 'bank_transfer');
      expect(
        settleMethodFromWeb('service_offset'),
        FriendSettleMethod.serviceOffset,
      );
      expect(settleMethodFromWeb('other'), FriendSettleMethod.cash);
      final FriendSettlement back = friendSettlementFromMap(
        's1',
        friendSettlementToMap(settlement('s1', 't1', 'f1')),
      );
      expect(back.amount, 2000);
      expect(back.method, FriendSettleMethod.bank);
    });

    test('unknown transaction values fall back', () {
      final FriendTransaction t = friendTransactionFromMap(
        'x',
        <String, Object?>{
          'friend_id': 'f1',
          'type': 'weird',
          'direction': 'weird',
          'amount': 5,
        },
      );
      expect(t.type, FriendTxType.money);
      expect(t.direction, FriendTxDirection.lent);
    });
  });

  group('FriendsRepository with a store', () {
    test('loads, computes balances and writes through', () async {
      final FriendsRepository repo = FriendsRepository();
      final FakeFriendsStore store = FakeFriendsStore(
        friends: <Friend>[friend('f1')],
        transactions: <FriendTransaction>[tx('t1', 'f1')],
      );
      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();

      expect(repo.isLoading, isFalse);
      expect(repo.friends.single.id, 'f1');
      expect(repo.overallBalance().owedToYou, 10000);

      repo.settle('t1', 4000, FriendSettleMethod.cash);
      await settle();
      expect(
        store.log.any((String l) => l.startsWith('saveSettlement:')),
        isTrue,
      );
      expect(store.log, contains('saveTransaction:t1'));
      expect(repo.transactionById('t1')!.paidAmount, 4000);
      expect(repo.overallBalance().owedToYou, 6000);

      repo.addFriend(friend('f2'));
      repo.addTransaction(tx('t2', 'f2'));
      await settle();
      expect(
        store.log,
        containsAll(<String>['saveFriend:f2', 'saveTransaction:t2']),
      );
    });

    test(
      'deleting a friend removes its transactions and settlements remotely',
      () async {
        final FriendsRepository repo = FriendsRepository();
        final FakeFriendsStore store = FakeFriendsStore(
          friends: <Friend>[friend('f1')],
          transactions: <FriendTransaction>[tx('t1', 'f1', paid: 2000)],
          settlements: <FriendSettlement>[settlement('s1', 't1', 'f1')],
        );
        repo.attachStore(store);
        await settle();

        repo.deleteFriend('f1');
        await settle();
        expect(
          store.log,
          containsAll(<String>[
            'deleteFriend:f1',
            'deleteTransaction:t1',
            'deleteSettlement:s1',
          ]),
        );
        expect(repo.friends, isEmpty);
        expect(repo.transactions, isEmpty);
        expect(repo.settlements, isEmpty);
      },
    );

    test('deleting a transaction removes its settlements remotely', () async {
      final FriendsRepository repo = FriendsRepository();
      final FakeFriendsStore store = FakeFriendsStore(
        friends: <Friend>[friend('f1')],
        transactions: <FriendTransaction>[tx('t1', 'f1', paid: 2000)],
        settlements: <FriendSettlement>[settlement('s1', 't1', 'f1')],
      );
      repo.attachStore(store);
      await settle();

      repo.deleteTransaction('t1');
      await settle();
      expect(
        store.log,
        containsAll(<String>['deleteTransaction:t1', 'deleteSettlement:s1']),
      );
    });

    test('detach empties and stops writing', () async {
      final FriendsRepository repo = FriendsRepository();
      final FakeFriendsStore store = FakeFriendsStore(
        friends: <Friend>[friend('f1')],
      );
      repo.attachStore(store);
      await settle();
      repo.detachStore();
      expect(repo.friends, isEmpty);
      repo.addFriend(friend('f9'));
      await settle();
      expect(store.log, isEmpty);
    });
  });

  group('milestones', () {
    Milestone ms(String id, {String projectId = 'p1', bool done = false}) =>
        Milestone(
          id: id,
          projectId: projectId,
          title: 'Design review',
          date: DateTime(2026, 11, 2),
          completed: done,
          createdAt: DateTime(2026, 10, 1),
        );

    test('document mapping', () {
      final Map<String, Object?> map = milestoneToMap(ms('m1', done: true));
      expect(map['project_id'], 'p1');
      expect(map['title'], 'Design review');
      expect(map['date'], '2026-11-02');
      expect(map['completed'], true);
      final Milestone back = milestoneFromMap('m1', map);
      expect(back.date, DateTime(2026, 11, 2));
      expect(back.completed, isTrue);
      expect(
        milestoneFromMap('m2', <String, Object?>{'title': 'x'}).completed,
        isFalse,
      );
    });

    test('repository follows the store and writes through', () async {
      final CalendarRepository repo = CalendarRepository();
      expect(repo.milestones, isNotEmpty);
      final FakeCalendarStore store = FakeCalendarStore(<Milestone>[ms('m1')]);
      repo.attachStore(store);
      expect(repo.isLoading, isTrue);
      await settle();
      expect(repo.milestones.single.id, 'm1');

      final Milestone added = repo.addMilestone(ms('').copyWith(id: ''));
      expect(added.id, startsWith('mil_'));
      repo.toggleMilestone('m1');
      await settle();
      expect(store.log, contains('save:m1'));
      expect(store.log, contains('save:${added.id}'));
      expect(repo.milestoneById('m1')!.completed, isTrue);

      repo.deleteMilestone('m1');
      await settle();
      expect(store.log, contains('delete:m1'));
    });

    test(
      'removing the milestones of a project deletes them remotely',
      () async {
        final CalendarRepository repo = CalendarRepository();
        final FakeCalendarStore store = FakeCalendarStore(<Milestone>[
          ms('m1'),
          ms('m2', projectId: 'p2'),
        ]);
        repo.attachStore(store);
        await settle();

        repo.removeMilestonesOf('p1');
        await settle();
        expect(store.log, <String>['delete:m1']);
        expect(repo.milestones.single.id, 'm2');
      },
    );

    test('detach empties the list', () async {
      final CalendarRepository repo = CalendarRepository();
      final FakeCalendarStore store = FakeCalendarStore(<Milestone>[ms('m1')]);
      repo.attachStore(store);
      await settle();
      repo.detachStore();
      expect(repo.milestones, isEmpty);
      repo.addMilestone(ms('m7'));
      await settle();
      expect(store.log, isEmpty);
    });
  });
}
