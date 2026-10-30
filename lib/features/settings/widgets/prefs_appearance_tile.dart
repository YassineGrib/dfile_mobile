import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Single theme appearance option tile matching SPEC.md (ST5).
class PrefsAppearanceTile extends StatelessWidget {
  const PrefsAppearanceTile({
    super.key,
    required this.label,
    required this.indicatorColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color indicatorColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        side: isSelected
            ? const BorderSide(
                color: AppColors.ink,
                width: 2.0,
              )
            : const BorderSide(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppText.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.ink : AppColors.mute,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
