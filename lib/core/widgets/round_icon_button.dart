import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// 44px circular icon button (white with 1.5px line border by default).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    this.icon,
    this.child,
    this.onPressed,
    this.tooltip,
    this.size = AppSpacing.iconButtonSize,
    this.backgroundColor = AppColors.card,
    this.iconColor = AppColors.ink,
    this.borderColor = AppColors.line,
  }) : assert(
         icon != null || child != null,
         'Either icon or child must be provided.',
       );

  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: CircleBorder(
          side: BorderSide(color: borderColor, width: AppSpacing.borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(child: child ?? Icon(icon, size: 20, color: iconColor)),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
