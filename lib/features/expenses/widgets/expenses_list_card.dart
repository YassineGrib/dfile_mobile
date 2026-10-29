import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/expense.dart';
import '../expense_strings.dart';
import '../expenses_list_strings.dart';

/// Single expense card displayed in the expenses list matching screen EX1.
class ExpensesListCard extends StatelessWidget {
  const ExpensesListCard({
    super.key,
    required this.expense,
    this.projectName,
  });

  final Expense expense;
  final String? projectName;

  (Color textColor, Color bgColor, String initial) get _categoryColors {
    switch (expense.category) {
      case ExpenseCategory.softwareTools:
        return (AppColors.purple, AppColors.softwareBg, 'S');
      case ExpenseCategory.hostingServices:
        return (AppColors.orange, AppColors.hostingBg, 'H');
      case ExpenseCategory.marketing:
        return (AppColors.coral, AppColors.marketingBg, 'M');
      case ExpenseCategory.equipment:
        return (AppColors.green, AppColors.equipmentBg, 'E');
      case ExpenseCategory.others:
        return (AppColors.mute, AppColors.othersBg, 'O');
    }
  }

  (Color textColor, Color bgColor) get _methodColors {
    switch (expense.method) {
      case PaymentMethod.baridimob:
        return (AppColors.purple, AppColors.waitingClientBg);
      case PaymentMethod.ccp:
        return (AppColors.ink, AppColors.ccpBg);
      case PaymentMethod.bank:
        return (AppColors.orange, AppColors.inProgressBg);
      case PaymentMethod.cash:
        return (AppColors.green, AppColors.greenBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color catTextColor, Color catBgColor, String initial) =
        _categoryColors;
    final (Color methodTextColor, Color methodBgColor) = _methodColors;

    final String projectSubtitle =
        (expense.isProjectLinked && projectName != null && projectName!.isNotEmpty)
            ? projectName!
            : ExpensesListStrings.generalCost;

    final String referenceText = expense.reference.trim().isNotEmpty
        ? expense.reference.trim()
        : ExpensesListStrings.noReference;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => context.push('${AppRoutes.expensesPath}/${expense.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category initial avatar, Description + Project, Negative Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InitialAvatar(
                        initial: initial,
                        color: catBgColor,
                        textColor: catTextColor,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              projectSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.label.copyWith(
                                color: AppColors.mute,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '-${formatMoney(expense.amount)}',
                        style: AppText.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Middle Row: Category chip + Method badge
                  Row(
                    children: [
                      _buildBadge(
                        label: expense.category.shortLabel,
                        textColor: catTextColor,
                        backgroundColor: catBgColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildBadge(
                        label: ExpenseStrings.methodLabel(expense.method),
                        textColor: methodTextColor,
                        backgroundColor: methodBgColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bottom Row: Date + Reference
                  Row(
                    children: [
                      Text(
                        formatDate(expense.date),
                        style: AppText.label.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          referenceText,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(
                            color: AppColors.mute,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppText.captionSm.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }
}
