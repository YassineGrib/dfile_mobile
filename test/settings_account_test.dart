import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/core/widgets/app_text_field.dart';
import 'package:dfile_mobile/core/widgets/user_avatar.dart';
import 'package:dfile_mobile/core/widgets/primary_button.dart';
import 'package:dfile_mobile/core/widgets/secondary_button.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/settings/change_password_screen.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/edit_profile_screen.dart';
import 'package:dfile_mobile/features/settings/settings_account_strings.dart';
import 'package:dfile_mobile/features/settings/settings_screen.dart';
import 'package:dfile_mobile/features/settings/widgets/account_action_bar.dart';
import 'package:dfile_mobile/features/settings/widgets/account_password_field.dart';
import 'package:dfile_mobile/features/settings/widgets/settings_row.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(SettingsRepository, GoRouter)> pumpAccountApp(
    WidgetTester tester, {
    required String initialLocation,
    SettingsRepository? settingsRepository,
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
    final ExpensesRepository expensesRepo = ExpensesRepository();
    final FriendsRepository friendsRepo = FriendsRepository();
    final SettingsRepository settingsRepo =
        settingsRepository ?? SettingsRepository();
    final GoRouter router = createAppRouter(initialLocation: initialLocation);

    await tester.pumpWidget(
      DfileApp(
        router: router,
        repository: clientsRepo,
        projectsRepository: projectsRepo,
        expensesRepository: expensesRepo,
        friendsRepository: friendsRepo,
        settingsRepository: settingsRepo,
      ),
    );
    await tester.pumpAndSettle();
    return (settingsRepo, router);
  }

  Finder findFieldByLabel(String label) {
    return find.descendant(
      of: find.widgetWithText(AppTextField, label),
      matching: find.byType(TextField),
    );
  }

  Finder findPasswordFieldByLabel(String label) {
    return find.descendant(
      of: find.widgetWithText(AccountPasswordField, label),
      matching: find.byType(TextField),
    );
  }

  group('EditProfileScreen (ST2)', () {
    testWidgets('prefills fields and avatar from SettingsRepository', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsProfilePath,
      );

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(
        find.text(SettingsAccountStrings.editProfileTitle),
        findsOneWidget,
      );

      // Avatar initial matches repository profile name initial 'Y'
      expect(find.byType(UserAvatar), findsOneWidget);

      // Name & designation
      expect(find.text(repo.profile.name), findsOneWidget);
      expect(find.text(repo.profile.designation), findsOneWidget);

      // Business email read-only with Verified pill
      expect(find.text(repo.profile.email), findsOneWidget);
      expect(find.text(SettingsAccountStrings.verifiedPill), findsOneWidget);

      // Phone & address
      expect(find.text(repo.profile.phone), findsOneWidget);
      expect(find.text(repo.profile.address), findsOneWidget);

      // Change password row and action buttons
      expect(
        find.text(SettingsAccountStrings.changePasswordRow),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(SecondaryButton, SettingsAccountStrings.cancel),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(PrimaryButton, SettingsAccountStrings.saveDetails),
        findsOneWidget,
      );
    });

    testWidgets('live avatar initial updates when name field changes', (
      WidgetTester tester,
    ) async {
      await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsProfilePath,
      );

      expect(find.byType(UserAvatar), findsOneWidget);

      final Finder nameField = findFieldByLabel(
        SettingsAccountStrings.displayNameLabel,
      );
      await tester.enterText(nameField, 'Karim Boualam');
      await tester.pumpAndSettle();

      expect(find.byType(UserAvatar), findsOneWidget);
      expect(
        tester.widget<UserAvatar>(find.byType(UserAvatar)).name,
        'Karim Boualam',
      );
    });

    testWidgets('required validation errors on empty name and designation', (
      WidgetTester tester,
    ) async {
      final (SettingsRepository repo, _) = await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsProfilePath,
      );

      // Initially no errors
      expect(find.text(SettingsAccountStrings.nameRequiredError), findsNothing);
      expect(
        find.text(SettingsAccountStrings.designationRequiredError),
        findsNothing,
      );

      // Clear display name
      final Finder nameField = findFieldByLabel(
        SettingsAccountStrings.displayNameLabel,
      );
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Clear designation
      final Finder desigField = findFieldByLabel(
        SettingsAccountStrings.designationLabel,
      );
      await tester.enterText(desigField, '');
      await tester.pumpAndSettle();

      // Attempt save
      await tester.tap(
        find.widgetWithText(PrimaryButton, SettingsAccountStrings.saveDetails),
      );
      await tester.pumpAndSettle();

      // Inline red errors appear
      expect(
        find.text(SettingsAccountStrings.nameRequiredError),
        findsOneWidget,
      );
      expect(
        find.text(SettingsAccountStrings.designationRequiredError),
        findsOneWidget,
      );

      // Repository profile has NOT been modified
      expect(repo.profile.name, isNotEmpty);

      // Entering valid name clears name error
      await tester.enterText(nameField, 'Amine T.');
      await tester.pumpAndSettle();
      expect(find.text(SettingsAccountStrings.nameRequiredError), findsNothing);
      expect(
        find.text(SettingsAccountStrings.designationRequiredError),
        findsOneWidget,
      );

      // Entering valid designation clears designation error
      await tester.enterText(desigField, 'Senior Mobile Engineer');
      await tester.pumpAndSettle();
      expect(find.text(SettingsAccountStrings.nameRequiredError), findsNothing);
      expect(
        find.text(SettingsAccountStrings.designationRequiredError),
        findsNothing,
      );
    });

    testWidgets(
      'save details updates repository and navigates to /settings with toast',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsProfilePath,
        );

        final Finder nameField = findFieldByLabel(
          SettingsAccountStrings.displayNameLabel,
        );
        await tester.enterText(nameField, 'Sarah Benali');

        final Finder desigField = findFieldByLabel(
          SettingsAccountStrings.designationLabel,
        );
        await tester.enterText(desigField, 'Lead Product Designer');

        final Finder phoneField = findFieldByLabel(
          SettingsAccountStrings.phoneLabel,
        );
        await tester.enterText(phoneField, '+213 555 99 88 77');

        final Finder addressField = findFieldByLabel(
          SettingsAccountStrings.addressLabel,
        );
        await tester.enterText(
          addressField,
          '45 Boulevard des Martyrs, Algiers',
        );

        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.saveDetails,
          ),
        );
        await tester.pumpAndSettle();

        // Verify repository updated
        expect(repo.profile.name, 'Sarah Benali');
        expect(repo.profile.designation, 'Lead Product Designer');
        expect(repo.profile.phone, '+213 555 99 88 77');
        expect(repo.profile.address, '45 Boulevard des Martyrs, Algiers');
        expect(repo.profile.email, 'yassine@decabyte.dz'); // email preserved

        // Lands on /settings
        expect(find.byType(SettingsScreen), findsOneWidget);

        // Toast appears
        expect(
          find.text(SettingsAccountStrings.profileUpdatedToast),
          findsOneWidget,
        );
      },
    );

    testWidgets('cancel button and back arrow navigate back to /settings', (
      WidgetTester tester,
    ) async {
      // 1. Cancel button
      final (_, GoRouter router) = await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsProfilePath,
      );

      await tester.tap(
        find.widgetWithText(SecondaryButton, SettingsAccountStrings.cancel),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // 2. Back arrow
      router.go(AppRoutes.settingsProfilePath);
      await tester.pumpAndSettle();
      expect(find.byType(EditProfileScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping Change password row pushes /settings/password', (
      WidgetTester tester,
    ) async {
      await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsProfilePath,
      );

      final Finder rowFinder = find.widgetWithText(
        SettingsRow,
        SettingsAccountStrings.changePasswordRow,
      );
      await tester.ensureVisible(rowFinder);
      await tester.pumpAndSettle();

      await tester.tap(rowFinder);
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets(
      '360x800 surface renders without overflow with keyboard up and down',
      (WidgetTester tester) async {
        await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsProfilePath,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Simulate keyboard open
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        expect(find.byType(AccountActionBar), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll content
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ChangePasswordScreen (ST3, ST4)', () {
    testWidgets(
      'mounts cleanly with header, subtitle, 3 obscured password fields and Show buttons',
      (WidgetTester tester) async {
        await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsPasswordPath,
        );

        expect(find.byType(ChangePasswordScreen), findsOneWidget);
        expect(
          find.text(SettingsAccountStrings.changePasswordTitle),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAccountStrings.changePasswordSubtitle),
          findsOneWidget,
        );

        expect(
          find.text(SettingsAccountStrings.currentPasswordLabel),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAccountStrings.newPasswordLabel),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAccountStrings.confirmPasswordLabel),
          findsOneWidget,
        );

        // 3 "Show" toggles visible initially
        expect(find.text(SettingsAccountStrings.showToggle), findsNWidgets(3));

        expect(
          find.widgetWithText(SecondaryButton, SettingsAccountStrings.cancel),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.updatePassword,
          ),
          findsOneWidget,
        );

        // Initially no errors
        expect(
          find.text(SettingsAccountStrings.currentPasswordIncorrectError),
          findsNothing,
        );
        expect(
          find.text(SettingsAccountStrings.passwordTooShortError),
          findsNothing,
        );
        expect(
          find.text(SettingsAccountStrings.passwordsDoNotMatchError),
          findsNothing,
        );
      },
    );

    testWidgets('Show/Hide toggle un-obscures and obscures password fields', (
      WidgetTester tester,
    ) async {
      await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsPasswordPath,
      );

      // Toggle first field
      final Finder firstShow = find
          .text(SettingsAccountStrings.showToggle)
          .first;
      await tester.tap(firstShow);
      await tester.pumpAndSettle();

      expect(find.text(SettingsAccountStrings.hideToggle), findsOneWidget);
      expect(find.text(SettingsAccountStrings.showToggle), findsNWidgets(2));

      // Toggle it back to Show
      final Finder hideBtn = find.text(SettingsAccountStrings.hideToggle);
      await tester.tap(hideBtn);
      await tester.pumpAndSettle();

      expect(find.text(SettingsAccountStrings.hideToggle), findsNothing);
      expect(find.text(SettingsAccountStrings.showToggle), findsNWidgets(3));
    });

    testWidgets(
      'validation displays every error on empty or invalid save attempt (ST4)',
      (WidgetTester tester) async {
        await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsPasswordPath,
        );

        // Tap Update password on empty form
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.updatePassword,
          ),
        );
        await tester.pumpAndSettle();

        // All 3 errors should appear
        expect(
          find.text(SettingsAccountStrings.currentPasswordIncorrectError),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAccountStrings.passwordTooShortError),
          findsOneWidget,
        );
        expect(
          find.text(SettingsAccountStrings.passwordsDoNotMatchError),
          findsOneWidget,
        );

        // Enter a current password
        final Finder currentField = findPasswordFieldByLabel(
          SettingsAccountStrings.currentPasswordLabel,
        );
        await tester.enterText(currentField, 'wrong_pass');
        await tester.pumpAndSettle();

        // Enter short new password (less than 6 chars)
        final Finder newField = findPasswordFieldByLabel(
          SettingsAccountStrings.newPasswordLabel,
        );
        await tester.enterText(newField, 'abc');
        await tester.pumpAndSettle();
        expect(
          find.text(SettingsAccountStrings.passwordTooShortError),
          findsOneWidget,
        );

        // Enter mismatching confirm password
        final Finder confirmField = findPasswordFieldByLabel(
          SettingsAccountStrings.confirmPasswordLabel,
        );
        await tester.enterText(confirmField, 'xyz123');
        await tester.pumpAndSettle();
        expect(
          find.text(SettingsAccountStrings.passwordsDoNotMatchError),
          findsOneWidget,
        );

        // A wrong current password is rejected by the auth service on submit
        await tester.enterText(newField, 'abcdef');
        await tester.enterText(confirmField, 'abcdef');
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.updatePassword,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(SettingsAccountStrings.currentPasswordIncorrectError),
          findsOneWidget,
        );
      },
    );

    testWidgets('entering valid credentials clears errors', (
      WidgetTester tester,
    ) async {
      await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsPasswordPath,
      );

      // Trigger errors first
      await tester.tap(
        find.widgetWithText(
          PrimaryButton,
          SettingsAccountStrings.updatePassword,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(SettingsAccountStrings.currentPasswordIncorrectError),
        findsOneWidget,
      );

      // Fix current password (mock password is 'demo123')
      final Finder currentField = findPasswordFieldByLabel(
        SettingsAccountStrings.currentPasswordLabel,
      );
      await tester.enterText(currentField, 'demo123');
      await tester.pumpAndSettle();
      expect(
        find.text(SettingsAccountStrings.currentPasswordIncorrectError),
        findsNothing,
      );

      // Fix new password (>= 6 chars)
      final Finder newField = findPasswordFieldByLabel(
        SettingsAccountStrings.newPasswordLabel,
      );
      await tester.enterText(newField, 'newSecretPassword');
      await tester.pumpAndSettle();
      expect(
        find.text(SettingsAccountStrings.passwordTooShortError),
        findsNothing,
      );

      // Fix confirm password to match new password
      final Finder confirmField = findPasswordFieldByLabel(
        SettingsAccountStrings.confirmPasswordLabel,
      );
      await tester.enterText(confirmField, 'newSecretPassword');
      await tester.pumpAndSettle();
      expect(
        find.text(SettingsAccountStrings.passwordsDoNotMatchError),
        findsNothing,
      );
    });

    testWidgets(
      'successful password update updates repository and shows toast',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsPasswordPath,
        );

        expect(repo.checkPassword('demo123'), isTrue);

        final Finder currentField = findPasswordFieldByLabel(
          SettingsAccountStrings.currentPasswordLabel,
        );
        await tester.enterText(currentField, 'demo123');

        final Finder newField = findPasswordFieldByLabel(
          SettingsAccountStrings.newPasswordLabel,
        );
        await tester.enterText(newField, 'brandNewPass2026');

        final Finder confirmField = findPasswordFieldByLabel(
          SettingsAccountStrings.confirmPasswordLabel,
        );
        await tester.enterText(confirmField, 'brandNewPass2026');

        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.updatePassword,
          ),
        );
        await tester.pumpAndSettle();

        // Password is now updated in repository
        expect(repo.checkPassword('brandNewPass2026'), isTrue);
        expect(repo.checkPassword('demo123'), isFalse);

        // Toast is displayed
        expect(
          find.text(SettingsAccountStrings.passwordUpdatedToast),
          findsOneWidget,
        );
      },
    );

    testWidgets('cancel button pops back', (WidgetTester tester) async {
      await pumpAccountApp(
        tester,
        initialLocation: AppRoutes.settingsPasswordPath,
      );

      await tester.tap(
        find.widgetWithText(SecondaryButton, SettingsAccountStrings.cancel),
      );
      await tester.pumpAndSettle();

      // Back to settings
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets(
      '360x800 surface renders without overflow with keyboard up and down',
      (WidgetTester tester) async {
        await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsPasswordPath,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(ChangePasswordScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Simulate keyboard open
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        expect(find.byType(AccountActionBar), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll content
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Full Settings Account push & pop flow', () {
    testWidgets(
      'Navigate profile -> password -> change password successfully -> pop to profile -> save profile -> settings with toast',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _) = await pumpAccountApp(
          tester,
          initialLocation: AppRoutes.settingsProfilePath,
        );

        expect(find.byType(EditProfileScreen), findsOneWidget);

        // Push password screen via Change password row
        final Finder rowFinder = find.widgetWithText(
          SettingsRow,
          SettingsAccountStrings.changePasswordRow,
        );
        await tester.ensureVisible(rowFinder);
        await tester.pumpAndSettle();
        await tester.tap(rowFinder);
        await tester.pumpAndSettle();

        expect(find.byType(ChangePasswordScreen), findsOneWidget);

        // Fill valid password update
        await tester.enterText(
          findPasswordFieldByLabel(SettingsAccountStrings.currentPasswordLabel),
          'demo123',
        );
        await tester.enterText(
          findPasswordFieldByLabel(SettingsAccountStrings.newPasswordLabel),
          'securePass99',
        );
        await tester.enterText(
          findPasswordFieldByLabel(SettingsAccountStrings.confirmPasswordLabel),
          'securePass99',
        );

        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.updatePassword,
          ),
        );
        await tester.pumpAndSettle();

        // Returned to EditProfileScreen with toast!
        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(
          find.text(SettingsAccountStrings.passwordUpdatedToast),
          findsOneWidget,
        );
        expect(repo.checkPassword('securePass99'), isTrue);

        // Now save profile
        await tester.tap(
          find.widgetWithText(
            PrimaryButton,
            SettingsAccountStrings.saveDetails,
          ),
        );
        await tester.pumpAndSettle();

        // Landed on SettingsScreen with profileUpdatedToast!
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(
          find.text(SettingsAccountStrings.profileUpdatedToast),
          findsOneWidget,
        );
      },
    );
  });
}
