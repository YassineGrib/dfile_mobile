import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/payments/payment_receipt_strings.dart';
import 'package:dfile_mobile/features/payments/payments_list_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/projects/project_detail_screen.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpReceiptApp(
    WidgetTester tester, {
    required String initialLocation,
    Size surfaceSize = const Size(390, 844),
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
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

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

  group('PaymentReceiptScreen Widget Tests', () {
    testWidgets('renders values for a seeded payment (budget / paid / remaining)', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');

      // Top bar
      expect(find.text(PaymentReceiptStrings.title), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Receipt Card Header
      expect(find.text(PaymentReceiptStrings.officialReceipt), findsOneWidget);
      expect(find.text('2026-04-02'), findsNWidgets(2)); // Header date & Date row
      expect(find.text('PAY-2041'), findsOneWidget);

      // Amount & Type
      expect(find.text('+100,000 DZ'), findsOneWidget);
      expect(find.text('Advance payment'), findsOneWidget);

      // Metadata rows
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Mohamed Bachir'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Fintask Landing Page'), findsOneWidget);
      expect(find.text('Method'), findsOneWidget);
      expect(find.text('BaridiMob'), findsOneWidget);
      expect(find.text('Reference'), findsOneWidget);
      expect(find.text('TXN-928471'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);

      // Project Financials
      expect(find.text('Project budget'), findsOneWidget);
      expect(find.text('450,000 DZ'), findsOneWidget);
      expect(find.text('Paid to date'), findsOneWidget);
      expect(find.text('245,000 DZ'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('205,000 DZ'), findsOneWidget);

      // Bottom action bar
      expect(find.text(PaymentReceiptStrings.shareReceipt), findsOneWidget);
    });

    testWidgets('displays Cleared (green) when remaining balance is 0', (
      WidgetTester tester,
    ) async {
      // pay5: Mobile App UI (budget: 320,000, paid: 320,000, remaining: 0)
      await pumpReceiptApp(tester, initialLocation: '/payments/pay5');

      expect(find.text('+320,000 DZ'), findsOneWidget); // amount received
      expect(find.text('320,000 DZ'), findsNWidgets(2)); // budget & paid
      expect(find.text(PaymentReceiptStrings.cleared), findsOneWidget);
      expect(find.text('Final payment'), findsOneWidget);
    });

    testWidgets('notes shown only when present (pay1 has notes)', (
      WidgetTester tester,
    ) async {
      // pay1 has notes: "Received after the first milestone delivery."
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');
      expect(find.text(PaymentReceiptStrings.notes), findsOneWidget);
      expect(
        find.text('Received after the first milestone delivery.'),
        findsOneWidget,
      );
    });

    testWidgets('notes hidden when payment notes are empty (pay2 has no notes)', (
      WidgetTester tester,
    ) async {
      // pay2 has no notes
      await pumpReceiptApp(tester, initialLocation: '/payments/pay2');
      expect(find.text(PaymentReceiptStrings.notes), findsNothing);
    });

    testWidgets('copy reference copies to Clipboard and shows toast', (
      WidgetTester tester,
    ) async {
      // pay1 with reference "TXN-928471"
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');

      // Tap '...' button to open actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(PaymentReceiptStrings.copyReference), findsOneWidget);
      await tester.tap(find.text(PaymentReceiptStrings.copyReference));
      await tester.pump();

      expect(
        find.text(PaymentReceiptStrings.copiedReferenceToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('copy reference on payment with empty reference shows no reference toast', (
      WidgetTester tester,
    ) async {
      // pay6 has empty reference
      await pumpReceiptApp(tester, initialLocation: '/payments/pay6');
      expect(find.text(PaymentReceiptStrings.emptyReferenceDash), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text(PaymentReceiptStrings.copyReference));
      await tester.pump();

      expect(
        find.text(PaymentReceiptStrings.noReferenceToCopyToast),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('share receipt triggers demo toast from bottom bar', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');

      // Tap bottom bar button
      await tester.tap(find.widgetWithText(PrimaryButton, PaymentReceiptStrings.shareReceipt));
      await tester.pump();
      expect(
        find.text(PaymentReceiptStrings.demoNotAvailable),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('share receipt triggers demo toast from actions sheet', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');

      // Open actions sheet and tap Share receipt
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text(PaymentReceiptStrings.shareReceipt),
        ),
      );
      await tester.pump();
      expect(
        find.text(PaymentReceiptStrings.demoNotAvailable),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(AppToast), findsNothing);
    });

    testWidgets('go to project navigates to /projects/:projectId', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(tester, initialLocation: '/payments/pay1');

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text(PaymentReceiptStrings.goToProject), findsOneWidget);
      await tester.tap(find.text(PaymentReceiptStrings.goToProject));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.text('Fintask Landing Page'), findsOneWidget);
    });

    testWidgets(
      'delete flow removes the payment and ends on /payments with extra toast',
      (WidgetTester tester) async {
        final (_, ProjectsRepository repo, _) = await pumpReceiptApp(
          tester,
          initialLocation: '/payments/pay1',
        );

        expect(repo.paymentById('pay1'), isNotNull);

        // Open actions sheet
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();

        // Tap Delete payment -> opens delete confirm sheet
        await tester.tap(find.text(PaymentReceiptStrings.deletePayment));
        await tester.pumpAndSettle();

        expect(
          find.text(PaymentReceiptStrings.deletePaymentTitle),
          findsOneWidget,
        );
        expect(
          find.text(PaymentReceiptStrings.deletePaymentSubtitle),
          findsOneWidget,
        );
        expect(
          find.text(
            PaymentReceiptStrings.deleteWarningAmountClient(
              '100,000',
              'Mohamed Bachir',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.text(PaymentReceiptStrings.deleteWarningRecalculate),
          findsOneWidget,
        );

        // Tap Confirm delete
        await tester.tap(find.text(PaymentReceiptStrings.confirmDelete));
        await tester.pumpAndSettle();

        // Payment is deleted from repository
        expect(repo.paymentById('pay1'), isNull);

        // Router ended on /payments (PaymentsListScreen)
        expect(find.byType(PaymentsListScreen), findsOneWidget);
      },
    );

    testWidgets('unknown payment id renders friendly Payment not found screen', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(tester, initialLocation: '/payments/unknown_id');

      expect(find.text(PaymentReceiptStrings.paymentNotFound), findsOneWidget);
      expect(find.text(PaymentReceiptStrings.backToPayments), findsOneWidget);

      await tester.tap(find.text(PaymentReceiptStrings.backToPayments));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentsListScreen), findsOneWidget);
    });

    testWidgets('360x800 surface renders receipt, actions, and delete sheet with no overflow', (
      WidgetTester tester,
    ) async {
      await pumpReceiptApp(
        tester,
        initialLocation: '/payments/pay1',
        surfaceSize: const Size(360, 800),
      );

      expect(tester.takeException(), isNull);

      // Open Actions sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Open Delete confirm sheet
      await tester.tap(find.text(PaymentReceiptStrings.deletePayment));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Cancel out
      await tester.tap(find.text(PaymentReceiptStrings.cancel));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
