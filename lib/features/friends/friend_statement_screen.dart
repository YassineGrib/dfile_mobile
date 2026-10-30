import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'friend_statement_strings.dart';
import 'widgets/friend_statement_balance_card.dart';
import 'widgets/widgets.dart';

/// Screen displaying an individual friend's debt statement per `docs/design/SPEC.md` (FD3).
class FriendStatementScreen extends StatefulWidget {
  const FriendStatementScreen({super.key, required this.friendId});

  final String friendId;

  @override
  State<FriendStatementScreen> createState() => _FriendStatementScreenState();
}

class _FriendStatementScreenState extends State<FriendStatementScreen> {
  Object? _lastHandledExtra;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingToast();
  }

  void _handleIncomingToast() {
    Object? extra;
    try {
      extra = GoRouterState.of(context).extra;
    } catch (_) {
      // In case GoRouter is not available in the context tree.
    }

    if (extra != null && !identical(extra, _lastHandledExtra)) {
      _lastHandledExtra = extra;
      String? message;
      if (extra is String) {
        message = extra;
      } else if (extra is Map) {
        final Object? toastValue = extra['toast'];
        if (toastValue is String) {
          message = toastValue;
        }
      }

      if (message != null && message.trim().isNotEmpty) {
        final String toastMessage = message;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context, toastMessage);
          }
        });
      }
    }
  }

  void _popOrGoFriends(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friendsPath);
    }
  }

  void _openActionsSheet({
    required BuildContext context,
    required Friend friend,
    required FriendBalance balance,
    required FriendsRepository repo,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  UserAvatar(name: friend.name, size: 48),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.name,
                          style: AppText.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (friend.phone.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(friend.phone.trim(), style: AppText.caption),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionItem(
                label: FriendStatementStrings.addTransaction,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(
                    '${AppRoutes.newFriendTransactionPath}?friendId=${friend.id}',
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: FriendStatementStrings.copyPhoneNumber,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (friend.phone.trim().isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: friend.phone.trim()));
                    showAppToast(
                      context,
                      FriendStatementStrings.copiedPhoneToast,
                    );
                  } else {
                    showAppToast(
                      context,
                      FriendStatementStrings.noPhoneNumberToast,
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: FriendStatementStrings.openTransactions,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go(
                    AppRoutes.friendsPath,
                    extra: <String, Object?>{
                      'tab': 'transactions',
                      'query': friend.name,
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: FriendStatementStrings.deleteFriend,
                textColor: AppColors.red,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openDeleteConfirmSheet(
                    context: context,
                    friend: friend,
                    activeCount: balance.active,
                    repo: repo,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDeleteConfirmSheet({
    required BuildContext context,
    required Friend friend,
    required int activeCount,
    required FriendsRepository repo,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext confirmContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          FriendStatementStrings.deleteFriendTitle,
                          style: AppText.sectionTitle.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          FriendStatementStrings.deleteFriendSubtitle,
                          style: AppText.caption.copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
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
                      FriendStatementStrings.deleteConfirmFriendName(
                        friend.name,
                      ),
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.red,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      FriendStatementStrings.deleteConfirmActiveWarning(
                        activeCount,
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
                    onTap: () {
                      repo.deleteFriend(friend.id);
                      Navigator.of(confirmContext).pop();
                      context.go(
                        AppRoutes.friendsPath,
                        extra: <String, Object?>{
                          'toast': FriendStatementStrings.friendDeletedToast,
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        FriendStatementStrings.confirmDelete,
                        style: AppText.button,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: FriendStatementStrings.cancel,
                onPressed: () => Navigator.of(confirmContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppText.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({
    required VoidCallback onBack,
    required VoidCallback onMore,
  }) {
    return Row(
      children: [
        const SizedBox(width: AppSpacing.iconButtonSize),
        Expanded(
          child: Center(
            child: Text(
              FriendStatementStrings.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
        ),
        RoundIconButton(
          icon: Icons.more_horiz,
          tooltip: FriendStatementStrings.moreOptions,
          onPressed: onMore,
        ),
      ],
    );
  }

  Widget _buildFriendHeader(Friend friend) {
    return Row(
      children: [
        UserAvatar(name: friend.name, size: 56),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.name,
                style: AppText.title.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (friend.phone.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  friend.phone.trim(),
                  style: AppText.caption.copyWith(
                    color: AppColors.mute,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                style: AppText.captionSm.copyWith(
                  color: AppColors.mute,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: AppText.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTilesRow(FriendBalance balance) {
    return Row(
      children: [
        _buildStatTile(
          label: FriendStatementStrings.owedToYou,
          value: formatAmount(balance.owedToYou),
          valueColor: AppColors.green,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildStatTile(
          label: FriendStatementStrings.youOwe,
          value: formatAmount(balance.youOwe),
          valueColor: AppColors.red,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildStatTile(
          label: FriendStatementStrings.active,
          value: '${balance.active}',
          valueColor: AppColors.ink,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildStatTile(
          label: FriendStatementStrings.settled,
          value: '${balance.settled}',
          valueColor: AppColors.ink,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(Friend friend) {
    return Row(
      children: [
        Expanded(
          child: Text(
            FriendStatementStrings.transactionHistory,
            style: AppText.sectionTitle.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.push(
            '${AppRoutes.newFriendTransactionPath}?friendId=${friend.id}',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              FriendStatementStrings.addTransactionShort,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final FriendsRepository repo = FriendsScope.of(context);
    final Friend? friend = repo.friendById(widget.friendId);

    // Unknown id -> friendly "Friend not found" screen with a back button
    if (friend == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          FriendStatementStrings.friendNotFound,
                          style: AppText.sectionTitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: FriendStatementStrings.backToFriends,
                        onPressed: () => _popOrGoFriends(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final FriendBalance balance = repo.friendBalance(widget.friendId);
    final List<FriendTransaction> transactions = repo.transactionsOf(
      widget.friendId,
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double horizontalGutter = screenWidth < 380
        ? AppSpacing.lg
        : AppSpacing.pageGutter;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalGutter,
            AppSpacing.lg,
            horizontalGutter,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox.shrink(
                child: Text(
                  'FriendStatementScreen',
                  style: TextStyle(fontSize: 0, color: AppColors.transparent),
                ),
              ),
              _buildTopBar(
                onBack: () => _popOrGoFriends(context),
                onMore: () => _openActionsSheet(
                  context: context,
                  friend: friend,
                  balance: balance,
                  repo: repo,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildFriendHeader(friend),
              const SizedBox(height: AppSpacing.xl),
              FriendStatementBalanceCard(balance: balance),
              const SizedBox(height: AppSpacing.md),
              _buildStatTilesRow(balance),
              const SizedBox(height: AppSpacing.xxl),
              _buildSectionHeader(friend),
              const SizedBox(height: AppSpacing.md),
              if (transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  alignment: Alignment.center,
                  child: Text(
                    FriendStatementStrings.noTransactions,
                    textAlign: TextAlign.center,
                    style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                  ),
                )
              else
                for (int i = 0; i < transactions.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          Widget card = FriendTxCard(
                            transaction: transactions[i],
                            friendName: friend.name,
                            showFriend: false,
                            onTap: () => context.push(
                              '/friends/transactions/${transactions[i].id}',
                            ),
                            onSettle: () => showSettleSheet(
                              context,
                              transactionId: transactions[i].id,
                            ),
                          );
                          if (constraints.maxWidth < 380) {
                            card = FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: SizedBox(width: 380, child: card),
                            );
                          }
                          return card;
                        },
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
