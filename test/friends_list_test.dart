import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/add_friend_screen.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/friend_statement_screen.dart';
import 'package:dfile_mobile/features/friends/friends_list_strings.dart';
import 'package:dfile_mobile/features/friends/friends_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_screen.dart';
import 'package:dfile_mobile/features/friends/widgets/friend_card.dart';
import 'package:dfile_mobile/features/friends/widgets/friend_tx_card.dart';
import 'package:dfile_mobile/features/friends/widgets/friends_list_balance_card.dart';
import 'package:dfile_mobile/features/friends/widgets/friends_list_filter_sheet.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('FriendsScreen tests on 390x844 surface', () {
    Future<(ClientsRepository, ProjectsRepository, FriendsRepository, GoRouter)>
    pumpFriendsApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.friendsPath,
      Size surfaceSize = const Size(390, 844),
      List<Friend>? initialFriends,
      List<FriendTransaction>? initialTransactions,
      List<FriendSettlement>? initialSettlements,
    }) async {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final ClientsRepository clientsRepo = ClientsRepository();
      final ProjectsRepository projectsRepo = ProjectsRepository(
        clientsRepository: clientsRepo,
      );
      final FriendsRepository friendsRepo = FriendsRepository(
        initialFriends: initialFriends,
        initialTransactions: initialTransactions,
        initialSettlements: initialSettlements,
      );
      final GoRouter router = createAppRouter(initialLocation: initialLocation);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clientsRepo,
          projectsRepository: projectsRepo,
          friendsRepository: friendsRepo,
        ),
      );
      await tester.pumpAndSettle();
      return (clientsRepo, projectsRepo, friendsRepo, router);
    }

    testWidgets(
      'Header, balance card values, and initial friends count match repository overallBalance',
      (WidgetTester tester) async {
        final (_, _, friendsRepo, _) = await pumpFriendsApp(tester);
        final OverallBalance overall = friendsRepo.overallBalance();

        // Screen title and subtitle
        expect(find.text(FriendsListStrings.title), findsOneWidget);
        expect(
          find.text(
            FriendsListStrings.friendsCount(friendsRepo.friends.length),
          ),
          findsOneWidget,
        );

        // Overall net balance card
        expect(find.byType(FriendsListBalanceCard), findsOneWidget);
        expect(find.text(FriendsListStrings.overallNetBalance), findsOneWidget);
        expect(find.text('+58,000 DZ'), findsOneWidget);
        expect(find.text('Owed to you 70,000 DZ'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(FriendsListBalanceCard),
            matching: find.text('You owe 12,000 DZ'),
          ),
          findsOneWidget,
        );
        expect(overall.net, 58000.0);
        expect(overall.owedToYou, 70000.0);
        expect(overall.youOwe, 12000.0);

        // Friend cards are displayed
        expect(find.byType(FriendCard), findsWidgets);
        expect(find.text('Karim Boualam'), findsOneWidget);
        expect(find.text('Yacine Mebarki'), findsOneWidget);
      },
    );

    testWidgets(
      'Tab toggle switches between Friends and Transactions tabs while preserving search state',
      (WidgetTester tester) async {
        final (_, _, friendsRepo, _) = await pumpFriendsApp(tester);

        // Initially Friends tab
        expect(
          find.text(
            FriendsListStrings.friendsCount(friendsRepo.friends.length),
          ),
          findsOneWidget,
        );
        expect(find.byType(FriendCard), findsWidgets);

        // Switch to Transactions tab via SegmentedToggle
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        // Subtitle now shows transactions count
        expect(
          find.text(
            FriendsListStrings.transactionsCount(
              friendsRepo.transactions.length,
            ),
          ),
          findsNWidgets(2), // In header and in count row
        );
        expect(find.byType(FriendTxCard), findsWidgets);
        expect(find.byType(FriendCard), findsNothing);

        // Type in transactions search field
        await tester.enterText(find.byType(TextField), 'Server');
        await tester.pumpAndSettle();

        // Only 1 matching transaction (Server hosting bill)
        expect(find.byType(FriendTxCard), findsOneWidget);
        expect(find.text('Server hosting bill'), findsOneWidget);

        // Switch back to Friends tab
        await tester.tap(find.text(FriendsListStrings.tabFriends));
        await tester.pumpAndSettle();

        // Friends search is empty and shows friends
        expect(find.byType(FriendCard), findsWidgets);
        final TextField friendsField = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(friendsField.controller?.text, isEmpty);

        // Switch back to Transactions tab
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        // Preserved transactions search query "Server" and filtered list
        final TextField txField = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(txField.controller?.text, 'Server');
        expect(find.byType(FriendTxCard), findsOneWidget);
      },
    );

    testWidgets(
      'Friends tab search and net filter pills correctly filter friends',
      (WidgetTester tester) async {
        await pumpFriendsApp(tester);

        // Search by friend name
        await tester.enterText(find.byType(TextField), 'Karim');
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsOneWidget);
        expect(find.text('Karim Boualam'), findsOneWidget);
        expect(find.text('Yacine Mebarki'), findsNothing);

        // Clear search
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsWidgets);

        // Tap "Owe me" pill (net > 0: Karim and Yacine)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.pillOweMe),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsNWidgets(2));
        expect(find.text('Karim Boualam'), findsOneWidget);
        expect(find.text('Yacine Mebarki'), findsOneWidget);

        // Tap "I owe" pill (net < 0: Amine)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.pillIOwe),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsOneWidget);
        expect(find.text('Amine Saidi'), findsOneWidget);

        // Drag pills row to bring Settled pill into view
        await tester.drag(
          find.byKey(const Key('friend-net-pills')),
          const Offset(-150, 0),
        );
        await tester.pumpAndSettle();

        // Tap "Settled" pill (net == 0: Lina)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.pillSettled),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsOneWidget);
        expect(find.text('Lina Cherif'), findsOneWidget);

        // Drag pills row back to bring All pill into view
        await tester.drag(
          find.byKey(const Key('friend-net-pills')),
          const Offset(200, 0),
        );
        await tester.pumpAndSettle();

        // Tap "All" pill
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.pillAll),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsWidgets);
      },
    );

    testWidgets(
      'Transactions quick pills and filter sheet filter transactions accurately',
      (WidgetTester tester) async {
        await pumpFriendsApp(tester);

        // Switch to Transactions tab
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        // 5 initial transactions
        expect(find.byType(FriendTxCard), findsWidgets);

        // Tap "Owed to me" pill (lent: 4 transactions)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.txPillOwedToMe),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsWidgets);
        expect(find.text('Hosting bill split'), findsNothing); // borrowed

        // Tap "I owe" pill (borrowed: 1 transaction)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.txPillIOwe),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsOneWidget);
        expect(find.text('Hosting bill split'), findsOneWidget);

        // Drag pills row to bring Settled pill into view
        await tester.drag(
          find.byKey(const Key('tx-quick-pills')),
          const Offset(-150, 0),
        );
        await tester.pumpAndSettle();

        // Tap "Settled" pill (1 settled transaction: Lunch and taxi)
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.txPillSettled),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsOneWidget);
        expect(find.text('Lunch and taxi'), findsOneWidget);

        // Drag pills row back to bring All pill into view
        await tester.drag(
          find.byKey(const Key('tx-quick-pills')),
          const Offset(200, 0),
        );
        await tester.pumpAndSettle();

        // Tap "All" pill
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.txPillAll),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsWidgets);

        // Open filter sheet
        await tester.tap(find.text(FriendsListStrings.filter));
        await tester.pumpAndSettle();

        expect(find.byType(FriendsListFilterSheet), findsOneWidget);
        expect(find.text(FriendsListStrings.filterSheetTitle), findsOneWidget);

        // In filter sheet, select Nature: Shared costs
        await tester.tap(
          find.widgetWithText(AppPill, FriendsListStrings.natureExpense),
        );
        await tester.pumpAndSettle();

        // Apply filters
        await tester.tap(find.text(FriendsListStrings.applyFilters));
        await tester.pumpAndSettle();

        // Only 1 transaction is Shared cost (Server hosting bill)
        expect(find.byType(FriendTxCard), findsOneWidget);
        expect(find.text('Server hosting bill'), findsOneWidget);

        // Open filter sheet and Reset
        await tester.tap(find.text(FriendsListStrings.filter));
        await tester.pumpAndSettle();

        await tester.tap(find.text(FriendsListStrings.reset));
        await tester.pumpAndSettle();

        await tester.tap(find.text(FriendsListStrings.applyFilters));
        await tester.pumpAndSettle();

        expect(find.byType(FriendTxCard), findsWidgets);
      },
    );

    testWidgets(
      'Empty states and filter no-match states handle clearing and adding',
      (WidgetTester tester) async {
        // 1. Completely empty friends repository state
        await pumpFriendsApp(
          tester,
          initialFriends: <Friend>[],
          initialTransactions: <FriendTransaction>[],
          initialSettlements: <FriendSettlement>[],
        );

        expect(find.text(FriendsListStrings.emptyFriendsTitle), findsOneWidget);
        expect(
          find.text(FriendsListStrings.emptyFriendsSubtitle),
          findsOneWidget,
        );
        expect(find.text(FriendsListStrings.addFriendButton), findsOneWidget);

        // Drag down to ensure button is visible then tap [+ Add friend]
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        await tester.tap(find.text(FriendsListStrings.addFriendButton));
        await tester.pumpAndSettle();
        expect(find.byType(AddFriendScreen), findsOneWidget);
        expect(find.text('AddFriendScreen'), findsOneWidget);

        // 2. No-match friends filter state
        await pumpFriendsApp(tester);
        await tester.enterText(find.byType(TextField), 'NonExistentPerson');
        await tester.pumpAndSettle();

        expect(
          find.text(FriendsListStrings.emptyFriendsFilterTitle),
          findsOneWidget,
        );
        expect(find.text(FriendsListStrings.clearFilters), findsOneWidget);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        await tester.tap(find.text(FriendsListStrings.clearFilters));
        await tester.pumpAndSettle();
        expect(find.byType(FriendCard), findsWidgets);

        // 3. Empty transactions state
        await pumpFriendsApp(
          tester,
          initialTransactions: <FriendTransaction>[],
        );
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        expect(
          find.text(FriendsListStrings.emptyTransactionsTitle),
          findsOneWidget,
        );

        // 4. No-match transactions filter state
        await pumpFriendsApp(tester);
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'NonExistentTx');
        await tester.pumpAndSettle();

        expect(
          find.text(FriendsListStrings.emptyTransactionsFilterTitle),
          findsOneWidget,
        );
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
        await tester.tap(find.text(FriendsListStrings.clearFilters));
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsWidgets);
      },
    );

    testWidgets(
      'Taps navigate to statement, transaction detail, and add friend screen',
      (WidgetTester tester) async {
        await pumpFriendsApp(tester);

        // Tap first FriendCard (Karim Boualam) -> navigates to /friends/fr1
        await tester.tap(find.text('Karim Boualam'));
        await tester.pumpAndSettle();
        expect(find.byType(FriendStatementScreen), findsOneWidget);
        expect(find.text('Karim Boualam'), findsOneWidget);

        // Back to Friends
        await pumpFriendsApp(tester);

        // Tap "+" button in header -> navigates to /friends/new
        final Finder addButton = find.widgetWithIcon(
          RoundIconButton,
          Icons.add,
        );
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        expect(find.byType(AddFriendScreen), findsOneWidget);
        expect(find.text('Add new friend'), findsOneWidget);

        // Back to Friends, switch to Transactions
        await pumpFriendsApp(tester);
        await tester.tap(find.text(FriendsListStrings.tabTransactions));
        await tester.pumpAndSettle();

        // Tap a transaction card -> navigates to /friends/transactions/:id
        await tester.tap(find.byType(FriendTxCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(TransactionDetailScreen), findsOneWidget);
        expect(find.text('Cash via BaridiMob'), findsOneWidget);
      },
    );

    testWidgets('Settle button on transaction card opens the settle sheet', (
      WidgetTester tester,
    ) async {
      await pumpFriendsApp(tester);

      // Switch to Transactions tab
      await tester.tap(find.text(FriendsListStrings.tabTransactions));
      await tester.pumpAndSettle();

      // Find Settle buttons on non-settled transactions
      final Finder settleButtons = find.text(FriendsListStrings.settle);
      expect(settleButtons, findsWidgets);

      // Tap the first Settle button
      await tester.tap(settleButtons.first);
      await tester.pumpAndSettle();

      // Bottom sheet opens
      expect(find.text('Record settlement'), findsOneWidget);
    });

    testWidgets(
      'Toast via GoRouterState.extra works for Map, plain String, and tab switching',
      (WidgetTester tester) async {
        final (_, _, _, GoRouter router) = await pumpFriendsApp(tester);

        // Map payload: {'toast': 'Friend deleted successfully'}
        router.go(
          AppRoutes.friendsPath,
          extra: <String, Object?>{
            'toast': FriendsListStrings.friendDeletedToast,
          },
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          find.text(FriendsListStrings.friendDeletedToast),
          findsOneWidget,
        );

        // Wait to auto-dismiss
        await tester.pump(const Duration(seconds: 4));
        expect(find.text(FriendsListStrings.friendDeletedToast), findsNothing);

        // Plain String payload: 'Friend added'
        router.go(
          AppRoutes.friendsPath,
          extra: FriendsListStrings.friendAddedToast,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(FriendsListStrings.friendAddedToast), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        expect(find.text(FriendsListStrings.friendAddedToast), findsNothing);

        // Map payload with 'tab': 'transactions'
        router.go(
          AppRoutes.friendsPath,
          extra: <String, Object?>{'tab': 'transactions'},
        );
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.byType(FriendTxCard), findsWidgets);
      },
    );

    testWidgets('Renders on 360x800 surface without any layout overflow', (
      WidgetTester tester,
    ) async {
      await pumpFriendsApp(tester, surfaceSize: const Size(360, 800));

      expect(find.byType(FriendsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll Friends list on 360x800
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Transactions on 360x800
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text(FriendsListStrings.tabTransactions));
      await tester.pumpAndSettle();

      // Scroll Transactions list on 360x800
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Check empty states on 360x800
      await pumpFriendsApp(
        tester,
        surfaceSize: const Size(360, 800),
        initialFriends: <Friend>[],
        initialTransactions: <FriendTransaction>[],
      );
      expect(find.text(FriendsListStrings.emptyFriendsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
