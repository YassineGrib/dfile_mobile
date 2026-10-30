import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_privacy_strings.dart';
import 'settings_strings.dart';
import 'widgets/widgets.dart';

/// Screen displaying the Settings Hub per `docs/design/SPEC.md` (ST1, ST16).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.morePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final UserProfile profile = settingsRepo.profile;

    final String initial = profile.name.trim().isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : 'Y';

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.moreTabIndex,
      ),
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
            // Top back button
            Align(
              alignment: Alignment.centerLeft,
              child: RoundIconButton(
                icon: Icons.arrow_back,
                onPressed: () => _handleBack(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              SettingsStrings.title,
              style: AppText.title,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile Card (ST1)
            Material(
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                side: const BorderSide(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.go(AppRoutes.settingsProfilePath);
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: AppText.cardTitle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.name,
                              style: AppText.cardTitle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.designation,
                              style: AppText.caption.copyWith(
                                color: AppColors.mute,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email,
                              style: AppText.caption.copyWith(
                                color: AppColors.mute,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.placeholder,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 6 Settings Rows
            SettingsGroupCard(
              children: [
                SettingsRow(
                  iconData: AppIcons.user,
                  iconBgColor: AppColors.greenBg,
                  iconTextColor: AppColors.green,
                  title: SettingsStrings.accountTitle,
                  subtitle: SettingsStrings.accountSubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsProfilePath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.slidersHorizontal,
                  iconBgColor: AppColors.waitingClientBg,
                  iconTextColor: AppColors.purple,
                  title: SettingsStrings.preferencesTitle,
                  subtitle: SettingsStrings.preferencesSubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsPreferencesPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.shieldCheck,
                  iconBgColor: AppColors.inProgressBg,
                  iconTextColor: AppColors.orange,
                  title: SettingsStrings.securityTitle,
                  subtitle: SettingsStrings.securitySubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsSecurityPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.plug,
                  iconBgColor: AppColors.ccpBg,
                  iconTextColor: AppColors.ink,
                  title: SettingsStrings.integrationsTitle,
                  subtitle: SettingsStrings.integrationsSubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsIntegrationsPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.bell,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsStrings.notificationsTitle,
                  subtitle: SettingsStrings.notificationsSubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsNotificationsPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.database,
                  iconBgColor: AppColors.greenBg,
                  iconTextColor: AppColors.green,
                  title: SettingsPrivacyStrings.privacyDataTitle,
                  subtitle: SettingsPrivacyStrings.privacyDataSubtitle,
                  onTap: () {
                    context.go(AppRoutes.settingsPrivacyDataPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.info,
                  iconBgColor: AppColors.redBg,
                  iconTextColor: AppColors.red,
                  title: SettingsStrings.aboutTitle,
                  subtitle: SettingsStrings.aboutSubtitle,
                  last: true,
                  onTap: () {
                    context.go(AppRoutes.settingsAboutPath);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Footer
            Center(
              child: Text(
                SettingsStrings.footer,
                style: AppText.caption.copyWith(
                  color: AppColors.placeholder,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
