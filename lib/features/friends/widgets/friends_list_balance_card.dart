import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../data/friend.dart';
import '../friends_list_strings.dart';

/// Overall net balance card displayed on the Friends screen (FD1, FD8).
///
/// Shows overall portfolio net balance, total owed to you, and total you owe
/// without overflowing on small screen widths.
class FriendsListBalanceCard extends StatelessWidget {
  const FriendsListBalanceCard({super.key, required this.balance, this.title});

  final OverallBalance balance;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final double netVal = balance.net;
    final Color netColor = netVal > 0
        ? AppColors.green
        : (netVal < 0 ? AppColors.red : AppColors.ink);
    final String sign = netVal > 0 ? '+' : '';

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
          Text(
            title ?? FriendsListStrings.overallNetBalance,
            style: AppText.caption.copyWith(
              color: AppColors.mute,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sign${formatMoney(netVal)}',
            style: AppText.title.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: netColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${FriendsListStrings.owedToYou} ${formatMoney(balance.owedToYou)}',
                    style: AppText.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.mute,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${FriendsListStrings.youOwe} ${formatMoney(balance.youOwe)}',
                    style: AppText.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.mute,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
