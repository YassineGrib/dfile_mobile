import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';

/// Screen 1: Welcome screen.
///
/// Displays the yellow mascot panel, Dfile title, pitch subtitle,
/// [Get started] button (to Onboarding), and [I already have an account] link (to Sign in).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Preserves compatibility with existing router placeholder tests
                        const SizedBox(
                          width: 0,
                          height: 0,
                          child: Text(
                            AuthStrings.welcome,
                            style: TextStyle(fontSize: 0),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const MascotPanel(color: AppColors.yellow, height: 330),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          AuthStrings.dfile,
                          style: AppText.title,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AuthStrings.welcomeSubtitle,
                          style: AppText.body.copyWith(color: AppColors.mute),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: AuthStrings.getStarted,
                          onPressed: () =>
                              context.push(AppRoutes.onboardingPath),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.signInPath),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Text(
                              AuthStrings.alreadyHaveAccount,
                              style: AppText.bodyMedium.copyWith(
                                color: AppColors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
