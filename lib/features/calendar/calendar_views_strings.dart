/// User-facing strings for the Calendar agenda and timeline views (Agent B).
abstract final class CalendarViewsStrings {
  // Agenda View
  static String overdueLabel(int count) => 'OVERDUE - $count';
  static const String todayLabel = 'TODAY';
  static const String thisWeekLabel = 'THIS WEEK';
  static const String laterLabel = 'LATER';
  static const String emptyAgenda = 'Nothing coming up';

  // Timeline View
  static const String ongoingPill = 'Ongoing';
  static String allPill(int count) => 'All ($count)';
  static const String todayFlag = 'Today';
  static const String legendOngoing = 'Ongoing contract';
  static const String legendWaitingClient = 'Waiting client';
  static const String legendPlanned = 'Planned';
  static const String legendMilestone = 'Milestone';
  static const String capacityTitle = 'Capacity and availability';
  static String workloadSubtitle(String levelLabel) => '$levelLabel workload';
  static const String emptyTimeline = 'No projects to display';
}
