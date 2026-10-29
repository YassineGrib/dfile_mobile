import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/more/more_screen.dart';
import 'package:dfile_mobile/features/payments/payment_receipt_screen.dart';
import 'package:dfile_mobile/features/payments/payments_list_screen.dart';
import 'package:dfile_mobile/features/payments/payments_list_strings.dart';
import 'package:dfile_mobile/features/payments/record_payment_screen.dart';
import 'package:dfile_mobile/features/payments/widgets/payments_list_card.dart';
import 'package:dfile_mobile/features/payments/widgets/payments_list_kpis.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PaymentsListScreen tests on 390x844 surface', () {
    Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpPaymentsApp(
      WidgetTester tester, {
      String initialLocation = AppRoutes.paymentsPath,
      Size surfaceSize = const Size(390, 844),
      List<ProjectPayment>? initialPayments,
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
        initialPayments: initialPayments,
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

    testWidgets(
      'KPI tiles, header, and count match repository paymentStats',
      (WidgetTester tester) async {
        final (_, repo, _) = await pumpPaymentsApp(tester);
        final PaymentStats stats = repo.paymentStats();

        // Header
        expect(find.text(PaymentsListStrings.title), findsOneWidget);
        expect(
          find.text(PaymentsListStrings.paymentsRecorded(repo.allPayments.length)),
          findsOneWidget,
        );

        // 4 KPI tiles
        expect(find.byType(PaymentsListKpis), findsOneWidget);
        expect(find.text(PaymentsListStrings.collected), findsOneWidget);
        expect(find.text('665,000 DZ'), findsOneWidget);
        expect(find.text(PaymentsListStrings.outstanding), findsOneWidget);
        expect(find.text('420,000 DZ'), findsOneWidget);
        expect(find.text(PaymentsListStrings.thisMonth), findsOneWidget);
        expect(find.text('60,000 DZ'), findsOneWidget);
        expect(find.text(PaymentsListStrings.collectionRate), findsOneWidget);
        expect(find.text('${stats.collectionRate}%'), findsOneWidget);

        // Count row
        expect(
          find.text(PaymentsListStrings.paymentsCount(repo.allPayments.length)),
          findsOneWidget,
        );
        expect(find.text('Sort: Newest ▾'), findsOneWidget);

        // Payments rendered
        expect(find.byType(PaymentsListCard), findsWidgets);
        expect(find.text('Sarah Benali'), findsOneWidget);
        expect(find.text('Brand Identity'), findsOneWidget);

        // Scroll to bottom to verify subsequent payments rendered
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('Logo Pack'), findsOneWidget);

        // Bottom tab bar has More active
        final AppTabBar tabBar = tester.widget<AppTabBar>(find.byType(AppTabBar));
        expect(tabBar.currentIndex, AppTabBar.moreTabIndex);
      },
    );

    testWidgets(
      'Search filters payments by client name, project name, reference, and notes (case-insensitive)',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        final Finder searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);

        // Search by client name "sarah" (case-insensitive)
        await tester.enterText(searchField, 'sarah');
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('Sarah Benali'), findsOneWidget);
        expect(find.text('Brand Identity'), findsOneWidget);

        // Search by project name "fintask"
        await tester.enterText(searchField, 'FINTASK');
        await tester.pumpAndSettle();
        expect(find.text('3 payments'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsWidgets);

        // Search by reference "WIRE-7783"
        await tester.enterText(searchField, 'wire-7783');
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('+320,000 DZ'), findsOneWidget);
        expect(find.text('WIRE-7783'), findsOneWidget);

        // Search by notes "milestone delivery"
        await tester.enterText(searchField, 'milestone delivery');
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('TXN-928471'), findsOneWidget);
        expect(find.text('+100,000 DZ'), findsOneWidget);

        // Clear search restores all 6 cards
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
        expect(find.text('6 payments'), findsOneWidget);
        expect(find.text('Sarah Benali'), findsOneWidget);
      },
    );

    testWidgets(
      'Method filter pills filter payments correctly and horizontally scroll without error',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        final Finder pillsScrollView = find.byKey(const Key('payment-method-pills'));
        expect(pillsScrollView, findsOneWidget);

        // BaridiMob filter (Advance 60k, Milestone 85k, Advance 100k) -> 3 payments
        await tester.tap(find.widgetWithText(AppPill, PaymentsListStrings.filterBaridimob));
        await tester.pumpAndSettle();
        expect(find.text('3 payments'), findsOneWidget);
        expect(find.text('Brand Identity'), findsOneWidget);

        // CCP filter (Milestone 60k) -> 1 payment
        await tester.tap(find.widgetWithText(AppPill, PaymentsListStrings.filterCcp));
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('CCP-5521'), findsOneWidget);

        // Horizontally scroll pills to bring Bank and Cash into view
        await tester.drag(pillsScrollView, const Offset(-150, 0));
        await tester.pumpAndSettle();

        // Bank wire filter (Final 320k) -> 1 payment
        await tester.tap(find.widgetWithText(AppPill, PaymentsListStrings.filterBank));
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('WIRE-7783'), findsOneWidget);
        expect(find.text('+320,000 DZ'), findsOneWidget);

        // Cash filter (Final 40k) -> 1 payment
        await tester.tap(find.widgetWithText(AppPill, PaymentsListStrings.filterCash));
        await tester.pumpAndSettle();
        expect(find.text('1 payment'), findsOneWidget);
        expect(find.text('Logo Pack'), findsOneWidget);
        expect(find.text('+40,000 DZ'), findsOneWidget);

        // Scroll back to All and select it
        await tester.drag(pillsScrollView, const Offset(200, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(AppPill, PaymentsListStrings.filterAll));
        await tester.pumpAndSettle();
        expect(find.text('6 payments'), findsOneWidget);
        expect(find.text('Sarah Benali'), findsOneWidget);
      },
    );

    testWidgets(
      'Sort sheet applies each sort order: newest, oldest, highest, lowest amount',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        // Verify default order: Newest first (Sarah Benali 2026-10-12 is first)
        List<PaymentsListCard> cards = tester
            .widgetList<PaymentsListCard>(find.byType(PaymentsListCard))
            .toList();
        expect(cards.first.payment.date, DateTime(2026, 10, 12));
        expect(cards.first.payment.reference, 'TXN-552104');

        // Open sort sheet and select Oldest first
        await tester.tap(find.text('Sort: Newest ▾'));
        await tester.pumpAndSettle();
        expect(find.text(PaymentsListStrings.sortSheetTitle), findsOneWidget);

        await tester.tap(find.text(PaymentsListStrings.sortOldestFirst));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Oldest ▾'), findsOneWidget);

        cards = tester
            .widgetList<PaymentsListCard>(find.byType(PaymentsListCard))
            .toList();
        expect(cards.first.payment.date, DateTime(2026, 4, 2));
        expect(cards.first.payment.reference, 'TXN-928471');

        // Open sort sheet and select Highest amount
        await tester.tap(find.text('Sort: Oldest ▾'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(PaymentsListStrings.sortHighestAmount));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Highest ▾'), findsOneWidget);

        cards = tester
            .widgetList<PaymentsListCard>(find.byType(PaymentsListCard))
            .toList();
        expect(cards.first.payment.amount, 320000.0);
        expect(cards.first.payment.reference, 'WIRE-7783');

        // Open sort sheet and select Lowest amount
        await tester.tap(find.text('Sort: Highest ▾'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(PaymentsListStrings.sortLowestAmount));
        await tester.pumpAndSettle();
        expect(find.text('Sort: Lowest ▾'), findsOneWidget);

        cards = tester
            .widgetList<PaymentsListCard>(find.byType(PaymentsListCard))
            .toList();
        expect(cards.first.payment.amount, 40000.0);
        expect(cards.first.payment.reference, '');
      },
    );

    testWidgets(
      'Empty state (zero payments recorded) matches PY3 and navigates to /payments/new',
      (WidgetTester tester) async {
        final (_, repo, _) = await pumpPaymentsApp(
          tester,
          initialPayments: <ProjectPayment>[],
        );
        final PaymentStats stats = repo.paymentStats();

        // Header shows 0 payments recorded
        expect(find.text(PaymentsListStrings.paymentsRecorded(0)), findsOneWidget);

        // KPIs match repo stats (Collected and This month are 0 DZ)
        expect(find.text('0 DZ'), findsNWidgets(2));
        expect(find.text(formatMoney(stats.outstanding)), findsOneWidget);
        expect(find.text('${stats.collectionRate}%'), findsOneWidget);

        // Count row
        expect(find.text('0 payments'), findsOneWidget);

        // Empty card & button per PY3
        expect(find.text(PaymentsListStrings.emptyTitle), findsOneWidget);
        expect(find.text(PaymentsListStrings.emptySubtitle), findsOneWidget);
        expect(find.text(PaymentsListStrings.recordFirstPayment), findsOneWidget);
        expect(find.byType(PaymentsListCard), findsNothing);

        // Scroll down to tap [+ Record first payment]
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(PaymentsListStrings.recordFirstPayment));
        await tester.pumpAndSettle();

        expect(find.byType(RecordPaymentScreen), findsOneWidget);
        expect(find.text('RecordPaymentScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Filter empty state shows friendly message and [Clear filters] resets search and pills',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        final Finder searchField = find.byType(TextField);
        await tester.enterText(searchField, 'nonexistent_query_string');
        await tester.pumpAndSettle();

        // Empty filter state
        expect(find.text(PaymentsListStrings.emptyFilterTitle), findsOneWidget);
        expect(find.text(PaymentsListStrings.emptyFilterSubtitle), findsOneWidget);
        expect(find.text(PaymentsListStrings.clearFilters), findsOneWidget);
        expect(find.byType(PaymentsListCard), findsNothing);

        // Scroll down to tap [Clear filters]
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text(PaymentsListStrings.clearFilters));
        await tester.pumpAndSettle();

        // List is restored
        expect(find.text('6 payments'), findsOneWidget);
        expect(find.text('Sarah Benali'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping a payment card pushes receipt route /payments/:id (placeholder)',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        // Tap the first card (Sarah Benali / Brand Identity TXN-552104)
        await tester.tap(find.byType(PaymentsListCard).first);
        await tester.pumpAndSettle();

        expect(find.byType(PaymentReceiptScreen), findsOneWidget);
        expect(find.text('PaymentReceiptScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping "+" in header navigates to record route /payments/new (placeholder)',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        // The "+" round icon button is in the header
        final Finder addButton = find.widgetWithIcon(RoundIconButton, Icons.add);
        expect(addButton, findsOneWidget);

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(find.byType(RecordPaymentScreen), findsOneWidget);
        expect(find.text('RecordPaymentScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'Back button pops or navigates to /more fallback when stack cannot pop',
      (WidgetTester tester) async {
        await pumpPaymentsApp(tester);

        // Back button is the arrow_back RoundIconButton
        final Finder backButton = find.widgetWithIcon(RoundIconButton, Icons.arrow_back);
        expect(backButton, findsOneWidget);

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(find.byType(MoreScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Toast via GoRouterState.extra works for both Map and plain String payloads',
      (WidgetTester tester) async {
        final (_, _, GoRouter router) = await pumpPaymentsApp(tester);

        // Navigating with Map payload: {'toast': 'Payment deleted successfully'}
        router.go(
          AppRoutes.paymentsPath,
          extra: <String, Object?>{'toast': PaymentsListStrings.paymentDeletedToast},
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(PaymentsListStrings.paymentDeletedToast), findsOneWidget);

        // Wait for toast duration to auto-dismiss
        await tester.pump(const Duration(seconds: 4));
        expect(find.text(PaymentsListStrings.paymentDeletedToast), findsNothing);

        // Navigating with plain String payload: 'Payment recorded'
        router.go(
          AppRoutes.paymentsPath,
          extra: PaymentsListStrings.paymentRecordedToast,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(PaymentsListStrings.paymentRecordedToast), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        expect(find.text(PaymentsListStrings.paymentRecordedToast), findsNothing);
      },
    );

    testWidgets(
      'Renders on 360x800 surface without any layout overflow',
      (WidgetTester tester) async {
        // Populated list on 360x800
        await pumpPaymentsApp(
          tester,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(PaymentsListScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll down to ensure all cards render without overflow
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Also test empty state on 360x800
        await pumpPaymentsApp(
          tester,
          surfaceSize: const Size(360, 800),
          initialPayments: <ProjectPayment>[],
        );
        expect(find.text(PaymentsListStrings.emptyTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
