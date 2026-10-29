import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Coloured circular avatar displaying a single uppercase initial.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    super.key,
    required this.initial,
    required this.color,
    this.size = 48,
    this.textColor = AppColors.ink,
  });

  final String initial;
  final Color color;
  final double size;
  final Color textColor;

  String get _displayInitial {
    final String trimmed = initial.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _displayInitial,
        style: AppText.cardTitle.copyWith(
          fontSize: size * 0.4,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}
