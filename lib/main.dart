import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/clients/data/data.dart';
import 'features/expenses/data/data.dart';
import 'features/friends/data/data.dart';
import 'features/projects/data/data.dart';
import 'features/settings/data/data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const DfileApp());
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
  });

  final GoRouter? router;
  final ClientsRepository? repository;
  final ProjectsRepository? projectsRepository;
  final ExpensesRepository? expensesRepository;
  final FriendsRepository? friendsRepository;
  final SettingsRepository? settingsRepository;

  @override
  State<DfileApp> createState() => _DfileAppState();
}

class _DfileAppState extends State<DfileApp> {
  ProjectsRepository? _fallbackProjectsRepository;

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

    return ClientsScope(
      repository: effectiveClientsRepo,
      child: ProjectsScope(
        repository: effectiveProjectsRepo,
        child: ExpensesScope(
          repository: effectiveExpensesRepo,
          child: FriendsScope(
            repository: effectiveFriendsRepo,
            child: SettingsScope(
              repository: effectiveSettingsRepo,
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
