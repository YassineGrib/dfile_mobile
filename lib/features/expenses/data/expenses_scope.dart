import 'package:flutter/widgets.dart';

import 'expenses_repository.dart';

/// Provides [ExpensesRepository] down the widget tree using [InheritedNotifier].
class ExpensesScope extends InheritedNotifier<ExpensesRepository> {
  const ExpensesScope({
    super.key,
    required ExpensesRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [ExpensesRepository] from [context].
  ///
  /// If [listen] is true (the default), the calling widget will rebuild when
  /// the repository notifies listeners.
  static ExpensesRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final ExpensesScope? scope =
          context.dependOnInheritedWidgetOfExactType<ExpensesScope>();
      assert(scope != null, 'No ExpensesScope found in context.');
      return scope!.notifier!;
    } else {
      final ExpensesScope? scope =
          context.getInheritedWidgetOfExactType<ExpensesScope>();
      assert(scope != null, 'No ExpensesScope found in context.');
      return scope!.notifier!;
    }
  }
}
