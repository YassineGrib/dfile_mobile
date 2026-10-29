import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Selectable filled/outline stadium pill (radius = height / 2).
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.height = 38,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: selected ? AppColors.ink : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
          side: selected
              ? BorderSide.none
              : const BorderSide(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                label,
                style: AppText.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.mute,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
