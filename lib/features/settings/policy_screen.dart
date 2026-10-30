import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'data/policy_kind.dart';
import 'settings_about_strings.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';

/// Screen displaying either Privacy Policy or Terms & Conditions per `docs/design/SPEC.md` (ST15).
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.kind});

  final PolicyKind kind;

  @override
  Widget build(BuildContext context) {
    final bool isPrivacy = kind == PolicyKind.privacy;

    final String title = isPrivacy
        ? SettingsAboutStrings.privacyPolicyTitle
        : SettingsAboutStrings.termsConditionsTitle;

    final String heading = isPrivacy
        ? SettingsAboutStrings.privacyPolicyHeading
        : SettingsAboutStrings.termsConditionsHeading;

    final List<(String, String)> sections = isPrivacy
        ? <(String, String)>[
            (
              SettingsAboutStrings.privacyStoreTitle,
              SettingsAboutStrings.privacyStoreBody,
            ),
            (
              SettingsAboutStrings.privacyNeverTitle,
              SettingsAboutStrings.privacyNeverBody,
            ),
            (
              SettingsAboutStrings.privacyChoicesTitle,
              SettingsAboutStrings.privacyChoicesBody,
            ),
          ]
        : <(String, String)>[
            (
              SettingsAboutStrings.termsLicenseTitle,
              SettingsAboutStrings.termsLicenseBody,
            ),
            (
              SettingsAboutStrings.termsContentTitle,
              SettingsAboutStrings.termsContentBody,
            ),
            (
              SettingsAboutStrings.termsUsageTitle,
              SettingsAboutStrings.termsUsageBody,
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          children: [
            SettingsHeader(
              title: title,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.settingsPath),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Top section heading
            Text(
              heading,
              style: AppText.sectionTitle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3 static titled cards
            for (final (String cardTitle, String cardBody) in sections) ...[
              SettingsGroupCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    cardTitle,
                    style: AppText.cardTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    cardBody,
                    style: AppText.bodyMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.ink,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            const SizedBox(height: AppSpacing.md),

            // Footer
            Center(
              child: Text(
                SettingsAboutStrings.policyLastUpdated,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
