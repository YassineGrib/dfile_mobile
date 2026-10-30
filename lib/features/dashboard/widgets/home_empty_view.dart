import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/dashboard_stats.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';

/// New-user empty home (HM7):
/// - Top "Welcome" / Profile name is rendered by HomeScreen header
/// - Yellow "Set up your ledger" card with progress bar and "N of 3"
/// - Three step rows:
///   1. "Add your first client" (userPlus, yellow/orange) -> /clients/new
///   2. "Create a project" (folderPlus, purple) -> /projects/new
///   3. "Record a payment" (banknote, green) -> /payments/new
///   Each has a ring or green check icon indicating completion
/// - "Your numbers" strip: Net profit 0 DZ, Pending 0 DZ
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({super.key, required this.setup});

  final NewAccountSetup setup;

  Widget _buildStepRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDone,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                DashIconBubble(
                  icon: icon,
                  background: iconBg,
                  foreground: iconColor,
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppText.bodyBold),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppText.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.greenBg : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone ? AppColors.green : AppColors.placeholder,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                          AppIcons.circleCheck,
                          size: 18,
                          color: AppColors.green,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int completed = setup.completedCount;
    final double progressFraction = (completed / 3.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yellow "Set up your ledger" card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashIconBubble(
                    icon: AppIcons.sparkles,
                    background: AppColors.white,
                    foreground: AppColors.ink,
                    size: 40,
                  ),
                  const Spacer(),
                  Text(
                    '$completed of 3',
                    style: AppText.bodyBold.copyWith(color: AppColors.ink),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                DashboardHomeStrings.setUpYourLedger,
                style: AppText.sectionTitle.copyWith(
                  color: AppColors.ink,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DashboardHomeStrings.setUpSubtitle,
                style: AppText.body.copyWith(
                  color: const Color(0xFF4A4A54),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Progress track
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progressFraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Three step cards
        _buildStepRow(
          context: context,
          icon: AppIcons.userPlus,
          iconBg: AppColors.yellowBg,
          iconColor: AppColors.orange,
          title: DashboardHomeStrings.addFirstClient,
          subtitle: DashboardHomeStrings.addFirstClientSub,
          isDone: setup.hasClient,
          route: '/clients/new',
        ),
        _buildStepRow(
          context: context,
          icon: AppIcons.folderPlus,
          iconBg: AppColors.purpleBg,
          iconColor: AppColors.purple,
          title: DashboardHomeStrings.createProject,
          subtitle: DashboardHomeStrings.createProjectSub,
          isDone: setup.hasProject,
          route: '/projects/new',
        ),
        _buildStepRow(
          context: context,
          icon: AppIcons.banknote,
          iconBg: AppColors.greenBg,
          iconColor: AppColors.green,
          title: DashboardHomeStrings.recordAPayment,
          subtitle: DashboardHomeStrings.recordAPaymentSub,
          isDone: setup.hasPayment,
          route: '/payments/new',
        ),

        const SizedBox(height: AppSpacing.md),
        Text(DashboardHomeStrings.yourNumbers, style: AppText.cardTitle),
        const SizedBox(height: AppSpacing.md),

        // "Your numbers" strip: Net profit 0 DZ, Pending 0 DZ
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashIconBubble(
                      icon: AppIcons.wallet,
                      background: AppColors.greenBg,
                      foreground: AppColors.green,
                      size: 34,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '0 DZ',
                      style: AppText.cardTitle.copyWith(fontSize: 17),
                    ),
                    Text(
                      DashboardHomeStrings.netProfit,
                      style: AppText.captionSm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashIconBubble(
                      icon: AppIcons.clock,
                      background: AppColors.yellowBg,
                      foreground: AppColors.orange,
                      size: 34,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '0 DZ',
                      style: AppText.cardTitle.copyWith(fontSize: 17),
                    ),
                    Text(
                      DashboardHomeStrings.pending,
                      style: AppText.captionSm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
