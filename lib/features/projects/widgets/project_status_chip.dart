import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../data/project.dart';

/// Coloured stadium pill displaying a [ProjectStatus] per `docs/design/SPEC.md`.
class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final ProjectStatus status;

  (Color bg, Color fg) get _colors {
    switch (status) {
      case ProjectStatus.planned:
        return (AppColors.plannedBg, AppColors.mute);
      case ProjectStatus.inProgress:
        return (AppColors.inProgressBg, AppColors.orange);
      case ProjectStatus.waitingClient:
        return (AppColors.waitingClientBg, AppColors.purple);
      case ProjectStatus.completed:
        return (AppColors.greenBg, AppColors.green);
      case ProjectStatus.delivered:
        return (AppColors.ink, AppColors.white);
      case ProjectStatus.cancelled:
        return (AppColors.redBg, AppColors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        softWrap: false,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Neutral stadium chip displaying a project category (`Development`, `Design`, etc.).
class ProjectCategoryChip extends StatelessWidget {
  const ProjectCategoryChip({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.captionSm.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Coloured stadium pill displaying a [TaskStatus] on the Tasks tab (P6).
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status});

  final TaskStatus status;

  (Color bg, Color fg) get _colors {
    switch (status) {
      case TaskStatus.nextUp:
        return (AppColors.plannedBg, AppColors.mute);
      case TaskStatus.inProgress:
        return (AppColors.inProgressBg, AppColors.orange);
      case TaskStatus.complete:
        return (AppColors.greenBg, AppColors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        softWrap: false,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
