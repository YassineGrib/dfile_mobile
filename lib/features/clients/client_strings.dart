/// Centralised user-facing strings for the client management feature.
abstract final class ClientStrings {
  // Navigation & Screen titles
  static const String clientsList = 'Clients';
  static const String clientsTitle = 'Clients';
  static const String clientDetail = 'Client detail';
  static const String clientDetailTitle = 'Client';
  static const String addClient = 'Add client';
  static const String addClientWithPlus = '+ Add client';
  static const String addNewClientTitle = 'Add new client';
  static const String addNewClientSubtitle = 'Add a new client ledger entry';
  static const String editClient = 'Edit client';
  static const String editClientTitle = 'Edit client profile';
  static const String editClientSubtitle =
      'Update contact data and social links';
  static const String clientNotFound = 'Client not found';
  static const String backToClients = 'Back to clients';

  // Subtitles & Counts
  static String clientsCount(int n) => '$n clients in your workspace';
  static String clientsFound(int n) => '$n clients found';

  // Search & Filters
  static const String searchPlaceholder = 'Search name, email or phone...';
  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterInactive = 'Inactive';
  static const String sortPrefix = 'Sort: ';
  static const String sortName = 'Name';
  static const String sortRevenue = 'Revenue';
  static const String sortNewest = 'Newest';

  // Sort Sheet
  static const String sortSheetTitle = 'Sort by';
  static const String sortNameAZ = 'Name (A-Z)';
  static const String sortHighestRevenue = 'Highest revenue';
  static const String sortNewestFirst = 'Newest first';

  // Status & Card
  static const String statusActive = 'Active';
  static const String statusArchived = 'Archived';
  static String addedDate(String date) => 'Added: $date';
  static String joinedDate(String date) => 'Joined: $date';
  static String activeProjs(int n) => '• $n active projs';

  // Empty State
  static const String emptyTitle = 'No clients found';
  static const String emptySubtitle =
      'Try adjusting your search or add a new client to your workspace.';

  // Actions Sheet
  static const String actionsViewProfile = 'View profile';
  static const String actionsEditClient = 'Edit client';
  static const String actionsCopyEmail = 'Copy email';
  static const String actionsDeleteClient = 'Delete client';

  // Delete Confirm Sheet
  static const String deleteConfirmTitle = 'Delete client';
  static const String deleteConfirmSubtitle = 'This action cannot be undone';
  static String deleteConfirmWarning(String name) =>
      'You are about to delete client "$name" from your workspace.\n\n'
      'All contact details and social links will be permanently removed. '
      'Historic payments and ledger transactions will remain in your records.';
  static const String confirmDelete = 'Confirm delete';
  static const String cancel = 'Cancel';

  // Toasts
  static const String clientDeletedToast = 'Client deleted successfully';
  static const String clientAddedToast = 'Client added';
  static const String changesSavedToast = 'Changes saved';
  static const String copiedEmailToast = 'Copied email!';
  static const String copiedPhoneToast = 'Copied phone!';
  static const String copiedAddressToast = 'Copied address!';
  static const String demoNotAvailableToast = 'Not available in the demo';

  // Client Detail Quick Actions
  static const String quickActionCall = 'Call';
  static const String quickActionEmail = 'Email';
  static const String quickActionCopy = 'Copy';

  // Contact Card
  static const String contactEmail = 'Email';
  static const String contactPhone = 'Phone';
  static const String contactAddress = 'Address';
  static const String contactLinks = 'Links';
  static const String copyAction = 'Copy';

  // Finance Tiles
  static const String financeBudget = 'Total contract budget';
  static const String financeCleared = 'Payments cleared';
  static const String financeOutstanding = 'Outstanding balance';
  static const String financeProfit = 'Net client profit';

  // Projects & Payments Tabs
  static const String tabProjects = 'Projects';
  static const String tabPayments = 'Payments';
  static String completePercent(int pct) => '$pct% complete';
  static const String paymentReceived = 'Payment received';
  static const String totalCleared = 'Total cleared';

  // Form Fields
  static const String quickMode = 'Quick mode';
  static const String advancedMode = 'Advanced mode';
  static const String clientNameLabel = 'Client name *';
  static const String clientNamePlaceholder = 'e.g. Mohamed Bachir';
  static const String emailLabel = 'Email address';
  static const String emailPlaceholder = 'client@company.com';
  static const String phoneLabel = 'Phone number';
  static const String phonePlaceholder = '0550 00 00 00';
  static const String addressLabel = 'Physical address';
  static const String addressPlaceholder = 'e.g. Algiers, Algeria';
  static const String socialLinksLabel = 'Social media links';
  static const String linkedinPlaceholder = 'LinkedIn';
  static const String twitterPlaceholder = 'Twitter / X';
  static const String githubPlaceholder = 'GitHub';
  static const String websitePlaceholder = 'Website';
  static const String notesLabel = 'Notes';
  static const String notesPlaceholder = 'Payment terms, special conditions...';
  static const String quickModeHint =
      'Only a name is required. Switch to Advanced mode to add contact details, social links and notes.';
  static const String saveChanges = 'Save changes';
}
