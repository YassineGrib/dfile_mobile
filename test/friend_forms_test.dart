import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/format.dart';
import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/widgets.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/add_friend_screen.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/friends/friend_forms_strings.dart';
import 'package:dfile_mobile/features/friends/friend_statement_screen.dart';
import 'package:dfile_mobile/features/friends/friends_screen.dart';
import 'package:dfile_mobile/features/friends/transaction_form_screen.dart';
import 'package:dfile_mobile/features/friends/widgets/friend_form_select_field.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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

  Future<(ClientsRepository, ProjectsRepository, ExpensesRepository, FriendsRepository, GoRouter)>
      pumpFormsApp(
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
      tester.view.resetViewInsets();
    });

    final ClientsRepository clientsRepo = ClientsRepository();
    final ProjectsRepository projectsRepo =
        ProjectsRepository(clientsRepository: clientsRepo);
    final ExpensesRepository expensesRepo = ExpensesRepository();
    final FriendsRepository effectiveFriendsRepo =
        friendsRepo ?? FriendsRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        repository: clientsRepo,
        projectsRepository: projectsRepo,
        expensesRepository: expensesRepo,
        friendsRepository: effectiveFriendsRepo,
      ),
    );
    await tester.pumpAndSettle();
    return (
      clientsRepo,
      projectsRepo,
      expensesRepo,
      effectiveFriendsRepo,
      router,
    );
  }

  group('AddFriendScreen (FD7)', () {
    testWidgets('validation error on empty friend name and clears on typing', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.addFriendPath,
      );

      expect(find.byType(AddFriendScreen), findsOneWidget);
      expect(find.text(FriendFormsStrings.friendNameError), findsNothing);

      // Attempt to save without entering a name
      await tester.tap(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveFriend),
      );
      await tester.pumpAndSettle();

      // Error appears
      expect(find.text(FriendFormsStrings.friendNameError), findsOneWidget);

      // Type a friend name
      final Finder nameField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.friendNameLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, 'Sami Allouche');
      await tester.pumpAndSettle();

      // Error clears
      expect(find.text(FriendFormsStrings.friendNameError), findsNothing);
    });

    testWidgets('successful save adds friend to repository, shows toast, and navigates to /friends', (
      WidgetTester tester,
    ) async {
      final (
        _,
        _,
        _,
        FriendsRepository friendsRepo,
        _,
      ) = await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.addFriendPath,
      );

      final int initialCount = friendsRepo.friends.length;

      // Fill in friend details
      final Finder nameField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.friendNameLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField, 'Walid Benali');

      final Finder phoneField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.phoneLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(phoneField, '+213 551 22 33 44');

      final Finder notesField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.notesLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(notesField, 'Freelance backend developer partner');
      await tester.pumpAndSettle();

      // Tap Save friend
      await tester.tap(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveFriend),
      );
      await tester.pump();

      // Toast appears
      expect(find.text(FriendFormsStrings.friendAddedToast), findsOneWidget);

      await tester.pumpAndSettle();

      // Navigated to /friends
      expect(find.byType(FriendsScreen), findsOneWidget);

      // Friend added to repository
      expect(friendsRepo.friends.length, initialCount + 1);
      final Friend added = friendsRepo.friends.last;
      expect(added.name, 'Walid Benali');
      expect(added.phone, '+213 551 22 33 44');
      expect(added.notes, 'Freelance backend developer partner');
      expect(added.avatarColorIndex, initialCount % 4);
    });

    testWidgets('cancel button and X button pop or go to /friends', (
      WidgetTester tester,
    ) async {
      // 1. Direct navigation: tapping X falls back to /friends
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.addFriendPath,
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);

      // 2. Direct navigation: tapping Cancel falls back to /friends
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.addFriendPath,
      );
      await tester.tap(find.text(FriendFormsStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);
    });

    testWidgets('360x800 surface renders without layout overflow', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.addFriendPath,
        surfaceSize: const Size(360, 800),
      );

      expect(find.byType(AddFriendScreen), findsOneWidget);

      // Simulate keyboard opening
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();

      // Bottom bar stays visible above the keyboard
      expect(find.widgetWithText(PrimaryButton, FriendFormsStrings.saveFriend), findsOneWidget);

      // Scroll content
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Verify no overflow exception was thrown
      expect(tester.takeException(), isNull);
    });
  });

  group('TransactionFormScreen (FD11/FD12)', () {
    testWidgets('validation errors (missing friend / zero amount / empty description / due before date)', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );

      expect(find.byType(TransactionFormScreen), findsOneWidget);

      // Initially no errors
      expect(find.text(FriendFormsStrings.selectFriendError), findsNothing);
      expect(find.text(FriendFormsStrings.amountError), findsNothing);
      expect(find.text(FriendFormsStrings.descriptionError), findsNothing);
      expect(find.text(FriendFormsStrings.dueDateBeforeDateError), findsNothing);

      // Tap Save transaction on empty form
      await tester.tap(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveTransaction),
      );
      await tester.pumpAndSettle();

      // All 3 errors should appear
      expect(find.text(FriendFormsStrings.selectFriendError), findsOneWidget);
      expect(find.text(FriendFormsStrings.amountError), findsOneWidget);
      expect(find.text(FriendFormsStrings.descriptionError), findsOneWidget);

      // Enter zero amount: error remains
      final Finder amountField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.amountLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountField, '0');
      await tester.pumpAndSettle();
      expect(find.text(FriendFormsStrings.amountError), findsOneWidget);

      // Enter valid amount
      await tester.enterText(amountField, '15,000');
      await tester.pumpAndSettle();
      expect(find.text(FriendFormsStrings.amountError), findsNothing);

      // Enter valid description
      final Finder descField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.descriptionLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(descField, 'Loan for conference ticket');
      await tester.pumpAndSettle();
      expect(find.text(FriendFormsStrings.descriptionError), findsNothing);

      // Select friend via bottom sheet
      await tester.tap(
        find.descendant(
          of: find.byType(FriendFormSelectField),
          matching: find.text(FriendFormsStrings.selectFriendPlaceholder),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text(FriendFormsStrings.selectFriendSheetTitle),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Karim Boualam'));
      await tester.pumpAndSettle();
      expect(find.text('Karim Boualam'), findsOneWidget);
      expect(find.text(FriendFormsStrings.selectFriendError), findsNothing);

      // Scroll down so date fields are fully visible above bottom bar
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();

      // Set due date before transaction date
      final DateTime today = DateUtils.dateOnly(DateTime.now());
      // Set date = 2026-10-20
      await tester.tap(find.text(formatDate(today)));
      await tester.pumpAndSettle();
      await pickDateViaInputDialog(tester, '10/20/2026');
      expect(find.text('2026-10-20'), findsOneWidget);

      // Set due date = 2026-10-10 (before date!)
      await tester.tap(find.text(FriendFormsStrings.pickDatePlaceholder));
      await tester.pumpAndSettle();
      await pickDateViaInputDialog(tester, '10/10/2026');
      expect(find.text('2026-10-10'), findsOneWidget);

      // Error appears
      expect(find.text(FriendFormsStrings.dueDateBeforeDateError), findsOneWidget);

      // Attempt save -> blocked
      await tester.tap(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveTransaction),
      );
      await tester.pumpAndSettle();
      expect(find.text(FriendFormsStrings.dueDateBeforeDateError), findsOneWidget);
    });

    testWidgets('preselects friend when friendId query param is provided', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: '${AppRoutes.newFriendTransactionPath}?friendId=fr2',
      );

      // Friend fr2 (Yacine Mebarki) should be preselected
      expect(find.text('Yacine Mebarki'), findsOneWidget);
      expect(find.text(FriendFormsStrings.selectFriendPlaceholder), findsNothing);
    });

    testWidgets('direction and nature selection toggles state', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );

      // Direction: Owed to me is selected by default
      expect(find.text(FriendFormsStrings.owedToMeLabel), findsOneWidget);
      expect(find.text(FriendFormsStrings.iOweLabel), findsOneWidget);

      // Tap "I owe"
      await tester.tap(find.text(FriendFormsStrings.iOweLabel));
      await tester.pumpAndSettle();

      // Tap back to "Owed to me"
      await tester.tap(find.text(FriendFormsStrings.owedToMeLabel));
      await tester.pumpAndSettle();

      // Nature: Money loan is selected by default
      expect(find.text(FriendFormsStrings.natureMoney), findsOneWidget);
      expect(find.text(FriendFormsStrings.natureService), findsOneWidget);
      expect(find.text(FriendFormsStrings.natureSharedCost), findsOneWidget);

      // Tap "Service"
      await tester.tap(find.text(FriendFormsStrings.natureService));
      await tester.pumpAndSettle();

      // Tap "Shared cost"
      await tester.tap(find.text(FriendFormsStrings.natureSharedCost));
      await tester.pumpAndSettle();
    });

    testWidgets('placeholder per nature updates dynamically', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );

      // Default: Money loan -> money placeholder
      expect(
        find.text(FriendFormsStrings.descriptionPlaceholderMoney),
        findsOneWidget,
      );

      // Tap Service -> service placeholder
      await tester.tap(find.text(FriendFormsStrings.natureService));
      await tester.pumpAndSettle();
      expect(
        find.text(FriendFormsStrings.descriptionPlaceholderService),
        findsOneWidget,
      );

      // Tap Shared cost -> shared cost placeholder
      await tester.tap(find.text(FriendFormsStrings.natureSharedCost));
      await tester.pumpAndSettle();
      expect(
        find.text(FriendFormsStrings.descriptionPlaceholderSharedCost),
        findsOneWidget,
      );
    });

    testWidgets('+ New friend link pushes /friends/new', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );

      await tester.tap(find.text(FriendFormsStrings.newFriendLink));
      await tester.pumpAndSettle();

      expect(find.byType(AddFriendScreen), findsOneWidget);
    });

    testWidgets('successful save adds transaction to repository, shows toast, and navigates to friend statement', (
      WidgetTester tester,
    ) async {
      final (
        _,
        _,
        _,
        FriendsRepository friendsRepo,
        _,
      ) = await pumpFormsApp(
        tester,
        initialLocation: '${AppRoutes.newFriendTransactionPath}?friendId=fr1',
      );

      final int initialCount = friendsRepo.transactions.length;

      // Select direction = I owe
      await tester.tap(find.text(FriendFormsStrings.iOweLabel));
      await tester.pumpAndSettle();

      // Select nature = Shared cost
      await tester.tap(find.text(FriendFormsStrings.natureSharedCost));
      await tester.pumpAndSettle();

      // Enter amount
      final Finder amountField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.amountLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(amountField, '25,000');

      // Enter description
      final Finder descField = find.descendant(
        of: find.widgetWithText(AppTextField, FriendFormsStrings.descriptionLabel),
        matching: find.byType(TextField),
      );
      await tester.enterText(descField, 'Cloud hosting monthly share');
      await tester.pumpAndSettle();

      // Save transaction
      await tester.tap(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveTransaction),
      );
      await tester.pump();

      // Toast appears
      expect(find.text(FriendFormsStrings.transactionRecordedToast), findsOneWidget);

      await tester.pumpAndSettle();

      // Navigated to /friends/fr1 (statement screen)
      expect(find.byType(FriendStatementScreen), findsOneWidget);

      // Transaction added to repository
      expect(friendsRepo.transactions.length, initialCount + 1);
      final FriendTransaction saved = friendsRepo.transactions.last;
      expect(saved.friendId, 'fr1');
      expect(saved.direction, FriendTxDirection.borrowed);
      expect(saved.type, FriendTxType.expense);
      expect(saved.amount, 25000.0);
      expect(saved.paidAmount, 0.0);
      expect(saved.description, 'Cloud hosting monthly share');
    });

    testWidgets('close button X pops or navigates to /friends', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: AppRoutes.newFriendTransactionPath,
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(FriendsScreen), findsOneWidget);
    });

    testWidgets('360x800 surface renders without overflow with keyboard up and down', (
      WidgetTester tester,
    ) async {
      await pumpFormsApp(
        tester,
        initialLocation: '${AppRoutes.newFriendTransactionPath}?friendId=fr1',
        surfaceSize: const Size(360, 800),
      );

      expect(find.byType(TransactionFormScreen), findsOneWidget);

      // Keyboard inset
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(PrimaryButton, FriendFormsStrings.saveTransaction),
        findsOneWidget,
      );

      // Drag / scroll
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
