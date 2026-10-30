import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/primary_button.dart';
import 'settings_privacy_strings.dart';

/// Screen displayed after successful account deletion per `docs/design/SPEC.md` (PS7).
class AccountDeletedScreen extends StatelessWidget {
  const AccountDeletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Yellow panel with green check icon
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(AppRadius.panel),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.green,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Title
                Text(
                  SettingsPrivacyStrings.accountDeletedTitle,
                  style: AppText.title.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Subtitle / explanation
                Text(
                  SettingsPrivacyStrings.accountDeletedBody,
                  style: AppText.body.copyWith(
                    color: AppColors.mute,
                    fontSize: 15,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),
                const SizedBox(height: AppSpacing.xl),

                // Back to welcome
                PrimaryButton(
                  label: SettingsPrivacyStrings.backToWelcomeButton,
                  onPressed: () => context.go(AppRoutes.welcomePath),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
