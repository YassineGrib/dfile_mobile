import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'project_strings.dart';

/// Placeholder screen for `/projects/new` (wizard forms implemented in Task 4B).
class AddProjectScreen extends StatelessWidget {
  const AddProjectScreen({super.key});

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.projectsPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ProjectStrings.addNewProjectTitle,
                      style: AppText.sectionTitleLg,
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.close,
                    onPressed: () => _close(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProjectStrings.formPlaceholderSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
              const Spacer(),
              SecondaryButton(
                label: ProjectStrings.backToProjects,
                onPressed: () => _close(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
