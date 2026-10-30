import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/segmented_toggle.dart';
import '../expenses/data/expense.dart';
import '../expenses/data/expenses_repository.dart';
import '../expenses/data/expenses_scope.dart';
import '../projects/data/project.dart';
import '../projects/data/projects_repository.dart';
import '../projects/data/projects_scope.dart';
import 'dashboard_charts_strings.dart';
import 'data/dashboard_stats.dart';
import 'widgets/chart_cashflow_chart.dart';
import 'widgets/dash_card.dart';

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatThousands(double val) {
  final double k = val / 1000.0;
  if ((k - k.roundToDouble()).abs() < 0.001) {
    return k.round().toString();
  }
  return k.toStringAsFixed(1);
}

String _formatInflowK(double amount) {
  if (amount <= 0.0) return '0';
  return '+${_formatThousands(amount)}k';
}

String _formatOutflowK(double amount) {
  if (amount <= 0.0) return '0';
  return '-${_formatThousands(amount)}k';
}

String _formatNetK(double net) {
  if (net == 0.0) return '0';
  final String sign = net > 0.0 ? '+' : '-';
  return '$sign${_formatThousands(net.abs())}k';
}

/// Cashflow detail screen per HM4 in SPEC.md.
class CashflowScreen extends StatefulWidget {
  const CashflowScreen({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  State<CashflowScreen> createState() => _CashflowScreenState();
}

class _CashflowScreenState extends State<CashflowScreen> {
  int _rangeIndex = 0; // 0: Last 6 months, 1: This year

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

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
    final List<Expense> expenses = expensesRepo?.expenses ?? const <Expense>[];

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

    final List<MonthFlow> newestFirstFlows = flows.reversed.toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(DashboardChartsStrings.cashflow, style: AppText.cardTitle),
        leading: IconButton(
          icon: const Icon(AppIcons.arrowLeft, color: AppColors.ink),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Segmented range toggle
            SegmentedToggle(
              options: const <String>[
                DashboardChartsStrings.lastSixMonths,
                DashboardChartsStrings.thisYear,
              ],
              selectedIndex: _rangeIndex,
              onChanged: (int index) {
                setState(() {
                  _rangeIndex = index;
                });
              },
            ),
            const SizedBox(height: 16),

            // Chart card
            DashCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Legend totals
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
                  CashflowChart(flows: flows, height: 180),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MONTH BY MONTH header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      DashboardChartsStrings.monthByMonth,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.captionSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mute,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      DashboardChartsStrings.inHeader,
                      textAlign: TextAlign.right,
                      style: AppText.captionSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mute,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      DashboardChartsStrings.outHeader,
                      textAlign: TextAlign.right,
                      style: AppText.captionSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mute,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      DashboardChartsStrings.netHeader,
                      textAlign: TextAlign.right,
                      style: AppText.captionSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mute,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Month by month card
            DashCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: List<Widget>.generate(newestFirstFlows.length, (
                  int i,
                ) {
                  final MonthFlow flow = newestFirstFlows[i];
                  final bool isLast = i == newestFirstFlows.length - 1;

                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${_shortMonths[flow.month.month - 1]} ${flow.month.year}',
                                style: AppText.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: Text(
                                _formatInflowK(flow.inflow),
                                textAlign: TextAlign.right,
                                style: AppText.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: flow.inflow > 0
                                      ? AppColors.green
                                      : AppColors.mute,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 48,
                              child: Text(
                                _formatOutflowK(flow.outflow),
                                textAlign: TextAlign.right,
                                style: AppText.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: flow.outflow > 0
                                      ? AppColors.red
                                      : AppColors.mute,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 50,
                              child: Text(
                                _formatNetK(flow.net),
                                textAlign: TextAlign.right,
                                style: AppText.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          color: AppColors.line,
                          height: 1,
                          thickness: 1,
                        ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],
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
          style: AppText.bodyBold.copyWith(fontSize: 14, color: AppColors.ink),
        ),
      ],
    );
  }
}
