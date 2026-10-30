import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Small uppercase section header label per `docs/design/SPEC.md` (ST8, ST11).
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppText.caption.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.mute,
        letterSpacing: 0.5,
      ),
    );
  }
}
