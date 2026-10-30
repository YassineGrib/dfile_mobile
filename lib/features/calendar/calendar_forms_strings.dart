/// User-facing strings for Calendar forms, capacity, and sync screens (Agent C).
abstract final class CalendarFormsStrings {
  // Milestone Form
  static const String newMilestoneTitle = 'New milestone';
  static const String newMilestoneSubtitle = 'Add a real deadline to a project';
  static const String projectLabel = 'Project *';
  static const String selectProjectPlaceholder = 'Select project';
  static const String projectRequiredError = 'Please select a project';
  static const String milestoneTitleLabel = 'Milestone title *';
  static const String milestoneTitlePlaceholder = 'e.g. Client review session';
  static const String titleRequiredError = 'Please enter a title';
  static const String dueDateLabel = 'Due date *';
  static const String pickDatePlaceholder = 'Pick a date';
  static const String dueDateRequiredError = 'Please pick a due date';
  static const String cancel = 'Cancel';
  static const String registerMilestone = 'Register milestone';
  static const String milestoneRegisteredToast = 'Milestone registered';
  static const String selectProjectSheetTitle = 'Select project';
  static const String confirm = 'Confirm';

  // Capacity Screen
  static const String capacityTitle = 'Capacity';
  static const String workloadLabel = 'Workload';
  static const String noActiveProjects = 'No active projects';
  static const String lightLevel = 'Light';
  static const String moderateLevel = 'Moderate';
  static const String heavyLevel = 'Heavy';
  static const String lightSentence = 'Open: ready for new projects.';
  static const String moderateSentence =
      'Selective: you can take one more project.';
  static const String heavySentence = 'Near full capacity.';
  static const String nextAvailableSlot = 'Next available slot';
  static const String availableNow = 'Available now';
  static const String activeProjectsProgress = 'Active projects progress';
  static const String activeProjectsProgressTitle = 'Active projects progress';
  static const String calendarSyncRowTitle = 'Calendar sync';
  static const String calendarSyncConnected = 'Google Calendar connected';
  static const String calendarSyncNotConnected = 'Not connected';

  static String activeProjectsCount(int count) =>
      count == 1 ? '1 active project' : '$count active projects';
  static String averageProgress(int percent) => 'Average $percent%';
  static String earliestContractToFreeUp(String projectName) =>
      'Earliest contract to free up: $projectName';

  // Calendar Sync Screen
  static const String calendarSyncTitle = 'Calendar sync';
  static const String googleCalendarTitle = 'Google Calendar';
  static const String connected = 'Connected';
  static const String notConnected = 'Not connected';
  static const String syncNow = 'Sync now';
  static const String connectInSettings = 'Connect in Settings';
  static const String calendarSyncedToast = 'Calendar synced';
  static const String neverSynced = 'Never synced';
  static const String projectDeadlinesTitle = 'Project deadlines';
  static const String projectDeadlinesSubtitle =
      'Send due dates to your calendar';
  static const String milestonesTitle = 'Milestones';
  static const String milestonesSubtitle = 'Send milestones to your calendar';
  static const String debtsTitle = "Friends' debt due dates";
  static const String debtsSubtitle = 'Remind you when a debt is due';
  static const String syncNote =
      'Syncing is one way: Dfile sends events, it never edits your calendar.';

  static String lastSyncedToday(String time) => 'Last synced today at $time';
  static String lastSyncedAt(String date, String time) =>
      'Last synced $date at $time';
}
