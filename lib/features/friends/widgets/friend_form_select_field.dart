import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Labelled selector box matching FD11 (height min 56, radius 16, card bg, 1.5px border).
class FriendFormSelectField extends StatelessWidget {
  const FriendFormSelectField({
    super.key,
    this.label,
    this.topTrailing,
    this.value,
    this.placeholder,
    required this.onTap,
    this.leading,
    this.trailing,
    this.showArrow = true,
    this.hasError = false,
    this.errorText,
  });

  final String? label;
  final Widget? topTrailing;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool showArrow;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.trim().isNotEmpty;

    final Widget box = Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: hasError ? AppColors.red : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.inputHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  hasValue ? value! : (placeholder ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hasValue
                      ? AppText.body
                      : AppText.body.copyWith(color: AppColors.placeholder),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showArrow) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 24,
                  color: AppColors.mute,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || topTrailing != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: AppText.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ?topTrailing,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        box,
        if (hasError && errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppText.captionSm.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
