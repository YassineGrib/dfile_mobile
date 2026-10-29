/// Centralised user-facing strings for the project management feature.
abstract final class ProjectStrings {
  // Navigation & Screen titles
  static const String projectsTitle = 'Projects';
  static const String projectDetailTitle = 'Project';
  static const String addNewProjectTitle = 'Add new project';
  static const String editProjectTitle = 'Edit project';
  static const String recordPaymentTitle = 'Record payment';
  static const String projectNotFound = 'Project not found';
  static const String backToProjects = 'Back to projects';
  static const String unknownClient = 'Unknown client';

  // Placeholder copy (Task 4B)
  static const String formPlaceholderSubtitle =
      'Project creation and editing forms arrive in Task 4B.';
  static const String paymentPlaceholderBody =
      'Payment recording form arrives in Task 4B.';

  // Subtitles & Counts
  static String portfolioCount(int n) => '$n projects in your portfolio';
  static String projectsFound(int n) => '$n projects found';
  static String projectsListCount(int n) => '$n projects';

  // Summary tiles
  static const String summaryPortfolioValue = 'Portfolio value';
  static const String summaryAvgProgress = 'Avg progress';
  static const String summaryActive = 'Active';

  // Search, Pills, Filter & Sort
  static const String searchPlaceholder =
      'Search project, client or category...';
  static const String filterAll = 'All';
  static const String filterPlanned = 'Planned';
  static const String filterInProgress = 'In Progress';
  static const String filterCompleted = 'Completed';
  static const String filterDelivered = 'Delivered';
  static const String filterDone = 'Done';
  static const String filterAction = 'Filter';
  static const String sortPrefix = 'Sort: ';
  static const String sortShortNewest = 'Newest';
  static const String sortShortName = 'Name';
  static const String sortShortBudget = 'Budget';
  static const String sortShortProgress = 'Progress';
  static const String sortShortDeadline = 'Deadline';

  // Sort Sheet (P3)
  static const String sortSheetTitle = 'Sort by';
  static const String sortNewestFirst = 'Newest first';
  static const String sortNameAZ = 'Name (A-Z)';
  static const String sortHighestBudget = 'Highest budget';
  static const String sortProgress = 'Progress';
  static const String sortNearestDeadline = 'Nearest deadline';

  // Filter Sheet (P4)
  static const String filterSheetTitle = 'Filter projects';
  static const String reset = 'Reset';
  static const String filterSectionCategory = 'Category';
  static const String filterSectionClient = 'Client';
  static const String filterSectionStatus = 'Status';
  static const String applyFilters = 'Apply filters';
  static const String cancel = 'Cancel';

  // Project Card (P1)
  static String dueShort(String shortDate) => 'Due $shortDate';
  static const String noDeadline = 'No deadline';
  static String paidAmount(String formattedMoney) => 'Paid: $formattedMoney';
  static String dueAmount(String formattedAmount) => 'Due: $formattedAmount';
  static const String cleared = 'Cleared';

  // Empty State (P2)
  static const String emptyTitle = 'No projects match your filters';
  static const String emptySubtitle =
      'Try another status, category or client, or add a new project.';
  static const String clearFilters = 'Clear filters';

  // Detail Tabs (P5..P7)
  static const String tabOverview = 'Overview';
  static const String tabTasks = 'Tasks';
  static const String tabPayments = 'Payments';

  // Overview Tab (P5)
  static const String progressLabel = 'Progress';
  static const String tileBudget = 'Budget';
  static const String tilePaid = 'Paid';
  static const String tileRemaining = 'Remaining';
  static const String tileTimeline = 'Timeline';
  static const String descriptionLabel = 'Description';
  static const String noDescription = 'No description provided.';
  static const String addPaymentWithPlus = '+ Add payment';

  // Tasks Tab (P6)
  static const String tasksChecklistTitle = 'Tasks checklist';
  static String tasksDoneCount(int done, int total) => '$done of $total done';
  static const String noTasksYet = 'No tasks added yet.';
  static const String addNewTaskPlaceholder = 'Add a new task...';

  // Payments Tab (P7)
  static const String paidSoFar = 'Paid so far';
  static String ofBudget(String formattedBudget) => 'of $formattedBudget';
  static const String paymentReceived = 'Payment received';
  static const String noPaymentsYet = 'No payments recorded yet.';

  // Actions Sheet (P8)
  static const String actionEditProject = 'Edit project';
  static const String actionChangeStatus = 'Change status';
  static const String actionAddPayment = 'Add payment';
  static const String actionDeleteProject = 'Delete project';

