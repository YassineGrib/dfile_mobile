import 'package:flutter/foundation.dart';

import '../../../core/format.dart';
import '../../clients/data/data.dart';
import '../../friends/data/data.dart';
import '../../projects/data/data.dart';
import 'milestone.dart';

/// Classification of calendar events per `docs/design/SPEC.md`.
enum CalendarEventKind {
  over,
  due,
  start,
  milestone,
  done,
  debt,
}

/// A calendar event representing a project deadline, project start date,
/// milestone target, or friend debt settlement due date.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.date,
    this.pillText,
    this.route,
    this.milestoneId,
    this.projectId,
    this.transactionId,
  });

  /// Kind of calendar event.
  final CalendarEventKind kind;

  /// Primary event title.
  final String title;

  /// Secondary subtitle or context text.
  final String subtitle;

  /// Date-only timestamp representing the day of the event.
  final DateTime date;

  /// Optional pill badge label (e.g. "Overdue 5d", "3d left", "Done").
  final String? pillText;

  /// Optional navigation target route.
  final String? route;

  /// Associated milestone ID if this event represents a milestone.
  final String? milestoneId;

  /// Associated project ID if linked to a project.
  final String? projectId;

  /// Associated friend transaction ID if linked to a debt.
  final String? transactionId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent &&
        other.kind == kind &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.date == date &&
        other.pillText == pillText &&
        other.route == route &&
        other.milestoneId == milestoneId &&
        other.projectId == projectId &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode => Object.hash(
        kind,
        title,
        subtitle,
        date,
        pillText,
        route,
        milestoneId,
        projectId,
        transactionId,
      );

  @override
  String toString() =>
      'CalendarEvent(kind: $kind, title: $title, date: $date, pill: $pillText)';
}

