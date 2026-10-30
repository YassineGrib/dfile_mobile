import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/add_friend_screen.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/friend_statement_screen.dart';
import 'package:dfile_mobile/features/friends/friend_strings.dart';
import 'package:dfile_mobile/features/friends/friends_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_form_screen.dart';
import 'package:dfile_mobile/features/friends/widgets/widgets.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/more/more_strings.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Friends Enums, Labels, and Derived Properties', () {
    test('FriendTxType defines labels and glyph codes', () {
      expect(FriendTxType.money.label, 'Money loan');
      expect(FriendTxType.money.code, r'$');

      expect(FriendTxType.service.label, 'Service');
      expect(FriendTxType.service.code, 'S');

      expect(FriendTxType.expense.label, 'Shared cost');
      expect(FriendTxType.expense.code, 'C');

      expect(FriendTxType.tryParse('Money loan'), FriendTxType.money);
      expect(FriendTxType.tryParse('service'), FriendTxType.service);
      expect(FriendTxType.tryParse('Shared cost'), FriendTxType.expense);
      expect(FriendTxType.tryParse('unknown'), isNull);
    });

    test('FriendTxDirection defines labels and chip labels', () {
      expect(FriendTxDirection.lent.label, 'Owed to me');
      expect(FriendTxDirection.lent.chipLabel, 'Lent');
      expect(FriendTxDirection.lent.isLent, isTrue);
      expect(FriendTxDirection.lent.isBorrowed, isFalse);

      expect(FriendTxDirection.borrowed.label, 'I owe');
      expect(FriendTxDirection.borrowed.chipLabel, 'Borrowed');
      expect(FriendTxDirection.borrowed.isLent, isFalse);
      expect(FriendTxDirection.borrowed.isBorrowed, isTrue);

      expect(FriendTxDirection.tryParse('Owed to me'), FriendTxDirection.lent);
      expect(
        FriendTxDirection.tryParse('borrowed'),
        FriendTxDirection.borrowed,
      );
      expect(FriendTxDirection.tryParse('none'), isNull);
    });

    test('FriendTxStatus defines labels and boolean helpers', () {
      expect(FriendTxStatus.pending.label, 'Pending');
      expect(FriendTxStatus.pending.isPending, isTrue);
      expect(FriendTxStatus.partial.label, 'Partial');
      expect(FriendTxStatus.partial.isPartial, isTrue);
      expect(FriendTxStatus.settled.label, 'Settled');
      expect(FriendTxStatus.settled.isSettled, isTrue);
    });

    test('FriendSettleMethod defines labels', () {
      expect(FriendSettleMethod.baridimob.label, 'BaridiMob');
      expect(FriendSettleMethod.cash.label, 'Cash');
      expect(FriendSettleMethod.bank.label, 'Bank');
      expect(FriendSettleMethod.serviceOffset.label, 'Offset');

      expect(
        FriendSettleMethod.tryParse('BaridiMob'),
        FriendSettleMethod.baridimob,
      );
      expect(FriendSettleMethod.tryParse('cash'), FriendSettleMethod.cash);
      expect(FriendSettleMethod.tryParse('bank'), FriendSettleMethod.bank);
      expect(
        FriendSettleMethod.tryParse('offset'),
        FriendSettleMethod.serviceOffset,
      );
      expect(FriendSettleMethod.tryParse('invalid'), isNull);
    });

    test('FriendsTab and FriendNetFilter define labels', () {
      expect(FriendsTab.friends.label, 'Friends');
      expect(FriendsTab.transactions.label, 'Transactions');
      expect(FriendsTab.fromString('transactions'), FriendsTab.transactions);
      expect(FriendsTab.fromString('other'), FriendsTab.friends);

      expect(FriendNetFilter.all.label, 'All');
      expect(FriendNetFilter.owedToMe.label, 'Owe me');
      expect(FriendNetFilter.iOwe.label, 'I owe');
      expect(FriendNetFilter.settled.label, 'Settled');
    });

    test('FriendStrings centralises all labels and helper methods', () {
      expect(FriendStrings.moneyLoan, 'Money loan');
      expect(FriendStrings.service, 'Service');
      expect(FriendStrings.sharedCost, 'Shared cost');
      expect(FriendStrings.owedToMe, 'Owed to me');
      expect(FriendStrings.iOwe, 'I owe');
      expect(FriendStrings.lent, 'Lent');
      expect(FriendStrings.borrowed, 'Borrowed');
      expect(FriendStrings.pending, 'Pending');
      expect(FriendStrings.partial, 'Partial');
      expect(FriendStrings.settled, 'Settled');
      expect(FriendStrings.baridimob, 'BaridiMob');
      expect(FriendStrings.cash, 'Cash');
      expect(FriendStrings.bank, 'Bank');
      expect(FriendStrings.offset, 'Offset');

      expect(FriendStrings.typeLabel(FriendTxType.money), 'Money loan');
      expect(
        FriendStrings.directionLabel(FriendTxDirection.lent),
        'Owed to me',
      );
      expect(FriendStrings.statusLabel(FriendTxStatus.pending), 'Pending');
      expect(FriendStrings.methodLabel(FriendSettleMethod.cash), 'Cash');
    });

    test('FriendTransaction derives remaining and status accurately', () {
      final FriendTransaction pendingTx = FriendTransaction(
        id: 't_pending',
        friendId: 'fr1',
        type: FriendTxType.money,
        direction: FriendTxDirection.lent,
        amount: 10000.0,
        paidAmount: 0.0,
        description: 'Test Pending',
        date: DateTime(2026, 10, 1),
      );
      expect(pendingTx.remaining, 10000.0);
      expect(pendingTx.status, FriendTxStatus.pending);
      expect(pendingTx.isSettled, isFalse);

      final FriendTransaction partialTx = pendingTx.copyWith(
        paidAmount: 4000.0,
      );
      expect(partialTx.remaining, 6000.0);
      expect(partialTx.status, FriendTxStatus.partial);
      expect(partialTx.isSettled, isFalse);

      final FriendTransaction settledTx = pendingTx.copyWith(
        paidAmount: 10000.0,
      );
      expect(settledTx.remaining, 0.0);
      expect(settledTx.status, FriendTxStatus.settled);
      expect(settledTx.isSettled, isTrue);

      final FriendTransaction overpaidTx = pendingTx.copyWith(
        paidAmount: 12000.0,
      );
      expect(overpaidTx.remaining, 0.0);
      expect(overpaidTx.status, FriendTxStatus.settled);
    });
  });

  group('FriendsRepository Mock Seed & Balances (SPEC.md)', () {
    test(
      'Default FriendsRepository initializes exact mock seed data from SPEC.md',
      () {
        final FriendsRepository repo = FriendsRepository();
        expect(repo.friends.length, 4);
        expect(repo.transactions.length, 5);
        expect(repo.settlements.length, 3);

        expect(repo.friendById('fr1')?.name, 'Karim Boualam');
        expect(repo.friendById('fr2')?.name, 'Yacine Mebarki');
        expect(repo.friendById('fr3')?.name, 'Amine Saidi');
        expect(repo.friendById('fr4')?.name, 'Lina Cherif');
      },
    );

    test('overallBalance calculates net 58,000 / 70,000 / 12,000', () {
      final FriendsRepository repo = FriendsRepository();
      final OverallBalance overall = repo.overallBalance();

      expect(overall.owedToYou, 70000.0);
      expect(overall.youOwe, 12000.0);
      expect(overall.net, 58000.0);
    });

    test(
      'friendBalance calculates Karim Boualam net 45,000 and last activity',
      () {
        final FriendsRepository repo = FriendsRepository();
        final FriendBalance karim = repo.friendBalance('fr1');

        expect(karim.owedToYou, 45000.0);
        expect(karim.youOwe, 0.0);
        expect(karim.net, 45000.0);
        expect(karim.active, 2);
        expect(karim.settled, 0);
        expect(karim.lastActivity, DateTime(2026, 10, 5));
      },
    );

    test('friendBalance calculates Yacine, Amine, and Lina balances', () {
      final FriendsRepository repo = FriendsRepository();

      final FriendBalance yacine = repo.friendBalance('fr2');
      expect(yacine.owedToYou, 25000.0);
      expect(yacine.youOwe, 0.0);
      expect(yacine.net, 25000.0);
      expect(yacine.active, 1);
      expect(yacine.settled, 0);
      expect(yacine.lastActivity, DateTime(2026, 10, 20));

      final FriendBalance amine = repo.friendBalance('fr3');
      expect(amine.owedToYou, 0.0);
      expect(amine.youOwe, 12000.0);
      expect(amine.net, -12000.0);
      expect(amine.active, 1);
      expect(amine.settled, 0);
      expect(amine.lastActivity, DateTime(2026, 10, 10));

      final FriendBalance lina = repo.friendBalance('fr4');
      expect(lina.owedToYou, 0.0);
      expect(lina.youOwe, 0.0);
      expect(lina.net, 0.0);
      expect(lina.active, 0);
      expect(lina.settled, 1);
      expect(lina.lastActivity, DateTime(2026, 8, 20));
    });
  });

  group('FriendsRepository Settle Operations & Validation', () {
    test('settle validates amount > 0 and amount <= remaining, throwing ArgumentError', () {
      final FriendsRepository repo = FriendsRepository();

      // Zero amount
      expect(
        () => repo.settle('tx1', 0.0, FriendSettleMethod.cash),
        throwsA(isA<ArgumentError>()),
      );

      // Negative amount
      expect(
        () => repo.settle('tx1', -500.0, FriendSettleMethod.cash),
        throwsA(isA<ArgumentError>()),
      );

      // Amount exceeding remaining (tx1 remaining is 30,000)
      expect(
        () => repo.settle('tx1', 30001.0, FriendSettleMethod.cash),
        throwsA(isA<ArgumentError>()),
      );

      // Unknown transaction
      expect(
        () => repo.settle('nonexistent', 1000.0, FriendSettleMethod.cash),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'settle records exact full settlement and updates transaction to settled',
      () {
        final FriendsRepository repo = FriendsRepository();
        bool notified = false;
        repo.addListener(() => notified = true);

        // tx1 remaining is 30,000
        final FriendSettlement settlement = repo.settle(
          'tx1',
          30000.0,
          FriendSettleMethod.baridimob,
          'Final payoff',
          DateTime(2026, 10, 25),
        );

        expect(settlement.amount, 30000.0);
        expect(settlement.method, FriendSettleMethod.baridimob);
        expect(settlement.notes, 'Final payoff');
        expect(notified, isTrue);

        final FriendTransaction updatedTx = repo.transactionById('tx1')!;
        expect(updatedTx.paidAmount, 50000.0);
        expect(updatedTx.remaining, 0.0);
        expect(updatedTx.status, FriendTxStatus.settled);

        // Check settlementsOf
        final List<FriendSettlement> txSettlements = repo.settlementsOf('tx1');
        expect(txSettlements.length, 3);
        expect(txSettlements.last.amount, 30000.0);

        // Karim net balance reduced by 30,000 (was 45,000 -> now 15,000)
        final FriendBalance karim = repo.friendBalance('fr1');
        expect(karim.net, 15000.0);
        expect(karim.active, 1);
        expect(karim.settled, 1);
      },
    );

    test('settle partial amount updates remaining and paidAmount', () {
      final FriendsRepository repo = FriendsRepository();

      // tx2 (amount 15,000, paid 0)
      repo.settle('tx2', 5000.0, FriendSettleMethod.cash);

      final FriendTransaction tx2 = repo.transactionById('tx2')!;
      expect(tx2.paidAmount, 5000.0);
      expect(tx2.remaining, 10000.0);
      expect(tx2.status, FriendTxStatus.partial);
    });
  });

  group('FriendsRepository Cascade Deletion', () {
    test(
      'deleteTransaction cascades deletion to all associated settlements',
      () {
        final FriendsRepository repo = FriendsRepository();
        expect(repo.settlementsOf('tx1').length, 2);

        final bool deleted = repo.deleteTransaction('tx1');
        expect(deleted, isTrue);
        expect(repo.transactionById('tx1'), isNull);
        expect(repo.settlementsOf('tx1'), isEmpty);
      },
    );

    test(
      'deleteFriend cascades deletion to friend, transactions, and settlements',
      () {
        final FriendsRepository repo = FriendsRepository();
        expect(repo.friendById('fr1'), isNotNull);
        expect(repo.transactionsOf('fr1').length, 2);
        expect(repo.settlementsOf('tx1').length, 2);

        final bool deleted = repo.deleteFriend('fr1');
        expect(deleted, isTrue);
        expect(repo.friendById('fr1'), isNull);
        expect(repo.transactionsOf('fr1'), isEmpty);
        expect(repo.settlementsOf('tx1'), isEmpty);
      },
    );
  });

  group('Pure Filter Helpers', () {
    test('filterFriends filters by query text and FriendNetFilter', () {
      final FriendsRepository repo = FriendsRepository();
      final List<Friend> friends = repo.friends;

      // Query filter
      final List<Friend> karimMatches = filterFriends(friends, query: 'karim');
      expect(karimMatches.length, 1);
      expect(karimMatches.first.name, 'Karim Boualam');

      final List<Friend> phoneMatches = filterFriends(friends, query: '661 45');
      expect(phoneMatches.length, 1);
      expect(phoneMatches.first.name, 'Yacine Mebarki');

      // Net filters
      final List<Friend> owedToMe = filterFriends(
        friends,
        filter: FriendNetFilter.owedToMe,
        balanceLookup: repo.friendBalance,
      );
      expect(
        owedToMe.map((Friend f) => f.id),
        containsAll(<String>['fr1', 'fr2']),
      );

      final List<Friend> iOwe = filterFriends(
        friends,
        filter: FriendNetFilter.iOwe,
        balanceLookup: repo.friendBalance,
      );
      expect(iOwe.map((Friend f) => f.id), containsAll(<String>['fr3']));

      final List<Friend> settled = filterFriends(
        friends,
        filter: FriendNetFilter.settled,
        balanceLookup: repo.friendBalance,
      );
      expect(settled.map((Friend f) => f.id), containsAll(<String>['fr4']));
    });

    test(
      'filterTransactions filters by query, directions, status, and type',
      () {
        final FriendsRepository repo = FriendsRepository();
        final List<FriendTransaction> txs = repo.transactions;

        String nameOf(String id) => repo.friendById(id)?.name ?? '';

        // Query matching description
        final List<FriendTransaction> hostingSplit = filterTransactions(
          txs,
          query: 'hosting bill split',
          nameOf: nameOf,
        );
        expect(hostingSplit.length, 1);
        expect(hostingSplit.first.id, 'tx3');

        // Query matching friend name
        final List<FriendTransaction> karimTxs = filterTransactions(
          txs,
          query: 'Karim',
          nameOf: nameOf,
        );
        expect(karimTxs.length, 2);

        // Direction filter
        final List<FriendTransaction> lentTxs = filterTransactions(
          txs,
          directions: FriendTxDirection.lent,
        );
        expect(lentTxs.length, 4);

        final List<FriendTransaction> borrowedTxs = filterTransactions(
          txs,
          directions: FriendTxDirection.borrowed,
        );
        expect(borrowedTxs.length, 1);

        // Status filter
        final List<FriendTransaction> partialTxs = filterTransactions(
          txs,
          status: FriendTxStatus.partial,
        );
        expect(partialTxs.length, 1);
        expect(partialTxs.first.id, 'tx1');

        final List<FriendTransaction> settledTxs = filterTransactions(
          txs,
          status: FriendTxStatus.settled,
        );
        expect(settledTxs.length, 1);
        expect(settledTxs.first.id, 'tx4');

        // Type filter
        final List<FriendTransaction> serviceTxs = filterTransactions(
          txs,
          type: FriendTxType.service,
        );
        expect(serviceTxs.length, 1);
        expect(serviceTxs.first.description, 'Frontend UI design');

        final List<FriendTransaction> expenseTxs = filterTransactions(
          txs,
          type: FriendTxType.expense,
        );
        expect(expenseTxs.length, 1);
        expect(expenseTxs.first.description, 'Server hosting bill');
      },
    );
  });

  group('Friends Widgets & 390x844 Surface', () {
    testWidgets(
      'FriendCard renders name, phone, avatar, net chip, counts, and handles tap',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final Friend friend = Friend(
          id: 'fr1',
          name: 'Karim Boualam',
          phone: '+213 550 12 34 56',
          createdAt: DateTime(2026, 8, 1),
          avatarColorIndex: 0,
        );
        final FriendBalance balance = FriendBalance(
          net: 45000.0,
          owedToYou: 45000.0,
          youOwe: 0.0,
          active: 2,
          settled: 0,
          lastActivity: DateTime(2026, 10, 5),
        );

        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FriendCard(
                  friend: friend,
                  balance: balance,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Karim Boualam'), findsOneWidget);
        expect(find.text('+213 550 12 34 56'), findsOneWidget);
        expect(find.text('K'), findsOneWidget); // avatar initial
        expect(find.text('Owed 45,000 DZ'), findsOneWidget);
        expect(find.text('2 active • 0 settled'), findsOneWidget);
        expect(find.text('Last: 2026-10-05'), findsOneWidget);

        await tester.tap(find.byType(FriendCard));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'FriendTxCard renders type glyph, amount, chips, and Settle button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final FriendTransaction pendingTx = FriendTransaction(
          id: 'tx1',
          friendId: 'fr1',
          type: FriendTxType.money,
          direction: FriendTxDirection.lent,
          amount: 50000.0,
          paidAmount: 20000.0,
          description: 'Cash via BaridiMob',
          date: DateTime(2026, 9, 2),
          dueDate: DateTime(2026, 11, 2),
        );

        bool settledClicked = false;
        bool cardClicked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: FriendTxCard(
                  transaction: pendingTx,
                  friendName: 'Karim Boualam',
                  showFriend: true,
                  onTap: () => cardClicked = true,
                  onSettle: () => settledClicked = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Cash via BaridiMob'), findsOneWidget);
        expect(find.text('50,000 DZ'), findsOneWidget);
        expect(find.text(r'$'), findsOneWidget);
        expect(
          find.text('Karim Boualam • Money loan • 2026-09-02'),
          findsOneWidget,
        );
        expect(find.text('Lent'), findsOneWidget);
        expect(find.text('Partial'), findsOneWidget);
        expect(find.text('Due 11-02'), findsOneWidget);
        expect(find.text('Settle'), findsOneWidget);
        expect(find.text('Paid 20,000 DZ'), findsOneWidget);
        expect(find.text('Remaining 30,000 DZ'), findsOneWidget);

        await tester.tap(find.text('Settle'));
        expect(settledClicked, isTrue);

        await tester.tap(find.byType(FriendTxCard));
        expect(cardClicked, isTrue);
      },
    );

    testWidgets(
      'FriendTxCard hides Settle button and shows green Settled when fully paid',
      (WidgetTester tester) async {
        final FriendTransaction settledTx = FriendTransaction(
          id: 'tx4',
          friendId: 'fr4',
          type: FriendTxType.money,
          direction: FriendTxDirection.lent,
          amount: 8000.0,
          paidAmount: 8000.0,
          description: 'Lunch and taxi',
          date: DateTime(2026, 8, 14),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: FriendTxCard(transaction: settledTx)),
            ),
          ),
        );

        expect(find.text('Settle'), findsNothing);
        expect(find.text('Paid 8,000 DZ'), findsOneWidget);
        expect(find.text('Settled'), findsWidgets);
      },
    );

    testWidgets('FriendBalanceCard renders overall and statement variants', (
      WidgetTester tester,
    ) async {
      final OverallBalance overall = OverallBalance(
        net: 58000.0,
        owedToYou: 70000.0,
        youOwe: 12000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FriendBalanceCard.overall(balance: overall)),
          ),
        ),
      );

      expect(find.text('Overall net balance'), findsOneWidget);
      expect(find.text('+58,000 DZ'), findsOneWidget);
      expect(find.text('Owed to you 70,000 DZ'), findsOneWidget);
      expect(find.text('You owe 12,000 DZ'), findsOneWidget);

      final FriendBalance friendBal = FriendBalance(
        net: 45000.0,
        owedToYou: 45000.0,
        youOwe: 0.0,
        active: 2,
        settled: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FriendBalanceCard.statement(balance: friendBal),
            ),
          ),
        ),
      );

      expect(find.text('Net balance'), findsOneWidget);
      expect(find.text('Owed to you'), findsOneWidget);
      expect(find.text('45,000 DZ'), findsOneWidget);
    });

    testWidgets(
      'showSettleSheet displays modal bottom sheet with settlement form',
      (WidgetTester tester) async {
        final FriendsRepository repo = FriendsRepository();
        await tester.pumpWidget(
          FriendsScope(
            repository: repo,
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton(
                      onPressed: () =>
                          showSettleSheet(context, transactionId: 'tx1'),
                      child: const Text('Open Settle'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Settle'));
        await tester.pumpAndSettle();

        expect(find.text('Record settlement'), findsOneWidget);
      },
    );
  });

  group('MoreScreen & Friends Routes Navigation on 390x844 Surface', () {
    Future<(FriendsRepository, GoRouter)> pumpApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.morePath,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
      final ExpensesRepository expensesRepo = ExpensesRepository();
      final FriendsRepository friendsRepo = FriendsRepository();
      final GoRouter router = createAppRouter(initialLocation: initialLocation);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clientsRepo,
          projectsRepository: projectsRepo,
          expensesRepository: expensesRepo,
          friendsRepository: friendsRepo,
        ),
      );
      await tester.pumpAndSettle();
      return (friendsRepo, router);
    }

    testWidgets(
      'Tapping Friends debts row in MoreScreen navigates to /friends and back',
      (WidgetTester tester) async {
        await pumpApp(tester, initialLocation: AppRoutes.morePath);

        expect(find.byType(MoreScreen), findsOneWidget);
        expect(find.text(MoreStrings.friendsDebtsTitle), findsOneWidget);

        // Tap Friends' debts row
        await tester.tap(find.text(MoreStrings.friendsDebtsTitle));
        await tester.pumpAndSettle();

        // Navigated to FriendsScreen
        expect(find.byType(FriendsScreen), findsOneWidget);
        expect(find.text('FriendsScreen'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Back on MoreScreen
        expect(find.byType(MoreScreen), findsOneWidget);
      },
    );

    testWidgets('Placeholder screens render for all friends debt routes', (
      WidgetTester tester,
    ) async {
      // 1. /friends/new
      await pumpApp(tester, initialLocation: AppRoutes.addFriendPath);
      expect(find.byType(AddFriendScreen), findsOneWidget);
      expect(find.text('AddFriendScreen'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);

      // 2. /friends/transactions/new
      await pumpApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );
      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(find.text('TransactionFormScreen'), findsOneWidget);

      // 3. /friends/transactions/:id
      await pumpApp(tester, initialLocation: '/friends/transactions/tx1');
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
      expect(find.text('Cash via BaridiMob'), findsOneWidget);

      // 4. /friends/:id
      await pumpApp(tester, initialLocation: '/friends/fr1');
      expect(find.byType(FriendStatementScreen), findsOneWidget);
      expect(find.text('FriendStatementScreen'), findsOneWidget);
    });
  });
}
