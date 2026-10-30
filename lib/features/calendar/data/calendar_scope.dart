import 'package:flutter/widgets.dart';

import 'calendar_repository.dart';

/// Provides [CalendarRepository] down the widget tree using [InheritedNotifier].
class CalendarScope extends InheritedNotifier<CalendarRepository> {
  const CalendarScope({
    super.key,
    required CalendarRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [CalendarRepository] from [context].
  ///
  /// If [listen] is true (default), the calling widget rebuilds whenever the
  /// repository notifies listeners.
  static CalendarRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final CalendarScope? scope = context
          .dependOnInheritedWidgetOfExactType<CalendarScope>();
      assert(scope != null, 'No CalendarScope found in context.');
      return scope!.notifier!;
    } else {
      final CalendarScope? scope = context
          .getInheritedWidgetOfExactType<CalendarScope>();
      assert(scope != null, 'No CalendarScope found in context.');
      return scope!.notifier!;
    }
  }

  /// Attempts to retrieve the [CalendarRepository] from [context], or returns `null`.
  static CalendarRepository? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<CalendarScope>()
          ?.notifier;
    } else {
      return context.getInheritedWidgetOfExactType<CalendarScope>()?.notifier;
    }
  }
}
