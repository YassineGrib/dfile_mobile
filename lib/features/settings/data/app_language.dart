/// Supported application languages per `docs/design/SPEC.md`.
enum AppLanguage {
  en('en', 'English'),
  ar('ar', 'العربية');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (AppLanguage l) => l.code == code,
      orElse: () => AppLanguage.en,
    );
  }
}
