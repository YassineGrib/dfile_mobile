import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../friend_statement_strings.dart';
import 'friend_balance_card.dart';
import 'friend_net_chip.dart';

/// Statement variant of [FriendBalanceCard] for FD3 with overflow resilience.
class FriendStatementBalanceCard extends FriendBalanceCard {
  const FriendStatementBalanceCard({
    super.key,
    required super.balance,
    super.title,
  }) : super.statement();

  @override
  Widget build(BuildContext context) {
    final double netVal = friendBalance?.net ?? 0.0;
    final String chipLabel = netVal > 0
        ? 'Owed to you'
        : (netVal < 0 ? 'You owe' : 'Settled');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title ?? FriendStatementStrings.netBalance,
                  style: AppText.caption.copyWith(
                    color: AppColors.mute,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FriendNetChip(
                net: netVal,
                label: chipLabel,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatMoney(netVal.abs()),
            style: AppText.title.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
