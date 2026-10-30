import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';

/// Quick actions row per HM1: 4 square tiles ->
/// 1. Record payment (/payments/new, banknote, green)
/// 2. Add expense (/expenses/new, receipt, coral)
/// 3. New project (/projects/new, folderPlus, purple)
/// 4. Add client (/clients/new, userPlus, orange)
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String route,
  }) {
    return Expanded(
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
              vertical: AppSpacing.md,
              horizontal: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DashIconBubble(
                  icon: icon,
                  background: iconBg,
                  foreground: iconColor,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppText.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    fontSize: 11.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DashboardHomeStrings.quickActions, style: AppText.cardTitle),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildTile(
              context: context,
              icon: AppIcons.banknote,
              iconBg: AppColors.greenBg,
              iconColor: AppColors.green,
              label: DashboardHomeStrings.recordPayment,
              route: '/payments/new',
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildTile(
              context: context,
              icon: AppIcons.receipt,
              iconBg: AppColors.coralBg,
              iconColor: AppColors.coral,
              label: DashboardHomeStrings.addExpense,
              route: '/expenses/new',
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildTile(
              context: context,
              icon: AppIcons.folderPlus,
              iconBg: AppColors.purpleBg,
              iconColor: AppColors.purple,
              label: DashboardHomeStrings.newProject,
              route: '/projects/new',
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildTile(
              context: context,
              icon: AppIcons.userPlus,
              iconBg: AppColors.yellowBg,
              iconColor: AppColors.orange,
              label: DashboardHomeStrings.addClient,
              route: '/clients/new',
            ),
          ],
        ),
      ],
    );
  }
}
