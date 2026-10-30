import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../projects/data/data.dart';
import 'data/data.dart';
import 'expense_detail_strings.dart';
import 'widgets/expense_detail_widgets.dart';

/// Screen displaying expense details and actions per `docs/design/SPEC.md` (EX5..EX8).
class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  void _popOrGoExpenses(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.expensesPath);
    }
  }

  void _openActionsSheet({
    required BuildContext context,
    required Expense expense,
    required ExpensesRepository repo,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ExpenseDetailCategoryIcon(
                    category: expense.category,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: AppText.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ExpenseDetailStrings.actionSheetSubtitle(
                            expense.amount,
                            expense.date,
                          ),
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionItem(
                label: ExpenseDetailStrings.editExpense,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/expenses/${expense.id}/edit');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: ExpenseDetailStrings.copyReference,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (expense.reference.trim().isNotEmpty) {
                    Clipboard.setData(
                      ClipboardData(text: expense.reference.trim()),
                    );
                    showAppToast(
                      context,
                      ExpenseDetailStrings.copiedReferenceToast,
                    );
                  } else {
                    showAppToast(
                      context,
                      ExpenseDetailStrings.noReferenceToCopyToast,
                    );
                  }
                },
              ),
              if (expense.isProjectLinked) ...[
                const SizedBox(height: AppSpacing.md),
                _buildActionItem(
                  label: ExpenseDetailStrings.goToProject,
                  textColor: AppColors.ink,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/projects/${expense.projectId}');
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: ExpenseDetailStrings.deleteExpense,
                textColor: AppColors.red,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openDeleteConfirmSheet(
                    context: context,
                    expense: expense,
                    repo: repo,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDeleteConfirmSheet({
    required BuildContext context,
    required Expense expense,
    required ExpensesRepository repo,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext confirmContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ExpenseDetailStrings.deleteExpenseTitle,
                          style: AppText.sectionTitle.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ExpenseDetailStrings.deleteExpenseSubtitle,
                          style: AppText.caption.copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.2),
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ExpenseDetailStrings.deleteWarningExpense(
                        expense.description,
                        expense.amount,
                      ),
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.red,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      ExpenseDetailStrings.deleteWarningRecalculate,
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.red,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: Material(
                  color: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      repo.delete(expense.id);
                      Navigator.of(confirmContext).pop();
                      context.go(
                        AppRoutes.expensesPath,
                        extra: <String, Object?>{
                          'toast': ExpenseDetailStrings.expenseDeletedToast,
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        ExpenseDetailStrings.confirmDelete,
                        style: AppText.button,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: ExpenseDetailStrings.cancel,
                onPressed: () => Navigator.of(confirmContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppText.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({
    required VoidCallback onBack,
    required VoidCallback onMore,
  }) {
    return Row(
      children: [
        RoundIconButton(
          icon: Icons.arrow_back,
          tooltip: ExpenseDetailStrings.back,
          onPressed: onBack,
        ),
        Expanded(
          child: Center(
            child: Text(
              ExpenseDetailStrings.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
        ),
        RoundIconButton(
          icon: Icons.more_horiz,
          tooltip: ExpenseDetailStrings.moreOptions,
          onPressed: onMore,
        ),
      ],
    );
  }

  Widget _buildDetailRow({required String label, required Widget value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppText.bodyMedium.copyWith(color: AppColors.mute)),
        const Spacer(),
        Flexible(child: value),
      ],
    );
  }

  Widget _buildTextDetailRow({
    required String label,
    required String value,
    Color valueColor = AppColors.ink,
  }) {
    return _buildDetailRow(
      label: label,
      value: Text(
        value,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: AppText.bodyMedium.copyWith(
          color: valueColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Expense expense) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.line, width: AppSpacing.borderWidth),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: ExpenseDetailStrings.editExpense,
            onPressed: () => context.push('/expenses/${expense.id}/edit'),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required Expense expense,
    required String projectName,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category icon, description, category label
          Row(
            children: [
              ExpenseDetailCategoryIcon(category: expense.category, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: AppText.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(expense.category.fullLabel, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.lg),

          // Amount spent
          Text(
            ExpenseDetailStrings.amountSpent,
            style: AppText.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '-${formatMoney(expense.amount.abs())}',
            style: AppText.title.copyWith(
              color: AppColors.red,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.lg),

          // Metadata rows
          _buildDetailRow(
            label: ExpenseDetailStrings.category,
            value: ExpenseDetailCategoryChip(category: expense.category),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: ExpenseDetailStrings.project,
            value: projectName,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            label: ExpenseDetailStrings.method,
            value: ExpenseDetailMethodBadge(method: expense.method),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: ExpenseDetailStrings.date,
            value: formatDate(expense.date),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: ExpenseDetailStrings.reference,
            value: expense.reference.trim().isNotEmpty
                ? expense.reference.trim()
                : ExpenseDetailStrings.emptyReferenceDash,
          ),

          // Notes (only when non-empty)
          if (expense.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, thickness: 1, color: AppColors.line),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ExpenseDetailStrings.notes,
              style: AppText.caption.copyWith(color: AppColors.mute),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              expense.notes.trim(),
              style: AppText.bodyMedium.copyWith(color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpensesRepository expensesRepo = ExpensesScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);

    final Expense? expense = expensesRepo.byId(expenseId);

    // Unknown id -> friendly "Expense not found" screen with a back button
    if (expense == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back,
                  tooltip: ExpenseDetailStrings.back,
                  onPressed: () => _popOrGoExpenses(context),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ExpenseDetailStrings.expenseNotFound,
                        style: AppText.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: ExpenseDetailStrings.backToExpenses,
                        onPressed: () => _popOrGoExpenses(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String projectName;
    if (expense.isProjectLinked) {
      final ProjectItem? project = projectsRepo.byId(expense.projectId!);
      projectName =
          project?.name ??
          expense.projectId ??
          ExpenseDetailStrings.unknownProject;
    } else {
      projectName = ExpenseDetailStrings.generalCost;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _buildBottomBar(context, expense),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox.shrink(
                child: Text(
                  'ExpenseDetailScreen',
                  style: TextStyle(fontSize: 0, color: AppColors.transparent),
                ),
              ),
              _buildTopBar(
                onBack: () => _popOrGoExpenses(context),
                onMore: () => _openActionsSheet(
                  context: context,
                  expense: expense,
                  repo: expensesRepo,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDetailCard(expense: expense, projectName: projectName),
            ],
          ),
        ),
      ),
    );
  }
}
