import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/privacy_export.dart';
import 'settings_privacy_strings.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_section_label.dart';

/// Privacy centre screen per `docs/design/SPEC.md` (PS2).
class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
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
              title: SettingsPrivacyStrings.privacyDataTitle,
              onBack: () => _handleBack(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Intro card (Your data belongs to you)
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
                  Text(
                    SettingsPrivacyStrings.dataBelongsToYouTitle,
                    style: AppText.cardTitle.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    SettingsPrivacyStrings.dataBelongsToYouBody,
                    style: AppText.body.copyWith(
                      color: AppColors.mute,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action rows
            SettingsGroupCard(
              children: [
                SettingsRow(
                  iconData: AppIcons.shield,
                  iconBgColor: AppColors.waitingClientBg,
                  iconTextColor: AppColors.purple,
                  title: SettingsPrivacyStrings.privacyPolicyTitle,
                  subtitle: SettingsPrivacyStrings.privacyPolicySubtitle,
                  onTap: () => context.push(AppRoutes.settingsPrivacyPath),
                ),
                SettingsRow(
                  iconData: AppIcons.fileText,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsPrivacyStrings.termsTitle,
                  subtitle: SettingsPrivacyStrings.termsSubtitle,
                  onTap: () => context.push(AppRoutes.settingsTermsPath),
                ),
                SettingsRow(
                  iconData: AppIcons.eye,
                  iconBgColor: AppColors.inProgressBg,
                  iconTextColor: AppColors.orange,
                  title: SettingsPrivacyStrings.howWeUseDataTitle,
                  subtitle: SettingsPrivacyStrings.howWeUseDataSubtitle,
                  onTap: () => context.push(AppRoutes.settingsDataUsagePath),
                ),
                SettingsRow(
                  iconData: AppIcons.download,
                  iconBgColor: AppColors.greenBg,
                  iconTextColor: AppColors.green,
                  title: SettingsPrivacyStrings.exportDataTitle,
                  subtitle: SettingsPrivacyStrings.exportDataSubtitle,
                  last: true,
                  onTap: () async {
                    await PrivacyDataExporter.copyToClipboard(context);
                    if (context.mounted) {
                      showAppToast(
                        context,
                        SettingsPrivacyStrings.backupCopiedToast,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Danger Zone
            const SettingsSectionLabel(SettingsPrivacyStrings.dangerZoneTitle),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: AppColors.red.withValues(alpha: 0.35),
                  width: AppSpacing.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SettingsRow(
                iconData: AppIcons.trash2,
                iconBgColor: AppColors.redBg,
                iconTextColor: AppColors.red,
                title: SettingsPrivacyStrings.deleteAccountTitle,
                subtitle: SettingsPrivacyStrings.deleteAccountSubtitle,
                last: true,
                onTap: () => context.push(AppRoutes.settingsDeleteAccountPath),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
