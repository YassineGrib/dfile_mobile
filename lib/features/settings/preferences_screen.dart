import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_prefs_strings.dart';
import 'widgets/prefs_appearance_tile.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_section_label.dart';

/// Screen for managing application preferences (ST5).
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final AppLanguage language = settingsRepo.language;
    final AppThemeMode themeMode = settingsRepo.themeMode;
    final int categoryCount = settingsRepo.categories.length;

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
              title: SettingsPrefsStrings.preferencesTitle,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Language section
            const SettingsSectionLabel(SettingsPrefsStrings.languageSection),
            const SizedBox(height: AppSpacing.sm),
            SegmentedToggle(
              options: const <String>[
                SettingsPrefsStrings.languageEnglish,
                SettingsPrefsStrings.languageArabic,
              ],
              selectedIndex: language == AppLanguage.ar ? 1 : 0,
              onChanged: (int index) {
                if (index == 1) {
                  showAppToast(
                    context,
                    SettingsPrefsStrings.arabicComingSoonToast,
                  );
                } else {
                  settingsRepo.setLanguage(AppLanguage.en);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Appearance section
            const SettingsSectionLabel(SettingsPrefsStrings.appearanceSection),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: PrefsAppearanceTile(
                    label: SettingsPrefsStrings.themeLight,
                    indicatorColor: AppColors.yellow,
                    isSelected: themeMode == AppThemeMode.light,
                    onTap: () {
                      settingsRepo.setThemeMode(AppThemeMode.light);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrefsAppearanceTile(
                    label: SettingsPrefsStrings.themeDark,
                    indicatorColor: AppColors.ink,
                    isSelected: themeMode == AppThemeMode.dark,
                    onTap: () {
                      showAppToast(
                        context,
                        SettingsPrefsStrings.darkThemeComingSoonToast,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrefsAppearanceTile(
                    label: SettingsPrefsStrings.themeSystem,
                    indicatorColor: AppColors.seg,
                    isSelected: themeMode == AppThemeMode.system,
                    onTap: () {
                      showAppToast(
                        context,
                        SettingsPrefsStrings.darkThemeComingSoonToast,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Workspace section
            const SettingsSectionLabel(SettingsPrefsStrings.workspaceSection),
            const SizedBox(height: AppSpacing.sm),
            SettingsGroupCard(
              children: [
                SettingsRow(
                  iconData: AppIcons.typeIcon,
                  iconBgColor: AppColors.seg,
                  iconTextColor: AppColors.ink,
                  title: SettingsPrefsStrings.fontStyleTitle,
                  subtitle: SettingsPrefsStrings.fontStyleValue,
                  onTap: () {
                    showAppToast(
                      context,
                      SettingsPrefsStrings.demoNotAvailableToast,
                    );
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.tags,
                  iconBgColor: AppColors.waitingClientBg,
                  iconTextColor: AppColors.purple,
                  title: SettingsPrefsStrings.projectCategoriesTitle,
                  subtitle:
                      SettingsPrefsStrings.categoriesCount(categoryCount),
                  onTap: () {
                    context.push(AppRoutes.settingsCategoriesPath);
                  },
                ),
                SettingsRow(
                  iconData: AppIcons.scale,
                  iconBgColor: AppColors.orangeBg,
                  iconTextColor: AppColors.orange,
                  title: SettingsPrefsStrings.legalClausesTemplateTitle,
                  subtitle: SettingsPrefsStrings.legalClausesTemplateSubtitle,
                  last: true,
                  onTap: () {
                    context.push(AppRoutes.settingsLegalPath);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
