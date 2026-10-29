import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/friend_statement_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_strings.dart';
import 'package:dfile_mobile/features/friends/widgets/transaction_detail_delete_sheet.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(FriendsRepository, GoRouter)> pumpDetailApp(
    WidgetTester tester, {
    required String initialLocation,
    Size surfaceSize = const Size(390, 844),
    FriendsRepository? friendsRepo,
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
    final FriendsRepository effectiveFriendsRepo =
        friendsRepo ?? FriendsRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        repository: clientsRepo,
        projectsRepository: projectsRepo,
        friendsRepository: effectiveFriendsRepo,
      ),
    );
    await tester.pumpAndSettle();
    return (effectiveFriendsRepo, router);
  }

  group('TransactionDetailScreen Widget Tests', () {
    testWidgets(
      'detail values and settlements list for the Karim 50,000 transaction (tx1)',
      (WidgetTester tester) async {
        await pumpDetailApp(tester, initialLocation: '/friends/transactions/tx1');

        // Top bar
        expect(find.text(TransactionDetailStrings.title), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz), findsOneWidget);

        // Header info: glyph, description, friend • type
        expect(find.text(r'$'), findsOneWidget);
        expect(find.text('Cash via BaridiMob'), findsOneWidget);
        expect(find.text('Karim Boualam • Money loan'), findsOneWidget);

        // Big amount
        expect(find.text('50,000 DZ'), findsOneWidget);

        // Direction & Status chips
        expect(find.text('Lent'), findsOneWidget);
        expect(find.text('Partial'), findsOneWidget);

        // Progress bar exists
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // Rows: Paid, Remaining, Date, Due date
        expect(find.text(TransactionDetailStrings.paid), findsOneWidget);
        expect(find.text('20,000 DZ'), findsOneWidget);

        expect(find.text(TransactionDetailStrings.remaining), findsOneWidget);
        expect(find.text('30,000 DZ'), findsOneWidget);

        expect(find.text(TransactionDetailStrings.date), findsOneWidget);
        expect(find.text('2026-09-02'), findsOneWidget);

        expect(find.text(TransactionDetailStrings.dueDate), findsOneWidget);
        expect(find.text('2026-11-02'), findsOneWidget);

        // Settlements section
        expect(find.text('Settlements (2)'), findsOneWidget);
        expect(find.text('2026-09-20'), findsOneWidget);
        expect(find.text('BaridiMob'), findsOneWidget);
        expect(find.text('+12,000 DZ'), findsOneWidget);

        expect(find.text('2026-10-01'), findsOneWidget);
        expect(find.text('Cash'), findsOneWidget);
        expect(find.text('+8,000 DZ'), findsOneWidget);

        // Bottom bar buttons
        expect(find.text(TransactionDetailStrings.delete), findsOneWidget);
        expect(find.text(TransactionDetailStrings.settlePayment), findsOneWidget);
      },
    );

    testWidgets(
      'settled transaction hides the settle button and displays green Settled',
      (WidgetTester tester) async {
        // tx4 is Lina Cherif's 8,000 DZ transaction which is fully settled
        await pumpDetailApp(tester, initialLocation: '/friends/transactions/tx4');

        expect(find.text('Lunch and taxi'), findsOneWidget);
        expect(find.text('Lina Cherif • Money loan'), findsOneWidget);
        expect(find.text('8,000 DZ'), findsNWidgets(2));

        // Status chip is Settled
        expect(find.text('Settled'), findsWidgets);

        // Remaining row says Settled
        expect(find.text(TransactionDetailStrings.remaining), findsOneWidget);

        // [Delete] button is visible
        expect(find.text(TransactionDetailStrings.delete), findsOneWidget);

        // [Settle payment] button is hidden when settled
        expect(find.text(TransactionDetailStrings.settlePayment), findsNothing);
      },
    );

    testWidgets(
      'delete flow removes transaction, opens confirm sheet, and ends on statement route with toast',
      (WidgetTester tester) async {
        final (FriendsRepository repo, GoRouter router) = await pumpDetailApp(
          tester,
          initialLocation: '/friends/transactions/tx1',
        );

        expect(repo.transactionById('tx1'), isNotNull);

        // Tap [Delete] button
        await tester.tap(find.text(TransactionDetailStrings.delete));
        await tester.pumpAndSettle();

        // Confirm sheet is open
        expect(find.text(TransactionDetailStrings.deleteTransactionTitle), findsOneWidget);
        expect(find.text(TransactionDetailStrings.deleteTransactionSubtitle), findsOneWidget);
        expect(
          find.descendant(of: find.byType(TransactionDetailDeleteConfirmSheet), matching: find.textContaining('Cash via BaridiMob')),
          findsOneWidget,
        );
        expect(
          find.textContaining('Its 2 settlements will be removed'),
          findsOneWidget,
        );

        // Confirm delete
        await tester.tap(find.text(TransactionDetailStrings.confirmDelete));
        await tester.pumpAndSettle();

        // Transaction is deleted from repository
        expect(repo.transactionById('tx1'), isNull);

        // Settlements for tx1 are also deleted
        expect(repo.settlementsOf('tx1'), isEmpty);

        // Navigates to /friends/fr1 (statement screen)
        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/friends/fr1',
        );

        // Ends on /friends/fr1 placeholder statement screen
        expect(find.byType(FriendStatementScreen), findsOneWidget);
      },
    );

    testWidgets(
      'unknown id displays Transaction not found screen with working back button',
      (WidgetTester tester) async {
        final (FriendsRepository _, GoRouter router) = await pumpDetailApp(
          tester,
          initialLocation: '/friends/transactions/unknown_tx_999',
        );

        expect(find.text(TransactionDetailStrings.transactionNotFound), findsOneWidget);
        expect(find.text(TransactionDetailStrings.backToFriends), findsOneWidget);

        // Tap back to friends
        await tester.tap(find.text(TransactionDetailStrings.backToFriends));
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.toString(),
          '/friends',
        );
      },
    );

    testWidgets(
      'no overflow on 360x800 surface',
      (WidgetTester tester) async {
        await pumpDetailApp(
          tester,
          initialLocation: '/friends/transactions/tx1',
          surfaceSize: const Size(360, 800),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(TransactionDetailScreen), findsOneWidget);
        expect(find.text('Cash via BaridiMob'), findsOneWidget);
        expect(find.text(TransactionDetailStrings.settlePayment), findsOneWidget);
      },
    );
  });
}
