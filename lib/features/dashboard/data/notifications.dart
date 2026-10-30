import 'package:flutter/widgets.dart';

import '../../friends/data/friend_transaction.dart';
import '../../friends/data/friend_tx_type.dart';
import '../../projects/data/project.dart';
import '../../settings/data/notification_prefs.dart';

/// Categories of dashboard notifications derived from repositories.
enum AppNotificationKind {
  deadline,
  overdueDebt,
  payment,
}

/// A derived notification item displayed on HM5 (/home/notifications).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.route,
    this.isOverdue = false,
  });

  final String id;
  final AppNotificationKind kind;
  final String title;
  final String subtitle;
  final DateTime date;
  final String route;
  final bool isOverdue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification &&
        other.id == id &&
        other.kind == kind &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.date == date &&
        other.route == route &&
        other.isOverdue == isOverdue;
  }

  @override
  int get hashCode => Object.hash(id, kind, title, subtitle, date, route, isOverdue);
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Pure function deriving notification items per SPEC.md HM5:
/// - Project deadlines within 3 days or overdue
/// - Overdue friend debts (lent transactions with past due date and remaining > 0)
/// - Recent payments
///
/// Respects [settings]:
/// - When push is false, returns empty list.
/// - When deadlines is false, excludes project deadlines.
/// - When payments is false, excludes payments and overdue friend debts.
List<AppNotification> deriveNotifications({
  required DateTime now,
  required NotificationPrefs settings,
  List<ProjectItem> projects = const <ProjectItem>[],
  List<FriendTransaction> transactions = const <FriendTransaction>[],
  List<ProjectPayment> payments = const <ProjectPayment>[],
  String Function(String friendId)? friendNameLookup,
  String Function(String projectId)? projectNameLookup,
}) {
  if (!settings.push) {
    return <AppNotification>[];
  }

  final List<AppNotification> notifications = <AppNotification>[];
  final DateTime today = _dateOnly(now);

  // 1. Deadline warnings
  if (settings.deadlines) {
    for (final ProjectItem project in projects) {
      if (project.status == ProjectStatus.completed ||
          project.status == ProjectStatus.delivered ||
          project.status == ProjectStatus.cancelled) {
        continue;
      }
      if (project.endDate == null) {
        continue;
      }

      final int daysLeft = _dateOnly(project.endDate!).difference(today).inDays;
      if (daysLeft <= 3) {
        final bool isOverdue = daysLeft < 0;
        final String title = isOverdue
            ? 'Project deadline overdue'
            : 'Project deadline approaching';
        final String subtitle = isOverdue
            ? '${project.name} is ${daysLeft.abs()}d overdue'
            : (daysLeft == 0
                ? '${project.name} is due today'
                : '${project.name} is due in ${daysLeft}d');

        notifications.add(
          AppNotification(
            id: 'deadline_${project.id}',
            kind: AppNotificationKind.deadline,
            title: title,
            subtitle: subtitle,
            date: project.endDate!,
            route: '/projects/${project.id}',
            isOverdue: isOverdue,
          ),
        );
      }
    }
  }

  // 2. Payments & overdue debts
  if (settings.payments) {
    // Overdue friend debts
    for (final FriendTransaction tx in transactions) {
      if (tx.direction == FriendTxDirection.lent &&
          tx.remaining > 0 &&
          tx.dueDate != null) {
        final int daysDue = _dateOnly(tx.dueDate!).difference(today).inDays;
        if (daysDue < 0) {
          final String friend = friendNameLookup?.call(tx.friendId) ?? 'Friend';
          notifications.add(
            AppNotification(
              id: 'debt_${tx.id}',
              kind: AppNotificationKind.overdueDebt,
              title: 'Payment overdue',
              subtitle: '$friend owes you ${tx.remaining.round()} DZ',
              date: tx.dueDate!,
              route: '/friends/${tx.friendId}',
              isOverdue: true,
            ),
          );
        }
      }
    }

    // Recent payments
    for (final ProjectPayment p in payments) {
      final String pName = projectNameLookup?.call(p.projectId) ?? 'Project';
      notifications.add(
        AppNotification(
          id: 'payment_${p.id}',
          kind: AppNotificationKind.payment,
          title: 'Payment received',
          subtitle: '$pName: +${p.amount.round()} DZ',
          date: p.date,
          route: '/payments/${p.id}',
          isOverdue: false,
        ),
      );
    }
  }

  notifications.sort((AppNotification a, AppNotification b) =>
      b.date.compareTo(a.date));

  return notifications;
}

/// In-memory store managing notification read state per SPEC.md HM5.
class NotificationsStore extends ChangeNotifier {
  NotificationsStore({Set<String>? initialReadIds})
      : _readIds = Set<String>.of(initialReadIds ?? <String>{});

  final Set<String> _readIds;

  /// Set of read notification IDs.
  Set<String> get readIds => Set<String>.unmodifiable(_readIds);

  /// Checks if [id] has been marked read.
  bool isRead(String id) => _readIds.contains(id);

  /// Marks a single notification [id] as read.
  void markRead(String id) {
    if (_readIds.add(id)) {
      notifyListeners();
    }
  }

  /// Marks multiple [ids] as read and notifies listeners.
  void markAllRead([Iterable<String>? ids]) {
    bool changed = false;
    if (ids != null) {
      for (final String id in ids) {
        if (_readIds.add(id)) {
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Calculates the unread count from a collection of [items].
  int unreadCount(Iterable<AppNotification> items) {
    return items.where((AppNotification item) => !_readIds.contains(item.id)).length;
  }

  /// Resets the read IDs set.
  void clear() {
    _readIds.clear();
    notifyListeners();
  }
}

/// Provides [NotificationsStore] down the widget tree using [InheritedNotifier].
class NotificationsScope extends InheritedNotifier<NotificationsStore> {
  const NotificationsScope({
    super.key,
    required NotificationsStore store,
    required super.child,
  }) : super(notifier: store);

  static NotificationsStore of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final NotificationsScope? scope =
          context.dependOnInheritedWidgetOfExactType<NotificationsScope>();
      assert(scope != null, 'No NotificationsScope found in context.');
      return scope!.notifier!;
    } else {
      final NotificationsScope? scope =
          context.getInheritedWidgetOfExactType<NotificationsScope>();
      assert(scope != null, 'No NotificationsScope found in context.');
      return scope!.notifier!;
    }
  }
}
