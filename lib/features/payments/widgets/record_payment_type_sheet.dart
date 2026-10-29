import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../payment_strings.dart';
import '../record_payment_strings.dart';

/// Opens a bottom sheet picker for choosing a [PaymentType].
Future<PaymentType?> showRecordPaymentTypeSheet({
  required BuildContext context,
  required PaymentType selectedType,
}) {
  const List<PaymentType> options = <PaymentType>[
    PaymentType.advance,
    PaymentType.milestone,
    PaymentType.final_,
    PaymentType.tip,
  ];

  return showAppSheet<PaymentType>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RecordPaymentStrings.selectPaymentTypeTitle,
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _TypeOptionRow(
                type: options[i],
                isSelected: options[i] == selectedType,
                onTap: () => Navigator.of(sheetContext).pop(options[i]),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _TypeOptionRow extends StatelessWidget {
  const _TypeOptionRow({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  PaymentStrings.typeLabel(type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyBold.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.ink : AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                  color: isSelected ? AppColors.ink : AppColors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
