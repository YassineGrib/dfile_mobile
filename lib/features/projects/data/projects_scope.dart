import 'package:flutter/widgets.dart';

import 'projects_repository.dart';

/// Provides [ProjectsRepository] down the widget tree using [InheritedNotifier].
class ProjectsScope extends InheritedNotifier<ProjectsRepository> {
  const ProjectsScope({
    super.key,
    required ProjectsRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Retrieves the [ProjectsRepository] from [context].
  ///
  /// If [listen] is true (the default), the calling widget will rebuild when
  /// the repository notifies listeners.
  static ProjectsRepository of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final ProjectsScope? scope = context
          .dependOnInheritedWidgetOfExactType<ProjectsScope>();
      assert(scope != null, 'No ProjectsScope found in context.');
      return scope!.notifier!;
    } else {
      final ProjectsScope? scope = context
          .getInheritedWidgetOfExactType<ProjectsScope>();
      assert(scope != null, 'No ProjectsScope found in context.');
      return scope!.notifier!;
    }
  }
}
