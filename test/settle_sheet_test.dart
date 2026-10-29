import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/transaction_detail_strings.dart';
import 'package:dfile_mobile/features/friends/widgets/settle_sheet_content.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(FriendsRepository, GoRouter)> pumpSettleSheetApp(
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

  group('SettleSheet Widget Tests', () {
    testWidgets('validation (zero, too large, exact full)', (WidgetTester tester) async {
      final (FriendsRepository repo, _) = await pumpSettleSheetApp(
        tester,
        initialLocation: '/friends/transactions/tx1',
      );

      // tx1 remaining is 30,000 DZ (50,000 - 20,000)
      expect(repo.transactionById('tx1')?.remaining, 30000.0);

      // Open settle sheet
      await tester.tap(find.text(TransactionDetailStrings.settlePayment));
      await tester.pumpAndSettle();

      expect(find.byType(SettleSheet), findsOneWidget);
      expect(find.text(TransactionDetailStrings.recordSettlementTitle), findsOneWidget);

      final Finder amountInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          TransactionDetailStrings.settlementAmountLabel,
        ),
        matching: find.byType(TextField),
      );

      // 1. Enter 0 and tap Confirm -> error
      await tester.enterText(amountInput, '0');
      await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
      await tester.pumpAndSettle();

      expect(
        find.text(TransactionDetailStrings.errorValidAmount),
        findsOneWidget,
      );

      // 2. Enter too large amount (> 30,000) -> error
      await tester.enterText(amountInput, '35000');
      await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
      await tester.pumpAndSettle();

      expect(
        find.text(TransactionDetailStrings.errorExceedsRemaining),
        findsOneWidget,
      );

      // 3. Enter exact full remaining balance (30,000) -> success
      await tester.enterText(amountInput, '30000');
      await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
      await tester.pumpAndSettle();

      // Sheet closes
      expect(find.byType(SettleSheet), findsNothing);

      // Toast is displayed
      expect(
        find.text(TransactionDetailStrings.settlementRecordedToast),
        findsOneWidget,
      );

      // Transaction is now settled
      final FriendTransaction? updatedTx = repo.transactionById('tx1');
      expect(updatedTx?.paidAmount, 50000.0);
      expect(updatedTx?.remaining, 0.0);
      expect(updatedTx?.isSettled, isTrue);
    });

    testWidgets('100% full chip fills remaining amount', (WidgetTester tester) async {
      final (FriendsRepository _, _) = await pumpSettleSheetApp(
        tester,
        initialLocation: '/friends/transactions/tx1',
      );

      await tester.tap(find.text(TransactionDetailStrings.settlePayment));
      await tester.pumpAndSettle();

      expect(find.text(TransactionDetailStrings.full100Percent), findsOneWidget);

      // Tap 100% full
      await tester.tap(find.text(TransactionDetailStrings.full100Percent));
      await tester.pumpAndSettle();

      // Field should now have 30000
      expect(find.text('30000'), findsOneWidget);
    });

    testWidgets('offset method requires notes with inline error', (WidgetTester tester) async {
      final (FriendsRepository _, _) = await pumpSettleSheetApp(
        tester,
        initialLocation: '/friends/transactions/tx1',
      );

      await tester.tap(find.text(TransactionDetailStrings.settlePayment));
      await tester.pumpAndSettle();

      // Enter valid amount
      final Finder amountInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          TransactionDetailStrings.settlementAmountLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountInput, '5000');

      // Select Offset method
      await tester.tap(find.text(TransactionDetailStrings.methodOffset));
      await tester.pumpAndSettle();

      // Label changes to "Offset service details *"
      expect(
        find.text(TransactionDetailStrings.notesOffsetRequiredLabel),
        findsOneWidget,
      );

      // Attempt confirm without notes
      await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
      await tester.pumpAndSettle();

      // Error shown
      expect(
        find.text(TransactionDetailStrings.errorDescribeServiceOffset),
        findsOneWidget,
      );

      // Enter notes
      final Finder notesInput = find.descendant(
        of: find.widgetWithText(
          AppTextField,
          TransactionDetailStrings.notesOffsetRequiredLabel,
        ),
        matching: find.byType(TextField),
      );
      await tester.enterText(notesInput, 'Consulting service offset');
      await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
      await tester.pumpAndSettle();

      // Sheet closes successfully
      expect(find.byType(SettleSheet), findsNothing);
      expect(
        find.text(TransactionDetailStrings.settlementRecordedToast),
        findsOneWidget,
      );
    });

    testWidgets(
      'successful partial settle updates paid / remaining / status and updates detail screen',
      (WidgetTester tester) async {
        final (FriendsRepository repo, _) = await pumpSettleSheetApp(
          tester,
          initialLocation: '/friends/transactions/tx1',
        );

        // Before: paid 20,000 DZ, remaining 30,000 DZ
        expect(find.text('20,000 DZ'), findsWidgets);
        expect(find.text('30,000 DZ'), findsWidgets);

        await tester.tap(find.text(TransactionDetailStrings.settlePayment));
        await tester.pumpAndSettle();

        final Finder amountInput = find.descendant(
          of: find.widgetWithText(
            AppTextField,
            TransactionDetailStrings.settlementAmountLabel,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(amountInput, '5000');

        await tester.tap(find.text(TransactionDetailStrings.confirmSettlement));
        await tester.pumpAndSettle();

        // Repository updated
        final FriendTransaction? tx = repo.transactionById('tx1');
        expect(tx?.paidAmount, 25000.0);
        expect(tx?.remaining, 25000.0);
        expect(tx?.status, FriendTxStatus.partial);

        // Detail screen automatically rebuilt via FriendsScope listener
        expect(find.text('25,000 DZ'), findsWidgets);
        expect(find.text('Settlements (3)'), findsOneWidget);
        expect(find.text('+5,000 DZ'), findsOneWidget);
      },
    );

    testWidgets('cancel button closes sheet without modifying transaction', (
      WidgetTester tester,
    ) async {
      final (FriendsRepository repo, _) = await pumpSettleSheetApp(
        tester,
        initialLocation: '/friends/transactions/tx1',
      );

      await tester.tap(find.text(TransactionDetailStrings.settlePayment));
      await tester.pumpAndSettle();

      expect(find.byType(SettleSheet), findsOneWidget);

      await tester.tap(find.text(TransactionDetailStrings.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(SettleSheet), findsNothing);
      expect(repo.transactionById('tx1')?.paidAmount, 20000.0);
    });

    testWidgets('no overflow on 360x800 surface', (WidgetTester tester) async {
      await pumpSettleSheetApp(
        tester,
        initialLocation: '/friends/transactions/tx1',
        surfaceSize: const Size(360, 800),
      );

      await tester.tap(find.text(TransactionDetailStrings.settlePayment));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettleSheet), findsOneWidget);
      expect(find.text(TransactionDetailStrings.recordSettlementTitle), findsOneWidget);
    });
  });
}
