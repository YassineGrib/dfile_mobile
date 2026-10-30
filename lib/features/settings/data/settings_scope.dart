import 'package:flutter/widgets.dart';

import 'settings_repository.dart';

/// Provides [SettingsRepository] down the widget tree using [InheritedNotifier].
class SettingsScope extends InheritedNotifier<SettingsRepository> {
  const SettingsScope({
    super.key,
    required SettingsRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [SettingsRepository] from [context].
  ///
  /// If [listen] is true (the default), the calling widget will rebuild when
  /// the repository notifies listeners.
  static SettingsRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final SettingsScope? scope = context
          .dependOnInheritedWidgetOfExactType<SettingsScope>();
      assert(scope != null, 'No SettingsScope found in context.');
      return scope!.notifier!;
    } else {
      final SettingsScope? scope = context
          .getInheritedWidgetOfExactType<SettingsScope>();
      assert(scope != null, 'No SettingsScope found in context.');
      return scope!.notifier!;
    }
  }
}
