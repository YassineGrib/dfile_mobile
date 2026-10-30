import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../projects/data/data.dart';
import 'data/data.dart';
import 'expenses_list_strings.dart';
import 'widgets/expenses_list_card.dart';
import 'widgets/expenses_list_filter_sheet.dart';
import 'widgets/expenses_list_kpis.dart';

/// Screen displaying the list of all recorded expenses per `docs/design/SPEC.md` (EX1..EX4, EX8, EX13).
///
/// Supports receiving an optional toast notification message via [GoRouterState.extra]
/// when arriving from other screens (e.g. `{'toast': 'Expense deleted successfully'}`
/// or `'Expense recorded'`).
class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseCategory? _categoryFilter;
  ExpenseLinkFilter _linkFilter = ExpenseLinkFilter.all;
  ExpenseSort _sort = ExpenseSort.newest;
  Object? _lastHandledExtra;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingToast();
  }

  void _handleIncomingToast() {
    Object? extra;
    try {
      extra = GoRouterState.of(context).extra;
    } catch (_) {
      // In case GoRouter is not available in the context tree.
    }

    if (extra != null && !identical(extra, _lastHandledExtra)) {
      _lastHandledExtra = extra;
      String? message;
      if (extra is String) {
        message = extra;
      } else if (extra is Map) {
        final Object? toastValue = extra['toast'];
        if (toastValue is String) {
          message = toastValue;
        }
      }

      if (message != null && message.trim().isNotEmpty) {
        final String toastMessage = message;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context, toastMessage);
          }
        });
      }
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _categoryFilter = null;
      _linkFilter = ExpenseLinkFilter.all;
    });
  }

  String get _sortShortLabel {
    switch (_sort) {
      case ExpenseSort.newest:
        return ExpensesListStrings.sortShortNewest;
      case ExpenseSort.oldest:
        return ExpensesListStrings.sortShortOldest;
      case ExpenseSort.highestAmount:
        return ExpensesListStrings.sortShortHighest;
      case ExpenseSort.lowestAmount:
        return ExpensesListStrings.sortShortLowest;
    }
  }

  List<Expense> _getFilteredAndSortedExpenses(
    ExpensesRepository repo,
    ProjectsRepository projectsRepo,
  ) {
    final List<Expense> filtered = filterExpenses(
      repo.expenses,
      query: _searchController.text,
      category: _categoryFilter,
      link: _linkFilter,
      projectName: (String id) => projectsRepo.byId(id)?.name ?? id,
    );
    return sortExpenses(filtered, _sort);
  }

  void _openSortSheet() {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ExpensesListStrings.sortSheetTitle,
                style: AppText.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ExpensesListStrings.sortNewestFirst,
                sortValue: ExpenseSort.newest,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ExpensesListStrings.sortOldestFirst,
                sortValue: ExpenseSort.oldest,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ExpensesListStrings.sortHighestAmount,
                sortValue: ExpenseSort.highestAmount,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSortOption(
                sheetContext: sheetContext,
                title: ExpensesListStrings.sortLowestAmount,
                sortValue: ExpenseSort.lowestAmount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext sheetContext,
    required String title,
    required ExpenseSort sortValue,
  }) {
    final bool isSelected = _sort == sortValue;
    return InkWell(
      onTap: () {
        setState(() => _sort = sortValue);
        Navigator.of(sheetContext).pop();
      },
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppText.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.ink : AppColors.line,
                  width: isSelected ? 6 : 1.5,
                ),
                color: isSelected ? AppColors.white : AppColors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet() {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return ExpensesListFilterSheet(
          initialCategory: _categoryFilter,
          initialLink: _linkFilter,
          onApply: (ExpenseCategory? category, ExpenseLinkFilter link) {
            setState(() {
              _categoryFilter = category;
              _linkFilter = link;
            });
          },
        );
      },
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.morePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExpensesRepository repo = ExpensesScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ExpenseStats stats = repo.expenseStats();
    final List<Expense> allExpenses = repo.expenses;
    final List<Expense> displayedExpenses = _getFilteredAndSortedExpenses(
      repo,
      projectsRepo,
    );

    const List<(String, ExpenseCategory?)> categoryPills =
        <(String, ExpenseCategory?)>[
          (ExpensesListStrings.categoryAll, null),
          (ExpensesListStrings.categorySoftware, ExpenseCategory.softwareTools),
          (
            ExpensesListStrings.categoryHosting,
            ExpenseCategory.hostingServices,
          ),
          (ExpensesListStrings.categoryMarketing, ExpenseCategory.marketing),
          (ExpensesListStrings.categoryEquipment, ExpenseCategory.equipment),
          (ExpensesListStrings.categoryOthers, ExpenseCategory.others),
        ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.expensesTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top section: Header, KPIs, Search
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.lg,
                AppSpacing.pageGutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button supporting BackButton finder
                    RoundIconButton(
                      onPressed: () => _handleBack(context),
                      child: BackButton(
                        color: AppColors.ink,
                        onPressed: () => _handleBack(context),
                      ),
                    ),
                    const SizedBox.shrink(child: Text('ExpensesListScreen')),
                    const SizedBox(height: AppSpacing.md),

                    // Header row: Title + count, and "+" button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ExpensesListStrings.title,
                                style: AppText.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ExpensesListStrings.expensesLogged(
                                  allExpenses.length,
                                ),
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundIconButton(
                          backgroundColor: AppColors.ink,
                          borderColor: AppColors.ink,
                          iconColor: AppColors.white,
                          icon: Icons.add,
                          onPressed: () =>
                              context.push(AppRoutes.newExpensePath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4 KPI tiles
                    ExpensesListKpis(stats: stats),
                    const SizedBox(height: 14),

                    // Search field
                    Container(
                      height: AppSpacing.searchHeight,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.search),
                        border: Border.all(
                          color: AppColors.line,
                          width: AppSpacing.borderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppText.body,
                        cursorColor: AppColors.ink,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: ExpensesListStrings.searchPlaceholder,
                          hintStyle: AppText.body.copyWith(
                            color: AppColors.placeholder,
                          ),
                          prefixIcon: const Icon(
                            Icons.circle_outlined,
                            size: 18,
                            color: AppColors.mute,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Horizontally scrollable category pills
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                key: const Key('expense-category-pills'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < categoryPills.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      AppPill(
                        label: categoryPills[i].$1,
                        selected: _categoryFilter == categoryPills[i].$2,
                        onTap: () => setState(
                          () => _categoryFilter = categoryPills[i].$2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Count, Filter & Sort control row
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ExpensesListStrings.expensesCount(
                          displayedExpenses.length,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.label.copyWith(
                          fontSize: 14,
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          ExpensesListStrings.filter,
                          style: AppText.label.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.purple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    InkWell(
                      onTap: _openSortSheet,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${ExpensesListStrings.sortPrefix}$_sortShortLabel ▾',
                              maxLines: 1,
                              softWrap: false,
                              style: AppText.label.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content: Empty state (zero in repo), Filter empty state, or List of expense cards
            if (allExpenses.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.line,
                            width: AppSpacing.borderWidth,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: 28,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: AppColors.redBg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 22,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              ExpensesListStrings.emptyTitle,
                              textAlign: TextAlign.center,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ExpensesListStrings.emptySubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: ExpensesListStrings.recordFirstExpense,
                        onPressed: () => context.push(AppRoutes.newExpensePath),
                      ),
                    ],
                  ),
                ),
              )
            else if (displayedExpenses.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.xs,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.line,
                            width: AppSpacing.borderWidth,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: 28,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '?',
                                style: AppText.title.copyWith(
                                  fontSize: 36,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              ExpensesListStrings.emptyFilterTitle,
                              textAlign: TextAlign.center,
                              style: AppText.sectionTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ExpensesListStrings.emptyFilterSubtitle,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: ExpensesListStrings.clearFilters,
                        onPressed: _clearAllFilters,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  0,
                  AppSpacing.pageGutter,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: entranceDelegate((BuildContext context, int index) {
                    final Expense expense = displayedExpenses[index];
                    final String? projectName = expense.isProjectLinked
                        ? projectsRepo.byId(expense.projectId!)?.name
                        : null;
                    return ExpensesListCard(
                      expense: expense,
                      projectName: projectName,
                    );
                  }, childCount: displayedExpenses.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
