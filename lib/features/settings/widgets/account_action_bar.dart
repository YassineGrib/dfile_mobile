import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../settings_account_strings.dart';

/// Fixed bottom action bar for account settings forms docked above the software keyboard.
class AccountActionBar extends StatelessWidget {
  const AccountActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel = SettingsAccountStrings.cancel,
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
