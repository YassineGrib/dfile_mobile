import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../friends/data/friend.dart';
import '../../friends/data/friends_repository.dart';
import '../../friends/data/friends_scope.dart';
import '../dashboard_activity_strings.dart';
import 'dash_card.dart';
import 'dash_icon_bubble.dart';

/// Friends' debts snapshot card per `docs/design/SPEC.md` (HM3).
///
/// Shows:
/// - Title "Friends' debts" with tinted purple arrowRightLeft bubble
/// - Subtitle "Net balance across friends"
/// - Net balance amount on the right (green when > 0, red when < 0, ink at 0)
/// - Chips "Owed N" (green with arrowDownRight) and "You owe N" (red with arrowUpRight)
/// - Tapping card -> `context.push('/friends')`
/// - When there are no friends, shows "Track money you lend or borrow" and chips at 0.
class FriendsSnapshotCard extends StatelessWidget {
  const FriendsSnapshotCard({super.key, this.clock});

  /// Optional clock provider for deterministic testing.
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final FriendsRepository friendsRepo = FriendsScope.of(context);
    final List<Friend> friends = friendsRepo.friends;
    final OverallBalance overall = friendsRepo.overallBalance();

    final bool hasFriends = friends.isNotEmpty;
    final double netVal = hasFriends ? overall.net : 0.0;
    final double owedToYou = hasFriends ? overall.owedToYou : 0.0;
    final double youOwe = hasFriends ? overall.youOwe : 0.0;

    final Color netColor = netVal > 0
        ? AppColors.green
        : (netVal < 0 ? AppColors.red : AppColors.ink);

    final String netText = netVal > 0
        ? '+${formatMoney(netVal)}'
        : (netVal < 0 ? '-${formatMoney(netVal.abs())}' : formatMoney(0));

    return DashCard(
      onTap: () => context.push(AppRoutes.friendsPath),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const DashIconBubble(
                icon: AppIcons.arrowRightLeft,
                foreground: AppColors.purple,
                background: AppColors.purpleBg,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DashboardActivityStrings.friendsDebts,
                      style: AppText.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasFriends
                          ? DashboardActivityStrings.netBalanceAcrossFriends
                          : DashboardActivityStrings.trackMoneyLendBorrow,
                      style: AppText.caption.copyWith(
                        color: AppColors.mute,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    netText,
                    style: AppText.cardTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: netColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DebtChip(
                  icon: AppIcons.arrowDownRight,
                  label:
                      '${DashboardActivityStrings.owedPrefix} ${formatMoney(owedToYou)}',
                  textColor: AppColors.green,
                  bgColor: AppColors.greenBg,
                  borderColor: AppColors.green.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DebtChip(
                  icon: AppIcons.arrowUpRight,
                  label:
                      '${DashboardActivityStrings.youOwePrefix} ${formatMoney(youOwe)}',
                  textColor: AppColors.red,
                  bgColor: AppColors.redBg,
                  borderColor: AppColors.red.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebtChip extends StatelessWidget {
  const _DebtChip({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppText.captionSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
