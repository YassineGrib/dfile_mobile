import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/round_icon_button.dart';
import '../expenses/data/expense.dart';
import '../expenses/data/expenses_repository.dart';
import '../expenses/data/expenses_scope.dart';
import '../projects/data/project.dart';
import '../projects/data/projects_repository.dart';
import '../projects/data/projects_scope.dart';
import 'dashboard_activity_strings.dart';
import 'data/dashboard_stats.dart';
import 'widgets/dash_card.dart';

/// Profit screen per `docs/design/SPEC.md` (HM8).
///
/// Features:
/// - Back button and "Profit" title in header
/// - Ink card with "Net profit, all time", large white value,
///   profit margin bar with "Profit margin N%" (0% when no revenue),
///   and revenue & expenses sub-tiles
/// - "TOP EARNING PROJECTS" (top 3, bars relative to best, colours green, purple, orange)
/// - "WHERE THE MONEY GOES" (top 3 expense categories, bars relative to largest, colours green, orange, coral)
/// - Friendly empty lines when no projects/expenses exist
/// - Responsive & scrollable without overflow on 360x800 screen
class ProfitScreen extends StatelessWidget {
  const ProfitScreen({super.key, this.clock});

  /// Optional clock provider for deterministic testing.
  final DateTime Function()? clock;

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ExpensesRepository expensesRepo = ExpensesScope.of(context);

    final List<ProjectPayment> payments = projectsRepo.payments;
    final List<Expense> expenses = expensesRepo.expenses;

    final double totalRevenue = payments.fold<double>(
      0.0,
      (double sum, ProjectPayment p) => sum + p.amount,
    );
    final double totalExpenses = expenses.fold<double>(
      0.0,
      (double sum, Expense e) => sum + e.amount,
    );
    final double net = netProfit(payments, expenses);
    final double margin = profitMargin(payments, expenses);

    final List<TopProjectItem> topProjects = topProjectsByPaid(
      projectsRepo.projects,
      payments,
      limit: 3,
    );

    final List<TopExpenseCategoryItem> topExpenses = topExpenseCategories(
      expenses,
      limit: 3,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: 12,
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: AppIcons.arrowLeft,
                    onPressed: () => _handleBack(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DashboardActivityStrings.profit,
                      style: AppText.sectionTitle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  8,
                  AppSpacing.pageGutter,
                  AppSpacing.xxl,
                ),
                children: [
                  // Hero Ink Card
                  _ProfitHeroCard(
                    netProfit: net,
                    margin: margin,
                    revenue: totalRevenue,
                    expenses: totalExpenses,
                  ),
                  const SizedBox(height: 20),

                  // TOP EARNING PROJECTS Card
                  _TopProjectsCard(topProjects: topProjects),
                  const SizedBox(height: 20),

                  // WHERE THE MONEY GOES Card
                  _TopExpensesCard(topExpenses: topExpenses),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitHeroCard extends StatelessWidget {
  const _ProfitHeroCard({
    required this.netProfit,
    required this.margin,
    required this.revenue,
    required this.expenses,
  });

  final double netProfit;
  final double margin;
  final double revenue;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final int roundedMargin = margin.round();
    final double clampedFraction = (margin / 100.0).clamp(0.0, 1.0);

    return DashCard(
      color: AppColors.ink,
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DashboardActivityStrings.netProfitAllTime,
            style: AppText.caption.copyWith(
              color: AppColors.placeholder,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(netProfit),
              style: AppText.title.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Margin Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DashboardActivityStrings.profitMarginPrefix} $roundedMargin%',
                style: AppText.captionSm.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.mute.withValues(alpha: 0.35),
                  ),
                  FractionallySizedBox(
                    widthFactor: clampedFraction,
                    child: Container(color: AppColors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFF2C2C33)),
          const SizedBox(height: 16),

          // Revenue & Expenses Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashboardActivityStrings.revenue,
                      style: AppText.captionSm.copyWith(
                        color: AppColors.placeholder,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatMoney(revenue),
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DashboardActivityStrings.expenses,
                      style: AppText.captionSm.copyWith(
                        color: AppColors.placeholder,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatMoney(expenses),
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopProjectsCard extends StatelessWidget {
  const _TopProjectsCard({required this.topProjects});

  final List<TopProjectItem> topProjects;

  static const List<Color> _barColors = <Color>[
    AppColors.green,
    AppColors.purple,
    AppColors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final double maxPaid = topProjects.isNotEmpty
        ? topProjects.first.paid
        : 0.0;

    return DashCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DashboardActivityStrings.topEarningProjects,
            style: AppText.captionSm.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.mute,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (topProjects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                DashboardActivityStrings.noProjectsYet,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
            )
          else
            for (int i = 0; i < topProjects.length; i++) ...[
              _RankedBarRow(
                name: topProjects[i].project.name,
                amount: topProjects[i].paid,
                ratio: maxPaid > 0
                    ? (topProjects[i].paid / maxPaid).clamp(0.0, 1.0)
                    : 0.0,
                color: _barColors[i % _barColors.length],
              ),
              if (i < topProjects.length - 1) const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _TopExpensesCard extends StatelessWidget {
  const _TopExpensesCard({required this.topExpenses});

  final List<TopExpenseCategoryItem> topExpenses;

  static const List<Color> _barColors = <Color>[
    AppColors.green,
    AppColors.orange,
    AppColors.coral,
  ];

  @override
  Widget build(BuildContext context) {
    final double maxTotal = topExpenses.isNotEmpty
        ? topExpenses.first.total
        : 0.0;

    return DashCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DashboardActivityStrings.whereTheMoneyGoes,
            style: AppText.captionSm.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.mute,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (topExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                DashboardActivityStrings.noExpensesYet,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
            )
          else
            for (int i = 0; i < topExpenses.length; i++) ...[
              _RankedBarRow(
                name: topExpenses[i].category.label,
                amount: topExpenses[i].total,
                ratio: maxTotal > 0
                    ? (topExpenses[i].total / maxTotal).clamp(0.0, 1.0)
                    : 0.0,
                color: _barColors[i % _barColors.length],
              ),
              if (i < topExpenses.length - 1) const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _RankedBarRow extends StatelessWidget {
  const _RankedBarRow({
    required this.name,
    required this.amount,
    required this.ratio,
    required this.color,
  });

  final String name;
  final double amount;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: AppText.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatMoney(amount),
                  style: AppText.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(width: double.infinity, color: AppColors.seg),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
