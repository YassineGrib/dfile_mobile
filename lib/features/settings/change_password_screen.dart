import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'widgets/settings_header.dart';

/// Screen for changing account password (Agent A).
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

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
                title: 'ChangePasswordScreen',
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.settingsPath),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'ChangePasswordScreen',
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
