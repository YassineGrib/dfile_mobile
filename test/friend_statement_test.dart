import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/friend_statement_screen.dart';
import 'package:dfile_mobile/features/friends/friend_statement_strings.dart';
import 'package:dfile_mobile/features/friends/friends_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_form_screen.dart';
import 'package:dfile_mobile/features/friends/widgets/widgets.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(FriendsRepository, GoRouter)> pumpFriendApp(
    WidgetTester tester, {
    required String initialLocation,
    Size surfaceSize = const Size(390, 844),
    FriendsRepository? friendsRepo,
    Object? initialExtra,
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final FriendsRepository effectiveFriendsRepo =
        friendsRepo ?? FriendsRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(router: router, friendsRepository: effectiveFriendsRepo),
    );
    if (initialExtra != null) {
      router.go(initialLocation, extra: initialExtra);
    }
    await tester.pumpAndSettle();
    return (effectiveFriendsRepo, router);
  }

  group('FriendStatementScreen Widget Tests', () {
    testWidgets('renders values for Karim (45,000 DZ net, 2 active)', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr1');

      // Top bar
      expect(find.text(FriendStatementStrings.title), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Friend header
      expect(find.text('Karim Boualam'), findsOneWidget);
      expect(find.text('+213 550 12 34 56'), findsOneWidget);

      // Net balance card & chip
      expect(find.text('Net balance'), findsOneWidget);
      expect(find.text('Owed to you'), findsWidgets); // chip + stat tile
      expect(find.text('45,000 DZ'), findsOneWidget);

      // 4 Stat tiles
      expect(find.text(FriendStatementStrings.owedToYou), findsWidgets);
      expect(find.text('45,000'), findsOneWidget);

      expect(find.text(FriendStatementStrings.youOwe), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2)); // youOwe: 0, settled: 0

      expect(find.text(FriendStatementStrings.active), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      expect(find.text(FriendStatementStrings.settled), findsOneWidget);
    });

    testWidgets('renders values for a settled friend (Lina Cherif)', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr4');

      // Friend header
      expect(find.text('Lina Cherif'), findsOneWidget);
      expect(find.text('+213 555 98 76 54'), findsOneWidget);

      // Net balance card & chip
      expect(find.text('Settled'), findsWidgets); // chip + stat tile
      expect(find.text('0 DZ'), findsOneWidget);

      // 4 Stat tiles
      expect(find.text(FriendStatementStrings.owedToYou), findsWidgets);
      expect(find.text(FriendStatementStrings.youOwe), findsOneWidget);
      expect(find.text(FriendStatementStrings.active), findsOneWidget);
      expect(find.text(FriendStatementStrings.settled), findsWidgets);

      // Lina has 0 owedToYou, 0 youOwe, 0 active, 1 settled
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets(
      'transaction cards present and tapping card navigates to detail',
      (WidgetTester tester) async {
        await pumpFriendApp(tester, initialLocation: '/friends/fr1');

        // Transactions list section header
        expect(
          find.text(FriendStatementStrings.transactionHistory),
          findsOneWidget,
        );
        expect(
          find.text(FriendStatementStrings.addTransactionShort),
          findsOneWidget,
        );

        // Both seeded transactions for Karim are present
        expect(find.byType(FriendTxCard), findsNWidgets(2));
        expect(find.text('Cash via BaridiMob'), findsOneWidget);
        expect(find.text('Frontend UI design'), findsOneWidget);

        // Tapping a transaction card pushes transaction detail
        await tester.tap(find.text('Cash via BaridiMob'));
        await tester.pumpAndSettle();

        expect(find.byType(TransactionDetailScreen), findsOneWidget);
      },
    );

    testWidgets('+ Add navigates with friendId in query parameters', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr1');

      expect(
        find.text(FriendStatementStrings.addTransactionShort),
        findsOneWidget,
      );
      await tester.tap(find.text(FriendStatementStrings.addTransactionShort));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionFormScreen), findsOneWidget);
    });

    testWidgets('actions sheet Add transaction navigates with friendId', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr1');

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(FriendStatementStrings.addTransaction), findsOneWidget);
      await tester.tap(find.text(FriendStatementStrings.addTransaction));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionFormScreen), findsOneWidget);
    });

    testWidgets('copy phone with a phone copies to Clipboard and shows toast', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr1');

      // Open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(FriendStatementStrings.copyPhoneNumber), findsOneWidget);
      await tester.tap(find.text(FriendStatementStrings.copyPhoneNumber));
      await tester.pump();

      expect(
        find.text(FriendStatementStrings.copiedPhoneToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('copy phone without a phone shows No phone number toast', (
      WidgetTester tester,
    ) async {
      final FriendsRepository repo = FriendsRepository();
      repo.addFriend(
        Friend(
          id: 'fr_no_phone',
          name: 'Samir NoPhone',
          phone: '',
          createdAt: DateTime(2026, 8, 1),
        ),
      );

      await pumpFriendApp(
        tester,
        initialLocation: '/friends/fr_no_phone',
        friendsRepo: repo,
      );

      // Open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(FriendStatementStrings.copyPhoneNumber), findsOneWidget);
      await tester.tap(find.text(FriendStatementStrings.copyPhoneNumber));
      await tester.pump();

      expect(
        find.text(FriendStatementStrings.noPhoneNumberToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets(
      'Open transactions in actions sheet navigates to /friends with extra',
      (WidgetTester tester) async {
        await pumpFriendApp(tester, initialLocation: '/friends/fr1');

        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        expect(
          find.text(FriendStatementStrings.openTransactions),
          findsOneWidget,
        );
        await tester.tap(find.text(FriendStatementStrings.openTransactions));
        await tester.pumpAndSettle();

        expect(find.byType(FriendsScreen), findsOneWidget);
      },
    );

    testWidgets('delete flow removes the friend and ends on /friends', (
      WidgetTester tester,
    ) async {
      final (FriendsRepository repo, GoRouter router) = await pumpFriendApp(
        tester,
        initialLocation: '/friends/fr1',
      );

      expect(repo.friendById('fr1'), isNotNull);

      // Open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Tap Delete friend -> opens delete confirm sheet
      expect(find.text(FriendStatementStrings.deleteFriend), findsOneWidget);
      await tester.tap(find.text(FriendStatementStrings.deleteFriend));
      await tester.pumpAndSettle();

      // Confirm sheet elements
      expect(
        find.text(FriendStatementStrings.deleteFriendTitle),
        findsOneWidget,
      );
      expect(
        find.text(FriendStatementStrings.deleteFriendSubtitle),
        findsOneWidget,
      );
      expect(
        find.text(
          FriendStatementStrings.deleteConfirmFriendName('Karim Boualam'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(FriendStatementStrings.deleteConfirmActiveWarning(2)),
        findsOneWidget,
      );

      // Tap Confirm delete
      await tester.tap(find.text(FriendStatementStrings.confirmDelete));
      await tester.pumpAndSettle();

      // Friend is deleted from repository
      expect(repo.friendById('fr1'), isNull);

      // Router ended on /friends
      expect(find.byType(FriendsScreen), findsOneWidget);
      expect(router.state.matchedLocation, AppRoutes.friendsPath);
    });

    testWidgets(
      'delete flow cancel button dismisses sheet without deleting friend',
      (WidgetTester tester) async {
        final (FriendsRepository repo, _) = await pumpFriendApp(
          tester,
          initialLocation: '/friends/fr1',
        );

        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        await tester.tap(find.text(FriendStatementStrings.deleteFriend));
        await tester.pumpAndSettle();

        expect(find.text(FriendStatementStrings.cancel), findsOneWidget);
        await tester.tap(find.text(FriendStatementStrings.cancel));
        await tester.pumpAndSettle();

        // Friend still exists
        expect(repo.friendById('fr1'), isNotNull);
        expect(find.byType(FriendStatementScreen), findsOneWidget);
      },
    );

    testWidgets('Settle button opens the sheet', (WidgetTester tester) async {
      await pumpFriendApp(tester, initialLocation: '/friends/fr1');

      final Finder settleButtons = find.text('Settle');
      expect(settleButtons, findsWidgets);

      await tester.tap(settleButtons.first);
      await tester.pumpAndSettle();

      // Settle sheet is shown
      expect(find.text('Record settlement'), findsOneWidget);
    });

    testWidgets(
      'screen shows updated numbers when repository updates after settle',
      (WidgetTester tester) async {
        final (FriendsRepository repo, _) = await pumpFriendApp(
          tester,
          initialLocation: '/friends/fr1',
        );

        // Initially net is 45,000 DZ, active is 2
        expect(find.text('45,000 DZ'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        // Settle tx2 completely (15,000 DZ)
        repo.settle('tx2', 15000.0, FriendSettleMethod.cash);
        await tester.pumpAndSettle();

        // Net should now be 30,000 DZ, active is 1, settled is 1
        expect(find.text('30,000 DZ'), findsOneWidget);
        expect(find.text('1'), findsNWidgets(2)); // active: 1, settled: 1
      },
    );

    testWidgets(
      'unknown friend id renders friendly Friend not found screen with back button',
      (WidgetTester tester) async {
        await pumpFriendApp(tester, initialLocation: '/friends/unknown_friend');

        expect(
          find.text(FriendStatementStrings.friendNotFound),
          findsOneWidget,
        );
        expect(find.text(FriendStatementStrings.backToFriends), findsOneWidget);

        await tester.tap(find.text(FriendStatementStrings.backToFriends));
        await tester.pumpAndSettle();

        expect(find.byType(FriendsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'renders friendly empty message when friend has no transactions',
      (WidgetTester tester) async {
        final FriendsRepository repo = FriendsRepository();
        repo.addFriend(
          Friend(
            id: 'fr_empty',
            name: 'Empty Friend',
            phone: '+213 555 00 00 00',
            createdAt: DateTime(2026, 8, 1),
          ),
        );

        await pumpFriendApp(
          tester,
          initialLocation: '/friends/fr_empty',
          friendsRepo: repo,
        );

        expect(
          find.text(FriendStatementStrings.noTransactions),
          findsOneWidget,
        );
        expect(find.byType(FriendTxCard), findsNothing);
      },
    );

    testWidgets('accepts toast via GoRouterState.extra and displays it', (
      WidgetTester tester,
    ) async {
      await pumpFriendApp(
        tester,
        initialLocation: '/friends/fr1',
        initialExtra: <String, Object?>{'toast': 'Settlement recorded'},
      );

      expect(find.text('Settlement recorded'), findsOneWidget);
    });

    testWidgets(
      '360x800 surface renders statement, actions sheet, and delete confirm sheet without overflow',
      (WidgetTester tester) async {
        await pumpFriendApp(
          tester,
          initialLocation: '/friends/fr1',
          surfaceSize: const Size(360, 800),
        );

        expect(tester.takeException(), isNull);

        // Open Actions sheet
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Open Delete confirm sheet
        await tester.tap(find.text(FriendStatementStrings.deleteFriend));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Cancel out
        await tester.tap(find.text(FriendStatementStrings.cancel));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
