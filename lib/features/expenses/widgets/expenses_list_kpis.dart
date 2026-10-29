import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../data/expense.dart';
import '../expenses_list_strings.dart';

/// 4 KPI tiles displayed at the top of the expenses list matching screen EX1.
class ExpensesListKpis extends StatelessWidget {
  const ExpensesListKpis({
    super.key,
    required this.stats,
  });

  final ExpenseStats stats;

  static String formatKpiAmount(num amount) {
    if (amount == 0) {
      return '0 DZ';
    }
    return '-${formatMoney(amount)}';
  }

  Widget _buildKpiTile({
    required String label,
    required String value,
    required Color valueColor,
    required Color bubbleColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppText.captionSm.copyWith(
                        color: AppColors.mute,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top KPI Row: Total outlays & Project-linked
        Row(
          children: [
            _buildKpiTile(
              label: ExpensesListStrings.totalOutlays,
              value: formatKpiAmount(stats.total),
              valueColor: AppColors.red,
              bubbleColor: AppColors.redBg,
            ),
            const SizedBox(width: 10),
            _buildKpiTile(
              label: ExpensesListStrings.projectLinked,
              value: formatKpiAmount(stats.projectLinked),
              valueColor: AppColors.orange,
              bubbleColor: AppColors.inProgressBg,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Bottom KPI Row: This month & Average outlay
        Row(
          children: [
            _buildKpiTile(
              label: ExpensesListStrings.thisMonth,
              value: formatKpiAmount(stats.thisMonth),
              valueColor: AppColors.purple,
              bubbleColor: AppColors.waitingClientBg,
            ),
            const SizedBox(width: 10),
            _buildKpiTile(
              label: ExpensesListStrings.averageOutlay,
              value: formatKpiAmount(stats.average),
              valueColor: AppColors.ink,
              bubbleColor: AppColors.yellow,
            ),
          ],
        ),
      ],
    );
  }
}
