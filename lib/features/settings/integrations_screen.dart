import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'widgets/settings_header.dart';

/// Screen for managing cloud sync, integrations, and backup (Agent D).
class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: Column(
            children: [
              SettingsHeader(
                title: 'IntegrationsScreen',
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.settingsPath),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'IntegrationsScreen',
                    style: AppText.title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
