import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Top bar used across settings screens with a centred title.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.title,
    this.rightAction,
    this.onBack,
  });

  final String title;
  final Widget? rightAction;

  /// Kept so existing callers compile; the header no longer shows a back button.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.iconButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              title,
              style: AppText.cardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rightAction != null)
            Align(alignment: Alignment.centerRight, child: rightAction!),
        ],
      ),
    );
  }
}
