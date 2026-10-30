import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import 'app_icons.dart';

/// Four-tab bottom bar (Home, Projects, Clients, More) with real Lucide icons.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, this.currentIndex = clientsTabIndex, this.onTap});

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

  static const List<IconData> tabIcons = <IconData>[
    AppIcons.house,
    AppIcons.folderKanban,
    AppIcons.users,
    AppIcons.ellipsis,
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
    } else if (index == moreTabIndex) {
      GoRouter.maybeOf(context)?.go('/more');
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
                child: InkWell(
                  onTap: () => _handleTap(context, index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.seg : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          tabIcons[index],
                          size: 22,
                          color: isActive ? AppColors.ink : AppColors.mute,
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
