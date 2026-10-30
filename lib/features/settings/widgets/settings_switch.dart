import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// 48x28 green toggle switch matching ST8 and ST11 per `docs/design/SPEC.md`.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  static const double trackWidth = 48.0;
  static const double trackHeight = 28.0;
  static const double knobSize = 24.0;
  static const double knobPadding = 2.0;

  void _handleTap() {
    if (!enabled || onChanged == null) return;
    onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final Color trackColor;
    if (!enabled) {
      trackColor = value
          ? AppColors.green.withValues(alpha: 0.4)
          : AppColors.line.withValues(alpha: 0.6);
    } else {
      trackColor = value ? AppColors.green : AppColors.line;
    }

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: trackWidth,
        height: trackHeight,
        padding: const EdgeInsets.all(knobPadding),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(trackHeight / 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: knobSize,
            height: knobSize,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
