import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/motion_widgets.dart';
import '../dashboard_home_strings.dart';

/// One quick action: where it goes and how its card looks.
class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String label;
  final String route;
}

/// Quick actions: a horizontally scrollable row of equal-size cards. The
/// first four are the everyday "add" actions, the rest open the sections that
/// are not in the bottom bar (Calendar, Friends' debts, Settings).
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  static const double cardWidth = 104;
  static const double cardHeight = 108;

  static const List<_QuickAction> _actions = <_QuickAction>[
    _QuickAction(
      icon: AppIcons.banknote,
      background: AppColors.greenBg,
      foreground: AppColors.green,
      label: DashboardHomeStrings.recordPayment,
      route: '/payments/new',
    ),
    _QuickAction(
      icon: AppIcons.receipt,
      background: AppColors.coralBg,
      foreground: AppColors.coral,
      label: DashboardHomeStrings.addExpense,
      route: '/expenses/new',
    ),
    _QuickAction(
      icon: AppIcons.folderPlus,
      background: AppColors.purpleBg,
      foreground: AppColors.purple,
      label: DashboardHomeStrings.newProject,
      route: '/projects/new',
    ),
    _QuickAction(
      icon: AppIcons.userPlus,
      background: AppColors.yellowBg,
      foreground: AppColors.orange,
      label: DashboardHomeStrings.addClient,
      route: '/clients/new',
    ),
    _QuickAction(
      icon: AppIcons.milestone,
      background: AppColors.orangeBg,
      foreground: AppColors.orange,
      label: DashboardHomeStrings.newMilestone,
      route: '/calendar/new',
    ),
    _QuickAction(
      icon: AppIcons.calendarDays,
      background: AppColors.purpleBg,
      foreground: AppColors.purple,
      label: DashboardHomeStrings.calendar,
      route: '/calendar',
    ),
    _QuickAction(
      icon: AppIcons.handCoins,
      background: AppColors.greenBg,
      foreground: AppColors.green,
      label: DashboardHomeStrings.friendsDebts,
      route: '/friends',
    ),
    _QuickAction(
      icon: AppIcons.settings,
      background: AppColors.seg,
      foreground: AppColors.ink,
      label: DashboardHomeStrings.settings,
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DashboardHomeStrings.quickActions, style: AppText.cardTitle),
        const SizedBox(height: AppSpacing.md),
        // The page has a side gutter; the list bleeds to the screen edges so
        // the next card peeks in and invites a swipe.
        SizedBox(
          height: cardHeight,
          child: OverflowBox(
            minWidth: screenWidth,
            maxWidth: screenWidth,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              itemCount: _actions.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) =>
                  _QuickActionCard(action: _actions[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: SizedBox(
        width: HomeQuickActions.cardWidth,
        height: HomeQuickActions.cardHeight,
        child: Material(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(action.route),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: action.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      action.icon,
                      size: 22,
                      color: action.foreground,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.captionSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
