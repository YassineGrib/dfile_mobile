import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Rounded coloured panel displaying `assets/images/mascots.png` fitted inside.
class MascotPanel extends StatelessWidget {
  const MascotPanel({
    super.key,
    required this.color,
    required this.height,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  static const String mascotAsset = 'assets/images/mascots.png';

  final Color color;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.panel),
      ),
      child: Center(
        child: Image.asset(
          mascotAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
