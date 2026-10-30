import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../projects/data/data.dart';
import 'calendar_forms_strings.dart';
import 'data/data.dart';
import 'widgets/calendar_forms_bottom_bar.dart';
import 'widgets/calendar_forms_project_sheet.dart';
import 'widgets/calendar_forms_select_field.dart';

/// Milestone creation form per `docs/design/SPEC.md` (CL8-CL10).
class MilestoneFormScreen extends StatefulWidget {
  const MilestoneFormScreen({
    super.key,
    this.projectId,
    this.date,
    this.clock,
  });

  final String? projectId;
  final String? date;
  final DateTime Function()? clock;

  static DateTime Function() defaultClock = DateTime.now;

  @override
  State<MilestoneFormScreen> createState() => _MilestoneFormScreenState();
}

class _MilestoneFormScreenState extends State<MilestoneFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  String? _selectedProjectId;
  DateTime? _dueDate;

  bool _initialized = false;
  bool _saveAttempted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        _selectedProjectId = widget.projectId;
      }
      if (widget.date != null && widget.date!.isNotEmpty) {
        final DateTime? parsed = DateTime.tryParse(widget.date!);
        if (parsed != null) {
          _dueDate = DateUtils.dateOnly(parsed);
        }
      }
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant MilestoneFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.date != widget.date) {
      _initialized = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/calendar');
    }
  }

  Future<void> _pickProject(
    ProjectsRepository projectsRepo,
    ClientsRepository clientsRepo,
  ) async {
    final String? result = await showMilestoneProjectSheet(
      context: context,
      projectsRepo: projectsRepo,
      clientsRepo: clientsRepo,
      selectedProjectId: _selectedProjectId,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedProjectId = result;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final DateTime now = (widget.clock ?? MilestoneFormScreen.defaultClock)();
    final DateTime initial = _dueDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _onSave(CalendarRepository calendarRepo) {
    setState(() {
      _saveAttempted = true;
    });

    if (_selectedProjectId == null ||
        _titleController.text.trim().isEmpty ||
        _dueDate == null) {
      return;
    }

    final DateTime now = (widget.clock ?? MilestoneFormScreen.defaultClock)();
    final String uniqueId = 'm_${DateTime.now().microsecondsSinceEpoch}';
    final Milestone milestone = Milestone(
      id: uniqueId,
      projectId: _selectedProjectId!,
      title: _titleController.text.trim(),
      date: _dueDate!,
      completed: false,
      createdAt: now,
    );
    calendarRepo.addMilestone(milestone);

    final String dateParam = formatDateYyyyMmDd(_dueDate!);
    context.go(
      '/calendar?date=$dateParam',
      extra: <String, Object?>{
        'toast': CalendarFormsStrings.milestoneRegisteredToast,
      },
    );
  }

  String _formatDisplayDate(DateTime dt) {
    const List<String> weekdays = <String>[
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CalendarFormsStrings.newMilestoneTitle,
                style: AppText.sectionTitleLg,
              ),
              const SizedBox(height: 4),
              Text(
                CalendarFormsStrings.newMilestoneSubtitle,
                style: AppText.body.copyWith(
                  color: AppColors.mute,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        RoundIconButton(
          icon: AppIcons.x,
          onPressed: _close,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final CalendarRepository calendarRepo = CalendarScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);

    final ProjectItem? selectedProject = _selectedProjectId != null
        ? projectsRepo.byId(_selectedProjectId!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: CalendarFormsBottomBar(
        secondaryLabel: CalendarFormsStrings.cancel,
        onSecondaryPressed: _close,
        primaryLabel: CalendarFormsStrings.registerMilestone,
        onPrimaryPressed: () => _onSave(calendarRepo),
      ),
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
              _buildTopHeader(),
              const SizedBox(height: AppSpacing.xxl),

              // 1. Project selector
              CalendarFormsSelectField(
                label: CalendarFormsStrings.projectLabel,
                placeholder: CalendarFormsStrings.selectProjectPlaceholder,
                value: selectedProject?.name,
                onTap: () => _pickProject(projectsRepo, clientsRepo),
                trailing: const Icon(
                  AppIcons.chevronDown,
                  size: 20,
                  color: AppColors.mute,
                ),
                hasError: _saveAttempted && _selectedProjectId == null,
                errorText: CalendarFormsStrings.projectRequiredError,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Title field
              AppTextField(
                label: CalendarFormsStrings.milestoneTitleLabel,
                placeholder: CalendarFormsStrings.milestoneTitlePlaceholder,
                controller: _titleController,
                focusNode: _titleFocusNode,
                errorText: _saveAttempted && _titleController.text.trim().isEmpty
                    ? CalendarFormsStrings.titleRequiredError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Due date selector
              CalendarFormsSelectField(
                label: CalendarFormsStrings.dueDateLabel,
                placeholder: CalendarFormsStrings.pickDatePlaceholder,
                value: _dueDate != null ? _formatDisplayDate(_dueDate!) : null,
                onTap: _pickDueDate,
                trailing: const Icon(
                  AppIcons.calendarDays,
                  size: 20,
                  color: AppColors.mute,
                ),
                hasError: _saveAttempted && _dueDate == null,
                errorText: CalendarFormsStrings.dueDateRequiredError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
