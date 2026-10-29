import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

/// Four-tab bottom bar (Home, Projects, Clients, More) with Clients active by default.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    this.currentIndex = clientsTabIndex,
    this.onTap,
  });

  static const int homeTabIndex = 0;
  static const int projectsTabIndex = 1;
  static const int clientsTabIndex = 2;
  static const int moreTabIndex = 3;
  static const List<String> labels = <String>[
    'Home',
    'Projects',
    'Clients',
    'More',
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
    if (index == projectsTabIndex) {
      GoRouter.maybeOf(context)?.go('/projects');
    } else if (index == clientsTabIndex) {
      GoRouter.maybeOf(context)?.go('/clients');
    } else if (index == moreTabIndex) {
      GoRouter.maybeOf(context)?.go('/more');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.tabBarHeight,
          child: Row(
            children: List<Widget>.generate(labels.length, (int index) {
              final bool isActive = index == currentIndex;
              final bool isInteractive =
                  onTap != null ||
                  index == projectsTabIndex ||
                  index == clientsTabIndex ||
                  index == moreTabIndex;
              return Expanded(
                child: InkWell(
                  onTap: isInteractive ? () => _handleTap(context, index) : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.ink : AppColors.seg,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 6),
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
