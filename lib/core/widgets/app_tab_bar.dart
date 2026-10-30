import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../haptics.dart';
import '../motion.dart';
import '../theme/theme.dart';
import 'app_icons.dart';
import 'motion_widgets.dart';

/// Five-tab bottom bar (Home, Projects, Clients, Payments, Expenses) with
/// real Lucide icons. Other sections live in the Home quick actions.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, this.currentIndex = clientsTabIndex, this.onTap});

  static const int homeTabIndex = 0;
  static const int projectsTabIndex = 1;
  static const int clientsTabIndex = 2;
  static const int paymentsTabIndex = 3;
  static const int expensesTabIndex = 4;

  /// For screens reached from Home that belong to no tab (no tab highlighted).
  static const int noTabIndex = -1;
  static const List<String> labels = <String>[
    'Home',
    'Projects',
    'Clients',
    'Payments',
    'Expenses',
  ];

  static const List<IconData> tabIcons = <IconData>[
    AppIcons.house,
    AppIcons.folderKanban,
    AppIcons.users,
    AppIcons.banknote,
    AppIcons.receipt,
  ];

  final int currentIndex;
  final ValueChanged<int>? onTap;

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) {
      return;
    }
    if (index == homeTabIndex) {
      GoRouter.maybeOf(context)?.go('/home');
    } else if (index == projectsTabIndex) {
      GoRouter.maybeOf(context)?.go('/projects');
    } else if (index == clientsTabIndex) {
      GoRouter.maybeOf(context)?.go('/clients');
    } else if (index == paymentsTabIndex) {
      GoRouter.maybeOf(context)?.go('/payments');
    } else if (index == expensesTabIndex) {
      GoRouter.maybeOf(context)?.go('/expenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.tabBarHeight,
          child: Row(
            children: List<Widget>.generate(labels.length, (int index) {
              final bool isActive = index == currentIndex;
              return Expanded(
                child: PressScale(
                  scale: 0.92,
                  child: InkWell(
                    onTap: () {
                      if (index != currentIndex) AppHaptics.selection();
                      _handleTap(context, index);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppMotion.standard,
                          curve: AppMotion.standardCurve,
                          width: 52,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.seg
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedScale(
                            scale: isActive ? 1.1 : 1,
                            duration: AppMotion.standard,
                            curve: AppMotion.standardCurve,
                            child: Icon(
                              tabIcons[index],
                              size: 22,
                              color: isActive ? AppColors.ink : AppColors.mute,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: AppText.captionSm.copyWith(
                            color: isActive ? AppColors.ink : AppColors.mute,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
