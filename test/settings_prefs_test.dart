import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dfile_mobile/core/router/app_router.dart';
import 'package:dfile_mobile/features/clients/data/data.dart';
import 'package:dfile_mobile/features/expenses/data/data.dart';
import 'package:dfile_mobile/features/friends/data/data.dart';
import 'package:dfile_mobile/features/projects/add_project_screen.dart';
import 'package:dfile_mobile/features/projects/edit_project_screen.dart';
import 'package:dfile_mobile/features/projects/data/data.dart';
import 'package:dfile_mobile/features/projects/project_strings.dart';
import 'package:dfile_mobile/features/settings/categories_screen.dart';
import 'package:dfile_mobile/features/settings/data/data.dart';
import 'package:dfile_mobile/features/settings/legal_clauses_screen.dart';
import 'package:dfile_mobile/features/settings/preferences_screen.dart';
import 'package:dfile_mobile/features/settings/settings_prefs_strings.dart';
import 'package:dfile_mobile/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<(SettingsRepository, GoRouter, ClientsRepository, ProjectsRepository)>
      pumpPrefsApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.settingsPreferencesPath,
    Size surfaceSize = const Size(390, 844),
    SettingsRepository? customSettingsRepo,
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
    final FriendsRepository friendsRepo = FriendsRepository();
    final SettingsRepository settingsRepo =
        customSettingsRepo ?? SettingsRepository();
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

    return (settingsRepo, router, clientsRepo, projectsRepo);
  }

  group('PreferencesScreen (ST5) UI and Interactions', () {
    testWidgets(
      'Language segmented control selects English and shows coming soon for Arabic',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _, _, _) = await pumpPrefsApp(tester);

        expect(find.byType(PreferencesScreen), findsOneWidget);
        expect(repo.language, AppLanguage.en);

        // Tap Arabic
        await tester.tap(find.text(SettingsPrefsStrings.languageArabic));
        await tester.pumpAndSettle();

        // Toast shows Arabic is coming soon, language remains English
        expect(
          find.text(SettingsPrefsStrings.arabicComingSoonToast),
          findsOneWidget,
        );
        expect(repo.language, AppLanguage.en);

        // Tap English
        await tester.tap(find.text(SettingsPrefsStrings.languageEnglish));
        await tester.pumpAndSettle();
        expect(repo.language, AppLanguage.en);
      },
    );

    testWidgets(
      'Appearance tiles select Light and show coming soon for Dark and System',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _, _, _) = await pumpPrefsApp(tester);

        expect(repo.themeMode, AppThemeMode.light);

        // Tap Dark tile
        await tester.tap(find.text(SettingsPrefsStrings.themeDark));
        await tester.pumpAndSettle();

        expect(
          find.text(SettingsPrefsStrings.darkThemeComingSoonToast),
          findsWidgets,
        );
        expect(repo.themeMode, AppThemeMode.light);

        // Tap System tile
        await tester.tap(find.text(SettingsPrefsStrings.themeSystem));
        await tester.pumpAndSettle();

        expect(
          find.text(SettingsPrefsStrings.darkThemeComingSoonToast),
          findsWidgets,
        );
        expect(repo.themeMode, AppThemeMode.light);

        // Tap Light tile
        await tester.tap(find.text(SettingsPrefsStrings.themeLight));
        await tester.pumpAndSettle();
        expect(repo.themeMode, AppThemeMode.light);
      },
    );

    testWidgets(
      'Workspace group rows trigger toast or navigate to categories and legal',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _, _, _) = await pumpPrefsApp(tester);

        // Font style row
        expect(find.text(SettingsPrefsStrings.fontStyleTitle), findsOneWidget);
        expect(find.text(SettingsPrefsStrings.fontStyleValue), findsOneWidget);
        await tester.tap(find.text(SettingsPrefsStrings.fontStyleTitle));
        await tester.pumpAndSettle();
        expect(
          find.text(SettingsPrefsStrings.demoNotAvailableToast),
          findsOneWidget,
        );

        // Categories row
        final String catSubtitle =
            SettingsPrefsStrings.categoriesCount(repo.categories.length);
        expect(find.text(catSubtitle), findsOneWidget);
        await tester.tap(find.text(SettingsPrefsStrings.projectCategoriesTitle));
        await tester.pumpAndSettle();

        expect(find.byType(CategoriesScreen), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(PreferencesScreen), findsOneWidget);

        // Legal clauses row
        expect(
          find.text(SettingsPrefsStrings.legalClausesTemplateTitle),
          findsOneWidget,
        );
        await tester.tap(
          find.text(SettingsPrefsStrings.legalClausesTemplateTitle),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LegalClausesScreen), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.byType(PreferencesScreen), findsOneWidget);
      },
    );
  });

  group('CategoriesScreen (ST6) UI and Interactions', () {
    testWidgets(
      'Empty input does nothing, add adds category, duplicate warns, remove removes',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _, _, _) = await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.settingsCategoriesPath,
        );

        expect(find.byType(CategoriesScreen), findsOneWidget);
        final int initialCount = repo.categories.length;
        expect(initialCount, 5);

        // Find input field
        final Finder textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        // 1. Empty or whitespace input
        await tester.enterText(textField, '   ');
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        expect(repo.categories.length, initialCount);
        expect(find.text(SettingsPrefsStrings.categoryAddedToast), findsNothing);
        expect(
          find.text(SettingsPrefsStrings.categoryExistsToast),
          findsNothing,
        );

        // 2. Add valid new category
        await tester.enterText(textField, 'DevOps');
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        expect(repo.categories.length, initialCount + 1);
        expect(repo.categories.contains('DevOps'), isTrue);
        expect(find.text('DevOps'), findsOneWidget);
        expect(find.text(SettingsPrefsStrings.categoryAddedToast), findsOneWidget);

        // Field cleared
        final TextField inputWidget = tester.widget<TextField>(textField);
        expect(inputWidget.controller?.text, isEmpty);

        // 3. Duplicate category (case-insensitive) via onSubmitted
        await tester.enterText(textField, 'devops');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(repo.categories.length, initialCount + 1);
        expect(
          find.text(SettingsPrefsStrings.categoryExistsToast),
          findsOneWidget,
        );

        // 4. Remove category via "x"
        final Finder devOpsClose = find.descendant(
          of: find.ancestor(
            of: find.text('DevOps'),
            matching: find.byType(Container),
          ),
          matching: find.byIcon(Icons.close_rounded),
        );
        expect(devOpsClose, findsOneWidget);
        await tester.tap(devOpsClose);
        await tester.pumpAndSettle();

        expect(repo.categories.length, initialCount);
        expect(repo.categories.contains('DevOps'), isFalse);
        expect(find.text('DevOps'), findsNothing);
        expect(
          find.text(SettingsPrefsStrings.categoryRemovedToast),
          findsOneWidget,
        );
      },
    );
  });

  group('LegalClausesScreen (ST7) UI and Interactions', () {
    testWidgets(
      'Prefilled editor updates live character counter and save updates repository',
      (WidgetTester tester) async {
        final (SettingsRepository repo, _, _, _) = await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.settingsPreferencesPath,
        );

        // Navigate from preferences to legal
        await tester.tap(
          find.text(SettingsPrefsStrings.legalClausesTemplateTitle),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LegalClausesScreen), findsOneWidget);

        final String initialClauses = repo.legalClauses;
        expect(
          find.text(SettingsPrefsStrings.charactersCount(initialClauses.length)),
          findsOneWidget,
        );

        // Edit text
        const String newClauses = 'Clause 1: Fast delivery.';
        final Finder editorField = find.descendant(
          of: find.byType(LegalClausesScreen),
          matching: find.byType(TextField),
        );
        await tester.enterText(editorField, newClauses);
        await tester.pumpAndSettle();

        expect(
          find.text(SettingsPrefsStrings.charactersCount(newClauses.length)),
          findsOneWidget,
        );

        // Save clauses template
        await tester.tap(find.text(SettingsPrefsStrings.saveClausesButton));
        await tester.pumpAndSettle();

        expect(repo.legalClauses, newClauses);
        expect(
          find.text(SettingsPrefsStrings.legalClausesUpdatedToast),
          findsOneWidget,
        );
        // Popped back to preferences screen
        expect(find.byType(PreferencesScreen), findsOneWidget);
      },
    );
  });

  group('Project forms integration with SettingsScope', () {
    testWidgets(
      'Category added in Settings shows up in AddProjectScreen category picker',
      (WidgetTester tester) async {
        final SettingsRepository sharedSettingsRepo = SettingsRepository();
        final (_, GoRouter router, _, _) = await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.settingsCategoriesPath,
          customSettingsRepo: sharedSettingsRepo,
        );

        // Add custom category
        final Finder textField = find.byType(TextField);
        await tester.enterText(textField, 'CloudArchitecture');
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        expect(sharedSettingsRepo.categories.contains('CloudArchitecture'), isTrue);

        // Remove Branding
        final Finder brandingClose = find.descendant(
          of: find.ancestor(
            of: find.text('Branding'),
            matching: find.byType(Container),
          ),
          matching: find.byIcon(Icons.close_rounded),
        );
        await tester.tap(brandingClose);
        await tester.pumpAndSettle();
        expect(sharedSettingsRepo.categories.contains('Branding'), isFalse);

        // Navigate to AddProjectScreen
        router.go(AppRoutes.addProjectPath);
        await tester.pumpAndSettle();
        expect(find.byType(AddProjectScreen), findsOneWidget);

        // Default category is first item
        expect(find.text('Development'), findsWidgets);

        // Tap category selector
        await tester.tap(find.text('Development').first);
        await tester.pumpAndSettle();

        // Check picker options
        expect(find.text(ProjectStrings.selectCategoryTitle), findsOneWidget);
        expect(find.text('CloudArchitecture'), findsOneWidget);
        expect(find.text('Branding'), findsNothing);

        // Select CloudArchitecture
        await tester.tap(find.text('CloudArchitecture'));
        await tester.pumpAndSettle();

        expect(find.text('CloudArchitecture'), findsOneWidget);
      },
    );

    testWidgets(
      'Existing project whose category was removed still shows its category on EditProjectScreen',
      (WidgetTester tester) async {
        final SettingsRepository sharedSettingsRepo = SettingsRepository();
        // Remove Branding from categories
        sharedSettingsRepo.removeCategory('Branding');
        expect(sharedSettingsRepo.categories.contains('Branding'), isFalse);

        final (_, GoRouter router, _, ProjectsRepository projectsRepo) =
            await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.projectsPath,
          customSettingsRepo: sharedSettingsRepo,
        );

        // Project p4 is 'Logo Pack' with category 'Branding'
        final ProjectItem p4 = projectsRepo.byId('p4')!;
        expect(p4.category, 'Branding');

        router.go('/projects/p4/edit');
        await tester.pumpAndSettle();

        expect(find.byType(EditProjectScreen), findsOneWidget);
        // Form displays the removed category
        expect(find.text('Branding'), findsOneWidget);

        // Opening picker shows Branding as an option
        await tester.tap(find.text('Branding'));
        await tester.pumpAndSettle();

        expect(find.text(ProjectStrings.selectCategoryTitle), findsOneWidget);
        expect(find.text('Branding'), findsWidgets);
      },
    );
  });

  group('360x800 surface no-overflow checks', () {
    testWidgets('PreferencesScreen renders without overflow on 360x800', (
      WidgetTester tester,
    ) async {
      await pumpPrefsApp(
        tester,
        initialLocation: AppRoutes.settingsPreferencesPath,
        surfaceSize: const Size(360, 800),
      );

      expect(find.byType(PreferencesScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'CategoriesScreen renders without overflow on 360x800 with keyboard inset',
      (WidgetTester tester) async {
        await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.settingsCategoriesPath,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(CategoriesScreen), findsOneWidget);
        // Simulate keyboard inset
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'LegalClausesScreen renders without overflow on 360x800 with keyboard inset',
      (WidgetTester tester) async {
        await pumpPrefsApp(
          tester,
          initialLocation: AppRoutes.settingsLegalPath,
          surfaceSize: const Size(360, 800),
        );

        expect(find.byType(LegalClausesScreen), findsOneWidget);
        // Simulate keyboard inset
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
