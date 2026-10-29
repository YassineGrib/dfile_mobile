import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/client_detail_screen.dart';
import 'package:dfile_mobile/features/clients/client_strings.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/projects/add_project_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/projects/edit_project_screen.dart';
import 'package:dfile_mobile/features/projects/project_detail_screen.dart';
import 'package:dfile_mobile/features/projects/project_strings.dart';
import 'package:dfile_mobile/features/projects/projects_list_screen.dart';
import 'package:dfile_mobile/features/projects/widgets/record_payment_sheet.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(ClientsRepository, ProjectsRepository, GoRouter)> pumpFormsApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.projectsPath,
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

  Future<void> pickDateViaInputDialog(
    WidgetTester tester,
    String mmDdYyyy,
  ) async {
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    final Finder dateInput = find.descendant(
      of: find.byType(DatePickerDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(dateInput, mmDdYyyy);
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  group('Project forms on 390x844 surface', () {
    testWidgets(
      'Wizard validation per step, Next gating, state retention across Back/Next, and close button',
      (WidgetTester tester) async {
        final (_, ProjectsRepository projectsRepo, _) = await pumpFormsApp(
          tester,
        );

        // Open wizard from Projects list '+' button
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.byType(AddProjectScreen), findsOneWidget);
        expect(find.text(ProjectStrings.wizardStep1Subtitle), findsOneWidget);

        // Step 1 has Next only (no Back), and Next is disabled while name is empty
        expect(find.text(ProjectStrings.back), findsNothing);
        PrimaryButton nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Whitespace-only keeps Next disabled
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.projectNameLabel),
          '   ',
        );
        await tester.pump();
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Enter valid name, pick category Marketing, and enter description
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.projectNameLabel),
          'DecaByte Design',
        );
        await tester.pump();
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNotNull);

        await tester.tap(find.text(ProjectStrings.categoryDevelopment));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.selectCategoryTitle), findsOneWidget);
        await tester.tap(find.text(ProjectStrings.categoryMarketing));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.categoryMarketing), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.descriptionLabel),
          'Full growth & launch campaign.',
        );
        await tester.pump();

        // Advance to Step 2
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.wizardStep2Subtitle), findsOneWidget);
        expect(find.text(ProjectStrings.back), findsOneWidget);

        // Step 2: Next disabled until BOTH client and budget (> 0, digits only) are valid
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Select client Mohamed Bachir
        await tester.tap(find.text(ProjectStrings.selectClientPlaceholder));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text('Mohamed Bachir'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mohamed Bachir'), findsOneWidget);

        // Budget still empty -> Next disabled
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        final Finder budgetField = find.widgetWithText(
          AppTextField,
          ProjectStrings.projectBudgetRequiredLabel,
        );

        // Non-digits stripped -> still disabled
        await tester.enterText(budgetField, 'abc');
        await tester.pump();
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Zero -> still disabled
        await tester.enterText(budgetField, '0');
        await tester.pump();
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Positive budget -> Next enabled
        await tester.enterText(budgetField, '250000');
        await tester.pump();
        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNotNull);

        // Go Back to Step 1 -> verify state is preserved
        await tester.tap(
          find.widgetWithText(SecondaryButton, ProjectStrings.back),
        );
        await tester.pumpAndSettle();
        expect(find.text('DecaByte Design'), findsOneWidget);
        expect(find.text(ProjectStrings.categoryMarketing), findsOneWidget);
        expect(find.text('Full growth & launch campaign.'), findsOneWidget);

        // Forward to Step 2 again -> client and budget preserved
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mohamed Bachir'), findsOneWidget);
        expect(find.text('250000'), findsOneWidget);

        // Close button (✕) closes wizard without saving
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectsListScreen), findsOneWidget);
        expect(projectsRepo.projects.length, 5);

        // System back also closes wizard without discard dialog even when text was typed
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.projectNameLabel),
          'Unsaved Draft',
        );
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(ProjectsListScreen), findsOneWidget);
        expect(projectsRepo.projects.length, 5);
      },
    );

    testWidgets(
      'Wizard quick-add client, tasks add/remove, deadline-before-start error, status 100%, and full save',
      (WidgetTester tester) async {
        final (
          ClientsRepository clientsRepo,
          ProjectsRepository projectsRepo,
          _,
        ) = await pumpFormsApp(
          tester,
          initialLocation: AppRoutes.addProjectPath,
        );

        // Step 1: enter name & advance
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.projectNameLabel),
          'Atlas Portal',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.descriptionLabel),
          'B2B self-service client portal.',
        );
        await tester.pump();
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();

        // Step 2: switch to "+ Quick add client" (P14)
        await tester.tap(find.text(ProjectStrings.quickAddClientToggle));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.selectClientToggle), findsOneWidget);
        expect(find.text(ProjectStrings.quickAddClientHint), findsOneWidget);

        // Switch back with "Select client" and re-open "+ Quick add client"
        await tester.tap(find.text(ProjectStrings.selectClientToggle));
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.quickAddClientToggle), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.quickAddClientToggle));
        await tester.pumpAndSettle();

        // Enter budget first while in quick-add mode -> Next still disabled until client added
        await tester.enterText(
          find.widgetWithText(
            AppTextField,
            ProjectStrings.projectBudgetRequiredLabel,
          ),
          '175000',
        );
        await tester.pump();
        PrimaryButton nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNull);

        // Type quick client name and tap Add -> creates client in ClientsRepository and selects it
        await tester.enterText(
          find.byType(TextField).first,
          'Atlas Logistics',
        );
        await tester.pump();
        await tester.tap(find.text(ProjectStrings.addAction));
        await tester.pumpAndSettle();

        expect(clientsRepo.clients.length, 5);
        expect(
          clientsRepo.clients.any((Client c) => c.name == 'Atlas Logistics'),
          isTrue,
        );
        expect(find.text('Atlas Logistics'), findsOneWidget);

        nextBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        expect(nextBtn.onPressed, isNotNull);

        // Advance to Step 3: Tasks
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.wizardStep3Subtitle), findsOneWidget);

        // Add task 1 via '+' button
        final Finder subTaskInput = find.byType(TextField);
        await tester.enterText(subTaskInput, 'Database schema');
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.text('#1'), findsOneWidget);
        expect(find.text('Database schema'), findsOneWidget);

        // Add task 2 via keyboard Enter / submit
        await tester.enterText(subTaskInput, 'Auth endpoints');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.text('#2'), findsOneWidget);
        expect(find.text('Auth endpoints'), findsOneWidget);

        // Add task 3 and remove it via 'x'
        await tester.enterText(subTaskInput, 'Temp scratch task');
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.text('Temp scratch task'), findsOneWidget);

        // First close_rounded icon is top-right wizard close; subsequent ones are task remove buttons
        final Finder removeTaskButtons = find.descendant(
          of: find.byType(IconButton),
          matching: find.byIcon(Icons.close_rounded),
        );
        expect(removeTaskButtons, findsNWidgets(3));
        await tester.tap(removeTaskButtons.last);
        await tester.pumpAndSettle();
        expect(find.text('Temp scratch task'), findsNothing);
        expect(removeTaskButtons, findsNWidgets(2));

        // Advance to Step 4: Status & Dates
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(find.text(ProjectStrings.wizardStep4Subtitle), findsOneWidget);
        expect(find.text('0%'), findsOneWidget);

        // Choosing Completed sets slider to 100%
        await tester.tap(find.text(ProjectStatus.planned.label));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text(ProjectStatus.completed.label),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);
        expect(tester.widget<Slider>(find.byType(Slider)).value, 100.0);

        // Switch status to In Progress
        await tester.tap(find.text(ProjectStatus.completed.label));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text(ProjectStatus.inProgress.label),
          ),
        );
        await tester.pumpAndSettle();

        // Pick Start date = 2026-08-15 and Deadline = 2026-08-01 (before start!)
        final DateTime today = DateUtils.dateOnly(DateTime.now());
        await tester.tap(find.text(formatMediumDate(today)));
        await tester.pumpAndSettle();
        await pickDateViaInputDialog(tester, '08/15/2026');
        expect(find.text('Aug 15, 2026'), findsOneWidget);

        final DateTime defaultEnd = today.add(const Duration(days: 30));
        await tester.tap(find.text(formatMediumDate(defaultEnd)));
        await tester.pumpAndSettle();
        await pickDateViaInputDialog(tester, '08/01/2026');
        expect(find.text('Aug 01, 2026'), findsOneWidget);

        // Inline red error shown and Save project blocked
        expect(
          find.text(ProjectStrings.deadlineBeforeStartError),
          findsOneWidget,
        );
        PrimaryButton saveBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.saveProject),
        );
        expect(saveBtn.onPressed, isNull);

        // Fix deadline to 2026-09-30 -> error clears and Save project enabled
        await tester.tap(find.text('Aug 01, 2026'));
        await tester.pumpAndSettle();
        await pickDateViaInputDialog(tester, '09/30/2026');
        expect(
          find.text(ProjectStrings.deadlineBeforeStartError),
          findsNothing,
        );
        saveBtn = tester.widget<PrimaryButton>(
          find.widgetWithText(PrimaryButton, ProjectStrings.saveProject),
        );
        expect(saveBtn.onPressed, isNotNull);

        // Save project -> creates project + tasks, pops to list, shows "Project added" toast
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.saveProject),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProjectsListScreen), findsOneWidget);
        expect(find.text(ProjectStrings.projectAddedToast), findsOneWidget);
        expect(projectsRepo.projects.length, 6);

        final ProjectItem created = projectsRepo.projects.firstWhere(
          (ProjectItem p) => p.name == 'Atlas Portal',
        );
        expect(created.price, 175000.0);
        expect(created.status, ProjectStatus.inProgress);
        expect(created.startDate, DateTime(2026, 8, 15));
        expect(created.endDate, DateTime(2026, 9, 30));
        expect(projectsRepo.clientNameOf(created), 'Atlas Logistics');

        final List<ProjectTask> savedTasks = projectsRepo.tasksOf(created.id);
        expect(savedTasks.length, 2);
        expect(
          savedTasks.map((ProjectTask t) => t.name).toList(),
          <String>['Database schema', 'Auth endpoints'],
        );
      },
    );

    testWidgets(
      'Edit project prefills fields, validates name/budget/dates, updates project, and shows toast',
      (WidgetTester tester) async {
        final (_, ProjectsRepository projectsRepo, _) = await pumpFormsApp(
          tester,
          initialLocation: '/projects/p1',
        );

        // Open Actions sheet -> Edit project -> Cancel pops back to detail
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionEditProject));
        await tester.pumpAndSettle();
        expect(find.byType(EditProjectScreen), findsOneWidget);

        await tester.tap(
          find.widgetWithText(SecondaryButton, ProjectStrings.cancel),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProjectDetailScreen), findsOneWidget);

        // Open Actions sheet -> Edit project -> ✕ pops back to detail
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionEditProject));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(ProjectDetailScreen), findsOneWidget);

        // Open Actions sheet -> Edit project
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionEditProject));
        await tester.pumpAndSettle();

        expect(find.byType(EditProjectScreen), findsOneWidget);

        // Verify prefill from Fintask Landing Page (p1)
        expect(find.text('Fintask Landing Page'), findsOneWidget);
        expect(find.text('Mohamed Bachir'), findsOneWidget);
        expect(find.text('Development'), findsOneWidget);
        expect(find.text('450000'), findsOneWidget);
        expect(find.text('In Progress'), findsOneWidget);
        expect(find.text('65%'), findsOneWidget);
        expect(find.text('Jul 01, 2026'), findsOneWidget);
        expect(find.text('Aug 30, 2026'), findsOneWidget);

        // Empty name disables Save changes
        final Finder nameField = find.widgetWithText(
          AppTextField,
          ProjectStrings.projectNameLabel,
        );
        await tester.enterText(nameField, '');
        await tester.pump();
        expect(
          tester
              .widget<PrimaryButton>(
                find.widgetWithText(PrimaryButton, ProjectStrings.saveChanges),
              )
              .onPressed,
          isNull,
        );

        await tester.enterText(nameField, 'Fintask v2');
        await tester.pump();

        // Zero budget disables Save changes
        final Finder budgetField = find.widgetWithText(
          AppTextField,
          ProjectStrings.budgetShortLabel,
        );
        await tester.enterText(budgetField, '0');
        await tester.pump();
        expect(
          tester
              .widget<PrimaryButton>(
                find.widgetWithText(PrimaryButton, ProjectStrings.saveChanges),
              )
              .onPressed,
          isNull,
        );

        await tester.enterText(budgetField, '500000');
        await tester.pump();

        // Deadline before start date shows inline error and disables Save changes
        await tester.tap(find.text('Aug 30, 2026'));
        await tester.pumpAndSettle();
        await pickDateViaInputDialog(tester, '06/15/2026');
        expect(
          find.text(ProjectStrings.deadlineBeforeStartError),
          findsOneWidget,
        );
        expect(
          tester
              .widget<PrimaryButton>(
                find.widgetWithText(PrimaryButton, ProjectStrings.saveChanges),
              )
              .onPressed,
          isNull,
        );

        // Fix deadline to Sep 15, 2026
        await tester.tap(find.text('Jun 15, 2026'));
        await tester.pumpAndSettle();
        await pickDateViaInputDialog(tester, '09/15/2026');
        expect(
          find.text(ProjectStrings.deadlineBeforeStartError),
          findsNothing,
        );

        // Pick Delivered status -> sets slider to 100%
        await tester.tap(find.text('In Progress'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.text('Delivered'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);

        // Save changes -> updates repo, pops back to detail, shows "Changes saved"
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.saveChanges),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProjectDetailScreen), findsOneWidget);
        expect(find.text(ProjectStrings.changesSavedToast), findsOneWidget);
        expect(projectsRepo.byId('p1')?.name, 'Fintask v2');
        expect(projectsRepo.byId('p1')?.price, 500000.0);
        expect(projectsRepo.byId('p1')?.status, ProjectStatus.delivered);
        expect(projectsRepo.byId('p1')?.progress, 100);
        expect(find.text('Fintask v2'), findsOneWidget);
        expect(find.text('500,000 DZ'), findsOneWidget);
      },
    );

    testWidgets(
      'Edit project with unknown ID displays friendly Project not found screen',
      (WidgetTester tester) async {
        await pumpFormsApp(
          tester,
          initialLocation: '/projects/missing_id_404/edit',
        );

        expect(find.text(ProjectStrings.projectNotFound), findsOneWidget);
        expect(find.text(ProjectStrings.backToProjects), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.backToProjects));
        await tester.pumpAndSettle();

        expect(find.byType(ProjectsListScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Record payment sheet validates, updates project Overview & Payments tab, and syncs to Client detail',
      (WidgetTester tester) async {
        final (
          ClientsRepository clientsRepo,
          ProjectsRepository projectsRepo,
          GoRouter router,
        ) = await pumpFormsApp(
          tester,
          initialLocation: '/projects/p1',
        );

        // Fintask (p1): budget 450,000, paid 245,000, remaining 205,000
        expect(find.text('245,000 DZ'), findsOneWidget);
        expect(find.text('205,000 DZ'), findsOneWidget);

        // 1. Open from Overview [+ Add payment] button
        await tester.tap(find.text(ProjectStrings.addPaymentWithPlus));
        await tester.pumpAndSettle();
        expect(find.byType(RecordPaymentSheet), findsOneWidget);
        expect(
          find.text('Fintask Landing Page • Mohamed Bachir'),
          findsOneWidget,
        );
        expect(
          find.text('Remaining after this payment: 205,000 DZ'),
          findsOneWidget,
        );

        // Save disabled when amount is empty or 0
        final Finder savePaymentFinder = find.widgetWithText(
          PrimaryButton,
          ProjectStrings.savePayment,
        );
        expect(
          tester.widget<PrimaryButton>(savePaymentFinder).onPressed,
          isNull,
        );

        final Finder amountField = find.widgetWithText(
          AppTextField,
          ProjectStrings.amountRequiredLabel,
        );
        await tester.enterText(amountField, '0');
        await tester.pump();
        expect(
          tester.widget<PrimaryButton>(savePaymentFinder).onPressed,
          isNull,
        );

        // Enter 60,000 -> live preview shows 145,000 DZ
        await tester.enterText(amountField, '60000');
        await tester.pump();
        expect(
          find.text('Remaining after this payment: 145,000 DZ'),
          findsOneWidget,
        );
        expect(
          tester.widget<PrimaryButton>(savePaymentFinder).onPressed,
          isNotNull,
        );

        // Enter >= remaining (205,000) -> turns into "Fully paid"
        await tester.enterText(amountField, '210000');
        await tester.pump();
        expect(find.text(ProjectStrings.fullyPaidAfterPayment), findsOneWidget);

        // Set back to 60,000 + reference #A140 and save
        await tester.enterText(amountField, '60000');
        await tester.enterText(
          find.widgetWithText(
            AppTextField,
            ProjectStrings.referenceOptionalLabel,
          ),
          '#A140',
        );
        await tester.pump();

        await tester.tap(savePaymentFinder);
        await tester.pumpAndSettle();

        // Sheet closed, toast shown, Overview updated immediately
        expect(find.byType(RecordPaymentSheet), findsNothing);
        expect(find.text(ProjectStrings.paymentRecordedToast), findsOneWidget);
        expect(find.text('305,000 DZ'), findsOneWidget);
        expect(find.text('145,000 DZ'), findsOneWidget);
        expect(projectsRepo.paid(projectsRepo.byId('p1')!), 305000.0);

        // 2. Switch to Payments tab -> shows updated paid-so-far and #A140 row, and [+ Add payment] works
        await tester.tap(find.text(ProjectStrings.tabPayments));
        await tester.pumpAndSettle();
        expect(find.text('305,000 DZ'), findsOneWidget);
        expect(find.textContaining('#A140'), findsOneWidget);

        await tester.tap(find.text(ProjectStrings.addPaymentWithPlus));
        await tester.pumpAndSettle();
        expect(find.byType(RecordPaymentSheet), findsOneWidget);
        await tester.tap(find.text(ProjectStrings.cancel));
        await tester.pumpAndSettle();

        // 3. Open from Actions sheet ("⋯" -> "Add payment") and pay remaining 145,000 (#A141)
        await tester.tap(find.byIcon(Icons.more_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.actionAddPayment));
        await tester.pumpAndSettle();
        expect(find.byType(RecordPaymentSheet), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.amountRequiredLabel),
          '145000',
        );
        await tester.enterText(
          find.widgetWithText(
            AppTextField,
            ProjectStrings.referenceOptionalLabel,
          ),
          '#A141',
        );
        await tester.pump();
        expect(find.text(ProjectStrings.fullyPaidAfterPayment), findsOneWidget);

        await tester.tap(savePaymentFinder);
        await tester.pumpAndSettle();

        expect(projectsRepo.remaining(projectsRepo.byId('p1')!), 0.0);
        expect(find.text('+145,000 DZ'), findsOneWidget);

        // 4. Navigate to Client detail screen for Mohamed Bachir (/clients/c1) and verify new payments appear
        router.go('/clients/c1');
        await tester.pumpAndSettle();
        expect(find.byType(ClientDetailScreen), findsOneWidget);
        // p1 (450,000 paid) + p3 Mobile App UI (320,000 paid) = 770,000 DZ
        expect(
          clientsRepo.totalRevenue(clientsRepo.byId('c1')!),
          770000.0,
        );

        // Tap "Payments cleared" tile on client detail to open client Payments tab
        await tester.tap(find.text(ClientStrings.financeCleared));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.textContaining('#A140'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('#A140'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.textContaining('#A141'),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('#A141'), findsOneWidget);
        expect(find.text('+145,000 DZ'), findsOneWidget);
      },
    );

    testWidgets(
      '360x800 surface renders wizard steps, edit form (including keyboard inset), and payment sheet without overflow',
      (WidgetTester tester) async {
        final (_, _, GoRouter router) = await pumpFormsApp(
          tester,
          initialLocation: AppRoutes.addProjectPath,
          surfaceSize: const Size(360, 800),
        );
        expect(tester.takeException(), isNull);

        // Wizard Step 1 at 360x800
        await tester.enterText(
          find.widgetWithText(AppTextField, ProjectStrings.projectNameLabel),
          'Compact Viewport Project',
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Wizard Step 2 (select mode + quick-add mode) at 360x800
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(ProjectStrings.quickAddClientToggle));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.byType(TextField).first,
          'Narrow Phone Co',
        );
        await tester.pump();
        await tester.tap(find.text(ProjectStrings.addAction));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.widgetWithText(
            AppTextField,
            ProjectStrings.projectBudgetRequiredLabel,
          ),
          '90000',
        );
        await tester.pump();

        // Wizard Step 3 with tasks at 360x800
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.enterText(
          find.byType(TextField),
          'Long sub-task title to verify wrapping on 360px screen width',
        );
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Wizard Step 4 at 360x800
        await tester.tap(
          find.widgetWithText(PrimaryButton, ProjectStrings.next),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Edit Project at 360x800 (with and without software keyboard)
        router.go('/projects/p1/edit');
        await tester.pumpAndSettle();
        expect(find.byType(EditProjectScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final Rect saveChangesRect = tester.getRect(
          find.widgetWithText(PrimaryButton, ProjectStrings.saveChanges),
        );
        expect(saveChangesRect.bottom, lessThanOrEqualTo(800 - 280));

        tester.view.resetViewInsets();
        await tester.pumpAndSettle();

        // Record Payment sheet at 360x800 (with and without software keyboard)
        router.go('/projects/p1');
        await tester.pumpAndSettle();
        await tester.tap(find.text(ProjectStrings.addPaymentWithPlus));
        await tester.pumpAndSettle();
        expect(find.byType(RecordPaymentSheet), findsOneWidget);
        expect(tester.takeException(), isNull);

        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