/// Strips time components, returning a date-only [DateTime].
DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Computes the list of all calendar events across projects, clients, milestones,
/// and friend debt transactions per `docs/design/SPEC.md`.
List<CalendarEvent> calendarEvents({
  List<ProjectItem>? projects,
  List<Client>? clients,
  List<Milestone>? milestones,
  List<FriendTransaction>? friendTransactions,
  List<Friend>? friends,
  required DateTime now,
  bool includeDebts = true,
}) {
  final DateTime today = _dateOnly(now);
  final List<CalendarEvent> events = <CalendarEvent>[];

  final Map<String, String> clientNames = <String, String>{};
  if (clients != null) {
    for (final Client c in clients) {
      clientNames[c.id] = c.name;
    }
  }

  final Map<String, ProjectItem> projectsMap = <String, ProjectItem>{};
  if (projects != null) {
    for (final ProjectItem p in projects) {
      projectsMap[p.id] = p;
    }
  }

  // 1. Projects: Deadlines & Start dates
  if (projects != null) {
    for (final ProjectItem p in projects) {
      if (p.status == ProjectStatus.cancelled) {
        continue;
      }
      final String clientName = clientNames[p.clientId] ?? '';

      // Project deadline
      if (p.endDate != null) {
        final DateTime endDay = _dateOnly(p.endDate!);
        final CalendarEventKind kind;
        final String pill;

        if (p.status == ProjectStatus.completed ||
            p.status == ProjectStatus.delivered) {
          kind = CalendarEventKind.done;
          pill = 'Done';
        } else if (endDay.isBefore(today)) {
          kind = CalendarEventKind.over;
          final int diff = today.difference(endDay).inDays;
          pill = '${diff}d overdue';
        } else {
          kind = CalendarEventKind.due;
          final int diff = endDay.difference(today).inDays;
          pill = diff == 0 ? 'Today' : '${diff}d left';
        }

        final String subtitle =
            clientName.isNotEmpty ? clientName : 'Deadline ${_formatShortDate(endDay)}';

        events.add(
          CalendarEvent(
            kind: kind,
            title: p.name,
            subtitle: subtitle,
            date: endDay,
            pillText: pill,
            route: '/projects/${p.id}',
            projectId: p.id,
          ),
        );
      }

      // Project start date
      final DateTime startDay = _dateOnly(p.startDate);
      final String subtitle =
          clientName.isNotEmpty ? clientName : 'Project start';

      events.add(
        CalendarEvent(
          kind: CalendarEventKind.start,
          title: '${p.name} starts',
          subtitle: subtitle,
          date: startDay,
          route: '/projects/${p.id}',
          projectId: p.id,
        ),
      );
    }
  }

  // 2. Milestones
  if (milestones != null) {
    for (final Milestone m in milestones) {
      // Deleting a project removes its milestones: filter out orphaned milestones
      if (projects != null && projects.isNotEmpty && !projectsMap.containsKey(m.projectId)) {
        continue;
      }
      final DateTime mDay = _dateOnly(m.date);
      final ProjectItem? project = projectsMap[m.projectId];
      final String subtitle =
          project?.name ?? clientNames[project?.clientId ?? ''] ?? 'Milestone';

      final CalendarEventKind kind;
      final String pill;

      if (m.completed) {
        kind = CalendarEventKind.done;
        pill = 'Done';
      } else {
        kind = CalendarEventKind.milestone;
        final int diff = mDay.difference(today).inDays;
        if (diff == 0) {
          pill = 'Due today';
        } else if (diff > 0) {
          pill = '${diff}d left';
        } else {
          pill = '${diff.abs()}d overdue';
        }
      }

      events.add(
        CalendarEvent(
          kind: kind,
          title: m.title,
          subtitle: subtitle,
          date: mDay,
          pillText: pill,
          route: '/calendar',
          milestoneId: m.id,
          projectId: m.projectId,
        ),
      );
    }
  }

  // 3. Friend debt transactions
  if (includeDebts && friendTransactions != null) {
    final Map<String, String> friendNames = <String, String>{};
    if (friends != null) {
      for (final Friend f in friends) {
        friendNames[f.id] = f.name;
      }
    }

    for (final FriendTransaction t in friendTransactions) {
      if (t.isSettled || t.dueDate == null) {
        continue;
      }
      final DateTime dueDay = _dateOnly(t.dueDate!);
      final String friendName = friendNames[t.friendId] ?? 'Friend';
      final String title = t.direction == FriendTxDirection.lent
          ? '$friendName owes you'
          : 'You owe $friendName';
      final String subtitle = '${formatMoney(t.remaining)} due';

      final int diff = dueDay.difference(today).inDays;
      final String pill = diff == 0
          ? 'Today'
          : (diff > 0 ? '${diff}d left' : '${diff.abs()}d overdue');

      events.add(
        CalendarEvent(
          kind: CalendarEventKind.debt,
          title: title,
          subtitle: subtitle,
          date: dueDay,
          pillText: pill,
          route: '/friends/transactions/${t.id}',
          transactionId: t.id,
        ),
      );
    }
  }

  // Sort chronologically, then by kind, then by title
  events.sort((CalendarEvent a, CalendarEvent b) {
    final int dateCmp = a.date.compareTo(b.date);
    if (dateCmp != 0) return dateCmp;
    final int kindCmp = a.kind.index.compareTo(b.kind.index);
    if (kindCmp != 0) return kindCmp;
    return a.title.compareTo(b.title);
  });

  return events;
}

String _formatShortDate(DateTime date) {
  const List<String> months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

/// Returns a map of day numbers to event kinds for the given month,
/// showing up to 3 distinct kinds per day.
Map<int, List<CalendarEventKind>> dotsForMonth(
  List<CalendarEvent> events,
  int year,
  int month,
) {
  final Map<int, List<CalendarEventKind>> map = <int, List<CalendarEventKind>>{};

  for (final CalendarEvent event in events) {
    if (event.date.year == year && event.date.month == month) {
      final List<CalendarEventKind> kinds =
          map.putIfAbsent(event.date.day, () => <CalendarEventKind>[]);
      if (kinds.length < 3 && !kinds.contains(event.kind)) {
        kinds.add(event.kind);
      }
    }
  }

  return map;
}

/// Filters [events] occurring on the specified [day].
List<CalendarEvent> eventsOnDay(List<CalendarEvent> events, DateTime day) {
  final DateTime target = _dateOnly(day);
  return events
      .where((CalendarEvent e) => e.date.isAtSameMomentAs(target))
      .toList();
}

/// A single cell in the calendar month grid.
@immutable
class MonthGridCell {
  const MonthGridCell({
    required this.date,
    required this.inMonth,
  });

  final DateTime date;
  final bool inMonth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthGridCell &&
        other.date == date &&
        other.inMonth == inMonth;
  }

  @override
  int get hashCode => Object.hash(date, inMonth);
}

/// The computed grid structure for a given calendar month.
@immutable
class MonthGrid {
  const MonthGrid({
    required this.year,
    required this.month,
    required this.weeksCount,
    required this.cells,
  });

