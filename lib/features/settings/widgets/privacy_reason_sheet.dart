import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../settings_privacy_strings.dart';

/// Bottom sheet allowing the user to pick an optional reason for deleting their account.
Future<String?> showPrivacyReasonSheet({
  required BuildContext context,
  String? currentReason,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            SettingsPrivacyStrings.reasonSheetTitle,
            style: AppText.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...SettingsPrivacyStrings.reasons.map((String reason) {
            final bool isSelected = reason == currentReason;
            return InkWell(
              onTap: () => Navigator.of(sheetContext).pop(reason),
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.seg : AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        reason,
                        style: AppText.bodyMedium.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_rounded,
                        color: AppColors.ink,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],
      );
    },
  );
}
