/// String constants for preferences settings screens (Agent B) per `docs/design/SPEC.md`.
abstract final class SettingsPrefsStrings {
  // Preferences screen (ST5)
  static const String preferencesTitle = 'Preferences';
  static const String languageSection = 'Language';
  static const String languageEnglish = 'English';
  static const String languageArabic = 'Arabic';
  static const String arabicComingSoonToast = 'Arabic is coming soon';

  static const String appearanceSection = 'Appearance';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String themeSystem = 'System';
  static const String darkThemeComingSoonToast = 'Dark theme is coming soon';

  static const String workspaceSection = 'Workspace';
  static const String fontStyleTitle = 'Font style';
  static const String fontStyleValue = 'Modern Studio Pro';
  static const String demoNotAvailableToast = 'Not available in the demo';
  static const String projectCategoriesTitle = 'Project categories';
  static String categoriesCount(int count) => '$count categories';
  static const String legalClausesTemplateTitle = 'Legal clauses template';
  static const String legalClausesTemplateSubtitle = 'Added to agreements';

  // Project categories screen (ST6)
  static const String categoriesTitle = 'Project categories';
  static const String categoriesSubtitle =
      'Pick from these when you create a project.';
  static const String categoryRemovedToast = 'Category removed.';
  static const String categoryExistsToast = 'Category already exists!';
  static const String categoryAddedToast = 'Category added';
  static const String addCategoryPlaceholder = 'e.g. SaaS development';
  static const String tipTitle = 'Tip';
  static const String categoriesTip =
      'Removing a category does not change existing projects.';

  // Legal clauses screen (ST7)
  static const String legalClausesTitle = 'Legal clauses';
  static const String legalClausesSubtitle =
      'Boilerplate terms added to generated agreements.';
  static String charactersCount(int count) => '$count characters';
  static const String saveClausesButton = 'Save clauses template';
  static const String legalClausesUpdatedToast = 'Legal clauses updated';
}
