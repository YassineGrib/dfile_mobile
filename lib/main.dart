import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/data/firebase_auth_service.dart';
import 'features/auth/data/user_data_sync.dart';
import 'features/calendar/data/data.dart';
import 'features/clients/data/data.dart';
import 'features/dashboard/data/data.dart';
import 'features/expenses/data/data.dart';
import 'features/friends/data/data.dart';
import 'features/projects/data/data.dart';
import 'features/settings/data/data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  final AuthService auth = FirebaseAuthService();
  UserDataSync(
    auth: auth,
    clients: defaultClientsRepository,
    projects: defaultProjectsRepository,
  ).start();
  final GoRouter router = createAppRouter(
    initialLocation: auth.currentUser != null
        ? AppRoutes.homePath
        : AppRoutes.welcomePath,
  );
  runApp(DfileApp(authService: auth, router: router));
}

class DfileApp extends StatefulWidget {
  const DfileApp({
    super.key,
    this.router,
    this.repository,
    this.projectsRepository,
    this.expensesRepository,
    this.friendsRepository,
    this.settingsRepository,
    this.notificationsStore,
    this.calendarRepository,
    this.authService,
  });

  final GoRouter? router;
  final ClientsRepository? repository;
  final ProjectsRepository? projectsRepository;
  final ExpensesRepository? expensesRepository;
  final FriendsRepository? friendsRepository;
  final SettingsRepository? settingsRepository;
  final NotificationsStore? notificationsStore;
  final CalendarRepository? calendarRepository;
  final AuthService? authService;

  @override
  State<DfileApp> createState() => _DfileAppState();
}

class _DfileAppState extends State<DfileApp> {
  ProjectsRepository? _fallbackProjectsRepository;
  late final AuthService _fallbackAuth = FakeAuthService();

  @override
  void initState() {
    super.initState();
    _ensureFallbackRepository();
  }

  @override
  void didUpdateWidget(covariant DfileApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.projectsRepository != widget.projectsRepository) {
      _fallbackProjectsRepository = null;
      _ensureFallbackRepository();
    }
  }

  void _ensureFallbackRepository() {
    if (widget.projectsRepository == null && widget.repository != null) {
      _fallbackProjectsRepository = ProjectsRepository(
        clientsRepository: widget.repository,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ClientsRepository effectiveClientsRepo =
        widget.repository ??
        widget.projectsRepository?.clientsRepository ??
        defaultClientsRepository;
    final ProjectsRepository effectiveProjectsRepo =
        widget.projectsRepository ??
        _fallbackProjectsRepository ??
        defaultProjectsRepository;
    final ExpensesRepository effectiveExpensesRepo =
        widget.expensesRepository ?? defaultExpensesRepository;
    final FriendsRepository effectiveFriendsRepo =
        widget.friendsRepository ?? defaultFriendsRepository;
    final SettingsRepository effectiveSettingsRepo =
        widget.settingsRepository ?? defaultSettingsRepository;
    final NotificationsStore effectiveNotificationsStore =
        widget.notificationsStore ?? defaultNotificationsStore;
    final CalendarRepository effectiveCalendarRepo =
        widget.calendarRepository ?? defaultCalendarRepository;

    return AuthScope(
      service: widget.authService ?? _fallbackAuth,
      child: ClientsScope(
        repository: effectiveClientsRepo,
        child: ProjectsScope(
          repository: effectiveProjectsRepo,
          child: ExpensesScope(
            repository: effectiveExpensesRepo,
            child: FriendsScope(
              repository: effectiveFriendsRepo,
              child: SettingsScope(
                repository: effectiveSettingsRepo,
                child: CalendarScope(
                  repository: effectiveCalendarRepo,
                  child: NotificationsScope(
                    store: effectiveNotificationsStore,
                    child: MaterialApp.router(
                      title: 'Dfile',
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light,
                      routerConfig: widget.router ?? appRouter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final ClientsRepository defaultClientsRepository = ClientsRepository();
final ProjectsRepository defaultProjectsRepository = ProjectsRepository(
  clientsRepository: defaultClientsRepository,
);
final ExpensesRepository defaultExpensesRepository = ExpensesRepository();
final FriendsRepository defaultFriendsRepository = FriendsRepository();
final SettingsRepository defaultSettingsRepository = SettingsRepository();
final NotificationsStore defaultNotificationsStore = NotificationsStore();
final CalendarRepository defaultCalendarRepository = CalendarRepository();
