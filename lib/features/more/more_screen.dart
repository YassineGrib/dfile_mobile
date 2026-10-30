import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../projects/data/data.dart';
import 'more_strings.dart';

/// Screen displaying the More menu per `docs/design/SPEC.md` (PY1).
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final PaymentStats stats = repo.paymentStats();

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
            AppSpacing.xl,
            AppSpacing.pageGutter,
            AppSpacing.xxl + 80,
          ),
          children: [
            // Title & Subtitle
            Text(MoreStrings.title, style: AppText.title),
            const SizedBox(height: 4),
            Text(
              MoreStrings.subtitle,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.mute,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Workspace Card
            Container(
              constraints: const BoxConstraints(minHeight: 76),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                border: Border.all(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'D',
                        style: AppText.cardTitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoreStrings.workspaceTitle,
                          style: AppText.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          MoreStrings.workspaceSubtitle,
                          style: AppText.caption.copyWith(
                            color: AppColors.mute,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 5 Menu rows
            _MoreMenuRow(
              iconData: AppIcons.circleDollarSign,
              iconBgColor: AppColors.greenBg,
              iconTextColor: AppColors.green,
              title: MoreStrings.paymentsTitle,
              subtitle: MoreStrings.paymentsSubtitle(
                formatMoney(stats.collected),
              ),
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.paymentsPath);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _MoreMenuRow(
              iconData: AppIcons.calendarDays,
              iconBgColor: AppColors.orangeBg,
              iconTextColor: AppColors.orange,
              title: MoreStrings.calendarTitle,
              subtitle: MoreStrings.calendarSubtitle,
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.calendarPath);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _MoreMenuRow(
              iconData: AppIcons.receiptText,
              iconBgColor: AppColors.seg,
              iconTextColor: AppColors.ink,
              title: MoreStrings.expensesTitle,
              subtitle: MoreStrings.expensesSubtitle,
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.expensesPath);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _MoreMenuRow(
              iconData: AppIcons.fileText,
              iconBgColor: AppColors.seg,
              iconTextColor: AppColors.ink,
              title: MoreStrings.invoicesTitle,
              subtitle: MoreStrings.invoicesSubtitle,
              onTap: () {
                showAppToast(context, MoreStrings.notAvailableInDemo);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _MoreMenuRow(
              iconData: AppIcons.arrowLeftRight,
              iconBgColor: AppColors.seg,
              iconTextColor: AppColors.ink,
              title: MoreStrings.friendsDebtsTitle,
              subtitle: MoreStrings.friendsDebtsSubtitle,
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.friendsPath);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _MoreMenuRow(
              iconData: AppIcons.settings,
              iconBgColor: AppColors.seg,
              iconTextColor: AppColors.ink,
              title: MoreStrings.settingsTitle,
              subtitle: MoreStrings.settingsSubtitle,
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.settingsPath);
              },
            ),
            const SizedBox(height: 18),

            // Sign out button
            InkWell(
              onTap: () {
                GoRouter.maybeOf(context)?.go(AppRoutes.signInPath);
              },
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    MoreStrings.signOut,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuRow extends StatelessWidget {
  const _MoreMenuRow({
    required this.iconData,
    required this.iconBgColor,
    required this.iconTextColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData iconData;
  final Color iconBgColor;
  final Color iconTextColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconData, size: 20, color: iconTextColor),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.caption.copyWith(color: AppColors.mute),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.chevronRight,
              color: AppColors.placeholder,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
