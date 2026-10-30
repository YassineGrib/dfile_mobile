import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Labelled tappable selector field matching CL8/CL9 design.
class CalendarFormsSelectField extends StatelessWidget {
  const CalendarFormsSelectField({
    super.key,
    this.label,
    this.value,
    this.placeholder,
    required this.onTap,
    this.leading,
    this.trailing,
    this.hasError = false,
    this.errorText,
  });

  final String? label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
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
        if (label != null) ...[
          Text(
            label!,
            style: AppText.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
