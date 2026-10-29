/// Spacing, sizing, and border-radius constants from `docs/design/SPEC.md`.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal screen padding (24 logical px).
  static const double pageGutter = 24;

  /// Standard stroke width for cards, inputs, and secondary buttons.
  static const double borderWidth = 1.5;

  static const double buttonHeight = 56;
  static const double inputHeight = 56;
  static const double searchHeight = 52;
  static const double iconButtonSize = 44;
  static const double tabBarHeight = 80;

  static const double grabberWidth = 60;
  static const double grabberHeight = 5;
}

/// Corner radii from `docs/design/SPEC.md`.
abstract final class AppRadius {
  static const double otp = 14;
  static const double input = 16;
  static const double cardSmall = 20;
  static const double card = 24;
  static const double search = 26;
  static const double button = 28;
  static const double panel = 36;
  static const double pill = 999;
}
