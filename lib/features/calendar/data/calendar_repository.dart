import 'dart:async';

import 'package:flutter/foundation.dart';

import 'calendar_store.dart';
import 'milestone.dart';

/// In-memory repository managing milestones and calendar sync settings
/// per `docs/design/SPEC.md` (CL1-CL15).
class CalendarRepository extends ChangeNotifier {
  CalendarRepository({
    List<Milestone>? initialMilestones,
    DateTime? initialLastSynced,
    bool syncDeadlines = true,
    bool syncMilestones = true,
    bool syncDebts = false,
  }) : _milestones = List<Milestone>.of(
         initialMilestones ?? _createInitialMilestones(),
       ),
       _lastSynced = initialLastSynced {
    _syncDeadlines = syncDeadlines;
    _syncMilestones = syncMilestones;
    _syncDebts = syncDebts;
  }

  final List<Milestone> _milestones;
  int _idCounter = 100;
  CalendarStore? _store;
  StreamSubscription<List<Milestone>>? _subscription;
  bool _loading = false;
  Object? _syncError;

  /// True until the first snapshot of an attached store arrives.
  bool get isLoading => _loading;

  /// Last store error (read or write), if any.
  Object? get syncError => _syncError;

  bool get isAttached => _store != null;

  /// Switches to [store] as the source of truth for milestones: the demo data
  /// is dropped and the list follows the snapshots. Sync preferences stay local.
  void attachStore(CalendarStore store) {
    _subscription?.cancel();
    _store = store;
    _milestones.clear();
    _loading = true;
    _syncError = null;
    notifyListeners();
    _subscription = store.watch().listen(
      (List<Milestone> remote) {
        _milestones
          ..clear()
          ..addAll(remote);
        _loading = false;
        _syncError = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loading = false;
        _syncError = error;
        notifyListeners();
      },
    );
  }

  /// Stops following the store and empties the list (sign-out).
  void detachStore() {
    _subscription?.cancel();
    _subscription = null;
    _store = null;
    _loading = false;
    _syncError = null;
    _milestones.clear();
    notifyListeners();
  }

  /// Deletes this user's milestones from the store (before the account goes).
  Future<void> deleteRemoteData() async => _store?.deleteAll();