  final int year;
  final int month;
  final int weeksCount; // 5 or 6
  final List<MonthGridCell> cells; // length is weeksCount * 7
}

/// Computes the Sunday-first month grid structure (5 or 6 weeks) for [year] and [month].
MonthGrid monthGrid(int year, int month) {
  final DateTime firstDayOfMonth = DateTime(year, month, 1);
  final int daysInMonth = DateTime(year, month + 1, 0).day;

  // Sunday-first weekday index (Sunday = 0, Monday = 1, ..., Saturday = 6)
  final int startOffset = firstDayOfMonth.weekday % 7;

  final int totalDaysNeeded = startOffset + daysInMonth;
  final int weeksCount = (totalDaysNeeded / 7).ceil();
  final int totalCells = weeksCount * 7;

  final List<MonthGridCell> cells = <MonthGridCell>[];
  for (int i = 0; i < totalCells; i++) {
    final DateTime cellDate = DateTime(year, month, 1 - startOffset + i);
    final bool inMonth = cellDate.month == month;
    cells.add(MonthGridCell(date: cellDate, inMonth: inMonth));
  }

  return MonthGrid(
    year: year,
    month: month,
    weeksCount: weeksCount,
    cells: List<MonthGridCell>.unmodifiable(cells),
  );
}

/// Grouped agenda categories per `docs/design/SPEC.md` (CL4).
@immutable
class AgendaGroups {
  const AgendaGroups({
    required this.overdue,
    required this.today,
    required this.thisWeek,
    required this.later,
  });

  final List<CalendarEvent> overdue;
  final List<CalendarEvent> today;
  final List<CalendarEvent> thisWeek;
  final List<CalendarEvent> later;

  bool get isEmpty =>
      overdue.isEmpty && today.isEmpty && thisWeek.isEmpty && later.isEmpty;

  int get totalCount =>
      overdue.length + today.length + thisWeek.length + later.length;
}

/// Partitions [events] into Agenda groups: Overdue, Today, This Week (next 7 days),
/// and Later (up to 90 days).
AgendaGroups agendaGroups(List<CalendarEvent> events, DateTime now) {
  final DateTime today = _dateOnly(now);
  final DateTime nextWeekEnd = today.add(const Duration(days: 7));
  final DateTime ninetyDaysEnd = today.add(const Duration(days: 90));

  final List<CalendarEvent> overdue = <CalendarEvent>[];
  final List<CalendarEvent> todayEvents = <CalendarEvent>[];
  final List<CalendarEvent> thisWeek = <CalendarEvent>[];
  final List<CalendarEvent> later = <CalendarEvent>[];

  for (final CalendarEvent event in events) {
    final DateTime eventDate = event.date;

    if (eventDate.isBefore(today)) {
      // Overdue excludes already done items and past start dates
      if (event.kind != CalendarEventKind.done &&
          event.kind != CalendarEventKind.start) {
        overdue.add(event);
      }
    } else if (eventDate.isAtSameMomentAs(today)) {
      todayEvents.add(event);
    } else if (eventDate.isAfter(today) && !eventDate.isAfter(nextWeekEnd)) {
      thisWeek.add(event);
    } else if (eventDate.isAfter(nextWeekEnd) && !eventDate.isAfter(ninetyDaysEnd)) {
      later.add(event);
    }
  }

  overdue.sort((CalendarEvent a, CalendarEvent b) => a.date.compareTo(b.date));
  todayEvents.sort((CalendarEvent a, CalendarEvent b) => a.title.compareTo(b.title));
  thisWeek.sort((CalendarEvent a, CalendarEvent b) => a.date.compareTo(b.date));
  later.sort((CalendarEvent a, CalendarEvent b) => a.date.compareTo(b.date));

  return AgendaGroups(
    overdue: List<CalendarEvent>.unmodifiable(overdue),
    today: List<CalendarEvent>.unmodifiable(todayEvents),
    thisWeek: List<CalendarEvent>.unmodifiable(thisWeek),
    later: List<CalendarEvent>.unmodifiable(later),
  );
}

/// A 4-month timeline display window for Gantt scheduling.
@immutable
class TimelineWindow {
  const TimelineWindow({
    required this.startDate,
    required this.endDate,
    required this.months,
  });

  /// The first day of the 4-month span.
  final DateTime startDate;

  /// The end timestamp of the 4-month span (first day of the 5th month).
  final DateTime endDate;

  /// The first day of each of the 4 included months.
  final List<DateTime> months;

  /// Total days in the timeline window.
  int get totalDays => endDate.difference(startDate).inDays;
}

