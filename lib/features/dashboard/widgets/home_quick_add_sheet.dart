import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';

/// Modal sheet presenting 4 quick add actions (HM6).
class HomeQuickAddSheet extends StatelessWidget {
  const HomeQuickAddSheet({super.key});

  Widget _buildRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
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
          onTap: () {
            Navigator.of(context).pop();
            context.push(route);
          },
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
                const Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: AppColors.placeholder,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DashboardHomeStrings.createNew, style: AppText.sectionTitle),
        const SizedBox(height: AppSpacing.lg),
        _buildRow(
          context: context,
          icon: AppIcons.banknote,
          iconBg: AppColors.greenBg,
          iconColor: AppColors.green,
          title: DashboardHomeStrings.recordPayment,
          subtitle: DashboardHomeStrings.recordPaymentSub,
          route: '/payments/new',
        ),
        _buildRow(
          context: context,
          icon: AppIcons.receipt,
          iconBg: AppColors.coralBg,
          iconColor: AppColors.coral,
          title: DashboardHomeStrings.addExpense,
          subtitle: DashboardHomeStrings.addExpenseSub,
          route: '/expenses/new',
        ),
        _buildRow(
          context: context,
          icon: AppIcons.folderPlus,
          iconBg: AppColors.purpleBg,
          iconColor: AppColors.purple,
          title: DashboardHomeStrings.newProject,
          subtitle: DashboardHomeStrings.newProjectSub,
          route: '/projects/new',
        ),
        _buildRow(
          context: context,
          icon: AppIcons.userPlus,
          iconBg: AppColors.yellowBg,
          iconColor: AppColors.orange,
          title: DashboardHomeStrings.addClient,
          subtitle: DashboardHomeStrings.addClientSub,
          route: '/clients/new',
        ),
      ],
    );
  }
}
