import 'package:flutter/material.dart';

/// Design colour tokens from `docs/design/SPEC.md`.
///
/// All colours in the application must reference this class.
abstract final class AppColors {
  static const Color bg = Color(0xFFFBF7F0);
  static const Color ink = Color(0xFF1B1B1F);
  static const Color mute = Color(0xFF6B6B76);
  static const Color placeholder = Color(0xFFA8A8B3);
  static const Color card = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE8E1D5);
  static const Color seg = Color(0xFFEFE9DD);

  static const Color orange = Color(0xFFF4955F);
  static const Color orangeBg = Color(0xFFFDF0E8);
  static const Color inProgressBg = Color(0xFFFFF0E4);
  static const Color purple = Color(0xFF8F81EE);
  static const Color purpleBg = Color(0xFFF1EFFD);
  static const Color waitingClientBg = Color(0xFFEFEBFF);
  static const Color plannedBg = Color(0xFFEFE9DD);
  static const Color yellow = Color(0xFFFFD557);
  static const Color coral = Color(0xFFF0675A);

  static const Color green = Color(0xFF1E8A4C);
  static const Color greenBg = Color(0xFFE4F6E9);
  static const Color red = Color(0xFFD32F2F);
  static const Color redBg = Color(0xFFFFF0F0);

  /// 50% ink scrim used behind modal bottom sheets.
  static const Color scrim = Color(0x801B1B1F);
  static const Color transparent = Color(0x00000000);

  /// Background colour for the CCP payment method badge per SPEC.md (`#FFF3CC`).
  static const Color ccpBg = Color(0xFFFFF3CC);

  /// Expense category background tokens per SPEC.md.
  static const Color softwareBg = Color(0xFFEFEBFF);
  static const Color hostingBg = Color(0xFFFFF0E4);
  static const Color marketingBg = Color(0xFFFFE9E6);
  static const Color equipmentBg = greenBg;
  static const Color othersBg = seg;
}
