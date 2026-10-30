import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Full-rounded red danger action button (height 56, radius 28) per `docs/design/SPEC.md`.
class PrivacyDangerButton extends StatelessWidget {
  const PrivacyDangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    final Widget content = Center(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.button,
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSpacing.buttonHeight,
      child: Material(
        color: enabled ? AppColors.red : AppColors.red.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: content,
          ),
        ),
      ),
    );
  }
}
