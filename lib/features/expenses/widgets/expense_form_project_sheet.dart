import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../expense_form_strings.dart';

/// Wraps the chosen project ID (or `null` for General business cost) so that
/// confirming `null` is distinguishable from dismissing the modal bottom sheet.
class ExpenseProjectSelection {
  const ExpenseProjectSelection(this.projectId);
  final String? projectId;
}

/// Opens the Link Project bottom sheet (EX11) listing General business cost + every project.
Future<ExpenseProjectSelection?> showExpenseFormProjectSheet({
  required BuildContext context,
  required ProjectsRepository projectsRepo,
  required ClientsRepository clientsRepo,
  required String? selectedProjectId,
}) {
  return showAppSheet<ExpenseProjectSelection>(
    context: context,
    builder: (BuildContext sheetContext) {
      return ExpenseFormProjectSheetContent(
        projectsRepo: projectsRepo,
        clientsRepo: clientsRepo,
        selectedProjectId: selectedProjectId,
      );
    },
  );
}

class ExpenseFormProjectSheetContent extends StatefulWidget {
  const ExpenseFormProjectSheetContent({
    super.key,
    required this.projectsRepo,
    required this.clientsRepo,
    required this.selectedProjectId,
  });

  final ProjectsRepository projectsRepo;
  final ClientsRepository clientsRepo;
  final String? selectedProjectId;

  @override
  State<ExpenseFormProjectSheetContent> createState() =>
      _ExpenseFormProjectSheetContentState();
}

class _ExpenseFormProjectSheetContentState
    extends State<ExpenseFormProjectSheetContent> {
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
    final List<ProjectItem> projects = widget.projectsRepo.projects;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExpenseFormStrings.linkProjectSheetTitle,
            style: AppText.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            ExpenseFormStrings.linkProjectSheetSubtitle,
            style: AppText.body.copyWith(color: AppColors.mute, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Option 1: General business cost
          _buildOptionCard(
            title: ExpenseFormStrings.generalBusinessCost,
            subtitle: ExpenseFormStrings.notLinkedSubtitle,
            isSelected: _selectedId == null,
            onTap: () {
              setState(() {
                _selectedId = null;
              });
            },
          ),

          // Options 2..N: Every project with client name
          for (final ProjectItem project in projects) ...[
            const SizedBox(height: 12),
            _buildOptionCard(
              title: project.name,
              subtitle: widget.clientsRepo.byId(project.clientId)?.name ?? '',
              isSelected: _selectedId == project.id,
              onTap: () {
                setState(() {
                  _selectedId = project.id;
                });
              },
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: ExpenseFormStrings.confirm,
            onPressed: () {
              Navigator.of(context).pop(ExpenseProjectSelection(_selectedId));
            },
          ),
        ],
      ),
    );
  }
}
