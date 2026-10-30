import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_security_strings.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_section_label.dart';
import 'widgets/settings_toggle_row.dart';

/// Screen for managing push notifications and notification alerts per `docs/design/SPEC.md` (ST11).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
  }

  void _handleUpdate(
    BuildContext context,
    SettingsRepository repo,
    NotificationPrefs updatedPrefs,
  ) {
    repo.updateNotifications(updatedPrefs);
    showAppToast(
      context,
      SettingsSecurityStrings.notificationPreferencesSavedToast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);
    final NotificationPrefs notifications = repo.notifications;
    final bool pushEnabled = notifications.push;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: SettingsHeader(
                title: SettingsSecurityStrings.notificationsTitle,
                onBack: () => _handleBack(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                  AppSpacing.pageGutter,
                  AppSpacing.xxl,
                ),
                children: [
                  // Master Card: Push notification alerts
                  SettingsGroupCard(
                    children: [
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.pushNotificationAlerts,
                        subtitle:
                            SettingsSecurityStrings.pushNotificationSubtitle,
                        value: pushEnabled,
                        last: true,
                        onChanged: (bool value) {
                          _handleUpdate(
                            context,
                            repo,
                            notifications.copyWith(push: value),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Section label: WHAT TO NOTIFY
                  const SettingsSectionLabel(
                    SettingsSecurityStrings.whatToNotifySection,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // What to notify group
                  SettingsGroupCard(
                    children: [
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.projectDeadlines,
                        subtitle:
                            SettingsSecurityStrings.projectDeadlinesSubtitle,
                        value: notifications.deadlines,
                        enabled: pushEnabled,
                        onChanged: pushEnabled
                            ? (bool value) {
                                _handleUpdate(
                                  context,
                                  repo,
                                  notifications.copyWith(deadlines: value),
                                );
                              }
                            : null,
                      ),
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.paymentReminders,
                        subtitle:
                            SettingsSecurityStrings.paymentRemindersSubtitle,
                        value: notifications.payments,
                        enabled: pushEnabled,
                        onChanged: pushEnabled
                            ? (bool value) {
                                _handleUpdate(
                                  context,
                                  repo,
                                  notifications.copyWith(payments: value),
                                );
                              }
                            : null,
                      ),
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.taskUpdates,
                        subtitle: SettingsSecurityStrings.taskUpdatesSubtitle,
                        value: notifications.tasks,
                        enabled: pushEnabled,
                        last: true,
                        onChanged: pushEnabled
                            ? (bool value) {
                                _handleUpdate(
                                  context,
                                  repo,
                                  notifications.copyWith(tasks: value),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Footer note
                  Center(
                    child: Text(
                      SettingsSecurityStrings.changesSavedAutomatically,
                      style: AppText.caption.copyWith(
                        color: AppColors.mute,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
