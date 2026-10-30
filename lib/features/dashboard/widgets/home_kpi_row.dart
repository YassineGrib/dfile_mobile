import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';

/// KPI Row with horizontal scroll containing 4 cards (150x100 approx):
/// 1. Active projects (folderKanban, purple)
/// 2. Monthly expenses (receipt, coral)
/// 3. Pending invoices (clock, yellow/orange)
/// 4. Friends owe you (handCoins, green or red depending on net)
class HomeKpiRow extends StatelessWidget {
  const HomeKpiRow({
    super.key,
    required this.activeProjectsCount,
    required this.monthlyExpensesAmount,
    required this.pendingInvoicesAmount,
    required this.friendsNetBalance,
  });

  final int activeProjectsCount;
  final double monthlyExpensesAmount;
  final double pendingInvoicesAmount;
  final double friendsNetBalance;

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      width: 150,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DashIconBubble(
                icon: icon,
                background: iconBg,
                foreground: iconColor,
                size: 36,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppText.captionSm.copyWith(
                  color: AppColors.mute,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppText.cardTitle.copyWith(
                  fontSize: 17,
                  color: valueColor ?? AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool friendsPositive = friendsNetBalance >= 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildKpiCard(
            icon: AppIcons.folderKanban,
            iconBg: AppColors.waitingClientBg,
            iconColor: AppColors.purple,
            label: DashboardHomeStrings.activeProjects,
            value: '$activeProjectsCount',
          ),
          const SizedBox(width: AppSpacing.md),
          _buildKpiCard(
            icon: AppIcons.receipt,
            iconBg: AppColors.coralBg,
            iconColor: AppColors.coral,
            label: DashboardHomeStrings.monthlyExpenses,
            value: formatMoney(monthlyExpensesAmount),
          ),
          const SizedBox(width: AppSpacing.md),
          _buildKpiCard(
            icon: AppIcons.clock,
            iconBg: AppColors.yellowBg,
            iconColor: AppColors.orange,
            label: DashboardHomeStrings.pendingInvoices,
            value: formatMoney(pendingInvoicesAmount),
          ),
          const SizedBox(width: AppSpacing.md),
          _buildKpiCard(
            icon: AppIcons.handCoins,
            iconBg: friendsPositive ? AppColors.greenBg : AppColors.redBg,
            iconColor: friendsPositive ? AppColors.green : AppColors.red,
            label: DashboardHomeStrings.friendsOweYou,
            value: formatMoney(friendsNetBalance),
            valueColor: friendsPositive ? AppColors.green : AppColors.red,
          ),
        ],
      ),
    );
  }
}
