import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/round_icon_button.dart';
import '../friends/data/friends_repository.dart';
import '../friends/data/friends_scope.dart';
import '../projects/data/projects_repository.dart';
import '../projects/data/projects_scope.dart';
import '../settings/data/settings_repository.dart';
import '../settings/data/settings_scope.dart';
import 'dashboard_activity_strings.dart';
import 'data/notifications.dart';
import 'widgets/dash_card.dart';
import 'widgets/dash_icon_bubble.dart';

/// Notifications screen per `docs/design/SPEC.md` (HM5).
///
/// Features:
/// - Back button, "Notifications" header, and "Mark all read" button
/// - Grouping: TODAY and EARLIER (based on [clock] vs notification date)
/// - Cards with tinted icon bubbles:
///   - calendarClock orange (deadline soon)
///   - triangleAlert red (deadline overdue)
///   - wallet red (overdue friend debt)
///   - circleCheck green (payment received)
/// - Title, subtitle, relative time ("2h ago", "Oct 12", "just now")
/// - Coral dot indicator when unread
/// - Tapping an item marks it read in [NotificationsStore] and navigates via `context.push`
/// - Empty state: friendly bell card "You are all caught up"
/// - Dynamic reactivity via [NotificationsScope] + [deriveNotifications] observing repositories and settings switches.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.clock});

  /// Optional clock provider for deterministic testing.
  final DateTime Function()? clock;

  DateTime get _now => clock?.call() ?? DateTime.now();

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final FriendsRepository friendsRepo = FriendsScope.of(context);
    final SettingsRepository settingsRepo = SettingsScope.of(context);
    final NotificationsStore store = NotificationsScope.of(context);

    final DateTime now = _now;

    final List<AppNotification> items = deriveNotifications(
      now: now,
      settings: settingsRepo.notifications,
      projects: projectsRepo.projects,
      transactions: friendsRepo.transactions,
      payments: projectsRepo.payments,
      friendNameLookup: (String friendId) =>
          friendsRepo.friendById(friendId)?.name ?? 'Friend',
      projectNameLookup: (String projectId) =>
          projectsRepo.byId(projectId)?.name ?? 'Project',
    );

    final int unreadCount = store.unreadCount(items);
    final bool canMarkAllRead = unreadCount > 0;

    // Split items into TODAY and EARLIER
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final List<AppNotification> todayItems = <AppNotification>[];
    final List<AppNotification> earlierItems = <AppNotification>[];

    for (final AppNotification item in items) {
      final DateTime itemDate = DateTime(
        item.date.year,
        item.date.month,
        item.date.day,
      );
      if (itemDate.isAtSameMomentAs(todayStart) ||
          item.isOverdue ||
          itemDate.isAfter(todayStart)) {
        todayItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: 12,
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: AppIcons.arrowLeft,
                    onPressed: () => _handleBack(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DashboardActivityStrings.notifications,
                      style: AppText.sectionTitle,
                    ),
                  ),
                  GestureDetector(
                    onTap: canMarkAllRead
                        ? () => store.markAllRead(items.map((e) => e.id))
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      DashboardActivityStrings.markAllRead,
                      style: AppText.captionSm.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: canMarkAllRead
                            ? AppColors.purple
                            : AppColors.placeholder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyNotificationsView()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageGutter,
                        8,
                        AppSpacing.pageGutter,
                        AppSpacing.xxl,
                      ),
                      children: [
                        if (todayItems.isNotEmpty) ...[
                          _GroupHeader(title: DashboardActivityStrings.today),
                          const SizedBox(height: 8),
                          for (final AppNotification notif in todayItems) ...[
                            _NotificationCard(
                              notification: notif,
                              isRead: store.isRead(notif.id),
                              now: now,
                              onTap: () {
                                store.markRead(notif.id);
                                context.push(notif.route);
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 12),
                        ],
                        if (earlierItems.isNotEmpty) ...[
                          _GroupHeader(title: DashboardActivityStrings.earlier),
                          const SizedBox(height: 8),
                          for (final AppNotification notif in earlierItems) ...[
                            _NotificationCard(
                              notification: notif,
                              isRead: store.isRead(notif.id),
                              now: now,
                              onTap: () {
                                store.markRead(notif.id);
                                context.push(notif.route);
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: AppText.captionSm.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.mute,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isRead,
    required this.now,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isRead;
  final DateTime now;
  final VoidCallback onTap;

  String _formatRelativeTime(DateTime date, DateTime now) {
    final Duration diff = now.difference(date);
    if (diff.isNegative) {
      // Due in future or today
      final int days = date.difference(now).inDays;
      if (days <= 0) return DashboardActivityStrings.today.toLowerCase();
      return 'in ${days}d';
    }
    if (diff.inMinutes < 60) {
      if (diff.inMinutes <= 1) return DashboardActivityStrings.justNow;
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
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
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color fg, Color bg) = switch (notification.kind) {
      AppNotificationKind.deadline =>
        notification.isOverdue
            ? (AppIcons.triangleAlert, AppColors.red, AppColors.redBg)
            : (AppIcons.calendarClock, AppColors.orange, AppColors.orangeBg),
      AppNotificationKind.overdueDebt => (
        AppIcons.wallet,
        AppColors.red,
        AppColors.redBg,
      ),
      AppNotificationKind.payment => (
        AppIcons.circleCheck,
        AppColors.green,
        AppColors.greenBg,
      ),
    };

    return DashCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashIconBubble(icon: icon, foreground: fg, background: bg, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppText.bodyMedium.copyWith(
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: AppColors.ink,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatRelativeTime(notification.date, now),
                      style: AppText.captionSm.copyWith(
                        color: AppColors.placeholder,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subtitle,
                  style: AppText.caption.copyWith(
                    color: AppColors.mute,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
        child: DashCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DashIconBubble(
                icon: AppIcons.bell,
                foreground: AppColors.orange,
                background: AppColors.orangeBg,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                DashboardActivityStrings.allCaughtUp,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DashboardActivityStrings.allCaughtUpSubtitle,
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
