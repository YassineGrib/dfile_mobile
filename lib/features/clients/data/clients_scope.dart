import 'package:flutter/widgets.dart';

import 'clients_repository.dart';

/// Provides [ClientsRepository] down the widget tree using [InheritedNotifier].
class ClientsScope extends InheritedNotifier<ClientsRepository> {
  const ClientsScope({
    super.key,
    required ClientsRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [ClientsRepository] from [context].
  ///
  /// If [listen] is true (the default), the calling widget will rebuild when
  /// the repository notifies listeners.
  static ClientsRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final ClientsScope? scope = context
          .dependOnInheritedWidgetOfExactType<ClientsScope>();
      assert(scope != null, 'No ClientsScope found in context.');
      return scope!.notifier!;
    } else {
      final ClientsScope? scope = context
          .getInheritedWidgetOfExactType<ClientsScope>();
      assert(scope != null, 'No ClientsScope found in context.');
      return scope!.notifier!;
    }
  }
}
