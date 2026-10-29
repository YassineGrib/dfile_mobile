import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../data/friend_transaction.dart';
import '../data/friend_tx_type.dart';

/// Transaction card matching `docs/design/screens/FD3 Friend statement.png`
/// and `FD8 Transactions list.png`.
class FriendTxCard extends StatelessWidget {
  const FriendTxCard({
    super.key,
    required this.transaction,
    this.friendName,
    this.showFriend = false,
    this.onTap,
    this.onSettle,
  });

  final FriendTransaction transaction;
  final String? friendName;
  final bool showFriend;
  final VoidCallback? onTap;
  final VoidCallback? onSettle;

  (Color bg, Color fg, String text) get _typeProps {
    switch (transaction.type) {
      case FriendTxType.money:
        return (AppColors.greenBg, AppColors.green, r'$');
      case FriendTxType.service:
        return (AppColors.purpleBg, AppColors.purple, 'S');
      case FriendTxType.expense:
        return (AppColors.orangeBg, AppColors.orange, 'C');
    }
  }

  (Color bg, Color fg, String label) get _directionProps {
    switch (transaction.direction) {
      case FriendTxDirection.lent:
        return (AppColors.greenBg, AppColors.green, transaction.direction.chipLabel);
      case FriendTxDirection.borrowed:
        return (AppColors.redBg, AppColors.red, transaction.direction.chipLabel);
    }
  }

  (Color bg, Color fg, String label) get _statusProps {
    switch (transaction.status) {
      case FriendTxStatus.pending:
        return (AppColors.pendingBg, AppColors.orange, transaction.status.label);
      case FriendTxStatus.partial:
        return (AppColors.partialBg, AppColors.purple, transaction.status.label);
      case FriendTxStatus.settled:
        return (AppColors.greenBg, AppColors.green, transaction.status.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color typeBg, Color typeFg, String typeGlyph) = _typeProps;
    final (Color dirBg, Color dirFg, String dirLabel) = _directionProps;
    final (Color statBg, Color statFg, String statLabel) = _statusProps;

    final String subtitleText = (showFriend && friendName != null && friendName!.isNotEmpty)
        ? '$friendName • ${transaction.type.label} • ${formatDate(transaction.date)}'
        : '${transaction.type.label} • ${formatDate(transaction.date)}';

    final double progress = transaction.amount <= 0.0
        ? 1.0
        : (transaction.paidAmount / transaction.amount).clamp(0.0, 1.0);

    return Container(
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Type glyph circle, Description + Subtitle, Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: typeBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        typeGlyph,
                        style: AppText.cardTitle.copyWith(
                          color: typeFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.description,
                                  style: AppText.cardTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                formatMoney(transaction.amount),
                                style: AppText.cardTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitleText,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Chips & Action Row: Direction chip, Status chip, Due date, Settle button
                Row(
                  children: [
                    // Direction Chip (Lent / Borrowed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dirBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        dirLabel,
                        style: AppText.captionSm.copyWith(
                          color: dirFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Status Chip (Pending / Partial / Settled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        statLabel,
                        style: AppText.captionSm.copyWith(
                          color: statFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Due date text (optional)
                    if (transaction.dueDate != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Due ${transaction.dueDate!.month.toString().padLeft(2, '0')}-${transaction.dueDate!.day.toString().padLeft(2, '0')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.captionSm.copyWith(
                            color: AppColors.mute,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Settle button: hidden when settled
                    if (transaction.status != FriendTxStatus.settled)
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.line,
                            width: AppSpacing.borderWidth,
                          ),
                        ),
                        child: Material(
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: InkWell(
                            onTap: onSettle,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              child: Center(
                                child: Text(
                                  'Settle',
                                  style: AppText.captionSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Paid progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 5,
                    width: double.infinity,
                    color: AppColors.seg,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Paid & Remaining values row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Paid ${formatMoney(transaction.paidAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.captionSm.copyWith(
                          color: AppColors.mute,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (transaction.status == FriendTxStatus.settled)
                      Text(
                        'Settled',
                        style: AppText.captionSm.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          'Remaining ${formatMoney(transaction.remaining)}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.captionSm.copyWith(
                            color: AppColors.mute,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
