import '../../clients/data/client.dart';
import '../../expenses/data/expense.dart';
import '../../friends/data/friend.dart';
import '../../friends/data/friend_transaction.dart';
import '../../friends/data/friend_tx_type.dart';
import '../../projects/data/project.dart';

/// Representation of a single calendar month's cashflow totals.
class MonthFlow {
  const MonthFlow({
    required this.month,
    required this.inflow,
    required this.outflow,
    required this.net,
  });

  final DateTime month;
  final double inflow;
  final double outflow;
  final double net;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthFlow &&
        other.month.year == month.year &&
        other.month.month == month.month &&
        other.inflow == inflow &&
        other.outflow == outflow &&
        other.net == net;
  }

  @override
  int get hashCode => Object.hash(month.year, month.month, inflow, outflow, net);

  @override
  String toString() =>
      'MonthFlow(${month.year}-${month.month}: inflow: $inflow, outflow: $outflow, net: $net)';
}

/// Urgency state of an upcoming or overdue project deadline.
enum DeadlineState {
  overdue,
  soon,
  later,
}

/// Project deadline with calculated days remaining and status per SPEC.md.
class DeadlineItem {
  const DeadlineItem({
    required this.project,
    required this.daysLeft,
    required this.state,
  });

  final ProjectItem project;
  final int daysLeft;
  final DeadlineState state;

  bool get isOverdue => daysLeft < 0;
  bool get isToday => daysLeft == 0;
  bool get isSoon => state == DeadlineState.soon;

  String get pillText {
    if (daysLeft < 0) {
      return 'Overdue ${daysLeft.abs()}d';
    } else if (daysLeft == 0) {
      return 'Today';
    } else {
      return '${daysLeft}d left';
    }
  }
}

/// Top earning project summary item.
class TopProjectItem {
  const TopProjectItem({
    required this.project,
    required this.paid,
  });

  final ProjectItem project;
  final double paid;
}

/// Top expense category summary item.
class TopExpenseCategoryItem {
  const TopExpenseCategoryItem({
    required this.category,
    required this.total,
  });

  final ExpenseCategory category;
  final double total;
}

/// Category kind for dashboard recent activity items.
enum ActivityKind {
  payment,
  expense,
  settlement,
  projectStarted,
}

/// An entry in the dashboard recent activity feed.
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.amount,
    required this.date,
    required this.route,
  });

  final ActivityKind kind;
  final String title;
  final String subtitle;
  final double? amount;
  final DateTime date;
  final String route;
}

/// Setup progress and onboarding status for empty or partially configured accounts.
class NewAccountSetup {
  const NewAccountSetup({
    required this.hasClient,
    required this.hasProject,
    required this.hasPayment,
    required this.completedCount,
    required this.isNewAccount,
  });

  final bool hasClient;
  final bool hasProject;
  final bool hasPayment;
  final int completedCount;
  final bool isNewAccount;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Generates the dashboard greeting string based on the hour of [now] and [profileName].
///
/// - Before 12:00: "Good morning"
/// - Before 18:00: "Good afternoon"
/// - 18:00 and later: "Good evening"
String greetingFor(DateTime now, [String? profileName]) {
  final String timeGreeting;
  if (now.hour < 12) {
    timeGreeting = 'Good morning';
  } else if (now.hour < 18) {
    timeGreeting = 'Good afternoon';
  } else {
    timeGreeting = 'Good evening';
  }

  if (profileName == null || profileName.trim().isEmpty) {
    return timeGreeting;
  }

  final String firstWord = profileName.trim().split(RegExp(r'\s+')).first;
  return '$timeGreeting, $firstWord';
}

/// Computes net profit: all payments collected minus all recorded expenses.
double netProfit(List<ProjectPayment> payments, List<Expense> expenses) {
  final double totalInflow = payments.fold<double>(
    0.0,
    (double sum, ProjectPayment p) => sum + p.amount,
  );
  final double totalOutflow = expenses.fold<double>(
    0.0,
    (double sum, Expense e) => sum + e.amount,
  );
  return totalInflow - totalOutflow;
}

/// Returns the cashflows for the [months] calendar months ending with [now]'s month, oldest first.
List<MonthFlow> monthFlows(
  DateTime now, {
  required int months,
  List<ProjectPayment> payments = const <ProjectPayment>[],
  List<Expense> expenses = const <Expense>[],
}) {
  final List<MonthFlow> result = <MonthFlow>[];

  for (int i = months - 1; i >= 0; i--) {
    int year = now.year;
    int month = now.month - i;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }

    final double inflow = payments
        .where((ProjectPayment p) => p.date.year == year && p.date.month == month)
        .fold<double>(0.0, (double sum, ProjectPayment p) => sum + p.amount);

    final double outflow = expenses
        .where((Expense e) => e.date.year == year && e.date.month == month)
        .fold<double>(0.0, (double sum, Expense e) => sum + e.amount);

    result.add(
      MonthFlow(
        month: DateTime(year, month, 1),
        inflow: inflow,
        outflow: outflow,
        net: inflow - outflow,
      ),
    );
  }

