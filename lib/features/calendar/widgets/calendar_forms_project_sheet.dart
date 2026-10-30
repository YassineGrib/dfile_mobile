import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../calendar_forms_strings.dart';

/// Opens the Select Project bottom sheet (CL10) listing every non-Cancelled project.
Future<String?> showMilestoneProjectSheet({
  required BuildContext context,
  required ProjectsRepository projectsRepo,
  required ClientsRepository clientsRepo,
  required String? selectedProjectId,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return CalendarFormsProjectSheetContent(
        projectsRepo: projectsRepo,
        clientsRepo: clientsRepo,
        selectedProjectId: selectedProjectId,
      );
    },
  );
}

class CalendarFormsProjectSheetContent extends StatefulWidget {
  const CalendarFormsProjectSheetContent({
    super.key,
    required this.projectsRepo,
    required this.clientsRepo,
    required this.selectedProjectId,
  });

  final ProjectsRepository projectsRepo;
  final ClientsRepository clientsRepo;
  final String? selectedProjectId;

  @override
  State<CalendarFormsProjectSheetContent> createState() =>
      _CalendarFormsProjectSheetContentState();
}

class _CalendarFormsProjectSheetContentState
    extends State<CalendarFormsProjectSheetContent> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedProjectId;
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

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: const BorderSide(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.bodyBold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppText.captionSm.copyWith(color: AppColors.mute),
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

  @override
  Widget build(BuildContext context) {
    // Only non-cancelled projects per SPEC.md (CL8/CL10)
    final List<ProjectItem> projects = widget.projectsRepo.projects
        .where((ProjectItem p) => p.status != ProjectStatus.cancelled)
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  CalendarFormsStrings.selectProjectSheetTitle,
                  style: AppText.sectionTitle,
                ),
              ),
              const Icon(
                AppIcons.calendarDays,
                size: 20,
                color: AppColors.mute,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          for (final ProjectItem project in projects) ...[
            Builder(
              builder: (BuildContext context) {
                final String clientName =
                    widget.clientsRepo.byId(project.clientId)?.name ?? '';
                final String subtitle = clientName.isNotEmpty
                    ? '$clientName  -  ${project.status.label}'
                    : project.status.label;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOptionCard(
                    title: project.name,
                    subtitle: subtitle,
                    isSelected: _selectedId == project.id,
                    onTap: () {
                      setState(() {
                        _selectedId = project.id;
                      });
                    },
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: CalendarFormsStrings.confirm,
            onPressed: () {
              Navigator.of(context).pop(_selectedId);
            },
          ),
        ],
      ),
    );
  }
}
