/// User-facing strings for the Calendar month view and its modal sheets (Agent A).
abstract final class CalendarMonthStrings {
  static const String calendar = 'Calendar';
  static const String today = 'Today';
  static const String nothingPlanned = 'Nothing planned';
  static const String addMilestone = 'Add milestone';
  static const String jumpToMonth = 'Jump to month';
  static const String goToToday = 'Go to today';

  static const List<String> weekdays = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  static const List<String> shortMonths = <String>[
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

  static const String legendDeadline = 'Deadline';
  static const String legendStart = 'Start';
  static const String legendMilestone = 'Milestone';
  static const String legendDebtDue = 'Debt due';

  static String eventsCount(int count) =>
      count == 1 ? '1 event' : '$count events';

  // Deadline sheet
  static const String projectDeadline = 'Project deadline';
  static const String projectStart = 'Project start';
  static const String client = 'Client';
  static const String dueDate = 'Due date';
  static const String startDate = 'Start date';
  static const String status = 'Status';
  static const String budget = 'Budget';
  static const String openProject = 'Open project';
  static const String close = 'Close';

  // Milestone sheet
  static const String milestone = 'Milestone';
  static const String project = 'Project';
  static const String date = 'Date';
  static const String pending = 'Pending';
  static const String done = 'Done';
  static const String markAsDone = 'Mark as done';
  static const String markAsPending = 'Mark as pending';
  static const String deleteMilestone = 'Delete milestone';
  static const String milestoneMarkedAsDone = 'Milestone marked as done';
  static const String milestoneMarkedAsPending = 'Milestone marked as pending';
  static const String milestoneDeleted = 'Milestone deleted';

  // Delete milestone confirm sheet
  static const String thisActionCannotBeUndone = 'This action cannot be undone';
  static const String confirmDelete = 'Confirm delete';
  static const String cancel = 'Cancel';

  static String deleteMilestoneWarning({
    required String title,
    required String date,
    required String project,
  }) =>
      'You are about to delete "$title" ($date) from $project.\n\nYour project and its payments are not affected.';
}
