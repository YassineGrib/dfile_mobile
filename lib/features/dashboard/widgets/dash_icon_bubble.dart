import 'package:flutter/widgets.dart';

/// A tinted circular container displaying a Lucide icon.
class DashIconBubble extends StatelessWidget {
  const DashIconBubble({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 40.0,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: foreground,
        size: size * 0.5,
      ),
    );
  }
}
