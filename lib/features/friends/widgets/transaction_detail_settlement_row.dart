import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../data/data.dart';

/// Method badge for settlement history rows.
class SettleMethodBadge extends StatelessWidget {
  const SettleMethodBadge({super.key, required this.method});

  final FriendSettleMethod method;

  (Color bg, Color fg) get _colors {
    switch (method) {
      case FriendSettleMethod.baridimob:
        return (AppColors.waitingClientBg, AppColors.purple);
      case FriendSettleMethod.cash:
        return (AppColors.greenBg, AppColors.green);
      case FriendSettleMethod.serviceOffset:
        return (AppColors.inProgressBg, AppColors.orange);
      case FriendSettleMethod.bank:
        return (AppColors.seg, AppColors.mute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        method.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A single settlement item row in the transaction detail card.
class TransactionDetailSettlementRow extends StatelessWidget {
  const TransactionDetailSettlementRow({super.key, required this.settlement});

  final FriendSettlement settlement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date
          Text(
            formatDate(settlement.date),
            style: AppText.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Method badge
          SettleMethodBadge(method: settlement.method),

          const Spacer(),

          // +amount
          Flexible(
            child: Text(
              '+${formatMoney(settlement.amount)}',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppText.bodyBold.copyWith(
                color: AppColors.green,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
