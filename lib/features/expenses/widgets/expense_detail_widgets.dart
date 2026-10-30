import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../payments/payment_strings.dart';
import '../data/expense.dart';

/// Returns the background and foreground colors for an [ExpenseCategory] per SPEC.md.
(Color bg, Color fg) expenseCategoryColors(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.softwareTools:
      return (AppColors.softwareBg, AppColors.purple);
    case ExpenseCategory.hostingServices:
      return (AppColors.hostingBg, AppColors.orange);
    case ExpenseCategory.marketing:
      return (AppColors.marketingBg, AppColors.coral);
    case ExpenseCategory.equipment:
      return (AppColors.equipmentBg, AppColors.green);
    case ExpenseCategory.others:
      return (AppColors.othersBg, AppColors.mute);
  }
}

/// Returns the 1-letter initial for an [ExpenseCategory] per SPEC.md.
String expenseCategoryInitial(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.softwareTools:
      return 'S';
    case ExpenseCategory.hostingServices:
      return 'H';
    case ExpenseCategory.marketing:
      return 'M';
    case ExpenseCategory.equipment:
      return 'E';
    case ExpenseCategory.others:
      return 'O';
  }
}

/// Round category icon displaying the category initial in category colors.
class ExpenseDetailCategoryIcon extends StatelessWidget {
  const ExpenseDetailCategoryIcon({
    super.key,
    required this.category,
    this.size = 44,
  });

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = expenseCategoryColors(category);
    final String initial = expenseCategoryInitial(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: fg,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Coloured stadium chip displaying [ExpenseCategory.shortLabel] per SPEC.md.
class ExpenseDetailCategoryChip extends StatelessWidget {
  const ExpenseDetailCategoryChip({super.key, required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = expenseCategoryColors(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        category.shortLabel,
        maxLines: 1,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Coloured stadium pill displaying a [PaymentMethod] per SPEC.md.
class ExpenseDetailMethodBadge extends StatelessWidget {
  const ExpenseDetailMethodBadge({super.key, required this.method});

  final PaymentMethod method;

  (Color bg, Color fg) get _colors {
    switch (method) {
      case PaymentMethod.baridimob:
        return (AppColors.waitingClientBg, AppColors.purple);
      case PaymentMethod.ccp:
        return (AppColors.ccpBg, AppColors.ink);
      case PaymentMethod.bank:
        return (AppColors.inProgressBg, AppColors.orange);
      case PaymentMethod.cash:
        return (AppColors.greenBg, AppColors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        method.label,
        maxLines: 1,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
