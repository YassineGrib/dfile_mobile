import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'settings_privacy_strings.dart';
import 'widgets/settings_header.dart';

/// Data usage transparency screen per `docs/design/SPEC.md` (PS10).
class DataUsageScreen extends StatelessWidget {
  const DataUsageScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPrivacyDataPath);
    }
  }

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String details,
    required String usedFor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            details,
            style: AppText.body.copyWith(
              color: AppColors.mute,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.seg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              usedFor,
              style: AppText.caption.copyWith(
                color: AppColors.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          children: [
            SettingsHeader(
              title: SettingsPrivacyStrings.howWeUseDataScreenTitle,
              onBack: () => _handleBack(context),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Transparency Chips
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildChip(
                  SettingsPrivacyStrings.chipNeverSold,
                  AppColors.greenBg,
                  AppColors.green,
                ),
                _buildChip(
                  SettingsPrivacyStrings.chipNoAds,
                  AppColors.waitingClientBg,
                  AppColors.purple,
                ),
                _buildChip(
                  SettingsPrivacyStrings.chipEncrypted,
                  AppColors.inProgressBg,
                  AppColors.orange,
                ),
                _buildChip(
                  SettingsPrivacyStrings.chipDeletable,
                  AppColors.redBg,
                  AppColors.red,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Data categories
            _buildCategoryCard(
              title: SettingsPrivacyStrings.profileTitle,
              details: SettingsPrivacyStrings.profileDetails,
              usedFor: SettingsPrivacyStrings.profileUsedFor,
            ),
            _buildCategoryCard(
              title: SettingsPrivacyStrings.clientsProjectsTitle,
              details: SettingsPrivacyStrings.clientsProjectsDetails,
              usedFor: SettingsPrivacyStrings.clientsProjectsUsedFor,
            ),
            _buildCategoryCard(
              title: SettingsPrivacyStrings.paymentsExpensesTitle,
              details: SettingsPrivacyStrings.paymentsExpensesDetails,
              usedFor: SettingsPrivacyStrings.paymentsExpensesUsedFor,
            ),
            _buildCategoryCard(
              title: SettingsPrivacyStrings.appSettingsTitle,
              details: SettingsPrivacyStrings.appSettingsDetails,
              usedFor: SettingsPrivacyStrings.appSettingsUsedFor,
            ),
            const SizedBox(height: AppSpacing.md),

            // Delete your data any time card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                border: Border.all(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          SettingsPrivacyStrings.deleteAnytimeTitle,
                          style: AppText.cardTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    SettingsPrivacyStrings.deleteAnytimeInApp,
                    style: AppText.body.copyWith(
                      color: AppColors.mute,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    SettingsPrivacyStrings.deleteAnytimeWeb,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
