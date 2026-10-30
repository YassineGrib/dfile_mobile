import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../calendar_month_strings.dart';
import '../data/calendar_events.dart';
import 'calendar_event_card.dart';

/// Day header ("Friday, Oct 30", [Today] pill, "N events" chip) followed by
/// the day's [CalendarEventCard]s or the "Nothing planned" empty card.
class CalendarMonthDayList extends StatelessWidget {
  const CalendarMonthDayList({
    super.key,
    required this.selectedDay,
    required this.today,
    required this.events,
    required this.onEventTap,
    required this.onAddMilestone,
  });

  final DateTime selectedDay;
  final DateTime today;
  final List<CalendarEvent> events;
  final void Function(CalendarEvent event) onEventTap;
  final VoidCallback onAddMilestone;

  @override
  Widget build(BuildContext context) {
    final bool isToday =
        selectedDay.year == today.year &&
        selectedDay.month == today.month &&
        selectedDay.day == today.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Day header row
        Row(
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      formatWeekdayDate(selectedDay),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        CalendarMonthStrings.today,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.seg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                CalendarMonthStrings.eventsCount(events.length),
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Event cards or Empty State
        if (events.isNotEmpty)
          ...events.map(
            (CalendarEvent event) =>
                CalendarEventCard(event: event, onTap: () => onEventTap(event)),
          )
        else
          Material(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xxl,
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.seg,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        AppIcons.calendarDays,
                        size: 24,
                        color: AppColors.mute,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    CalendarMonthStrings.nothingPlanned,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 44,
                    child: Material(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onAddMilestone,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Center(
                            child: Text(
                              CalendarMonthStrings.addMilestone,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
