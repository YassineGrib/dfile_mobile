import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

/// Labelled tappable selector box matching PY9 (height 56, radius 16, card bg, 1.5px border).
class RecordPaymentSelectField extends StatelessWidget {
  const RecordPaymentSelectField({
    super.key,
    this.label,
    this.trailingLabel,
    this.value,
    this.placeholder,
    required this.onTap,
    this.leading,
    this.showArrow = true,
    this.hasError = false,
    this.errorText,
  });

  final String? label;
  final Widget? trailingLabel;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? leading;
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
              if (showArrow) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 22,
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
        if (label != null || trailingLabel != null) ...[
          if (trailingLabel != null)
            Row(
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
                const SizedBox(width: AppSpacing.xs),
                trailingLabel!,
              ],
            )
          else if (label != null)
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

/// Fixed bottom action bar that stays visible above the software keyboard matching PY9.
class RecordPaymentBottomBar extends StatelessWidget {
  const RecordPaymentBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: secondaryLabel == null
              ? PrimaryButton(label: primaryLabel, onPressed: onPrimaryPressed)
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SecondaryButton(
                        label: secondaryLabel!,
                        onPressed: onSecondaryPressed,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: primaryLabel,
                        onPressed: onPrimaryPressed,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
