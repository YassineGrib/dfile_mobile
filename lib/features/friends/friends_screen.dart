import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'friends_list_strings.dart';
import 'widgets/friend_card.dart';
import 'widgets/friend_tx_card.dart';
import 'widgets/friends_list_balance_card.dart';
import 'widgets/friends_list_filter_sheet.dart';
import 'widgets/settle_sheet.dart';

/// Screen displaying the Friends and Transactions tabs per `docs/design/SPEC.md` (FD1, FD8).
///
/// Supports receiving an optional toast notification message via [GoRouterState.extra]
/// when arriving from other screens (e.g. `{'toast': 'Friend deleted successfully'}`
/// or `'Friend added'`).
/// Also accepts `{'tab': 'transactions'}` to select the Transactions tab directly.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({
    super.key,
    this.initialTab = FriendsTab.friends,
    this.initialQuery,
  });

  final FriendsTab initialTab;
  final String? initialQuery;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendsTab _activeTab;

  final TextEditingController _friendsSearchController =
      TextEditingController();
  final TextEditingController _txSearchController = TextEditingController();

  FriendNetFilter _friendNetFilter = FriendNetFilter.all;

  FriendDirectionFilter _txDirectionFilter = FriendDirectionFilter.all;
  FriendStatusFilter _txStatusFilter = FriendStatusFilter.all;
  FriendTypeFilter _txTypeFilter = FriendTypeFilter.all;
  dynamic _txPill = FriendDirectionFilter.all;

  Object? _lastHandledExtra;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    if (widget.initialQuery != null) {
      if (widget.initialTab == FriendsTab.friends) {
        _friendsSearchController.text = widget.initialQuery!;
      } else {
        _txSearchController.text = widget.initialQuery!;
      }
    }
  }

  @override
  void dispose() {
    _friendsSearchController.dispose();
    _txSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleIncomingExtra();
  }

  @override
  void didUpdateWidget(covariant FriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      _activeTab = widget.initialTab;
    }
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != null) {
      if (_activeTab == FriendsTab.friends) {
        _friendsSearchController.text = widget.initialQuery!;
      } else {
        _txSearchController.text = widget.initialQuery!;
      }
    }
  }

  void _handleIncomingExtra() {
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

        final Object? tabValue = extra['tab'];
        if (tabValue is String) {
          final FriendsTab requestedTab = FriendsTab.fromString(tabValue);
          if (_activeTab != requestedTab) {
            _activeTab = requestedTab;
            if (mounted) {
              setState(() {});
            }
          }
        }
      } else if (extra is FriendsTab) {
        if (_activeTab != extra) {
          _activeTab = extra;
          if (mounted) {
            setState(() {});
          }
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

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.morePath);
    }
  }

  void _clearFriendsFilters() {
    setState(() {
      _friendsSearchController.clear();
      _friendNetFilter = FriendNetFilter.all;
    });
  }

  void _clearTxFilters() {
    setState(() {
      _txSearchController.clear();
      _txDirectionFilter = FriendDirectionFilter.all;
      _txStatusFilter = FriendStatusFilter.all;
      _txTypeFilter = FriendTypeFilter.all;
      _txPill = FriendDirectionFilter.all;
    });
  }

  void _openFilterSheet() {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return FriendsListFilterSheet(
          initialDirection: _txDirectionFilter,
          initialStatus: _txStatusFilter,
          initialType: _txTypeFilter,
          onApply: (
            FriendDirectionFilter direction,
            FriendStatusFilter status,
            FriendTypeFilter type,
          ) {
            setState(() {
              _txDirectionFilter = direction;
              _txStatusFilter = status;
              _txTypeFilter = type;
              _updateTxPillFromFilters();
            });
          },
        );
      },
    );
  }

  void _updateTxPillFromFilters() {
    if (_txDirectionFilter == FriendDirectionFilter.owedToMe &&
        _txStatusFilter == FriendStatusFilter.all &&
        _txTypeFilter == FriendTypeFilter.all) {
      _txPill = FriendDirectionFilter.owedToMe;
    } else if (_txDirectionFilter == FriendDirectionFilter.iOwe &&
        _txStatusFilter == FriendStatusFilter.all &&
        _txTypeFilter == FriendTypeFilter.all) {
      _txPill = FriendDirectionFilter.iOwe;
    } else if (_txStatusFilter == FriendStatusFilter.settled &&
        _txDirectionFilter == FriendDirectionFilter.all &&
        _txTypeFilter == FriendTypeFilter.all) {
      _txPill = FriendStatusFilter.settled;
    } else if (_txDirectionFilter == FriendDirectionFilter.all &&
        _txStatusFilter == FriendStatusFilter.all &&
        _txTypeFilter == FriendTypeFilter.all) {
      _txPill = FriendDirectionFilter.all;
    } else {
      _txPill = null;
    }
  }

  void _onTxPillSelected(dynamic target) {
    setState(() {
      _txPill = target;
      if (target == null || target == FriendDirectionFilter.all) {
        _txDirectionFilter = FriendDirectionFilter.all;
        _txStatusFilter = FriendStatusFilter.all;
        _txTypeFilter = FriendTypeFilter.all;
        _txPill = FriendDirectionFilter.all;
      } else if (target == FriendDirectionFilter.owedToMe) {
        _txDirectionFilter = FriendDirectionFilter.owedToMe;
        if (_txStatusFilter == FriendStatusFilter.settled) {
          _txStatusFilter = FriendStatusFilter.all;
        }
      } else if (target == FriendDirectionFilter.iOwe) {
        _txDirectionFilter = FriendDirectionFilter.iOwe;
        if (_txStatusFilter == FriendStatusFilter.settled) {
          _txStatusFilter = FriendStatusFilter.all;
        }
      } else if (target == FriendStatusFilter.settled) {
        _txStatusFilter = FriendStatusFilter.settled;
        _txDirectionFilter = FriendDirectionFilter.all;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final FriendsRepository repo = FriendsScope.of(context);
    final OverallBalance overall = repo.overallBalance();

    final List<Friend> allFriends = repo.friends;
    final List<FriendTransaction> allTransactions = repo.transactions;

    final List<Friend> displayedFriends = filterFriends(
      allFriends,
      query: _friendsSearchController.text,
      filter: _friendNetFilter,
      balanceLookup: repo.friendBalance,
    );

    final List<FriendTransaction> displayedTransactions = filterTransactions(
      allTransactions,
      query: _txSearchController.text,
      directions: _txDirectionFilter,
      status: _txStatusFilter,
      type: _txTypeFilter,
      nameOf: (String friendId) => repo.friendById(friendId)?.name ?? '',
    );

    final bool isFriendsTab = _activeTab == FriendsTab.friends;
    final TextEditingController activeSearchController =
        isFriendsTab ? _friendsSearchController : _txSearchController;

    const List<(String, FriendNetFilter)> friendPillOptions =
        <(String, FriendNetFilter)>[
      (FriendsListStrings.pillAll, FriendNetFilter.all),
      (FriendsListStrings.pillOweMe, FriendNetFilter.owedToMe),
      (FriendsListStrings.pillIOwe, FriendNetFilter.iOwe),
      (FriendsListStrings.pillSettled, FriendNetFilter.settled),
    ];

    const List<(String, dynamic)> txPillOptions = <(String, dynamic)>[
      (FriendsListStrings.txPillAll, FriendDirectionFilter.all),
      (FriendsListStrings.txPillOwedToMe, FriendDirectionFilter.owedToMe),
      (FriendsListStrings.txPillIOwe, FriendDirectionFilter.iOwe),
      (FriendsListStrings.txPillSettled, FriendStatusFilter.settled),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.moreTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top Section: Back, Title + count, "+" button, Balance Card, Tab toggle, Search
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.lg,
                AppSpacing.pageGutter,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    RoundIconButton(
                      onPressed: () => _handleBack(context),
                      child: BackButton(
                        color: AppColors.ink,
                        onPressed: () => _handleBack(context),
                      ),
                    ),
                    const SizedBox.shrink(child: Text('FriendsScreen')),
                    const SizedBox(height: AppSpacing.md),

                    // Header row: Title + count, and "+" button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FriendsListStrings.title,
                                style: AppText.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isFriendsTab
                                    ? FriendsListStrings.friendsCount(
                                        allFriends.length,
                                      )
                                    : FriendsListStrings.transactionsCount(
                                        allTransactions.length,
                                      ),
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundIconButton(
                          backgroundColor: AppColors.ink,
                          borderColor: AppColors.ink,
                          iconColor: AppColors.white,
                          icon: Icons.add,
                          onPressed: () =>
                              context.push(AppRoutes.addFriendPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Overall balance card
                    FriendsListBalanceCard(
                      balance: overall,
                    ),
                    const SizedBox(height: 14),

                    // Two-way toggle: Friends / Transactions
                    SegmentedToggle(
                      options: const <String>[
                        FriendsListStrings.tabFriends,
                        FriendsListStrings.tabTransactions,
                      ],
                      selectedIndex: isFriendsTab ? 0 : 1,
                      onChanged: (int index) {
                        setState(() {
                          _activeTab = index == 0
                              ? FriendsTab.friends
                              : FriendsTab.transactions;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Search field
                    Container(
                      height: AppSpacing.searchHeight,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.search),
                        border: Border.all(
                          color: AppColors.line,
                          width: AppSpacing.borderWidth,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: activeSearchController,
                        onChanged: (_) => setState(() {}),
                        style: AppText.body,
                        cursorColor: AppColors.ink,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: isFriendsTab
                              ? FriendsListStrings.searchFriendsPlaceholder
                              : FriendsListStrings
                                  .searchTransactionsPlaceholder,
                          hintStyle: AppText.body.copyWith(
                            color: AppColors.placeholder,
                          ),
                          prefixIcon: const Icon(
                            Icons.circle_outlined,
                            size: 18,
                            color: AppColors.mute,
                          ),
                          suffixIcon: activeSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: AppColors.mute,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      activeSearchController.clear();
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Horizontal pills row
            if (isFriendsTab)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  key: const Key('friend-net-pills'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < friendPillOptions.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        AppPill(
                          label: friendPillOptions[i].$1,
                          selected: _friendNetFilter == friendPillOptions[i].$2,
                          onTap: () => setState(
                            () => _friendNetFilter = friendPillOptions[i].$2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  key: const Key('tx-quick-pills'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < txPillOptions.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        AppPill(
                          label: txPillOptions[i].$1,
                          selected: _txPill == txPillOptions[i].$2,
                          onTap: () => _onTxPillSelected(txPillOptions[i].$2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Transactions tab: "N transactions" count and "Filter" row
            if (!isFriendsTab)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.md,
                  AppSpacing.pageGutter,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          FriendsListStrings.transactionsCount(
                            displayedTransactions.length,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(
                            fontSize: 14,
                            color: AppColors.mute,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      InkWell(
                        onTap: _openFilterSheet,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            FriendsListStrings.filter,
                            style: AppText.label.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.md),
              ),

            // Friends tab content
            if (isFriendsTab) ...[
              if (allFriends.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.xs,
                    AppSpacing.pageGutter,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: AppColors.line,
                              width: AppSpacing.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: AppColors.greenBg,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.people_outline_rounded,
                                  size: 36,
                                  color: AppColors.green,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                FriendsListStrings.emptyFriendsTitle,
                                textAlign: TextAlign.center,
                                style: AppText.sectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                FriendsListStrings.emptyFriendsSubtitle,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: FriendsListStrings.addFriendButton,
                          onPressed: () =>
                              context.push(AppRoutes.addFriendPath),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayedFriends.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.xs,
                    AppSpacing.pageGutter,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: AppColors.line,
                              width: AppSpacing.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: AppColors.yellow,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '?',
                                  style: AppText.title.copyWith(
                                    fontSize: 36,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                FriendsListStrings.emptyFriendsFilterTitle,
                                textAlign: TextAlign.center,
                                style: AppText.sectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                FriendsListStrings.emptyFriendsFilterSubtitle,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: FriendsListStrings.clearFilters,
                          onPressed: _clearFriendsFilters,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    0,
                    AppSpacing.pageGutter,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Friend friend = displayedFriends[index];
                        final FriendBalance balance =
                            repo.friendBalance(friend.id);
                        return LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Widget card = FriendCard(
                              friend: friend,
                              balance: balance,
                              onTap: () =>
                                  context.push('/friends/${friend.id}'),
                            );

                            if (constraints.maxWidth < 360) {
                              card = FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: 360,
                                  child: card,
                                ),
                              );
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: card,
                            );
                          },
                        );
                      },
                      childCount: displayedFriends.length,
                    ),
                  ),
                ),
            ],

            // Transactions tab content
            if (!isFriendsTab) ...[
              if (allTransactions.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.xs,
                    AppSpacing.pageGutter,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: AppColors.line,
                              width: AppSpacing.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: AppColors.purpleBg,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 36,
                                  color: AppColors.purple,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                FriendsListStrings.emptyTransactionsTitle,
                                textAlign: TextAlign.center,
                                style: AppText.sectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                FriendsListStrings.emptyTransactionsSubtitle,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: FriendsListStrings.addFriendButton,
                          onPressed: () =>
                              context.push(AppRoutes.addFriendPath),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayedTransactions.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.xs,
                    AppSpacing.pageGutter,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: AppColors.line,
                              width: AppSpacing.borderWidth,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: AppColors.yellow,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '?',
                                  style: AppText.title.copyWith(
                                    fontSize: 36,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                FriendsListStrings
                                    .emptyTransactionsFilterTitle,
                                textAlign: TextAlign.center,
                                style: AppText.sectionTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                FriendsListStrings
                                    .emptyTransactionsFilterSubtitle,
                                textAlign: TextAlign.center,
                                style: AppText.body.copyWith(
                                  color: AppColors.mute,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: FriendsListStrings.clearFilters,
                          onPressed: _clearTxFilters,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    0,
                    AppSpacing.pageGutter,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final FriendTransaction tx =
                            displayedTransactions[index];
                        final Friend? friend = repo.friendById(tx.friendId);
                        return LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Widget card = FriendTxCard(
                              transaction: tx,
                              showFriend: true,
                              friendName: friend?.name,
                              onTap: () => context
                                  .push('/friends/transactions/${tx.id}'),
                              onSettle: () => showSettleSheet(
                                context,
                                transactionId: tx.id,
                              ),
                            );

                            if (constraints.maxWidth < 380) {
                              card = FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: 380,
                                  child: card,
                                ),
                              );
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: card,
                            );
                          },
                        );
                      },
                      childCount: displayedTransactions.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
