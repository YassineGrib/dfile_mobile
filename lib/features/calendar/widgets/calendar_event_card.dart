import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/calendar_events.dart';
import 'calendar_event_colors.dart';

/// Card rendering a single [CalendarEvent] per `docs/design/SPEC.md` (CL1-CL5):
/// - White card radius 20 with 1.5 line border
/// - 40px tinted icon bubble with kind's Lucide icon
/// - Title 14 bold (greyed if kind is `done`)
/// - Subtitle 12
/// - Right status pill or chevron-right
class CalendarEventCard extends StatelessWidget {
  const CalendarEventCard({super.key, required this.event, this.onTap});

  final CalendarEvent event;
  final VoidCallback? onTap;

  (Color, Color) _resolvePillColors(CalendarEventKind kind, String pillText) {
    switch (kind) {
      case CalendarEventKind.over:
        return (AppColors.redBg, AppColors.red);
      case CalendarEventKind.due:
        return (AppColors.yellowBg, AppColors.orange);
      case CalendarEventKind.start:
        return (AppColors.purpleBg, AppColors.purple);
      case CalendarEventKind.milestone:
        if (pillText.toLowerCase().contains('overdue')) {
          return (AppColors.redBg, AppColors.red);
        }
        return (AppColors.greenBg, AppColors.green);
      case CalendarEventKind.done:
        return (AppColors.seg, AppColors.mute);
      case CalendarEventKind.debt:
        return (AppColors.coralBg, AppColors.coral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CalendarEventColors colors = CalendarEventColors.of(event.kind);
    final bool isDone = event.kind == CalendarEventKind.done;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // 40px tinted icon bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(colors.icon, size: 20, color: colors.fg),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDone ? AppColors.mute : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Right pill or chevron-right
                if (event.pillText != null && event.pillText!.isNotEmpty) ...[
                  Builder(
                    builder: (BuildContext context) {
                      final (Color pillBg, Color pillFg) = _resolvePillColors(
                        event.kind,
                        event.pillText!,
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.pillText!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: pillFg,
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const Icon(
                    AppIcons.chevronRight,
                    size: 18,
                    color: AppColors.placeholder,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