  // Change Status Sheet (P9)
  static const String changeStatusTitle = 'Change status';
  static const String changeStatusNote =
      'Completed and Delivered set progress to 100%.';
  static const String updateStatus = 'Update status';

  // Delete Confirm Sheet (P10)
  static const String deleteConfirmTitle = 'Delete project';
  static const String deleteConfirmSubtitle = 'This action cannot be undone';
  static String deleteConfirmWarning(String name) =>
      'You are about to delete project "$name" from your workspace.\n\n'
      'Its tasks and checklist will be permanently removed. '
      'Payments already recorded stay in your ledger.';
  static const String confirmDelete = 'Confirm delete';

  // Toasts (P11..P18)
  static const String projectDeletedToast = 'Project deleted successfully';
  static const String statusUpdatedToast = 'Status updated';
  static const String projectAddedToast = 'Project added';
  static const String changesSavedToast = 'Changes saved';
  static const String paymentRecordedToast = 'Payment recorded';

  // Categories
  static const String categoryDevelopment = 'Development';
  static const String categoryDesign = 'Design';
  static const String categoryBranding = 'Branding';
  static const String categoryMarketing = 'Marketing';
  static const String categoryOther = 'Other';
  static const List<String> projectCategories = <String>[
    categoryDevelopment,
    categoryDesign,
    categoryBranding,
    categoryMarketing,
    categoryOther,
  ];

  // Add Project Wizard (P12..P16)
  static const String wizardStep1Subtitle = 'Step 1 of 4 • Project details';
  static const String wizardStep2Subtitle = 'Step 2 of 4 • Client and budget';
  static const String wizardStep3Subtitle = 'Step 3 of 4 • Tasks (optional)';
  static const String wizardStep4Subtitle = 'Step 4 of 4 • Status and timeline';

  static const String stepDetails = 'Details';
  static const String stepClientAndCost = 'Client & Cost';
  static const String stepTasks = 'Tasks';
  static const String stepStatus = 'Status';

  static const String back = 'Back';
  static const String next = 'Next';
  static const String saveProject = 'Save project';
  static const String saveChanges = 'Save changes';

  // Form Labels, Placeholders & Hints
  static const String projectNameLabel = 'Project name *';
  static const String projectNamePlaceholder = 'e.g. DecaByte Design';
  static const String categoryLabel = 'Category';
  static const String selectCategoryTitle = 'Select category';
  static const String descriptionPlaceholder = 'Enter project overview...';

  static const String clientRequiredLabel = 'Client *';
  static const String clientLabel = 'Client';
  static const String selectClientPlaceholder = 'Select a client...';
  static const String selectClientTitle = 'Select client';
  static const String quickAddClientToggle = '+ Quick add client';
  static const String selectClientToggle = 'Select client';
  static const String quickAddClientPlaceholder = 'e.g. Nova Studio';
  static const String addAction = 'Add';
  static const String quickAddClientHint =
      'Creates a client with only a name. Add details later from Clients.';

  static const String projectBudgetRequiredLabel = 'Project budget (DZD) *';
  static const String budgetShortLabel = 'Budget (DZD)';
  static const String budgetPlaceholder = '50,000';
  static const String budgetHint =
      'The budget drives paid, remaining and net profit on the project and client screens.';

  static const String addSubTasksLabel = 'Add sub-tasks';
  static const String subTaskPlaceholder = 'Logo mockup sketches';
  static String taskIndexLabel(int index) => '#${index + 1}';

  static const String projectStatusLabel = 'Project status';
  static const String selectStatusTitle = 'Select status';
  static const String progressPercentageLabel = 'Progress percentage';
  static const String startDateLabel = 'Start date';
  static const String deadlineLabel = 'Deadline';
  static const String statusAutoProgressHint =
      'Completed or Delivered sets progress to 100% automatically.';
  static const String deadlineBeforeStartError =
      'Deadline cannot be before the start date.';

  // Edit Project (P17)
  static const String editProjectSubtitle = 'Update details, status and budget';

  // Record Payment Sheet (P18)
  static const String amountRequiredLabel = 'Amount (DZD) *';
  static const String amountPlaceholder = '60,000';
  static const String paymentDateLabel = 'Payment date';
  static const String referenceOptionalLabel = 'Reference (optional)';
  static const String referencePlaceholder = 'e.g. Bank transfer #A140';
  static String remainingAfterPayment(String formattedMoney) =>
      'Remaining after this payment: $formattedMoney';
  static const String fullyPaidAfterPayment = 'Fully paid';
  static const String savePayment = 'Save payment';
}
