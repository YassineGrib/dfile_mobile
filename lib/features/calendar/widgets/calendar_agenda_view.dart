import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../calendar_views_strings.dart';
import '../data/calendar_events.dart';
import 'calendar_event_card.dart';

/// Agenda view component per `docs/design/SPEC.md` (CL4).
class CalendarAgendaView extends StatelessWidget {
  const CalendarAgendaView({
    super.key,
    required this.events,
    required this.now,
    this.onEventTap,
    this.clock,
  });

  final List<CalendarEvent> events;
  final DateTime now;
  final void Function(CalendarEvent event)? onEventTap;
  final DateTime Function()? clock;

  static String _formatAgendaDate(DateTime date) {
    const List<String> weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String weekday = weekdays[date.weekday - 1];
    final String month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  static CalendarEvent _withAgendaSubtitle(CalendarEvent event) {
    final String dateStr = _formatAgendaDate(event.date);
    if (event.subtitle.startsWith(dateStr)) {
      return event;
    }
    final String subtitle = event.subtitle.isNotEmpty
        ? '$dateStr  -  ${event.subtitle}'
        : dateStr;
    return CalendarEvent(
      kind: event.kind,
      title: event.title,
      subtitle: subtitle,
      date: event.date,
      pillText: event.pillText,
      route: event.route,
      milestoneId: event.milestoneId,
      projectId: event.projectId,
      transactionId: event.transactionId,
    );
  }

  void _handleCardTap(BuildContext context, CalendarEvent event) {
    if (onEventTap != null) {
      onEventTap!(event);
      return;
    }
    if (event.kind == CalendarEventKind.debt) {
      final String txId = event.transactionId ?? '';
      context.push('/friends/transactions/$txId');
    } else {
      final String dateStr = formatDate(event.date);
      context.go('/calendar?date=$dateStr');
    }
  }

  Widget _buildGroup(
    BuildContext context, {
    required String label,
    required Color labelColor,
    required List<CalendarEvent> groupEvents,
    required bool addDateSubtitle,
  }) {
    if (groupEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: labelColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          for (final CalendarEvent event in groupEvents)
            CalendarEventCard(
              event: addDateSubtitle ? _withAgendaSubtitle(event) : event,
              onTap: () => _handleCardTap(context, event),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime effectiveNow = clock?.call() ?? now;
    final AgendaGroups groups = agendaGroups(events, effectiveNow);

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                AppIcons.calendarDays,
                size: 48,
                color: AppColors.placeholder,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                CalendarViewsStrings.emptyAgenda,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mute,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroup(
            context,
            label: CalendarViewsStrings.overdueLabel(groups.overdue.length),
            labelColor: AppColors.red,
            groupEvents: groups.overdue,
            addDateSubtitle: true,
          ),
          _buildGroup(
            context,
            label: CalendarViewsStrings.todayLabel,
            labelColor: AppColors.mute,
            groupEvents: groups.today,
            addDateSubtitle: false,
          ),
          _buildGroup(
            context,
            label: CalendarViewsStrings.thisWeekLabel,
            labelColor: AppColors.mute,
            groupEvents: groups.thisWeek,
            addDateSubtitle: true,
          ),
          _buildGroup(
            context,
            label: CalendarViewsStrings.laterLabel,
            labelColor: AppColors.mute,
            groupEvents: groups.later,
            addDateSubtitle: true,
          ),
        ],
      ),
    );
  }
}
