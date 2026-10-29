import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/clients/data/data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const DfileApp());
}

class DfileApp extends StatelessWidget {
  const DfileApp({
    super.key,
    this.router,
    this.repository,
  });

  final GoRouter? router;
  final ClientsRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ClientsScope(
      repository: repository ?? defaultClientsRepository,
      child: MaterialApp.router(
        title: 'Dfile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router ?? appRouter,
      ),
    );
  }
}

final ClientsRepository defaultClientsRepository = ClientsRepository();