  void _write(Future<void> Function(CalendarStore store) op) {
    final CalendarStore? store = _store;
    if (store == null) return;
    op(store).catchError((Object error) {
      _syncError = error;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  DateTime? _lastSynced;
  late bool _syncDeadlines;
  late bool _syncMilestones;
  late bool _syncDebts;

  /// Unmodifiable list of all recorded milestones.
  List<Milestone> get milestones => List<Milestone>.unmodifiable(_milestones);

  /// Returns all milestones associated with [projectId].
  List<Milestone> milestonesOf(String projectId) {
    return List<Milestone>.unmodifiable(
      _milestones.where((Milestone m) => m.projectId == projectId),
    );
  }

  /// Finds a milestone by [id], or returns `null` if not found.
  Milestone? milestoneById(String id) {
    for (final Milestone m in _milestones) {
      if (m.id == id) {
        return m;
      }
    }
    return null;
  }

  /// Adds a new milestone to the repository.
  ///
  /// If the provided milestone has an empty id, an auto-generated id is assigned.
  Milestone addMilestone(Milestone milestone) {
    final Milestone resolved = milestone.id.isEmpty
        ? milestone.copyWith(
            id: _store != null
                ? 'mil_${DateTime.now().microsecondsSinceEpoch}'
                : 'm${++_idCounter}',
          )
        : milestone;
    _milestones.add(resolved);
    notifyListeners();
    _write((CalendarStore st) => st.save(resolved));
    return resolved;
  }

  /// Toggles the completion status of a milestone by [id].
  ///
  /// Returns `true` if the milestone was found and toggled.
  bool toggleMilestone(String id) {
    final int index = _milestones.indexWhere((Milestone m) => m.id == id);
    if (index == -1) {
      return false;
    }
    final Milestone current = _milestones[index];
    final Milestone toggled = current.copyWith(completed: !current.completed);
    _milestones[index] = toggled;
    notifyListeners();
    _write((CalendarStore st) => st.save(toggled));
    return true;
  }

  /// Deletes a milestone by [id].
  ///
  /// Returns `true` if a milestone was removed.
  bool deleteMilestone(String id) {
    final int index = _milestones.indexWhere((Milestone m) => m.id == id);
    if (index == -1) {
      return false;
    }
    _milestones.removeAt(index);
    notifyListeners();
    _write((CalendarStore st) => st.delete(id));
    return true;
  }

  /// Removes all milestones associated with [projectId].
  void removeMilestonesOf(String projectId) {
    final int initialLength = _milestones.length;
    final List<String> removedIds = _milestones
        .where((Milestone m) => m.projectId == projectId)
        .map((Milestone m) => m.id)
        .toList();
    _milestones.removeWhere((Milestone m) => m.projectId == projectId);
    if (removedIds.isNotEmpty) {
      _write((CalendarStore st) async {
        for (final String id in removedIds) {
          await st.delete(id);
        }
      });
    }
    if (_milestones.length != initialLength) {
      notifyListeners();
    }
  }

  // Sync Preferences

  DateTime? get lastSynced => _lastSynced;
  set lastSynced(DateTime? value) {
    if (_lastSynced != value) {
      _lastSynced = value;
      notifyListeners();
    }
  }

  bool get syncDeadlines => _syncDeadlines;
  set syncDeadlines(bool value) {
    if (_syncDeadlines != value) {
      _syncDeadlines = value;
      notifyListeners();
    }
  }

  bool get syncMilestones => _syncMilestones;
  set syncMilestones(bool value) {
    if (_syncMilestones != value) {
      _syncMilestones = value;
      notifyListeners();
    }
  }

  bool get syncDebts => _syncDebts;
  set syncDebts(bool value) {
    if (_syncDebts != value) {
      _syncDebts = value;
      notifyListeners();
    }
  }

  /// Records the latest successful sync timestamp.
  void markSynced(DateTime when) {
    _lastSynced = when;
    notifyListeners();
  }

  /// Wipes all milestones and resets sync preferences to initial defaults.
  void clearAll() {
    _milestones.clear();
    _lastSynced = null;
    _syncDeadlines = true;
    _syncMilestones = true;
    _syncDebts = false;
    notifyListeners();
  }

  /// Default initial milestone seeds per `docs/design/SPEC.md`.
  static List<Milestone> _createInitialMilestones() {
    return <Milestone>[
      Milestone(
        id: 'm1',
        projectId: 'p2', // Brand Identity
        title: 'Moodboard sign-off',
        date: DateTime(2026, 10, 15),
        completed: true,
        createdAt: DateTime(2026, 9, 1),
      ),
      Milestone(
        id: 'm2',
        projectId: 'p2', // Brand Identity
        title: 'Client review',
        date: DateTime(2026, 10, 28),
        completed: true,
        createdAt: DateTime(2026, 9, 10),
      ),
      Milestone(
        id: 'm3',
        projectId: 'p1', // Fintask Landing Page
        title: 'Send invoice draft',
        date: DateTime(2026, 10, 30),
        completed: false,
        createdAt: DateTime(2026, 9, 15),
      ),
      Milestone(
        id: 'm4',
        projectId: 'p1', // Fintask Landing Page
        title: 'Beta handoff',
        date: DateTime(2026, 11, 2),
        completed: false,
        createdAt: DateTime(2026, 9, 20),
      ),
      Milestone(
        id: 'm5',
        projectId: 'p5', // Dashboard Redesign
        title: 'Final delivery review',
        date: DateTime(2026, 11, 12),
        completed: false,
        createdAt: DateTime(2026, 10, 1),
      ),
    ];
  }
}
