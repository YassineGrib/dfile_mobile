import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Four-tab bottom bar (Home, Projects, Clients, More) with Clients active by default.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    this.currentIndex = clientsTabIndex,
    this.onTap,
  });

  static const int clientsTabIndex = 2;
  static const List<String> labels = <String>[
    'Home',
    'Projects',
    'Clients',
    'More',
  ];

  final int currentIndex;
  final ValueChanged<int>? onTap;

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
              return Expanded(
                child: InkWell(
                  onTap: onTap != null ? () => onTap!(index) : null,
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
