import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';

/// Section header displaying [title] and an optional action (default: "See all") with a chevron.
class DashSectionHead extends StatelessWidget {
  const DashSectionHead({
    super.key,
    required this.title,
    this.action = 'See all',
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.cardTitle),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action!,
                  style: AppText.captionSm.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  AppIcons.chevronRight,
                  size: 16,
                  color: AppColors.purple,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
