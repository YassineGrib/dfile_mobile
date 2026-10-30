import 'package:flutter/widgets.dart';

import 'friends_repository.dart';

/// Provides [FriendsRepository] down the widget tree using [InheritedNotifier].
class FriendsScope extends InheritedNotifier<FriendsRepository> {
  const FriendsScope({
    super.key,
    required FriendsRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [FriendsRepository] from [context].
  ///
  /// If [listen] is true (the default), the calling widget will rebuild when
  /// the repository notifies listeners.
  static FriendsRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final FriendsScope? scope = context
          .dependOnInheritedWidgetOfExactType<FriendsScope>();
      assert(scope != null, 'No FriendsScope found in context.');
      return scope!.notifier!;
    } else {
      final FriendsScope? scope = context
          .getInheritedWidgetOfExactType<FriendsScope>();
      assert(scope != null, 'No FriendsScope found in context.');
      return scope!.notifier!;
    }
  }
}
