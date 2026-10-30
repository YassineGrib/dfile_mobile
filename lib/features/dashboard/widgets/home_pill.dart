import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Pill badge with custom background, text color, optional icon and border.
class HomePill extends StatelessWidget {
  const HomePill({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.seg,
    this.textColor = AppColors.ink,
    this.iconColor,
    this.height = 28,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: iconColor ?? textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppText.captionSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
