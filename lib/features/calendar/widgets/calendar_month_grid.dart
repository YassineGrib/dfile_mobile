import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../calendar_month_strings.dart';
import '../data/calendar_events.dart';
import 'calendar_event_colors.dart';

/// Month grid displaying Sunday-first weekday headers, 5 or 6 week rows,
/// day cells with today/selected styling and event dots, and the event legend.
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.grid,
    required this.shownMonth,
    required this.selectedDay,
    required this.today,
    required this.dots,
    required this.onDaySelected,
  });

  final MonthGrid grid;
  final DateTime shownMonth;
  final DateTime selectedDay;
  final DateTime today;
  final Map<int, List<CalendarEventKind>> dots;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cellWidth = constraints.maxWidth / 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weekday row: S M T W T F S
            Row(
              children: CalendarMonthStrings.weekdays.map((String day) {
                return SizedBox(
                  width: cellWidth,
                  height: 32,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mute,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),

            // Week rows
            for (int w = 0; w < grid.weeksCount; w++) ...[
              Row(
                children: [
                  for (int d = 0; d < 7; d++) ...[
                    _buildCell(
                      context,
                      grid.cells[w * 7 + d],
                      cellWidth,
                    ),
                  ],
                ],
              ),
              if (w < grid.weeksCount - 1) const SizedBox(height: 4),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Legend row: Deadline, Start, Milestone, Debt due
            _buildLegend(),
          ],
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    MonthGridCell cell,
    double cellWidth,
  ) {
    final bool isSelected = cell.date.year == selectedDay.year &&
        cell.date.month == selectedDay.month &&
        cell.date.day == selectedDay.day;

    final bool isToday = cell.date.year == today.year &&
        cell.date.month == today.month &&
        cell.date.day == today.day;

    final List<CalendarEventKind> cellDots = cell.inMonth
        ? (dots[cell.date.day] ?? const <CalendarEventKind>[])
        : const <CalendarEventKind>[];

    return SizedBox(
      width: cellWidth,
      height: 48,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => onDaySelected(cell.date),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Container(
              width: 36,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(color: AppColors.ink, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isToday)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${cell.date.day}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          height: 1.1,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '${cell.date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: cell.inMonth
                              ? AppColors.ink
                              : AppColors.placeholder,
                          height: 1.1,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 5,
                    child: cellDots.isNotEmpty
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cellDots.map((CalendarEventKind kind) {
                              return Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: CalendarEventColors.of(kind).dot,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 6,
      spacing: 8,
      children: [
        _buildLegendItem(AppColors.orange, CalendarMonthStrings.legendDeadline),
        _buildLegendItem(AppColors.purple, CalendarMonthStrings.legendStart),
        _buildLegendItem(AppColors.green, CalendarMonthStrings.legendMilestone),
        _buildLegendItem(AppColors.coral, CalendarMonthStrings.legendDebtDue),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mute,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
