import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../calendar_forms_strings.dart';

/// Fixed bottom action bar that stays visible above the software keyboard matching CL8/CL9.
class CalendarFormsBottomBar extends StatelessWidget {
  const CalendarFormsBottomBar({
    super.key,
    this.primaryLabel = CalendarFormsStrings.registerMilestone,
    required this.onPrimaryPressed,
    this.secondaryLabel = CalendarFormsStrings.cancel,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.line, width: AppSpacing.borderWidth),
        ),
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
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SecondaryButton(
                  label: secondaryLabel,
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
