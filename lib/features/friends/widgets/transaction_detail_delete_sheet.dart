import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/data.dart';
import '../transaction_detail_strings.dart';

/// Modal bottom sheet confirming transaction deletion per `docs/design/SPEC.md` (FD15).
class TransactionDetailDeleteConfirmSheet extends StatelessWidget {
  const TransactionDetailDeleteConfirmSheet({
    super.key,
    required this.transaction,
    required this.friendName,
    required this.settlementsCount,
    required this.onConfirm,
  });

  final FriendTransaction transaction;
  final String friendName;
  final int settlementsCount;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Red circle '!' + Title + Subtitle
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
                      TransactionDetailStrings.deleteTransactionTitle,
                      style: AppText.sectionTitle.copyWith(
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TransactionDetailStrings.deleteTransactionSubtitle,
                      style: AppText.caption.copyWith(
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Red Warning Box
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
                  TransactionDetailStrings.deleteWarningTransaction(
                    transaction.description,
                    transaction.amount,
                    friendName,
                  ),
                  style: AppText.bodyMedium.copyWith(
                    color: AppColors.red,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  TransactionDetailStrings.deleteWarningSettlements(
                    settlementsCount,
                  ),
                  style: AppText.bodyMedium.copyWith(
                    color: AppColors.red,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // [Confirm delete]
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
                onTap: onConfirm,
                child: Center(
                  child: Text(
                    TransactionDetailStrings.confirmDelete,
                    style: AppText.button,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // [Cancel]
          SecondaryButton(
            label: TransactionDetailStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
