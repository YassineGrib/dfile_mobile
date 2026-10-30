import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Tells the UI whether the cloud can be reached and whether a sync failed.
///
/// [sources] are the repositories to watch and [errorOf] returns the first
/// pending sync error (or null). Reachability is checked with [probe] every
/// [interval]; the default asks DNS for the Firestore host, which is exactly
/// what failed when a phone had no usable connection.
class SyncStatus extends ChangeNotifier {
  SyncStatus({
    required this.sources,
    required this.errorOf,
    Future<bool> Function()? probe,
    this.interval = const Duration(seconds: 10),
  }) : _probe = probe ?? _canReachFirestore;

  final List<Listenable> sources;
  final Object? Function() errorOf;
  final Future<bool> Function() _probe;
  final Duration interval;

  Timer? _timer;
  bool _offline = false;
  Object? _error;

  /// True when the last reachability check failed.
  bool get offline => _offline;

  /// The pending sync error, if any.
  Object? get error => _error;

  bool get hasProblem => _offline || _error != null;

  /// A short sentence for the banner, or null when everything is fine.
  String? get message {
    if (_offline) {
      return 'No connection. Changes are kept and will sync when you are back online.';
    }
    final Object? e = _error;
    if (e == null) return null;
    final String text = e.toString();
    if (text.contains('permission-denied')) {
      return 'The server refused the change. Sign out and in again.';
    }
    if (text.contains('unavailable')) {
      return 'The server is unreachable. Changes will sync later.';
    }
    return 'Some changes could not be synced.';
  }

  void start() {
    for (final Listenable s in sources) {
      s.addListener(_refreshError);
    }
    _refreshError();
    _check();
    _timer = Timer.periodic(interval, (_) => _check());
  }

  /// Re-checks reachability now (for example when the app returns to the front).
  Future<void> check() => _check();

  void _refreshError() {
    final Object? next = errorOf();
    if (next != _error) {
      _error = next;
      notifyListeners();
    }
  }

  Future<void> _check() async {
    bool ok;
    try {
      ok = await _probe();
    } catch (_) {
      ok = false;
    }
    if (_offline == ok) {
      _offline = !ok;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final Listenable s in sources) {
      s.removeListener(_refreshError);
    }
    super.dispose();
  }
}

Future<bool> _canReachFirestore() async {
  final List<InternetAddress> found = await InternetAddress.lookup(
    'firestore.googleapis.com',
  ).timeout(const Duration(seconds: 4));
  return found.isNotEmpty;
}
