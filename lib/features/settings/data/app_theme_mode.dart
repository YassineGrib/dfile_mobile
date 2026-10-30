/// Supported application theme modes per `docs/design/SPEC.md`.
enum AppThemeMode {
  light('light', 'Light'),
  dark('dark', 'Dark'),
  system('system', 'System');

  const AppThemeMode(this.code, this.label);

  final String code;
  final String label;

  static AppThemeMode fromCode(String code) {
    return AppThemeMode.values.firstWhere(
      (AppThemeMode m) => m.code == code,
      orElse: () => AppThemeMode.light,
    );
  }
}
