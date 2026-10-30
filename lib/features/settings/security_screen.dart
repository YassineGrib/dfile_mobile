import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_security_strings.dart';
import 'widgets/security_pin_sheet.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_toggle_row.dart';

/// Screen for managing PIN lock, fingerprint, and active sessions per `docs/design/SPEC.md` (ST8).
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
  }

  void _openPinSheet(BuildContext context, {bool isChanging = false}) {
    showSecurityPinSheet(context, isChanging: isChanging);
  }

  Widget _buildSessionRow(DeviceSession session) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: session.isCurrent ? AppColors.greenBg : AppColors.seg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            session.isCurrent
                ? Icons.phone_android_rounded
                : Icons.laptop_mac_rounded,
            size: 20,
            color: session.isCurrent ? AppColors.green : AppColors.mute,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.name,
                style: AppText.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                session.detail,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);
    final List<DeviceSession> sessions = repo.sessions;
    final bool hasOtherSessions = sessions.any(
      (DeviceSession s) => !s.isCurrent,
    );

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
                title: SettingsSecurityStrings.securityTitle,
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
                  // Card 1: Numeric PIN lock
                  SettingsGroupCard(
                    children: [
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.numericPinLock,
                        subtitle: SettingsSecurityStrings.numericPinSubtitle,
                        value: repo.pinEnabled,
                        last: !repo.pinEnabled,
                        onChanged: (bool value) {
                          if (value) {
                            _openPinSheet(context, isChanging: false);
                          } else {
                            repo.setPinEnabled(false);
                            showAppToast(
                              context,
                              SettingsSecurityStrings.pinLockDisabledToast,
                            );
                          }
                        },
                      ),
                      if (repo.pinEnabled)
                        SettingsRow(
                          title: SettingsSecurityStrings.changePin,
                          last: true,
                          onTap: () => _openPinSheet(context, isChanging: true),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Card 2: Fingerprint unlock
                  SettingsGroupCard(
                    children: [
                      SettingsToggleRow(
                        title: SettingsSecurityStrings.fingerprintUnlock,
                        subtitle: SettingsSecurityStrings.fingerprintSubtitle,
                        value: repo.biometricsEnabled,
                        last: true,
                        onChanged: (bool value) {
                          showAppToast(
                            context,
                            SettingsSecurityStrings.notAvailableInDemoToast,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Card 3: Active sessions
                  SettingsGroupCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Text(
                        SettingsSecurityStrings.activeSessions,
                        style: AppText.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SettingsSecurityStrings.activeSessionsSubtitle,
                        style: AppText.caption.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (int i = 0; i < sessions.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        _buildSessionRow(sessions[i]),
                      ],
                      if (hasOtherSessions) ...[
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeight,
                          child: Material(
                            color: AppColors.card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.button,
                              ),
                              side: const BorderSide(
                                color: AppColors.red,
                                width: AppSpacing.borderWidth,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                repo.terminateOtherSessions();
                                showAppToast(
                                  context,
                                  SettingsSecurityStrings
                                      .loggedOutOtherSessionsToast,
                                );
                              },
                              child: Center(
                                child: Text(
                                  SettingsSecurityStrings
                                      .terminateOtherSessions,
                                  style: AppText.button.copyWith(
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
