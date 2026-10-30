import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../expenses/data/data.dart';
import '../friends/data/data.dart';
import '../projects/data/data.dart';
import '../settings/data/data.dart';
import 'data/data.dart';
import 'dashboard_home_strings.dart';
import 'widgets/activity_card.dart';
import 'widgets/cashflow_card.dart';
import 'widgets/friends_snapshot_card.dart';
import 'widgets/home_empty_view.dart';
import 'widgets/home_follow_up.dart';
import 'widgets/home_hero_profit_card.dart';
import 'widgets/home_kpi_row.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_quick_add_sheet.dart';
import 'widgets/home_upcoming_deadlines.dart';
import 'widgets/status_donut_card.dart';

/// Dashboard home screen (agent A).
///
/// Supports an optional [clock] parameter to inject a deterministic time
/// for greeting and stats calculation in tests.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.clock});

  final DateTime Function()? clock;

  void _showQuickAdd(BuildContext context) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => const HomeQuickAddSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = clock != null ? clock!() : DateTime.now();

    // Listen to all repositories via their scopes
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ExpensesRepository expensesRepo = ExpensesScope.of(context);
    final FriendsRepository friendsRepo = FriendsScope.of(context);
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final NotificationsStore notifStore = NotificationsScope.of(context);

    final UserProfile profile = settingsRepo.profile;
    final List<Client> clients = clientsRepo.clients;
    final List<ProjectItem> projects = projectsRepo.projects;
    final List<ProjectPayment> payments = projectsRepo.payments;
    final List<Expense> expenses = expensesRepo.expenses;
    final List<Friend> friends = friendsRepo.friends;

    // Check account setup state (HM7 condition)
    final NewAccountSetup setup = newAccountSetup(
      clients: clients,
      projects: projects,
      payments: payments,
      expenses: expenses,
      friends: friends,
    );

    // SPEC.md:
    // "A brand new account (no clients, no projects, no payments, no expenses, no friends)
    // shows the empty home HM7: 'Welcome'..."
    // "TASK 9A: when newAccountSetup says isNewAccount (or fewer than 3 steps done AND nothing else exists)
    // show 'Welcome', the yellow 'Set up your ledger' card... once the three steps are done show normal home."
    final bool isEmptyHome =
        setup.isNewAccount ||
        (setup.completedCount < 3 && expenses.isEmpty && friends.isEmpty);

    // Top greeting string
    final String greetingText;
    final String nameWord;
    if (isEmptyHome) {
      greetingText = DashboardHomeStrings.welcome;
      nameWord = profile.name.trim().isNotEmpty
          ? profile.name.trim().split(RegExp(r'\s+')).first
          : '';
    } else {
      greetingText = greetingFor(now, profile.name);
      nameWord = '';
    }

    // Unread notifications check for the bell dot
    final List<AppNotification> notifs = deriveNotifications(
      now: now,
      settings: settingsRepo.notifications,
      projects: projects,
      transactions: friendsRepo.transactions,
      payments: payments,
      friendNameLookup: (String id) =>
          friendsRepo.friendById(id)?.name ?? 'Friend',
      projectNameLookup: (String id) =>
          projectsRepo.byId(id)?.name ?? 'Project',
    );
    final bool hasUnreadNotifs = notifStore.unreadCount(notifs) > 0;

    // Stats calculations
    final double profit = netProfit(payments, expenses);
    final double thisMonth = thisMonthNet(
      now,
      payments: payments,
      expenses: expenses,
    );
    final List<MonthFlow> last6Months = monthFlows(
      now,
      months: 6,
      payments: payments,
      expenses: expenses,
    );

    // KPIs:
    // 1. Active projects count
    final int activeCount = projects.where((ProjectItem p) {
      return p.status == ProjectStatus.inProgress ||
          p.status == ProjectStatus.waitingClient;
    }).length;

    // 2. Monthly expenses (outflow this month)
    final double monthlyExpenses = expenses
        .where(
          (Expense e) => e.date.year == now.year && e.date.month == now.month,
        )
        .fold<double>(0.0, (double sum, Expense e) => sum + e.amount);

    // 3. Pending invoices (paymentStats outstanding)
    final double pendingInvoices = projectsRepo.paymentStats().outstanding;

    // 4. Friends owe you (overallBalance().net)
    final double friendsNet = friendsRepo.overallBalance().net;

    // Deadlines
    final List<DeadlineItem> deadlines = upcomingDeadlines(
      projects,
      now,
      limit: 3,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const AppTabBar(
        currentIndex: AppTabBar.homeTabIndex,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          children: [
            // Header: Avatar, Greeting, Bell button (with dot), "+" ink button
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: UserAvatar(name: profile.name, size: 44),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greetingText,
                        style: AppText.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (nameWord.isNotEmpty)
                        Text(
                          nameWord,
                          style: AppText.cardTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Bell button with coral dot when unread
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    RoundIconButton(
                      icon: AppIcons.bell,
                      onPressed: () => context.push('/home/notifications'),
                    ),
                    if (hasUnreadNotifs)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                // Plus button (Ink fill, white plus)
                RoundIconButton(
                  icon: AppIcons.plus,
                  backgroundColor: AppColors.ink,
                  iconColor: AppColors.white,
                  borderColor: AppColors.ink,
                  onPressed: () => _showQuickAdd(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (isEmptyHome) ...[
              // HM7 New-user empty home
              HomeEmptyView(setup: setup),
            ] else ...[
              // Normal Home (HM1, HM2, HM3)
              FadeSlideIn(
                index: 0,
                child: HomeHeroProfitCard(
                  netProfitValue: profit,
                  thisMonthNetValue: thisMonth,
                  last6MonthFlows: last6Months,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              FadeSlideIn(
                index: 1,
                child: HomeKpiRow(
                  activeProjectsCount: activeCount,
                  monthlyExpensesAmount: monthlyExpenses,
                  pendingInvoicesAmount: pendingInvoices,
                  friendsNetBalance: friendsNet,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              FadeSlideIn(index: 2, child: const HomeQuickActions()),
              const SizedBox(height: AppSpacing.xxl),

              const FadeSlideIn(index: 3, child: HomeFollowUp()),
              FadeSlideIn(
                index: 4,
                child: HomeUpcomingDeadlines(
                  deadlines: deadlines,
                  clientNameLookup: (String id) =>
                      clientsRepo.byId(id)?.name ?? '',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              FadeSlideIn(index: 5, child: const CashflowCard()),
              const SizedBox(height: AppSpacing.lg),

              FadeSlideIn(index: 6, child: const StatusDonutCard()),
              const SizedBox(height: AppSpacing.lg),

              FadeSlideIn(index: 7, child: const ActivityCard()),
              const SizedBox(height: AppSpacing.lg),

              FadeSlideIn(index: 8, child: const FriendsSnapshotCard()),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