  return result;
}

/// Returns the cashflows for all 12 calendar months (January to December) of [now]'s year.
List<MonthFlow> yearFlows(
  DateTime now, {
  List<ProjectPayment> payments = const <ProjectPayment>[],
  List<Expense> expenses = const <Expense>[],
}) {
  final List<MonthFlow> result = <MonthFlow>[];

  for (int m = 1; m <= 12; m++) {
    final double inflow = payments
        .where((ProjectPayment p) => p.date.year == now.year && p.date.month == m)
        .fold<double>(0.0, (double sum, ProjectPayment p) => sum + p.amount);

    final double outflow = expenses
        .where((Expense e) => e.date.year == now.year && e.date.month == m)
        .fold<double>(0.0, (double sum, Expense e) => sum + e.amount);

    result.add(
      MonthFlow(
        month: DateTime(now.year, m, 1),
        inflow: inflow,
        outflow: outflow,
        net: inflow - outflow,
      ),
    );
  }

  return result;
}

/// Net cashflow for the current month of [now] (inflow minus outflow).
double thisMonthNet(
  DateTime now, {
  List<ProjectPayment> payments = const <ProjectPayment>[],
  List<Expense> expenses = const <Expense>[],
}) {
  final double inflow = payments
      .where((ProjectPayment p) =>
          p.date.year == now.year && p.date.month == now.month)
      .fold<double>(0.0, (double sum, ProjectPayment p) => sum + p.amount);

  final double outflow = expenses
      .where((Expense e) =>
          e.date.year == now.year && e.date.month == now.month)
      .fold<double>(0.0, (double sum, Expense e) => sum + e.amount);

  return inflow - outflow;
}

/// Upcoming deadlines per SPEC.md:
/// Up to [limit] projects that are not Completed / Delivered / Cancelled and have an end date,
/// ordered by end date ascending.
List<DeadlineItem> upcomingDeadlines(
  List<ProjectItem> projects,
  DateTime now, {
  int? limit = 3,
}) {
  final DateTime today = _dateOnly(now);

  final List<ProjectItem> validProjects = projects.where((ProjectItem p) {
    if (p.status == ProjectStatus.completed ||
        p.status == ProjectStatus.delivered ||
        p.status == ProjectStatus.cancelled) {
      return false;
    }
    return p.endDate != null;
  }).toList();

  validProjects.sort((ProjectItem a, ProjectItem b) {
    return a.endDate!.compareTo(b.endDate!);
  });

  final Iterable<ProjectItem> limited =
      limit != null ? validProjects.take(limit) : validProjects;

  return limited.map((ProjectItem p) {
    final int daysLeft = _dateOnly(p.endDate!).difference(today).inDays;
    final DeadlineState state;
    if (daysLeft < 0) {
      state = DeadlineState.overdue;
    } else if (daysLeft <= 7) {
      state = DeadlineState.soon;
    } else {
      state = DeadlineState.later;
    }
    return DeadlineItem(
      project: p,
      daysLeft: daysLeft,
      state: state,
    );
  }).toList();
}

/// Project counts grouped by the 5 active/visible statuses (Cancelled is ignored).
Map<ProjectStatus, int> statusCounts(List<ProjectItem> projects) {
  final Map<ProjectStatus, int> counts = <ProjectStatus, int>{
    ProjectStatus.delivered: 0,
    ProjectStatus.completed: 0,
    ProjectStatus.inProgress: 0,
    ProjectStatus.waitingClient: 0,
    ProjectStatus.planned: 0,
  };

  for (final ProjectItem p in projects) {
    if (counts.containsKey(p.status)) {
      counts[p.status] = (counts[p.status] ?? 0) + 1;
    }
  }

  return counts;
}

/// Top projects ranked by total collected payments descending.
List<TopProjectItem> topProjectsByPaid(
  List<ProjectItem> projects,
  List<ProjectPayment> payments, {
  int limit = 3,
}) {
  final List<TopProjectItem> items = projects.map((ProjectItem project) {
    final double paid = payments
        .where((ProjectPayment p) => p.projectId == project.id)
        .fold<double>(0.0, (double sum, ProjectPayment p) => sum + p.amount);
    return TopProjectItem(project: project, paid: paid);
  }).toList();

  items.sort((TopProjectItem a, TopProjectItem b) => b.paid.compareTo(a.paid));

  return items.take(limit).toList();
}

