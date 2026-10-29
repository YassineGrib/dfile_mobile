import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'transaction_detail_strings.dart';
import 'widgets/settle_sheet.dart';
import 'widgets/transaction_detail_delete_sheet.dart';
import 'widgets/transaction_detail_settlement_row.dart';

/// Screen displaying transaction details and settlement history per `docs/design/SPEC.md` (FD10).
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  void _popOrGoFriends(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friendsPath);
    }
  }

  void _openDeleteConfirmSheet(
    BuildContext context, {
    required FriendTransaction transaction,
    required String friendName,
    required int settlementsCount,
    required FriendsRepository repo,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return TransactionDetailDeleteConfirmSheet(
          transaction: transaction,
          friendName: friendName,
          settlementsCount: settlementsCount,
          onConfirm: () {
            repo.deleteTransaction(transaction.id);
            Navigator.of(sheetContext).pop();
            context.go(
              '/friends/${transaction.friendId}',
              extra: <String, Object?>{
                'toast': TransactionDetailStrings.transactionDeletedToast,
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FriendsRepository repo = FriendsScope.of(context);
    final FriendTransaction? transaction = repo.transactionById(transactionId);

    if (transaction == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back,
                  tooltip: TransactionDetailStrings.back,
                  onPressed: () => _popOrGoFriends(context),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.seg,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 32,
                          color: AppColors.mute,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        TransactionDetailStrings.transactionNotFound,
                        style: AppText.cardTitle,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: TransactionDetailStrings.backToFriends,
                        onPressed: () => _popOrGoFriends(context),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final Friend? friend = repo.friendById(transaction.friendId);
    final String friendName = friend?.name ?? '';
    final List<FriendSettlement> settlements =
        repo.settlementsOf(transaction.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: TransactionDetailStrings.back,
                    onPressed: () => _popOrGoFriends(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        TransactionDetailStrings.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sectionTitle.copyWith(fontSize: 20),
                      ),
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.more_horiz,
                    tooltip: TransactionDetailStrings.moreOptions,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                  AppSpacing.pageGutter,
                  AppSpacing.xl,
                ),
                child: _buildDetailCard(
                  context,
                  transaction: transaction,
                  friendName: friendName,
                  settlements: settlements,
                ),
              ),
            ),

            // Bottom Bar: [Delete] and [Settle payment]
            _buildBottomBar(
              context,
              transaction: transaction,
              friendName: friendName,
              settlementsCount: settlements.length,
              repo: repo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required FriendTransaction transaction,
    required String friendName,
    required List<FriendSettlement> settlements,
  }) {
    // Type icon properties
    final (Color typeBg, Color typeFg, String typeGlyph) = switch (transaction.type) {
      FriendTxType.money => (AppColors.greenBg, AppColors.green, r'$'),
      FriendTxType.service => (AppColors.purpleBg, AppColors.purple, 'S'),
      FriendTxType.expense => (AppColors.orangeBg, AppColors.orange, 'C'),
    };

    // Amount color: green lent / red borrowed
    final Color amountColor = transaction.direction == FriendTxDirection.lent
        ? AppColors.green
        : AppColors.red;

    // Direction chip
    final (Color dirBg, Color dirFg, String dirLabel) =
        transaction.direction == FriendTxDirection.lent
            ? (AppColors.greenBg, AppColors.green, transaction.direction.chipLabel)
            : (AppColors.redBg, AppColors.red, transaction.direction.chipLabel);

    // Status chip
    final (Color statBg, Color statFg, String statLabel) = switch (transaction.status) {
      FriendTxStatus.pending => (AppColors.pendingBg, AppColors.orange, transaction.status.label),
      FriendTxStatus.partial => (AppColors.partialBg, AppColors.purple, transaction.status.label),
      FriendTxStatus.settled => (AppColors.greenBg, AppColors.green, transaction.status.label),
    };

    // Progress bar calculation
    final double progress = transaction.amount <= 0.0
        ? 1.0
        : (transaction.paidAmount / transaction.amount).clamp(0.0, 1.0);

    final bool isSettled = transaction.isSettled;

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
        children: [
          // Header: Type icon + Description + "friend â€¢ type"
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  typeGlyph,
                  style: TextStyle(
                    color: typeFg,
                    fontSize: 20,
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
                      transaction.description,
                      style: AppText.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TransactionDetailStrings.detailSubtitle(
                        friendName,
                        transaction.type,
                      ),
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
          const SizedBox(height: AppSpacing.xl),

          // Big Amount
          Text(
            formatMoney(transaction.amount),
            style: AppText.title.copyWith(
              color: amountColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Direction & Status Chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Paid bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(
                isSettled ? AppColors.green : AppColors.orange,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Detail Rows: Paid, Remaining, Date, Due date
          _buildRow(
            label: TransactionDetailStrings.paid,
            value: Text(
              formatMoney(transaction.paidAmount),
              style: AppText.bodyMedium.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildRow(
            label: TransactionDetailStrings.remaining,
            value: Text(
              isSettled
                  ? TransactionDetailStrings.settled
                  : formatMoney(transaction.remaining),
              style: AppText.bodyMedium.copyWith(
                color: isSettled ? AppColors.green : AppColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildRow(
            label: TransactionDetailStrings.date,
            value: Text(
              formatDate(transaction.date),
              style: AppText.bodyMedium.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildRow(
            label: TransactionDetailStrings.dueDate,
            value: Text(
              transaction.dueDate != null
                  ? formatDate(transaction.dueDate!)
                  : TransactionDetailStrings.emptyDash,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Divider
          const Divider(
            color: AppColors.line,
            height: 1,
            thickness: AppSpacing.borderWidth,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Settlements section title
          Text(
            TransactionDetailStrings.settlementsCount(settlements.length),
            style: AppText.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.md),

          // Settlements rows or "No settlements yet"
          if (settlements.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                TransactionDetailStrings.noSettlementsYet,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
            )
          else
            ...settlements.map(
              (FriendSettlement s) =>
                  TransactionDetailSettlementRow(settlement: s),
            ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required Widget value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.bodyMedium.copyWith(color: AppColors.mute),
        ),
        value,
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context, {
    required FriendTransaction transaction,
    required String friendName,
    required int settlementsCount,
    required FriendsRepository repo,
  }) {
    final bool isSettled = transaction.isSettled;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              // [Delete] button (red outline)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: OutlinedButton(
                    onPressed: () => _openDeleteConfirmSheet(
                      context,
                      transaction: transaction,
                      friendName: friendName,
                      settlementsCount: settlementsCount,
                      repo: repo,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(
                        color: AppColors.red,
                        width: AppSpacing.borderWidth,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      TransactionDetailStrings.delete,
                      style: AppText.button.copyWith(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              // [Settle payment] button (hidden/disabled when settled)
              if (!isSettled) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: TransactionDetailStrings.settlePayment,
                    onPressed: () => showSettleSheet(
                      context,
                      transactionId: transaction.id,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
