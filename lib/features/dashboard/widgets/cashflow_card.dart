import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../expenses/data/expense.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../expenses/data/expenses_scope.dart';
import '../../projects/data/project.dart';
import '../../projects/data/projects_repository.dart';
import '../../projects/data/projects_scope.dart';
import '../dashboard_charts_strings.dart';
import '../data/dashboard_stats.dart';
import 'chart_cashflow_chart.dart';
import 'dash_card.dart';

/// Dashboard cashflow overview card per HM2 in SPEC.md.
class CashflowCard extends StatefulWidget {
  const CashflowCard({
    super.key,
    this.clock,
  });

  final DateTime Function()? clock;

  @override
  State<CashflowCard> createState() => _CashflowCardState();
}

class _CashflowCardState extends State<CashflowCard> {
  int _rangeIndex = 0; // 0: 6 mo, 1: Year

  @override
  Widget build(BuildContext context) {
    final DateTime now = (widget.clock ?? DateTime.now)();

    final ProjectsRepository? projectsRepo = context
        .dependOnInheritedWidgetOfExactType<ProjectsScope>()
        ?.notifier;
    final ExpensesRepository? expensesRepo = context
        .dependOnInheritedWidgetOfExactType<ExpensesScope>()
        ?.notifier;

    final List<ProjectPayment> payments =
        projectsRepo?.payments ?? const <ProjectPayment>[];
    final List<Expense> expenses =
        expensesRepo?.expenses ?? const <Expense>[];

    final List<MonthFlow> flows = _rangeIndex == 0
        ? monthFlows(now, months: 6, payments: payments, expenses: expenses)
        : yearFlows(now, payments: payments, expenses: expenses);

    final double totalInflow = flows.fold<double>(
      0.0,
      (double sum, MonthFlow f) => sum + f.inflow,
    );
    final double totalOutflow = flows.fold<double>(
      0.0,
      (double sum, MonthFlow f) => sum + f.outflow,
    );
    final double totalNet = totalInflow - totalOutflow;

    return DashCard(
      onTap: () => context.push('/home/cashflow'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Title + range toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                DashboardChartsStrings.cashflow,
                style: AppText.cardTitle,
              ),
              _buildRangeToggle(),
            ],
          ),
          const SizedBox(height: 16),

          // Three legend totals
          Row(
            children: <Widget>[
              Expanded(
                child: _buildLegendItem(
                  dotColor: AppColors.green,
                  label: DashboardChartsStrings.inflow,
                  value: formatAmount(totalInflow),
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  dotColor: AppColors.coral,
                  label: DashboardChartsStrings.outflow,
                  value: formatAmount(totalOutflow),
                ),
              ),
              Expanded(
                child: _buildLegendItem(
                  dotColor: AppColors.ink,
                  label: DashboardChartsStrings.net,
                  value: formatAmount(totalNet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          CashflowChart(flows: flows, height: 180),
          const SizedBox(height: 14),

          // Hint row
          Row(
            children: <Widget>[
              Text(
                DashboardChartsStrings.tapToSeeEveryMonth,
                style: AppText.captionSm.copyWith(color: AppColors.mute),
              ),
              const Spacer(),
              const Icon(
                AppIcons.chevronRight,
                size: 16,
                color: AppColors.mute,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeToggle() {
    return Container(
      width: 114,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          _buildToggleOption(0, DashboardChartsStrings.sixMonths),
          _buildToggleOption(1, DashboardChartsStrings.year),
        ],
      ),
    );
  }

  Widget _buildToggleOption(int index, String label) {
    final bool isSelected = _rangeIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_rangeIndex != index) {
            setState(() {
              _rangeIndex = index;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.card : AppColors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.captionSm.copyWith(
              color: isSelected ? AppColors.ink : AppColors.mute,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.captionSm.copyWith(color: AppColors.mute),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.bodyBold.copyWith(
            fontSize: 14,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
