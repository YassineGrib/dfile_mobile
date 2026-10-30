import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/secondary_button.dart';
import '../settings_about_strings.dart';

/// Modal bottom sheet content for confirming sign out per `docs/design/SPEC.md` (ST14).
class AboutSignOutSheetContent extends StatelessWidget {
  const AboutSignOutSheetContent({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  /// Helper to display the sign-out confirmation sheet using [showAppSheet].
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return AboutSignOutSheetContent(
          onConfirm: () {
            Navigator.of(sheetContext).pop();
            onConfirm();
          },
          onCancel: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Warning / Sign-out icon in red badge
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.redBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.red,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            SettingsAboutStrings.signOutSheetTitle,
            textAlign: TextAlign.center,
            style: AppText.sectionTitle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            SettingsAboutStrings.signOutSheetSubtitle,
            textAlign: TextAlign.center,
            style: AppText.bodyBold.copyWith(
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Explanation
          Text(
            SettingsAboutStrings.signOutSheetDescription,
            textAlign: TextAlign.center,
            style: AppText.bodyMedium.copyWith(
              fontSize: 14,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Primary destructive [Sign out] button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: Material(
              color: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onConfirm,
                child: Center(
                  child: Text(
                    SettingsAboutStrings.signOutConfirmButton,
                    style: AppText.button.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // [Cancel] button
          SecondaryButton(
            label: SettingsAboutStrings.cancelButton,
            onPressed: onCancel,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
