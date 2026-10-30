import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../data/friend.dart';
import 'friend_net_chip.dart';

/// Net balance card displaying either portfolio overall balance (FD1, FD8)
/// or an individual friend's statement net balance (FD3).
class FriendBalanceCard extends StatelessWidget {
  const FriendBalanceCard({
    super.key,
    this.overallBalance,
    this.friendBalance,
    this.title,
    this.net,
    this.owedToYou,
    this.youOwe,
    this.isStatement = false,
  });

  /// Factory constructor for the portfolio-wide net card matching FD1 / FD8.
  const FriendBalanceCard.overall({
    Key? key,
    required OverallBalance balance,
    String? title,
  }) : this(
         key: key,
         overallBalance: balance,
         title: title,
         isStatement: false,
       );

  /// Factory constructor for the statement net card matching FD3.
  const FriendBalanceCard.statement({
    Key? key,
    required FriendBalance balance,
    String? title,
  }) : this(key: key, friendBalance: balance, title: title, isStatement: true);

  final OverallBalance? overallBalance;
  final FriendBalance? friendBalance;
  final String? title;
  final double? net;
  final double? owedToYou;
  final double? youOwe;
  final bool isStatement;

  double get _effectiveNet =>
      net ?? friendBalance?.net ?? overallBalance?.net ?? 0.0;

  double get _effectiveOwedToYou =>
      owedToYou ?? friendBalance?.owedToYou ?? overallBalance?.owedToYou ?? 0.0;

  double get _effectiveYouOwe =>
      youOwe ?? friendBalance?.youOwe ?? overallBalance?.youOwe ?? 0.0;

  @override
  Widget build(BuildContext context) {
    if (isStatement || friendBalance != null) {
      return _buildStatementCard();
    }
    return _buildOverallCard();
  }

  /// FD3 Statement Variant
  Widget _buildStatementCard() {
    final double netVal = _effectiveNet;
    final String label = netVal > 0
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
              Text(
                title ?? 'Net balance',
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
              FriendNetChip(net: netVal, label: label),
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

  /// FD1 / FD8 Overall Variant
  Widget _buildOverallCard() {
    final double netVal = _effectiveNet;
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
            title ?? 'Overall net balance',
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
              Text(
                'Owed to you ${formatMoney(_effectiveOwedToYou)}',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  color: AppColors.mute,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'You owe ${formatMoney(_effectiveYouOwe)}',
                style: AppText.bodyMedium.copyWith(
                  fontSize: 13,
                  color: AppColors.mute,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
