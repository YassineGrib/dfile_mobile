import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/expense.dart';
import '../expenses_list_strings.dart';

/// Modal bottom sheet for filtering expenses per screen EX4.
class ExpensesListFilterSheet extends StatefulWidget {
  const ExpensesListFilterSheet({
    super.key,
    required this.initialCategory,
    required this.initialLink,
    required this.onApply,
  });

  final ExpenseCategory? initialCategory;
  final ExpenseLinkFilter initialLink;
  final void Function(ExpenseCategory? category, ExpenseLinkFilter link) onApply;

  @override
  State<ExpensesListFilterSheet> createState() => _ExpensesListFilterSheetState();
}

class _ExpensesListFilterSheetState extends State<ExpensesListFilterSheet> {
  late ExpenseCategory? _draftCategory = widget.initialCategory;
  late ExpenseLinkFilter _draftLink = widget.initialLink;

  void _handleReset() {
    setState(() {
      _draftCategory = null;
      _draftLink = ExpenseLinkFilter.all;
    });
  }

  void _handleApply() {
    widget.onApply(_draftCategory, _draftLink);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const List<(String, ExpenseCategory?)> categoryOptions =
        <(String, ExpenseCategory?)>[
      (ExpensesListStrings.categoryAll, null),
      (ExpensesListStrings.categorySoftware, ExpenseCategory.softwareTools),
      (ExpensesListStrings.categoryHosting, ExpenseCategory.hostingServices),
      (ExpensesListStrings.categoryMarketing, ExpenseCategory.marketing),
      (ExpensesListStrings.categoryEquipment, ExpenseCategory.equipment),
      (ExpensesListStrings.categoryOthers, ExpenseCategory.others),
    ];

    const List<(String, ExpenseLinkFilter)> linkOptions =
        <(String, ExpenseLinkFilter)>[
      (ExpensesListStrings.linkAll, ExpenseLinkFilter.all),
      (ExpensesListStrings.linkProjectLinked, ExpenseLinkFilter.linked),
      (ExpensesListStrings.linkGeneralCosts, ExpenseLinkFilter.general),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ExpensesListStrings.filterSheetTitle,
                  style: AppText.sectionTitle,
                ),
              ),
              InkWell(
                onTap: _handleReset,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    ExpensesListStrings.reset,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Category Section
          Text(
            ExpensesListStrings.filterSectionCategory,
            style: AppText.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (String label, ExpenseCategory? cat) in categoryOptions)
                AppPill(
                  label: label,
                  selected: _draftCategory == cat,
                  onTap: () => setState(() => _draftCategory = cat),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Project link Section
          Text(
            ExpensesListStrings.filterSectionProjectLink,
            style: AppText.label.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (String label, ExpenseLinkFilter link) in linkOptions)
                AppPill(
                  label: label,
                  selected: _draftLink == link,
                  onTap: () => setState(() => _draftLink = link),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Action Buttons
          PrimaryButton(
            label: ExpensesListStrings.applyFilters,
            onPressed: _handleApply,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: ExpensesListStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
