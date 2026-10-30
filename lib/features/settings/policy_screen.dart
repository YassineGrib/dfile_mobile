import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import 'data/policy_kind.dart';
import 'widgets/settings_header.dart';

/// Screen displaying either Privacy Policy or Terms & Conditions (Agent D).
class PolicyScreen extends StatelessWidget {
  const PolicyScreen({
    super.key,
    required this.kind,
  });

  final PolicyKind kind;

  @override
  Widget build(BuildContext context) {
    final String title = kind == PolicyKind.privacy
        ? 'Privacy Policy'
        : 'Terms and Conditions';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: Column(
            children: [
              SettingsHeader(
                title: title,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.settingsPath),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'PolicyScreen',
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
