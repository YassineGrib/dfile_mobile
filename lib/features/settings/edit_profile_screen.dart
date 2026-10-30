import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'widgets/settings_header.dart';

/// Screen for editing user profile (Agent A).
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
                title: 'EditProfileScreen',
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.settingsPath),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'EditProfileScreen',
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
