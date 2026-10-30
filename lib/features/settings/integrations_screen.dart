import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/status_pill.dart';
import '../clients/data/data.dart';
import '../expenses/data/data.dart';
import '../friends/data/data.dart';
import '../projects/data/data.dart';
import 'data/backup_builder.dart';
import 'data/settings_repository.dart';
import 'data/settings_scope.dart';
import 'settings_about_strings.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';

/// Screen for managing cloud sync, integrations, and workspace backup per `docs/design/SPEC.md` (ST10).
class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  void _handleBackup(BuildContext context) {
    final ClientsRepository clientsRepo =
        ClientsScope.of(context, listen: false);
    final ProjectsRepository projectsRepo =
        ProjectsScope.of(context, listen: false);
    final ExpensesRepository expensesRepo =
        ExpensesScope.of(context, listen: false);
    final FriendsRepository friendsRepo =
        FriendsScope.of(context, listen: false);
    final SettingsRepository settingsRepo =
        SettingsScope.of(context, listen: false);

    final String backupJson = buildWorkspaceBackupJson(
      clientsRepository: clientsRepo,
      projectsRepository: projectsRepo,
      expensesRepository: expensesRepo,
      friendsRepository: friendsRepo,
      settingsRepository: settingsRepo,
    );

    Clipboard.setData(ClipboardData(text: backupJson));
    showAppToast(context, SettingsAboutStrings.backupCopiedToast);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final bool isGoogleConnected = settingsRepo.googleConnected;

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
              title: SettingsAboutStrings.integrationsTitle,
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.settingsPath),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Cloud sync card (static Connected, Firebase Cloud Firestore)
            SettingsGroupCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.orangeBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'F',
                        style: AppText.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  SettingsAboutStrings.cloudSyncTitle,
                                  style: AppText.cardTitle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const StatusPill.active(
                                label: SettingsAboutStrings.cloudConnected,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SettingsAboutStrings.cloudSyncProvider,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, thickness: 1, color: AppColors.line),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.sync_rounded,
                      size: 16,
                      color: AppColors.mute,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        SettingsAboutStrings.cloudLastSynced,
                        style: AppText.caption.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Google Calendar card
            SettingsGroupCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.seg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'G',
                        style: AppText.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.googleBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SettingsAboutStrings.googleCalendarTitle,
                            style: AppText.cardTitle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SettingsAboutStrings.googleCalendarSubtitle,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isGoogleConnected)
                  SecondaryButton(
                    label: SettingsAboutStrings.disconnect,
                    onPressed: () {
                      settingsRepo.setGoogleConnected(false);
                      showAppToast(
                        context,
                        SettingsAboutStrings.googleUnlinkedToast,
                      );
                    },
                  )
                else
                  PrimaryButton(
                    label: SettingsAboutStrings.connectAccount,
                    onPressed: () {
                      settingsRepo.setGoogleConnected(true);
                      showAppToast(
                        context,
                        SettingsAboutStrings.googleLinkedToast,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Export and backup card
            SettingsGroupCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.seg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.ink,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SettingsAboutStrings.exportBackupTitle,
                            style: AppText.cardTitle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SettingsAboutStrings.exportBackupSubtitle,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: SettingsAboutStrings.downloadBackupButton,
                  onPressed: () => _handleBackup(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
