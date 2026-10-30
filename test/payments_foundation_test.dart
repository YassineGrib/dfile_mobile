import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/auth/sign_in_screen.dart';
import 'package:dfile_mobile/features/clients/clients_list_screen.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/more/more_strings.dart';
import 'package:dfile_mobile/features/payments/payment_receipt_screen.dart';
import 'package:dfile_mobile/features/payments/payment_strings.dart';
import 'package:dfile_mobile/features/payments/payments_list_screen.dart';
import 'package:dfile_mobile/features/payments/record_payment_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Payment Enums & Labels', () {
    test('PaymentMethod enum has expected values and labels', () {
      expect(PaymentMethod.values, <PaymentMethod>[
        PaymentMethod.baridimob,
        PaymentMethod.ccp,
        PaymentMethod.bank,
        PaymentMethod.cash,
      ]);

      expect(PaymentMethod.baridimob.label, 'BaridiMob');
      expect(PaymentMethod.ccp.label, 'CCP');
      expect(PaymentMethod.bank.label, 'Bank wire');
      expect(PaymentMethod.cash.label, 'Cash');

      expect(PaymentStrings.methodLabel(PaymentMethod.baridimob), 'BaridiMob');
      expect(PaymentStrings.methodLabel(PaymentMethod.ccp), 'CCP');
      expect(PaymentStrings.methodLabel(PaymentMethod.bank), 'Bank wire');
      expect(PaymentStrings.methodLabel(PaymentMethod.cash), 'Cash');
    });

    test('PaymentType enum has expected values, aliases, and labels', () {
      expect(PaymentType.values, <PaymentType>[
        PaymentType.advance,
        PaymentType.milestone,
        PaymentType.final_,
        PaymentType.tip,
      ]);

      expect(PaymentType.advance.label, 'Advance');
      expect(PaymentType.milestone.label, 'Milestone');
      expect(PaymentType.final_.label, 'Final');
      expect(PaymentType.finalPayment, PaymentType.final_);
      expect(PaymentType.tip.label, 'Tip');

      expect(PaymentStrings.typeLabel(PaymentType.advance), 'Advance');
      expect(PaymentStrings.typeLabel(PaymentType.milestone), 'Milestone');
      expect(PaymentStrings.typeLabel(PaymentType.final_), 'Final');
      expect(PaymentStrings.typeLabel(PaymentType.tip), 'Tip');
    });

    test('ProjectPayment entity defaults and copyWith behaviour', () {
      final payment = ProjectPayment(
        id: 'p_test',
        projectId: 'p1',
        date: DateTime(2026, 10, 29),
        amount: 25000.0,
      );

      expect(payment.clientId, '');
      expect(payment.reference, '');
      expect(payment.notes, '');
      expect(payment.type, PaymentType.milestone);
      expect(payment.method, PaymentMethod.baridimob);
      expect(payment.createdAt, DateTime(2026, 10, 29));

      final updated = payment.copyWith(
        clientId: 'c1',
        reference: 'REF-1',
        notes: 'Initial deposit',
        type: PaymentType.advance,
        method: PaymentMethod.bank,
      );

      expect(updated.clientId, 'c1');
      expect(updated.reference, 'REF-1');
      expect(updated.notes, 'Initial deposit');
      expect(updated.type, PaymentType.advance);
      expect(updated.method, PaymentMethod.bank);
      expect(updated == payment, isFalse);
    });
  });

  group('ProjectsRepository Payments Management', () {
    late ClientsRepository clientsRepo;
    late ProjectsRepository repo;

    setUp(() {
      clientsRepo = ClientsRepository();
      repo = ProjectsRepository(clientsRepository: clientsRepo);
    });

    test('Loads exact 6-payment mock seed per SPEC.md', () {
      expect(repo.allPayments.length, 6);
      expect(repo.payments.length, 6);

      // Total collected across all 6 payments = 665,000 DZ
      expect(
        repo.allPayments.fold<double>(0.0, (sum, p) => sum + p.amount),
        665000.0,
      );

      // Fintask Landing Page (p1, c1) -> 3 payments: 100k, 85k, 60k = 245,000 DZ
      final p1Payments = repo.paymentsOf('p1');
      expect(p1Payments.length, 3);
      expect(
        p1Payments.map((p) => p.reference).toList(),
        <String>['TXN-928471', 'TXN-441872', 'CCP-5521'],
      );
      expect(p1Payments[0].type, PaymentType.advance);
      expect(p1Payments[0].method, PaymentMethod.baridimob);
      expect(p1Payments[0].notes, 'Received after the first milestone delivery.');
      expect(p1Payments[1].type, PaymentType.milestone);
      expect(p1Payments[1].method, PaymentMethod.baridimob);
      expect(p1Payments[2].type, PaymentType.milestone);
      expect(p1Payments[2].method, PaymentMethod.ccp);

      // Brand Identity (p2, c2) -> 60,000 DZ Advance BaridiMob
      final p2Payments = repo.paymentsOf('p2');
      expect(p2Payments.length, 1);
      expect(p2Payments[0].amount, 60000.0);
      expect(p2Payments[0].reference, 'TXN-552104');
      expect(p2Payments[0].type, PaymentType.advance);
      expect(p2Payments[0].method, PaymentMethod.baridimob);

      // Mobile App UI (p3, c1) -> 320,000 DZ Final Bank wire
      final p3Payments = repo.paymentsOf('p3');
      expect(p3Payments.length, 1);
      expect(p3Payments[0].amount, 320000.0);
      expect(p3Payments[0].reference, 'WIRE-7783');
      expect(p3Payments[0].type, PaymentType.final_);
      expect(p3Payments[0].method, PaymentMethod.bank);

      // Logo Pack (p4, c3) -> 40,000 DZ Final Cash, empty reference
      final p4Payments = repo.paymentsOf('p4');
      expect(p4Payments.length, 1);
      expect(p4Payments[0].amount, 40000.0);
      expect(p4Payments[0].reference, '');
      expect(p4Payments[0].type, PaymentType.final_);
      expect(p4Payments[0].method, PaymentMethod.cash);

      // Dashboard Redesign (p5, c2) -> 0 payments
      expect(repo.paymentsOf('p5'), isEmpty);
    });

    test('paymentStats computes collected, outstanding, thisMonth, collectionRate', () {
      final fixedNow = DateTime(2026, 10, 15);
      final stats = repo.paymentStats(now: fixedNow);

      // Total collected = 665,000 DZ
      expect(stats.collected, 665000.0);

      // Outstanding = non-cancelled (p1: 205k + p2: 120k + p3: 0 + p4: 0 + p5: 95k) = 420,000 DZ
      expect(stats.outstanding, 420000.0);

      // Oct 2026: only pay4 (2026-10-12, 60,000 DZ)
      expect(stats.thisMonth, 60000.0);

      // Collection rate = min(100, round(665,000 / 1,085,000 * 100)) = 61%
      expect(stats.collectionRate, 61);

      // May 2026 check: pay2 (May 18, 85k) + pay6 (May 20, 40k) = 125,000 DZ
      final mayStats = repo.paymentStats(now: DateTime(2026, 5, 20));
      expect(mayStats.thisMonth, 125000.0);

      // Month with no payments: Jan 2026 -> 0
      final janStats = repo.paymentStats(now: DateTime(2026, 1, 10));
      expect(janStats.thisMonth, 0.0);
    });

    test('paymentStats excludes cancelled projects from outstanding', () {
      final initialStats = repo.paymentStats(now: DateTime(2026, 10, 15));
      expect(initialStats.outstanding, 420000.0);

      // Change p2 (outstanding: 120,000 DZ) to cancelled
      repo.changeStatus('p2', ProjectStatus.cancelled);

      final updatedStats = repo.paymentStats(now: DateTime(2026, 10, 15));
      expect(updatedStats.outstanding, 300000.0);
    });

    test('paymentById finds payment by id or returns null', () {
      expect(repo.paymentById('pay1')?.reference, 'TXN-928471');
      expect(repo.paymentById('pay4')?.amount, 60000.0);
      expect(repo.paymentById('nonexistent_id'), isNull);
    });

    test('addPayment derives clientId if missing, stores all new fields, and syncs client', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      final newPayment = ProjectPayment(
        id: 'pay_custom',
        projectId: 'p2', // belongs to c2 (Sarah Benali)
        date: DateTime(2026, 10, 25),
        amount: 30000.0,
        reference: 'TXN-CUSTOM',
        type: PaymentType.milestone,
        method: PaymentMethod.ccp,
        notes: 'Second installment',
      );

      final result = repo.addPayment(newPayment);

      expect(notifications, 1);
      expect(result.clientId, 'c2'); // derived from project p2
      expect(repo.allPayments.length, 7);
      expect(repo.paid(repo.byId('p2')!), 90000.0);
      expect(repo.remaining(repo.byId('p2')!), 90000.0);

      // Client c2 in ClientsRepository has synced payments
      final Client sarah = clientsRepo.byId('c2')!;
      expect(sarah.payments.any((p) => p.reference == 'TXN-CUSTOM'), isTrue);
    });

    test('deletePayment removes payment, updates totals, syncs client, and notifies', () {
      int notifications = 0;
      repo.addListener(() => notifications++);

      // pay4 is for p2 (60,000 DZ, client c2)
      final bool removed = repo.deletePayment('pay4');
      expect(removed, isTrue);
      expect(notifications, 1);
      expect(repo.allPayments.length, 5);
      expect(repo.paymentById('pay4'), isNull);

      // p2 paid is now 0.0, remaining is 180,000.0
      expect(repo.paid(repo.byId('p2')!), 0.0);
      expect(repo.remaining(repo.byId('p2')!), 180000.0);

      // Overall collected reduced by 60,000 DZ
      expect(repo.paymentStats().collected, 605000.0);

      // Client c2 payments list in ClientsRepository no longer contains pay4
      final Client sarah = clientsRepo.byId('c2')!;
      expect(sarah.payments.any((p) => p.id == 'pay4'), isFalse);

      // Deleting non-existent payment returns false without notifying
      expect(repo.deletePayment('nonexistent'), isFalse);
      expect(notifications, 1);
    });
  });

  group('Formatters', () {
    test('formatDate and formatDateYyyyMmDd return yyyy-MM-dd', () {
      final date = DateTime(2026, 10, 29);
      expect(formatDate(date), '2026-10-29');
      expect(formatDateYyyyMmDd(date), '2026-10-29');
    });

    test('formatMoney formats amounts with commas and DZ suffix', () {
      expect(formatMoney(665000), '665,000 DZ');
      expect(formatMoney(0), '0 DZ');
      expect(formatMoney(420000.5), '420,001 DZ');
    });
  });

  group('MoreScreen & Route Navigation on 390x844 Surface', () {
    Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpPaymentsApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.morePath,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final clientsRepo = ClientsRepository();
      final projectsRepo = ProjectsRepository(clientsRepository: clientsRepo);
      final router = createAppRouter(initialLocation: initialLocation);

      await tester.pumpWidget(
        DfileApp(
          router: router,
          repository: clientsRepo,
          projectsRepository: projectsRepo,
        ),
      );
      await tester.pumpAndSettle();
      return (clientsRepo, projectsRepo, router);
    }

    testWidgets('MoreScreen renders PY1 title, subtitle, workspace card, 5 rows, and sign out', (
      WidgetTester tester,
    ) async {
      await pumpPaymentsApp(tester, initialLocation: AppRoutes.morePath);

      // Title & Subtitle
      expect(find.text(MoreStrings.title), findsWidgets);
      expect(find.text(MoreStrings.subtitle), findsOneWidget);

      // Workspace card
      expect(find.text(MoreStrings.workspaceTitle), findsOneWidget);
      expect(find.text(MoreStrings.workspaceSubtitle), findsOneWidget);

      // Payments row shows exact "<collected> DZ collected"
      expect(find.text(MoreStrings.paymentsTitle), findsOneWidget);
      expect(find.text('665,000 DZ collected'), findsOneWidget);

      // Other 4 menu rows
      expect(find.text(MoreStrings.expensesTitle), findsOneWidget);
      expect(find.text(MoreStrings.expensesSubtitle), findsOneWidget);
      expect(find.text(MoreStrings.invoicesTitle), findsOneWidget);
      expect(find.text(MoreStrings.invoicesSubtitle), findsOneWidget);
      expect(find.text(MoreStrings.friendsDebtsTitle), findsOneWidget);
      expect(find.text(MoreStrings.friendsDebtsSubtitle), findsOneWidget);
      expect(find.text(MoreStrings.settingsTitle), findsOneWidget);
      expect(find.text(MoreStrings.settingsSubtitle), findsOneWidget);

      // Sign out button
      expect(find.text(MoreStrings.signOut), findsOneWidget);

      // AppTabBar is visible with More active
      expect(find.byType(AppTabBar), findsOneWidget);
    });

    testWidgets('Tapping Payments row navigates to /payments placeholder and back', (
      WidgetTester tester,
    ) async {
      await pumpPaymentsApp(tester, initialLocation: AppRoutes.morePath);

      // Tap Payments row
      await tester.tap(find.text(MoreStrings.paymentsTitle));
      await tester.pumpAndSettle();

      // Placeholder screen is displayed
      expect(find.byType(PaymentsListScreen), findsOneWidget);
      expect(find.text('PaymentsListScreen'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Back on MoreScreen
      expect(find.byType(MoreScreen), findsOneWidget);
    });

    testWidgets('Tapping demo menu rows triggers Not available in demo toast', (
      WidgetTester tester,
    ) async {
      await pumpPaymentsApp(tester, initialLocation: AppRoutes.morePath);

      // Tap Invoices row
      await tester.tap(find.text(MoreStrings.invoicesTitle));
      await tester.pump();
      expect(find.text(MoreStrings.notAvailableInDemo), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(MoreStrings.notAvailableInDemo), findsNothing);
    });

    testWidgets('Tapping Sign out navigates to /sign-in', (WidgetTester tester) async {
      await pumpPaymentsApp(tester, initialLocation: AppRoutes.morePath);

      await tester.tap(find.text(MoreStrings.signOut));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('AppTabBar More tab navigates to /more from clients and projects screens', (
      WidgetTester tester,
    ) async {
      await pumpPaymentsApp(tester, initialLocation: AppRoutes.clientsPath);

      expect(find.byType(ClientsListScreen), findsOneWidget);

      // Tap More in AppTabBar
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('More'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MoreScreen), findsOneWidget);

      // Switch to Clients tab
      await tester.tap(
        find.descendant(
          of: find.byType(AppTabBar),
          matching: find.text('Clients'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClientsListScreen), findsOneWidget);
    });

    testWidgets('Routes /payments/new and /payments/:id render their placeholder screens', (
      WidgetTester tester,
    ) async {
      final (_, _, GoRouter router) = await pumpPaymentsApp(
        tester,
        initialLocation: '${AppRoutes.recordPaymentPath}?projectId=p1',
      );

      // Record payment placeholder
      expect(find.byType(RecordPaymentScreen), findsOneWidget);
      expect(find.text('RecordPaymentScreen'), findsOneWidget);

      // Payment receipt placeholder
      router.go('/payments/pay1');
      await tester.pumpAndSettle();

      expect(find.byType(PaymentReceiptScreen), findsOneWidget);
      expect(find.text('PaymentReceiptScreen'), findsOneWidget);
    });
  });
}
