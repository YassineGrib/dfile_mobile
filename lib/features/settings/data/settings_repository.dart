import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_language.dart';
import 'app_theme_mode.dart';
import 'device_session.dart';
import 'notification_prefs.dart';
import 'settings_store.dart';
import 'support_ticket.dart';
import 'user_profile.dart';

/// In-memory repository managing application settings per `docs/design/SPEC.md`.
class SettingsRepository extends ChangeNotifier {
  SettingsRepository({
    UserProfile? initialProfile,
    AppLanguage initialLanguage = AppLanguage.en,
    AppThemeMode initialThemeMode = AppThemeMode.light,
    List<String>? initialCategories,
    String? initialLegalClauses,
    bool initialPinEnabled = false,
    String? initialPin,
    bool initialBiometricsEnabled = false,
    List<DeviceSession>? initialSessions,
    bool initialGoogleConnected = false,
    NotificationPrefs? initialNotifications,
    List<SupportTicket>? initialSupportTickets,
    String initialPassword = 'demo123',
  }) : _profile = initialProfile ?? defaultProfile,
       _language = initialLanguage,
       _themeMode = initialThemeMode,
       _categories = initialCategories != null
           ? List<String>.from(initialCategories)
           : List<String>.from(defaultCategories),
       _legalClauses = initialLegalClauses ?? defaultLegalClauses,
       _pinEnabled = initialPinEnabled,
       _pin = initialPin,
       _biometricsEnabled = initialBiometricsEnabled,
       _sessions = initialSessions != null
           ? List<DeviceSession>.from(initialSessions)
           : List<DeviceSession>.from(defaultSessions),
       _googleConnected = initialGoogleConnected,
       _notifications = initialNotifications ?? defaultNotificationPrefs,
       _supportTickets = initialSupportTickets != null
           ? List<SupportTicket>.from(initialSupportTickets)
           : <SupportTicket>[],
       _password = initialPassword;

  static const UserProfile defaultProfile = UserProfile(
    name: 'Yassine G.',
    designation: 'Independent designer',
    email: 'yassine@decabyte.dz',
    phone: '+213 550 12 34 56',
    address: '12 Rue Didouche Mourad, Algiers',
  );

  static const List<String> defaultCategories = <String>[
    'Development',
    'Design',
    'Branding',
    'Marketing',
    'Consulting',
  ];

  static const String defaultLegalClauses =
      '1. Payment: 50% upfront, 50% on delivery.\n\n'
      '2. Revisions: up to two rounds are included in the agreed price.\n\n'
      '3. Ownership: files transfer to the client once the final payment is cleared.';

  static const List<DeviceSession> defaultSessions = <DeviceSession>[
    DeviceSession(
      id: 'session-1',
      name: 'This phone',
      detail: 'Samsung S24 \u2022 Active now',
      isCurrent: true,
    ),
    DeviceSession(
      id: 'session-2',
      name: 'Office laptop',
      detail: 'Chrome, Windows \u2022 2 days ago',
      isCurrent: false,
    ),
  ];

  static const NotificationPrefs defaultNotificationPrefs = NotificationPrefs(
    push: true,
    deadlines: true,
    payments: true,
    tasks: false,
  );

  UserProfile _profile;
  AppLanguage _language;
  AppThemeMode _themeMode;
  final List<String> _categories;
  String _legalClauses;
  bool _pinEnabled;
  String? _pin;
  bool _biometricsEnabled;
  final List<DeviceSession> _sessions;
  bool _googleConnected;
  NotificationPrefs _notifications;
  final List<SupportTicket> _supportTickets;
  String _password;

  SettingsStore? _store;
  StreamSubscription<SettingsSnapshot>? _subscription;
  bool _loading = false;
  Object? _syncError;

  /// True until the first snapshot of an attached store arrives.
  bool get isLoading => _loading;

  /// Last store error (read or write), if any.
  Object? get syncError => _syncError;

  bool get isAttached => _store != null;

