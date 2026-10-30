import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_toast.dart';
import '../auth/data/auth_service.dart';
import 'settings_about_strings.dart';
import 'widgets/about_sign_out_sheet.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_row.dart';

/// Screen displaying About and Support information per `docs/design/SPEC.md` (ST12, ST14).
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Object? _lastHandledExtra;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingExtra();
  }

  void _handleIncomingExtra() {
    Object? extra;
    try {
      extra = GoRouterState.of(context).extra;
    } catch (_) {
      // In case GoRouter is not available in the context tree.
    }

    if (extra != null && !identical(extra, _lastHandledExtra)) {
      _lastHandledExtra = extra;
      String? message;

      if (extra is String) {
        message = extra;
      } else if (extra is Map) {
        final Object? toastValue = extra['toast'];
        if (toastValue is String) {
          message = toastValue;
        }
      }

      if (message != null && message.trim().isNotEmpty) {
        final String toastMessage = message;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context, toastMessage);
          }
        });
      }
    }
  }

  void _showSignOutConfirmSheet(BuildContext context) {
    AboutSignOutSheetContent.show(
      context,
      onConfirm: () async {
        await AuthScope.of(context).signOut();
        if (context.mounted) context.go(AppRoutes.welcomePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              title: SettingsAboutStrings.aboutTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.settingsPath),
            ),
            const SizedBox(height: AppSpacing.lg),

            // App Brand Card (icon, name, version, tagline)
            SettingsGroupCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'D',
                      style: AppText.sectionTitleLg.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  SettingsAboutStrings.appName,
                  textAlign: TextAlign.center,
                  style: AppText.sectionTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SettingsAboutStrings.appVersion,
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(
                    color: AppColors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  SettingsAboutStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: AppText.bodyMedium.copyWith(
                    color: AppColors.mute,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Navigation rows (Support ticket, Privacy policy, Terms and conditions)
            SettingsGroupCard(
              children: [
                SettingsRow(
                  iconData: AppIcons.lifeBuoy,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsAboutStrings.supportTicketRowTitle,
                  subtitle: SettingsAboutStrings.supportTicketRowSubtitle,
                  onTap: () => context.push(AppRoutes.settingsSupportPath),
                ),
                SettingsRow(
                  iconData: AppIcons.shield,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsAboutStrings.privacyPolicyRowTitle,
                  subtitle: SettingsAboutStrings.privacyPolicyRowSubtitle,
                  onTap: () => context.push(AppRoutes.settingsPrivacyPath),
                ),
                SettingsRow(
                  iconData: AppIcons.fileText,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsAboutStrings.termsConditionsRowTitle,
                  subtitle: SettingsAboutStrings.termsConditionsRowSubtitle,
                  onTap: () => context.push(AppRoutes.settingsTermsPath),
                  last: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Red "Sign out" card
            SettingsGroupCard(
              children: [
                InkWell(
                  onTap: () => _showSignOutConfirmSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.redBg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            SettingsAboutStrings.signOutRowTitle,
                            style: AppText.cardTitle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.red,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