/// Computes a 4-month [TimelineWindow] starting 2 months prior to [now]'s month.
TimelineWindow timelineWindow(DateTime now) {
  int startYear = now.year;
  int startMonth = now.month - 2;
  while (startMonth <= 0) {
    startMonth += 12;
    startYear -= 1;
  }

  final DateTime startDate = DateTime(startYear, startMonth, 1);
  final List<DateTime> months = <DateTime>[];

  for (int i = 0; i < 4; i++) {
    int m = startMonth + i;
    int y = startYear;
    while (m > 12) {
      m -= 12;
      y += 1;
    }
    months.add(DateTime(y, m, 1));
  }

  int endMonth = startMonth + 4;
  int endYear = startYear;
  while (endMonth > 12) {
    endMonth -= 12;
    endYear += 1;
  }
  final DateTime endDate = DateTime(endYear, endMonth, 1);

  return TimelineWindow(
    startDate: startDate,
    endDate: endDate,
    months: List<DateTime>.unmodifiable(months),
  );
}

/// Calculates the normalized horizontal offset fraction (0.0 to 1.0) of [date]
/// within [window].
double dayOffsetFraction(TimelineWindow window, DateTime date) {
  final int totalDays = window.totalDays;
  if (totalDays <= 0) {
    return 0.0;
  }
  final int offsetDays = _dateOnly(date).difference(window.startDate).inDays;
  final double fraction = offsetDays / totalDays;
  return fraction.clamp(0.0, 1.0);
}

/// Workload pressure levels per `docs/design/SPEC.md` (CL11).
enum CapacityLevel {
  light('Light', 'Open: ready for new projects.'),
  moderate('Moderate', 'Selective: you can take one more project.'),
  heavy('Heavy', 'Near full capacity.');

  const CapacityLevel(this.label, this.sentence);

  final String label;
  final String sentence;
}

/// Capacity and workload statistics for active portfolio projects.
@immutable
class CapacityInfo {
  const CapacityInfo({
    required this.activeCount,
    required this.level,
    this.nextAvailableDate,
    this.nextProject,
    required this.averageProgress,
    required this.activeProjects,
  });

  final int activeCount;
  final CapacityLevel level;
  final DateTime? nextAvailableDate;
  final ProjectItem? nextProject;
  final int averageProgress;
  final List<ProjectItem> activeProjects;

  /// Display string for the next available contract opening.
  String get nextSlotLabel => nextAvailableDate != null
      ? _formatDate(nextAvailableDate!)
      : 'Available now';

  static String _formatDate(DateTime dt) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

/// Analyzes workload and availability based on active contracts
/// (Planned, In Progress, Waiting Client) per `docs/design/SPEC.md` (CL11).
CapacityInfo capacityInfo(List<ProjectItem> projects, DateTime now) {
  final DateTime today = _dateOnly(now);

  final List<ProjectItem> activeProjects = projects.where((ProjectItem p) {
    return p.status == ProjectStatus.planned ||
        p.status == ProjectStatus.inProgress ||
        p.status == ProjectStatus.waitingClient;
  }).toList();

  final int activeCount = activeProjects.length;

  final CapacityLevel level;
  if (activeCount <= 1) {
    level = CapacityLevel.light;
  } else if (activeCount <= 3) {
    level = CapacityLevel.moderate;
  } else {
    level = CapacityLevel.heavy;
  }

  final int averageProgress = activeProjects.isEmpty
      ? 0
      : (activeProjects.fold<int>(0, (int sum, ProjectItem p) => sum + p.progress) /
              activeProjects.length)
          .round();

  // Earliest FUTURE end date among active projects
  final List<ProjectItem> futureEndProjects = activeProjects
      .where((ProjectItem p) =>
          p.endDate != null && _dateOnly(p.endDate!).isAfter(today))
      .toList();

  DateTime? nextAvailableDate;
  ProjectItem? nextProject;

  if (futureEndProjects.isNotEmpty) {
    futureEndProjects.sort((ProjectItem a, ProjectItem b) =>
        a.endDate!.compareTo(b.endDate!));
    nextProject = futureEndProjects.first;
    nextAvailableDate = nextProject.endDate;
  }

  return CapacityInfo(
    activeCount: activeCount,
    level: level,
    nextAvailableDate: nextAvailableDate,
    nextProject: nextProject,
    averageProgress: averageProgress,
    activeProjects: List<ProjectItem>.unmodifiable(activeProjects),
  );
}
