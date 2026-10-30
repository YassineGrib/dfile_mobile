import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'settings_switch.dart';

/// Row displaying a title, subtitle, and [SettingsSwitch] inside a card.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.last = false,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppText.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.ink : AppColors.mute,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(
                      color: enabled ? AppColors.mute : AppColors.placeholder,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SettingsSwitch(
            value: value,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        if (!last)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.lg),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.line,
            ),
          ),
      ],
    );
  }
}
