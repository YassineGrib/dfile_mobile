import 'package:flutter_test/flutter_test.dart';

import 'package:dfile_mobile/features/settings/data/data.dart';

Future<void> settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

const UserProfile seed = UserProfile(
  name: 'Seed Name',
  designation: '',
  email: 'seed@mail.co',
  phone: '',
  address: '',
);

void main() {
  group('settings document mapping', () {
    test('reads the web workspace document', () {
      final SettingsSnapshot s = settingsFromMap(<String, Object?>{
        'profile': <String, Object?>{
          'name': 'Yassine',
          'designation': 'Designer',
          'email': 'y@x.co',
          'phone': '0550',
          'address': 'Algiers',
        },
        'categories': <Object?>['Web', 'Logo', 7],
        'contract_clauses': '1. Pay on time',
        'notifications': <String, Object?>{
          'push_enabled': false,
          'notify_deadlines': true,
          'notify_payments': false,
          'notify_tasks': true,
        },
        'theme_mode': 'dark',
        'security': <String, Object?>{'pin_hash': 'abc'},
      });
      expect(s.profile!.name, 'Yassine');
      expect(s.categories, <String>['Web', 'Logo']);
      expect(s.legalClauses, '1. Pay on time');
      expect(s.notifications!.push, isFalse);
      expect(s.notifications!.tasks, isTrue);
    });

    test('a sparse document leaves fields null', () {
      final SettingsSnapshot s = settingsFromMap(<String, Object?>{});
      expect(s.profile, isNull);
      expect(s.categories, isNull);
      expect(s.notifications, isNull);
    });

    test('a partial profile falls back to the seed per field', () {
      final SettingsSnapshot s = settingsFromMap(<String, Object?>{
        'profile': <String, Object?>{'name': 'Web Name'},
      }, profileFallback: seed);
      expect(s.profile!.name, 'Web Name');
      expect(s.profile!.email, 'seed@mail.co');
    });

    test('writes use the web field names', () {
      expect(profileToMap(seed)['designation'], '');
      final Map<String, Object?> n = notificationsToMap(
        const NotificationPrefs(
          push: true,
          deadlines: false,
          payments: true,
          tasks: false,
        ),
      );
      expect(n['push_enabled'], true);
      expect(n['notify_deadlines'], false);
      expect(n['notify_payments'], true);
      expect(n['notify_tasks'], false);
    });
  });

  group('SettingsRepository with a store', () {
    test(
      'seeds the profile and defaults while the document is empty',
      () async {
        final SettingsRepository repo = SettingsRepository();
        repo.attachStore(FakeSettingsStore(), seedProfile: seed);
        expect(repo.isLoading, isTrue);
        await settle();

        expect(repo.isLoading, isFalse);
        expect(repo.profile.name, 'Seed Name');
        expect(repo.categories, SettingsRepository.defaultCategories);
      },
    );

    test('follows the document and writes through', () async {
      final SettingsRepository repo = SettingsRepository();
      final FakeSettingsStore store = FakeSettingsStore(
        const SettingsSnapshot(
          categories: <String>['Web'],
          legalClauses: 'Terms',
        ),
      );
      repo.attachStore(store, seedProfile: seed);
      await settle();
      expect(repo.categories, <String>['Web']);
      expect(repo.legalClauses, 'Terms');

      repo.addCategory('Logo');
      repo.removeCategory('Web');
      repo.setLegalClauses('New terms');
      repo.updateProfile(seed.copyWith(name: 'Edited'));
      repo.updateNotifications(
        SettingsRepository.defaultNotificationPrefs.copyWith(tasks: true),
      );
      await settle();

      expect(store.log, <String>[
        'categories',
        'categories',
        'clauses',
        'profile',
        'notifications',
      ]);
      expect(repo.categories, <String>['Logo']);
      expect(repo.profile.name, 'Edited');
    });

    test('detach resets to defaults and stops writing', () async {
      final SettingsRepository repo = SettingsRepository();
      final FakeSettingsStore store = FakeSettingsStore();
      repo.attachStore(store, seedProfile: seed);
      await settle();

      repo.detachStore();
      expect(repo.profile, SettingsRepository.defaultProfile);
      repo.addCategory('Offline');
      await settle();
      expect(store.log, isEmpty);
    });

    test('device-only settings are not written', () async {
      final SettingsRepository repo = SettingsRepository();
      final FakeSettingsStore store = FakeSettingsStore();
      repo.attachStore(store);
      await settle();

      repo.setPin('1234');
      repo.setBiometrics(true);
      repo.setThemeMode(AppThemeMode.light);
      repo.setLanguage(AppLanguage.en);
      await settle();
      expect(store.log, isEmpty);
    });
  });
}
