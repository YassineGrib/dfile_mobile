import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/payments/payments_list_screen.dart';
import 'package:dfile_mobile/features/payments/record_payment_screen.dart';
import 'package:dfile_mobile/features/payments/record_payment_strings.dart';
import 'package:dfile_mobile/features/payments/widgets/record_payment_fields.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpRecordPaymentApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.recordPaymentPath,
    Size surfaceSize = const Size(390, 844),
  }) async {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
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

  group('Record Payment Form', () {
    testWidgets(
      'validation errors (no client / no project / zero amount)',
      (WidgetTester tester) async {
        final (_, ProjectsRepository projectsRepo, _) =
            await pumpRecordPaymentApp(tester);

        expect(find.byType(RecordPaymentScreen), findsOneWidget);

        // Initially no errors shown
        expect(find.text(RecordPaymentStrings.clientRequiredError), findsNothing);
        expect(
          find.text(RecordPaymentStrings.projectRequiredError),
          findsNothing,
        );
        expect(find.text(RecordPaymentStrings.amountError), findsNothing);

        // Attempt to save empty form
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            RecordPaymentStrings.recordPaymentAction,
          ),
        );
        await tester.pumpAndSettle();

        // All 3 required errors should be displayed
        expect(
          find.text(RecordPaymentStrings.clientRequiredError),
          findsOneWidget,
        );
        expect(
          find.text(RecordPaymentStrings.projectRequiredError),
          findsOneWidget,
        );
        expect(find.text(RecordPaymentStrings.amountError), findsOneWidget);

        // Select a client (Mohamed Bachir)
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.payingClientLabel,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mohamed Bachir').last);
        await tester.pumpAndSettle();

        // Client error cleared, project error remains
        expect(find.text(RecordPaymentStrings.clientRequiredError), findsNothing);
        expect(
          find.text(RecordPaymentStrings.projectRequiredError),
          findsOneWidget,
        );

        // Select a project (Fintask Landing Page)
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.linkedProjectLabel,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fintask Landing Page').last);
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            RecordPaymentStrings.confirmProject,
          ),
        );
        await tester.pumpAndSettle();

        // Project error cleared, amount error remains
        expect(
          find.text(RecordPaymentStrings.projectRequiredError),
          findsNothing,
        );
        expect(find.text(RecordPaymentStrings.amountError), findsOneWidget);

        // Enter zero amount: error persists
        final Finder amountInput = find.descendant(
          of: find.widgetWithText(
            AppTextField,
            RecordPaymentStrings.amountLabel,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(amountInput, '0');
        await tester.pumpAndSettle();
        expect(find.text(RecordPaymentStrings.amountError), findsOneWidget);

        // Enter valid amount: error disappears immediately
        await tester.enterText(amountInput, '15000');
        await tester.pumpAndSettle();
        expect(find.text(RecordPaymentStrings.amountError), findsNothing);

        // Erasing to empty shows error again since field was touched
        await tester.enterText(amountInput, '');
        await tester.pumpAndSettle();
        expect(find.text(RecordPaymentStrings.amountError), findsOneWidget);

        // Verify no new payments were added to repository
        expect(projectsRepo.paymentsOf('p1').length, 3);
      },
    );

    testWidgets(
      'picker lists only the client\'s projects and changing client clears project',
      (WidgetTester tester) async {
        await pumpRecordPaymentApp(tester);

        // Select Sarah Benali (c2)
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.payingClientLabel,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sarah Benali').last);
        await tester.pumpAndSettle();

        // Open linked project picker
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.linkedProjectLabel,
          ),
        );
        await tester.pumpAndSettle();

        // Verify sheet title & subtitle
        expect(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text(RecordPaymentStrings.selectProjectTitle),
          ),
          findsOneWidget,
        );
        expect(
          find.text(RecordPaymentStrings.projectsOfClient('Sarah Benali')),
          findsOneWidget,
        );

        // Sarah Benali's projects should be present
        expect(find.text('Brand Identity'), findsOneWidget);
        expect(find.text('Dashboard Redesign'), findsOneWidget);

        // Mohamed Bachir's projects must NOT be in the picker
        expect(find.text('Fintask Landing Page'), findsNothing);
        expect(find.text('Mobile App UI'), findsNothing);

        // Verify status and due balances
        expect(find.text('Due 120,000 DZ'), findsOneWidget);
        expect(find.text('Due 95,000 DZ'), findsOneWidget);

        // Select Brand Identity and confirm
        await tester.tap(find.text('Brand Identity'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            RecordPaymentStrings.confirmProject,
          ),
        );
        await tester.pumpAndSettle();

        // Main form shows Brand Identity and Due 120,000 DZ
        expect(find.text('Brand Identity'), findsOneWidget);
        expect(find.text('Due 120,000 DZ'), findsOneWidget);

        // Changing client to Mohamed Bachir clears the linked project
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.payingClientLabel,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mohamed Bachir').last);
        await tester.pumpAndSettle();

        expect(find.text('Mohamed Bachir'), findsOneWidget);
        expect(find.text('Brand Identity'), findsNothing);
        expect(
          find.text(RecordPaymentStrings.selectProjectPlaceholder),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '100% full fills remaining balance',
      (WidgetTester tester) async {
        final (_, ProjectsRepository projectsRepo, _) =
            await pumpRecordPaymentApp(
          tester,
          initialLocation: '/payments/new?projectId=p1',
        );

        // Project p1 has budget 450,000, paid 245,000 -> remaining 205,000
        final ProjectItem project = projectsRepo.byId('p1')!;
        final double remaining = projectsRepo.remaining(project);
        expect(remaining, 205000.0);

        // Tap "100% full" chip
        await tester.tap(find.text(RecordPaymentStrings.fullChip));
        await tester.pumpAndSettle();

        // Amount field is populated with 205,000
        expect(find.text('205,000'), findsOneWidget);
        expect(find.text(RecordPaymentStrings.amountError), findsNothing);
      },
    );

    testWidgets(
      'preselect via projectId',
      (WidgetTester tester) async {
        await pumpRecordPaymentApp(
          tester,
          initialLocation: '/payments/new?projectId=p1',
        );

        // Preselects project p1 ("Fintask Landing Page") and its client ("Mohamed Bachir")
        expect(find.text('Mohamed Bachir'), findsOneWidget);
        expect(find.text('Fintask Landing Page'), findsOneWidget);
        expect(find.text('Due 205,000 DZ'), findsOneWidget);
      },
    );

    testWidgets(
      'successful save adds the payment (repository + project paid / remaining change + client sync) and navigates to /payments',
      (WidgetTester tester) async {
        final (
          ClientsRepository clientsRepo,
          ProjectsRepository projectsRepo,
          GoRouter router,
        ) = await pumpRecordPaymentApp(
          tester,
          initialLocation: '/payments/new?projectId=p1',
        );

        final ProjectItem initialProject = projectsRepo.byId('p1')!;
        final double paidBefore = projectsRepo.paid(initialProject);
        final double remainingBefore = projectsRepo.remaining(initialProject);
        final int projectPaymentsCountBefore =
            projectsRepo.paymentsOf('p1').length;

        // Enter amount 50,000
        final Finder amountInput = find.descendant(
          of: find.widgetWithText(
            AppTextField,
            RecordPaymentStrings.amountLabel,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(amountInput, '50000');
        await tester.pumpAndSettle();

        // Select Payment Method: CCP
        await tester.tap(find.text('CCP'));
        await tester.pumpAndSettle();

        // Select Payment Type: Final
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.paymentTypeLabel,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Final').last);
        await tester.pumpAndSettle();

        // Enter reference
        final Finder refInput = find.descendant(
          of: find.widgetWithText(
            AppTextField,
            RecordPaymentStrings.referenceLabel,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(refInput, 'TXN-998877');
        await tester.pumpAndSettle();

        // Enter notes
        final Finder notesInput = find.descendant(
          of: find.widgetWithText(
            AppTextField,
            RecordPaymentStrings.notesLabel,
          ),
          matching: find.byType(TextField),
        );
        await tester.enterText(notesInput, 'Project completion bonus payment');
        await tester.pumpAndSettle();

        // Tap [Record payment]
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            RecordPaymentStrings.recordPaymentAction,
          ),
        );
        await tester.pumpAndSettle();

        // Verify repository has the new payment
        final List<ProjectPayment> payments = projectsRepo.paymentsOf('p1');
        expect(payments.length, projectPaymentsCountBefore + 1);
        final ProjectPayment saved = payments.last;
        expect(saved.projectId, 'p1');
        expect(saved.clientId, 'c1');
        expect(saved.amount, 50000.0);
        expect(saved.method, PaymentMethod.ccp);
        expect(saved.type, PaymentType.final_);
        expect(saved.reference, 'TXN-998877');
        expect(saved.notes, 'Project completion bonus payment');

        // Verify project paid and remaining balances changed
        final ProjectItem updatedProject = projectsRepo.byId('p1')!;
        expect(projectsRepo.paid(updatedProject), paidBefore + 50000.0);
        expect(
          projectsRepo.remaining(updatedProject),
          remainingBefore - 50000.0,
        );

        // Verify client was synced
        final Client updatedClient = clientsRepo.byId('c1')!;
        expect(
          updatedClient.payments.any(
            (Payment p) =>
                p.amount == 50000.0 && p.reference == 'TXN-998877',
          ),
          isTrue,
        );
        expect(updatedClient.payments.last.amount, 50000.0);

        // Verify navigation back to /payments
        expect(router.state.matchedLocation, AppRoutes.paymentsPath);
        expect(find.byType(PaymentsListScreen), findsOneWidget);
      },
    );

    testWidgets(
      'cancel and X buttons pop / navigate back to /payments',
      (WidgetTester tester) async {
        final (_, _, GoRouter router) = await pumpRecordPaymentApp(
          tester,
          initialLocation: AppRoutes.recordPaymentPath,
        );

        // Tap close X button
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(router.state.matchedLocation, AppRoutes.paymentsPath);

        // Now navigate back to record payment screen
        router.go(AppRoutes.recordPaymentPath);
        await tester.pumpAndSettle();
        expect(find.byType(RecordPaymentScreen), findsOneWidget);

        // Tap Cancel button
        await tester.tap(
          find.widgetWithText(
            SecondaryButton,
            RecordPaymentStrings.cancel,
          ),
        );
        await tester.pumpAndSettle();
        expect(router.state.matchedLocation, AppRoutes.paymentsPath);
      },
    );

    testWidgets(
      '360x800 surface renders without overflow (including with software keyboard inset)',
      (WidgetTester tester) async {
        await pumpRecordPaymentApp(
          tester,
          initialLocation: '/payments/new?projectId=p1',
          surfaceSize: const Size(360, 800),
        );

        // Verify screen renders without any overflow
        expect(tester.takeException(), isNull);
        expect(find.byType(RecordPaymentScreen), findsOneWidget);

        // Simulate software keyboard appearance
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        // No overflow with keyboard up
        expect(tester.takeException(), isNull);

        // Action button stays visible above keyboard (bottom <= 800 - 280)
        final Rect actionBtnRect = tester.getRect(
          find.widgetWithText(
            PrimaryButton,
            RecordPaymentStrings.recordPaymentAction,
          ),
        );
        expect(actionBtnRect.bottom, lessThanOrEqualTo(800 - 280));

        // Reset view insets
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Open project selection sheet on 360x800
        await tester.tap(
          find.widgetWithText(
            RecordPaymentSelectField,
            RecordPaymentStrings.linkedProjectLabel,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(RecordPaymentStrings.selectProjectTitle),
          findsOneWidget,
        );
      },
    );
  });
}
