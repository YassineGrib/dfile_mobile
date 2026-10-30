import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import 'data/data.dart';
import 'project_strings.dart';
import 'widgets/project_status_chip.dart';
import 'widgets/record_payment_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _newTaskController = TextEditingController();
  int _selectedTab = 0; // 0: Overview, 1: Tasks, 2: Payments

  static const List<Color> _avatarColors = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  Color _avatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  void _popOrGoProjects() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.projectsPath);
    }
  }

  void _submitNewTask(ProjectsRepository repo, String projectId) {
    final String text = _newTaskController.text.trim();
    if (text.isEmpty) {
      return;
    }
    repo.addTask(projectId, text);
    _newTaskController.clear();
  }

  void _openRecordPaymentSheet(ProjectItem project, String clientName) {
    showRecordPaymentSheet(
      context: context,
      project: project,
      clientName: clientName,
    );
  }

  void _openActionsSheet(
    ProjectItem project,
    ProjectsRepository repo,
    String clientName,
  ) {
    final String initial = project.name.trim().isEmpty
        ? '?'
        : project.name.trim().characters.first.toUpperCase();

    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.seg,
                      borderRadius: BorderRadius.circular(AppRadius.otp),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: AppText.cardTitle.copyWith(
                        fontSize: 20,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: AppText.cardTitle),
                        const SizedBox(height: 2),
                        Text(
                          '$clientName • ${project.status.label}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionItem(
                label: ProjectStrings.actionEditProject,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/projects/${project.id}/edit');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: ProjectStrings.actionChangeStatus,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openChangeStatusSheet(project, repo);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: ProjectStrings.actionAddPayment,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openRecordPaymentSheet(project, clientName);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: ProjectStrings.actionDeleteProject,
                textColor: AppColors.red,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openDeleteConfirmSheet(project, repo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppText.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _openChangeStatusSheet(ProjectItem project, ProjectsRepository repo) {
    ProjectStatus selectedStatus = project.status;

    showAppSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProjectStrings.changeStatusTitle,
                    style: AppText.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (int i = 0; i < ProjectStatus.values.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _buildStatusRadioRow(
                      status: ProjectStatus.values[i],
                      isSelected: selectedStatus == ProjectStatus.values[i],
                      onTap: () => setSheetState(
                        () => selectedStatus = ProjectStatus.values[i],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ProjectStrings.changeStatusNote,
                    style: AppText.caption.copyWith(color: AppColors.mute),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: ProjectStrings.updateStatus,
                    onPressed: () {
                      repo.changeStatus(project.id, selectedStatus);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusRadioRow({
    required ProjectStatus status,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Row(
          children: [
            ProjectStatusChip(status: status),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.ink : AppColors.line,
                  width: 1.5,
                ),
                color: isSelected ? AppColors.ink : AppColors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeleteConfirmSheet(ProjectItem project, ProjectsRepository repo) {
    showAppSheet<void>(
      context: context,
      builder: (BuildContext confirmContext) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ProjectStrings.deleteConfirmTitle,
                          style: AppText.sectionTitle.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ProjectStrings.deleteConfirmSubtitle,
                          style: AppText.caption.copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.2),
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Text(
                  ProjectStrings.deleteConfirmWarning(project.name),
                  style: AppText.bodyMedium.copyWith(
                    color: AppColors.red,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: Material(
                  color: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      repo.delete(project.id);
                      Navigator.of(confirmContext).pop();
                      _popOrGoProjects();
                      showAppToast(context, ProjectStrings.projectDeletedToast);
                    },
                    child: Center(
                      child: Text(
                        ProjectStrings.confirmDelete,
                        style: AppText.button,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: ProjectStrings.cancel,
                onPressed: () => Navigator.of(confirmContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar({
    required VoidCallback onBack,
    required VoidCallback onMore,
  }) {
    return Row(
      children: [
        RoundIconButton(icon: Icons.arrow_back, onPressed: onBack),
        Expanded(
          child: Center(
            child: Text(
              ProjectStrings.projectDetailTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
        ),
        RoundIconButton(icon: Icons.more_horiz, onPressed: onMore),
      ],
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.label,
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: AppText.cardTitle.copyWith(
                  fontSize: 18,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeline(DateTime start, DateTime? end) {
    final String startLabel = formatShortDate(start);
    final String endLabel = end != null ? formatShortDate(end) : '—';
    return '$startLabel → $endLabel';
  }

  Widget _buildOverviewTab(ProjectItem project, ProjectsRepository repo) {
    final double paidAmount = repo.paid(project);
    final double remainingAmount = repo.remaining(project);
    final Color progressColor = project.progress >= 100
        ? AppColors.green
        : AppColors.purple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ProjectStrings.progressLabel,
                      style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                    ),
                  ),
                  Text('${project.progress}%', style: AppText.sectionTitle),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.seg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (project.progress / 100.0).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 2x2 tiles
        Row(
          children: [
            _buildInfoTile(
              label: ProjectStrings.tileBudget,
              value: formatMoney(project.price),
              valueColor: AppColors.ink,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildInfoTile(
              label: ProjectStrings.tilePaid,
              value: formatMoney(paidAmount),
              valueColor: AppColors.green,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildInfoTile(
              label: ProjectStrings.tileRemaining,
              value: formatMoney(remainingAmount),
              valueColor: remainingAmount > 0
                  ? AppColors.orange
                  : AppColors.green,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildInfoTile(
              label: ProjectStrings.tileTimeline,
              value: _formatTimeline(project.startDate, project.endDate),
              valueColor: AppColors.ink,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Description card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProjectStrings.descriptionLabel,
                style: AppText.bodyMedium.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                project.description.trim().isEmpty
                    ? ProjectStrings.noDescription
                    : project.description,
                style: AppText.body.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksTab(ProjectItem project, ProjectsRepository repo) {
    final List<ProjectTask> tasks = repo.tasksOf(project.id);
    final int doneCount = tasks
        .where((ProjectTask t) => t.status.isComplete)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ProjectStrings.tasksChecklistTitle,
                style: AppText.cardTitle,
              ),
            ),
            Text(
              ProjectStrings.tasksDoneCount(doneCount, tasks.length),
              style: AppText.bodyMedium.copyWith(color: AppColors.mute),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                ProjectStrings.noTasksYet,
                style: AppText.bodyMedium.copyWith(color: AppColors.mute),
              ),
            ),
          )
        else
          ...tasks.map((ProjectTask task) {
            final bool isComplete = task.status.isComplete;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    onTap: () => repo.toggleTask(task.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? AppColors.green
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: isComplete
                                  ? null
                                  : Border.all(
                                      color: AppColors.line,
                                      width: AppSpacing.borderWidth,
                                    ),
                            ),
                            alignment: Alignment.center,
                            child: isComplete
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 17,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.name,
                                  style: AppText.bodyBold.copyWith(
                                    fontSize: 16,
                                    color: isComplete
                                        ? AppColors.mute
                                        : AppColors.ink,
                                  ),
                                ),
                                if (task.due != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    ProjectStrings.dueShort(
                                      formatShortDate(task.due!),
                                    ),
                                    style: AppText.caption.copyWith(
                                      color: AppColors.mute,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          TaskStatusChip(status: task.status),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPaymentsTab(ProjectItem project, ProjectsRepository repo) {
    final List<ProjectPayment> payments = repo.paymentsOf(project.id);
    final double paidAmount = repo.paid(project);
    final double paidFraction = repo.paidFraction(project);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paid so far card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProjectStrings.paidSoFar,
                style: AppText.label.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatMoney(paidAmount),
                        maxLines: 1,
                        softWrap: false,
                        style: AppText.sectionTitleLg.copyWith(
                          fontSize: 24,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    ProjectStrings.ofBudget(formatMoney(project.price)),
                    style: AppText.bodyMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.seg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: paidFraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        if (payments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.line,
                width: AppSpacing.borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                ProjectStrings.noPaymentsYet,
                style: AppText.bodyMedium.copyWith(color: AppColors.mute),
              ),
            ),
          )
        else
          ...payments.map((ProjectPayment payment) {
            final String dateStr = formatDate(payment.date);
            final String subtitle = payment.reference.trim().isEmpty
                ? dateStr
                : '$dateStr • ${payment.reference}';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.line,
                    width: AppSpacing.borderWidth,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.greenBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ProjectStrings.paymentReceived,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '+${formatMoney(payment.amount)}',
                      style: AppText.cardTitle.copyWith(
                        fontSize: 17,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ProjectItem project,
    ProjectsRepository repo,
    String clientName,
  ) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: _selectedTab == 1
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          border: Border.all(
                            color: AppColors.line,
                            width: AppSpacing.borderWidth,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _newTaskController,
                          onSubmitted: (_) => _submitNewTask(repo, project.id),
                          style: AppText.body,
                          cursorColor: AppColors.ink,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: ProjectStrings.addNewTaskPlaceholder,
                            hintStyle: AppText.body.copyWith(
                              color: AppColors.placeholder,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Material(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _submitNewTask(repo, project.id),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 24,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : PrimaryButton(
                  label: ProjectStrings.addPaymentWithPlus,
                  onPressed: () => _openRecordPaymentSheet(project, clientName),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final ProjectItem? project = repo.byId(widget.projectId);

    if (project == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.go(AppRoutes.projectsPath),
                ),
                Expanded(
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
              ],
            ),
          ),
        ),
      );
    }

    final Client? client = clientsRepo.byId(project.clientId);
    final String clientName = client?.name ?? ProjectStrings.unknownClient;
    final Color clientColor = _avatarColor(client?.avatarColorIndex ?? 0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _buildBottomBar(context, project, repo, clientName),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(
                onBack: _popOrGoProjects,
                onMore: () => _openActionsSheet(project, repo, clientName),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(project.name, style: AppText.sectionTitleLg),
              const SizedBox(height: 10),

              Row(
                children: [
                  InitialAvatar(
                    initial: clientName,
                    color: clientColor,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ProjectStatusChip(status: project.status),
                  ProjectCategoryChip(category: project.category),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              SegmentedToggle(
                options: const <String>[
                  ProjectStrings.tabOverview,
                  ProjectStrings.tabTasks,
                  ProjectStrings.tabPayments,
                ],
                selectedIndex: _selectedTab,
                onChanged: (int index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_selectedTab == 0)
                _buildOverviewTab(project, repo)
              else if (_selectedTab == 1)
                _buildTasksTab(project, repo)
              else
                _buildPaymentsTab(project, repo),
            ],
          ),
        ),
      ),
    );
  }
}
