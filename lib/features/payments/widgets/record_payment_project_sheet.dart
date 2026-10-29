import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../record_payment_strings.dart';

/// Opens the Select Project bottom sheet (PY11) listing only projects for [client].
Future<String?> showRecordPaymentProjectSheet({
  required BuildContext context,
  required ProjectsRepository projectsRepo,
  required Client client,
  required String? selectedProjectId,
}) {
  final List<ProjectItem> clientProjects = projectsRepo.projects
      .where((ProjectItem p) => p.clientId == client.id)
      .toList(growable: false);

  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return _RecordPaymentProjectSheetContent(
        projectsRepo: projectsRepo,
        client: client,
        projects: clientProjects,
        initialSelectedProjectId: selectedProjectId,
      );
    },
  );
}

class _RecordPaymentProjectSheetContent extends StatefulWidget {
  const _RecordPaymentProjectSheetContent({
    required this.projectsRepo,
    required this.client,
    required this.projects,
    required this.initialSelectedProjectId,
  });

  final ProjectsRepository projectsRepo;
  final Client client;
  final List<ProjectItem> projects;
  final String? initialSelectedProjectId;

  @override
  State<_RecordPaymentProjectSheetContent> createState() =>
      _RecordPaymentProjectSheetContentState();
}

class _RecordPaymentProjectSheetContentState
    extends State<_RecordPaymentProjectSheetContent> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedProjectId;
    if (_selectedId == null && widget.projects.isNotEmpty) {
      // If none selected, default to the first one or keep null until tapped
      // In PY11, top project is selected by default if previously selected
    }
  }

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
        color: isSelected ? AppColors.ink : AppColors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            RecordPaymentStrings.selectProjectTitle,
            style: AppText.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            RecordPaymentStrings.projectsOfClient(widget.client.name),
            style: AppText.body.copyWith(
              color: AppColors.mute,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (widget.projects.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  RecordPaymentStrings.noProjectsForClient,
                  style: AppText.body.copyWith(color: AppColors.mute),
                ),
              ),
            ),
          ] else ...[
            for (int i = 0; i < widget.projects.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _buildProjectRow(widget.projects[i]),
            ],
          ],

          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: RecordPaymentStrings.confirmProject,
            onPressed: _selectedId != null
                ? () => Navigator.of(context).pop(_selectedId)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectRow(ProjectItem project) {
    final bool isSelected = project.id == _selectedId;
    final double remaining = widget.projectsRepo.remaining(project);

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.line : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedId = project.id;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: AppText.cardTitle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.status.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        if (remaining > 0)
                          Text(
                            RecordPaymentStrings.due(formatMoney(remaining)),
                            style: AppText.captionSm.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            RecordPaymentStrings.cleared,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildRadio(isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