/// Top expense categories ranked by total spent amount descending.
List<TopExpenseCategoryItem> topExpenseCategories(
  List<Expense> expenses, {
  int limit = 3,
}) {
  final Map<ExpenseCategory, double> totals = <ExpenseCategory, double>{};

  for (final Expense e in expenses) {
    totals[e.category] = (totals[e.category] ?? 0.0) + e.amount;
  }

  final List<TopExpenseCategoryItem> items = totals.entries
      .map((MapEntry<ExpenseCategory, double> entry) =>
          TopExpenseCategoryItem(category: entry.key, total: entry.value))
      .toList();

  items.sort((TopExpenseCategoryItem a, TopExpenseCategoryItem b) =>
      b.total.compareTo(a.total));

  return items.take(limit).toList();
}

/// Profit margin percentage (net profit / total revenue * 100), or 0.0 when revenue <= 0.
double profitMargin(
  List<ProjectPayment> payments,
  List<Expense> expenses,
) {
  final double revenue = payments.fold<double>(
    0.0,
    (double sum, ProjectPayment p) => sum + p.amount,
  );
  if (revenue <= 0.0) return 0.0;
  final double net = netProfit(payments, expenses);
  return (net / revenue) * 100.0;
}

/// Builds recent activity items newest first per SPEC.md HM3.
List<ActivityItem> recentActivity({
  required List<ProjectPayment> payments,
  required List<Expense> expenses,
  List<FriendSettlement> settlements = const <FriendSettlement>[],
  List<FriendTransaction> friendTransactions = const <FriendTransaction>[],
  List<ProjectItem> projects = const <ProjectItem>[],
  String Function(String clientId)? clientNameLookup,
  String Function(String projectId)? projectNameLookup,
  String Function(String friendId)? friendNameLookup,
  int? limit = 4,
}) {
  final List<ActivityItem> items = <ActivityItem>[];

  // 1. Payments
  for (final ProjectPayment p in payments) {
    final String client = clientNameLookup?.call(p.clientId) ?? '';
    final String project = projectNameLookup?.call(p.projectId) ?? '';
    final String subtitle = [client, project].where((s) => s.isNotEmpty).join(' - ');

    items.add(
      ActivityItem(
        kind: ActivityKind.payment,
        title: 'Payment received',
        subtitle: subtitle.isNotEmpty ? subtitle : p.reference,
        amount: p.amount,
        date: p.date,
        route: '/payments/${p.id}',
      ),
    );
  }

  // 2. Expenses
  for (final Expense e in expenses) {
    items.add(
      ActivityItem(
        kind: ActivityKind.expense,
        title: 'Expense added',
        subtitle: e.description,
        amount: -e.amount,
        date: e.date,
        route: '/expenses/${e.id}',
      ),
    );
  }

  // 3. Friend settlements
  for (final FriendSettlement s in settlements) {
    FriendTransaction? matchedTx;
    for (final FriendTransaction tx in friendTransactions) {
      if (tx.id == s.transactionId) {
        matchedTx = tx;
        break;
      }
    }
    final bool isLent = matchedTx == null || matchedTx.direction == FriendTxDirection.lent;
    final String friendName = friendNameLookup?.call(s.friendId) ?? 'Friend';

    items.add(
      ActivityItem(
        kind: ActivityKind.settlement,
        title: isLent ? 'Settlement received' : 'Settlement paid',
        subtitle: friendName,
        amount: isLent ? s.amount : -s.amount,
        date: s.date,
        route: '/friends/${s.friendId}',
      ),
    );
  }

  // 4. Projects started (In Progress)
  for (final ProjectItem p in projects) {
    if (p.status == ProjectStatus.inProgress) {
      final String clientName = clientNameLookup?.call(p.clientId) ?? '';
      items.add(
        ActivityItem(
          kind: ActivityKind.projectStarted,
          title: 'Project started',
          subtitle: clientName.isNotEmpty ? '${p.name} ($clientName)' : p.name,
          amount: null,
          date: p.startDate,
          route: '/projects/${p.id}',
        ),
      );
    }
  }

  items.sort((ActivityItem a, ActivityItem b) => b.date.compareTo(a.date));

  if (limit != null) {
    return items.take(limit).toList();
  }
  return items;
}

/// Evaluates account setup and whether the account is completely new (empty).
NewAccountSetup newAccountSetup({
  required List<Client> clients,
  required List<ProjectItem> projects,
  required List<ProjectPayment> payments,
  List<Expense> expenses = const <Expense>[],
  List<Friend> friends = const <Friend>[],
}) {
  final bool hasClient = clients.isNotEmpty;
  final bool hasProject = projects.isNotEmpty;
  final bool hasPayment = payments.isNotEmpty;
  final int completedCount =
      (hasClient ? 1 : 0) + (hasProject ? 1 : 0) + (hasPayment ? 1 : 0);

  final bool isNewAccount = clients.isEmpty &&
      projects.isEmpty &&
      payments.isEmpty &&
      expenses.isEmpty &&
      friends.isEmpty;

  return NewAccountSetup(
    hasClient: hasClient,
    hasProject: hasProject,
    hasPayment: hasPayment,
    completedCount: completedCount,
    isNewAccount: isNewAccount,
  );
}