  /// Switches to [store] for the settings shared with the web app (profile,
  /// categories, contract clauses, notification switches). [seedProfile] is
  /// shown until the document has a profile. PIN, biometrics, theme and
  /// language stay on this device.
  void attachStore(SettingsStore store, {UserProfile? seedProfile}) {
    _subscription?.cancel();
    _store = store;
    _loading = true;
    _syncError = null;
    if (seedProfile != null) _profile = seedProfile;
    _categories
      ..clear()
      ..addAll(defaultCategories);
    _legalClauses = defaultLegalClauses;
    _notifications = defaultNotificationPrefs;
    notifyListeners();
    _subscription = store.watch().listen(
      (SettingsSnapshot snap) {
        if (snap.profile != null) _profile = snap.profile!;
        if (snap.categories != null) {
          _categories
            ..clear()
            ..addAll(snap.categories!);
        }
        if (snap.legalClauses != null) _legalClauses = snap.legalClauses!;
        if (snap.notifications != null) _notifications = snap.notifications!;
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

  /// Stops following the store and resets to the defaults (sign-out).
  void detachStore() {
    _subscription?.cancel();
    _subscription = null;
    _store = null;
    _loading = false;
    _syncError = null;
    clearAll();
  }

  /// Deletes this user's settings document (before the account goes).
  Future<void> deleteRemoteData() async => _store?.deleteAll();

  void _write(Future<void> Function(SettingsStore store) op) {
    final SettingsStore? store = _store;
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

  // --- Getters ---

  UserProfile get profile => _profile;
  AppLanguage get language => _language;
  AppThemeMode get themeMode => _themeMode;
  List<String> get categories => List<String>.unmodifiable(_categories);
  String get legalClauses => _legalClauses;
  bool get pinEnabled => _pinEnabled;
  String? get pin => _pin;
  bool get biometricsEnabled => _biometricsEnabled;
  List<DeviceSession> get sessions =>
      List<DeviceSession>.unmodifiable(_sessions);
  bool get googleConnected => _googleConnected;
  NotificationPrefs get notifications => _notifications;
  List<SupportTicket> get supportTickets =>
      List<SupportTicket>.unmodifiable(_supportTickets);
  String get mockPassword => _password;

  // --- Setters & Actions ---

  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
    _write((SettingsStore st) => st.saveProfile(newProfile));
  }

  void setLanguage(AppLanguage language) {
    _language = language;
    notifyListeners();
  }

  void setThemeMode(AppThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  /// Adds a new project category.
  ///
  /// Returns `false` if [category] is empty after trimming or is a
  /// case-insensitive duplicate. Otherwise adds the trimmed category and
  /// returns `true`.
  bool addCategory(String category) {
    final String trimmed = category.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final bool duplicate = _categories.any(
      (String c) => c.toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      return false;
    }
    _categories.add(trimmed);
    notifyListeners();
    final List<String> added = List<String>.of(_categories);
    _write((SettingsStore st) => st.saveCategories(added));
    return true;
  }

  /// Removes a category by name (case-insensitive).
  ///
  /// Returns `true` if removed, `false` otherwise.
  bool removeCategory(String category) {
    final String target = category.trim().toLowerCase();
    final int index = _categories.indexWhere(
      (String c) => c.toLowerCase() == target,
    );
    if (index != -1) {
      _categories.removeAt(index);
      notifyListeners();
      final List<String> remaining = List<String>.of(_categories);
      _write((SettingsStore st) => st.saveCategories(remaining));
      return true;
    }
    return false;
  }

  void setLegalClauses(String clauses) {
    _legalClauses = clauses;
    notifyListeners();
    _write((SettingsStore st) => st.saveLegalClauses(clauses));
  }

  /// Sets or clears the 4-digit PIN.
  ///
  /// If [pin] is null, clears the PIN and disables PIN lock.
  /// If [pin] is non-null, validates that it consists of exactly 4 digits,
  /// throws [ArgumentError] if invalid, and enables PIN lock.
  void setPin(String? pin) {
    if (pin == null) {
      _pin = null;
      _pinEnabled = false;
      notifyListeners();
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits');
    }
    _pin = pin;
    _pinEnabled = true;
    notifyListeners();
  }

  void setPinEnabled(bool enabled) {
    _pinEnabled = enabled;
    if (!enabled) {
      _pin = null;
    }
    notifyListeners();
  }

  void setBiometrics(bool enabled) {
    _biometricsEnabled = enabled;
    notifyListeners();
  }

  void setBiometricsEnabled(bool enabled) => setBiometrics(enabled);

  /// Keeps the current active session and terminates all other sessions.
  void terminateOtherSessions() {
    _sessions.removeWhere((DeviceSession s) => !s.isCurrent);
    notifyListeners();
  }

  void setGoogleConnected(bool connected) {
    _googleConnected = connected;
    notifyListeners();
  }

  void updateNotifications(NotificationPrefs prefs) {
    _notifications = prefs;
    notifyListeners();
    _write((SettingsStore st) => st.saveNotifications(prefs));
  }

  void addSupportTicket(SupportTicket ticket) {
    _supportTickets.add(ticket);
    notifyListeners();
  }

  bool checkPassword(String password) {
    return _password == password;
  }

  void changePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  /// Resets all settings to default values and clears sessions and PIN.
  void clearAll() {
    _profile = defaultProfile;
    _language = AppLanguage.en;
    _themeMode = AppThemeMode.light;
    _categories.clear();
    _categories.addAll(defaultCategories);
    _legalClauses = defaultLegalClauses;
    _pinEnabled = false;
    _pin = null;
    _biometricsEnabled = false;
    _sessions.clear();
    _googleConnected = false;
    _notifications = defaultNotificationPrefs;
    _supportTickets.clear();
    _password = 'demo123';
    notifyListeners();
  }

  /// Alias for [clearAll].
  void reset() => clearAll();
}
