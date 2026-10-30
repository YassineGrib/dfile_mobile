import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/privacy_export.dart';
import 'settings_privacy_strings.dart';
import 'widgets/privacy_danger_button.dart';
import 'widgets/settings_header.dart';

/// Step 1 of the account deletion flow per `docs/design/SPEC.md` (PS3).
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPrivacyDataPath);
    }
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: AppSpacing.md),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: AppSpacing.md,
              ),
              child: SettingsHeader(
                title: SettingsPrivacyStrings.deleteAccountTitle,
                onBack: () => _handleBack(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                children: [
                  // Red warning card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.redBg,
                      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.35),
                        width: AppSpacing.borderWidth,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.red,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                SettingsPrivacyStrings.permanentWarningTitle,
                                style: AppText.cardTitle.copyWith(
                                  color: AppColors.red,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          SettingsPrivacyStrings.permanentWarningBody,
                          style: AppText.body.copyWith(
                            color: AppColors.ink,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // What will be deleted
                  Text(
                    SettingsPrivacyStrings.whatWillBeDeletedTitle,
                    style: AppText.cardTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        _buildDeleteItem(SettingsPrivacyStrings.itemProfile),
                        _buildDeleteItem(SettingsPrivacyStrings.itemClients),
                        _buildDeleteItem(SettingsPrivacyStrings.itemProjects),
                        _buildDeleteItem(SettingsPrivacyStrings.itemExpenses),
                        _buildDeleteItem(SettingsPrivacyStrings.itemFriends),
                        _buildDeleteItem(SettingsPrivacyStrings.itemSettings),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // No copy kept
                  Text(
                    SettingsPrivacyStrings.noCopyKept,
                    style: AppText.caption.copyWith(
                      color: AppColors.mute,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  top: BorderSide(
                    color: AppColors.line,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: SettingsPrivacyStrings.exportFirstButton,
                      onPressed: () async {
                        await PrivacyDataExporter.copyToClipboard(context);
                        if (context.mounted) {
                          showAppToast(
                            context,
                            SettingsPrivacyStrings.backupCopiedToast,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrivacyDangerButton(
                      label: SettingsPrivacyStrings.continueButton,
                      onPressed: () {
                        context.push(AppRoutes.settingsDeleteAccountConfirmPath);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
