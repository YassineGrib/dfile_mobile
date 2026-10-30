import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/store_utils.dart';
import 'notification_prefs.dart';
import 'user_profile.dart';

/// The workspace preferences the phone shares with the web app
/// (`users/{uid}/settings/workspace`). A field is null when the document does
/// not have it yet. The PIN, biometrics, theme, language and the connected
/// Google flag stay on the device on purpose.
class SettingsSnapshot {
  const SettingsSnapshot({
    this.profile,
    this.categories,
    this.legalClauses,
    this.notifications,
  });

  final UserProfile? profile;
  final List<String>? categories;
  final String? legalClauses;
  final NotificationPrefs? notifications;
}

/// Persistence behind [SettingsRepository].
abstract class SettingsStore {
  /// Emits the document on every change; a missing document is an empty snapshot.
  Stream<SettingsSnapshot> watch();

  Future<void> saveProfile(UserProfile profile);

  Future<void> saveCategories(List<String> categories);

  Future<void> saveLegalClauses(String clauses);

  Future<void> saveNotifications(NotificationPrefs prefs);

  /// Removes the settings document (account deletion).
  Future<void> deleteAll();
}

Map<String, Object?> profileToMap(UserProfile p) => <String, Object?>{
  'name': p.name,
  'designation': p.designation,
  'email': p.email,
  'phone': p.phone,
  'address': p.address,
};

Map<String, Object?> notificationsToMap(NotificationPrefs n) =>
    <String, Object?>{
      'push_enabled': n.push,
      'notify_deadlines': n.deadlines,
      'notify_payments': n.payments,
      'notify_tasks': n.tasks,
    };

/// Reads the workspace document written by the web app or by this app.
SettingsSnapshot settingsFromMap(
  Map<String, Object?> data, {
  UserProfile? profileFallback,
}) {
  final Object? rawProfile = data['profile'];
  UserProfile? profile;
  if (rawProfile is Map) {
    final Map<String, Object?> p = Map<String, Object?>.from(rawProfile);
    final UserProfile base =
        profileFallback ??
        const UserProfile(
          name: '',
          designation: '',
          email: '',
          phone: '',
          address: '',
        );
    profile = UserProfile(
      name: p.containsKey('name') ? textOf(p['name']) : base.name,
      designation: p.containsKey('designation')
          ? textOf(p['designation'])
          : base.designation,
      email: p.containsKey('email') ? textOf(p['email']) : base.email,
      phone: p.containsKey('phone') ? textOf(p['phone']) : base.phone,
      address: p.containsKey('address') ? textOf(p['address']) : base.address,
    );
  }

  final Object? rawCategories = data['categories'];
  final List<String>? categories = rawCategories is List
      ? rawCategories.whereType<String>().toList()
      : null;

  final Object? rawClauses = data['contract_clauses'];
  final String? clauses = rawClauses is String ? rawClauses : null;

  final Object? rawNotifications = data['notifications'];
  NotificationPrefs? notifications;
  if (rawNotifications is Map) {
    final Map<String, Object?> n = Map<String, Object?>.from(rawNotifications);
    bool flag(String key, bool fallback) =>
        n[key] is bool ? n[key]! as bool : fallback;
    notifications = NotificationPrefs(
      push: flag('push_enabled', true),
      deadlines: flag('notify_deadlines', true),
      payments: flag('notify_payments', true),
      tasks: flag('notify_tasks', false),
    );
  }

  return SettingsSnapshot(
    profile: profile,
    categories: categories,
    legalClauses: clauses,
    notifications: notifications,
  );
}

/// Firestore-backed store for one signed-in user. Writes merge into the
/// document, so settings the phone does not know are never wiped.
class FirestoreSettingsStore implements SettingsStore {
  FirestoreSettingsStore(
    this.uid, {
    this.profileFallback,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final UserProfile? profileFallback;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('users').doc(uid).collection('settings').doc('workspace');

  @override
  Stream<SettingsSnapshot> watch() => _doc.snapshots().map(
    (DocumentSnapshot<Map<String, dynamic>> snap) => snap.exists
        ? settingsFromMap(
            Map<String, Object?>.from(snap.data()!),
            profileFallback: profileFallback,
          )
        : const SettingsSnapshot(),
  );

  Future<void> _merge(Map<String, Object?> fields) =>
      _doc.set(<String, Object?>{
        ...fields,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

  @override
  Future<void> saveProfile(UserProfile profile) =>
      _merge(<String, Object?>{'profile': profileToMap(profile)});

  @override
  Future<void> saveCategories(List<String> categories) =>
      _merge(<String, Object?>{'categories': categories});

  @override
  Future<void> saveLegalClauses(String clauses) =>
      _merge(<String, Object?>{'contract_clauses': clauses});

  @override
  Future<void> saveNotifications(NotificationPrefs prefs) =>
      _merge(<String, Object?>{'notifications': notificationsToMap(prefs)});

  @override
  Future<void> deleteAll() => _doc.delete();
}

/// In-memory store for tests.
class FakeSettingsStore implements SettingsStore {
  FakeSettingsStore([SettingsSnapshot initial = const SettingsSnapshot()])
    : _current = initial;

  SettingsSnapshot _current;
  final StreamController<SettingsSnapshot> _controller =
      StreamController<SettingsSnapshot>.broadcast();
  final List<String> log = <String>[];

  void _emit() => _controller.add(_current);

  @override
  Stream<SettingsSnapshot> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    log.add('profile');
    _current = SettingsSnapshot(
      profile: profile,
      categories: _current.categories,
      legalClauses: _current.legalClauses,
      notifications: _current.notifications,
    );
    _emit();
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    log.add('categories');
    _current = SettingsSnapshot(
      profile: _current.profile,
      categories: categories,
      legalClauses: _current.legalClauses,
      notifications: _current.notifications,
    );
    _emit();
  }

  @override
  Future<void> saveLegalClauses(String clauses) async {
    log.add('clauses');
    _current = SettingsSnapshot(
      profile: _current.profile,
      categories: _current.categories,
      legalClauses: clauses,
      notifications: _current.notifications,
    );
    _emit();
  }

  @override
  Future<void> saveNotifications(NotificationPrefs prefs) async {
    log.add('notifications');
    _current = SettingsSnapshot(
      profile: _current.profile,
      categories: _current.categories,
      legalClauses: _current.legalClauses,
      notifications: prefs,
    );
    _emit();
  }

  @override
  Future<void> deleteAll() async {
    log.add('deleteAll');
    _current = const SettingsSnapshot();
    _emit();
  }
}
