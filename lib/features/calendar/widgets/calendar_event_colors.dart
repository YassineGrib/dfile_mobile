import 'package:flutter/widgets.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/calendar_events.dart';

/// Visual styling configuration for a calendar event kind
/// per `docs/design/SPEC.md` (CL1-CL15).
class CalendarEventColors {
  const CalendarEventColors({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.dot,
  });

  /// Background color for the 40px icon bubble.
  final Color bg;

  /// Foreground color for the icon.
  final Color fg;

  /// Lucide icon representation.
  final IconData icon;

  /// Dot color rendered in the month grid and Gantt charts.
  final Color dot;

  /// Returns the color and icon tokens for [kind].
  static CalendarEventColors of(CalendarEventKind kind) {
    switch (kind) {
      case CalendarEventKind.over:
        return const CalendarEventColors(
          bg: AppColors.redBg,
          fg: AppColors.red,
          icon: AppIcons.triangleAlert,
          dot: AppColors.red,
        );
      case CalendarEventKind.due:
        return const CalendarEventColors(
          bg: AppColors.yellowBg,
          fg: AppColors.orange,
          icon: AppIcons.calendarClock,
          dot: AppColors.orange,
        );
      case CalendarEventKind.start:
        return const CalendarEventColors(
          bg: AppColors.purpleBg,
          fg: AppColors.purple,
          icon: AppIcons.play,
          dot: AppColors.purple,
        );
      case CalendarEventKind.milestone:
        return const CalendarEventColors(
          bg: AppColors.greenBg,
          fg: AppColors.green,
          icon: AppIcons.milestone,
          dot: AppColors.green,
        );
      case CalendarEventKind.done:
        return const CalendarEventColors(
          bg: AppColors.seg,
          fg: AppColors.mute,
          icon: AppIcons.circleCheck,
          dot: AppColors.calendarDotDone,
        );
      case CalendarEventKind.debt:
        return const CalendarEventColors(
          bg: AppColors.coralBg,
          fg: AppColors.coral,
          icon: AppIcons.handCoins,
          dot: AppColors.coral,
        );
    }
  }
}
