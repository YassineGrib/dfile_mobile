import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'project_strings.dart';

/// Placeholder screen for `/projects/:id/edit` (form implemented in Task 4B).
class EditProjectScreen extends StatelessWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.projectsPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final ProjectItem? project = repo.byId(projectId);

    if (project == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ProjectStrings.projectNotFound,
                  style: AppText.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: ProjectStrings.backToProjects,
                  onPressed: () => context.go(AppRoutes.projectsPath),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      ProjectStrings.editProjectTitle,
                      style: AppText.sectionTitleLg,
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.close,
                    onPressed: () => _close(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                project.name,
                style: AppText.cardTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProjectStrings.formPlaceholderSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
              const Spacer(),
              SecondaryButton(
                label: ProjectStrings.cancel,
                onPressed: () => _close(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
