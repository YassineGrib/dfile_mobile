import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../settings/data/data.dart';
import 'data/data.dart';
import 'project_strings.dart';
import 'widgets/project_form_fields.dart';
import 'widgets/project_step_indicator.dart';

/// 4-step wizard screen for `/projects/new` matching screens P12..P16.
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  int _currentStep = 0;

  // Step 1: Details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _category = ProjectStrings.categoryDevelopment;
  bool _categoryInitialized = false;

  // Step 2: Client & Cost
  String? _selectedClientId;
  bool _isQuickAddClient = false;
  final TextEditingController _quickClientNameController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // Step 3: Tasks
  final TextEditingController _taskInputController = TextEditingController();
  final List<String> _draftTasks = <String>[];

  // Step 4: Status & Dates
  ProjectStatus _status = ProjectStatus.planned;
  int _progress = 0;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    _startDate = today;
    _endDate = today.add(const Duration(days: 30));

    _nameController.addListener(_onFieldChanged);
    _budgetController.addListener(_onFieldChanged);
    _quickClientNameController.addListener(_onFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_categoryInitialized) {
      _categoryInitialized = true;
      try {
        final List<String> categories = SettingsScope.of(
          context,
          listen: false,
        ).categories;
        if (categories.isNotEmpty) {
          _category = categories.first;
        }
      } catch (_) {
        // Fallback to default
      }
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _budgetController.removeListener(_onFieldChanged);
    _quickClientNameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _quickClientNameController.dispose();
    _budgetController.dispose();
    _taskInputController.dispose();
    super.dispose();
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return ProjectStrings.wizardStep1Subtitle;
      case 1:
        return ProjectStrings.wizardStep2Subtitle;
      case 2:
        return ProjectStrings.wizardStep3Subtitle;
      default:
        return ProjectStrings.wizardStep4Subtitle;
    }
  }

  int? get _parsedBudget {
    final String raw = _budgetController.text.replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  bool get _isStep1Valid => _nameController.text.trim().isNotEmpty;

  bool _isStep2Valid(ClientsRepository clientsRepo) {
    if (_isQuickAddClient) {
      return false;
    }
    if (_selectedClientId == null ||
        clientsRepo.byId(_selectedClientId!) == null) {
      return false;
    }
    final int? budget = _parsedBudget;
    return budget != null && budget > 0;
  }

  bool get _isDeadlineBeforeStart =>
      DateUtils.dateOnly(_endDate).isBefore(DateUtils.dateOnly(_startDate));

  bool _canAdvance(ClientsRepository clientsRepo) {
    switch (_currentStep) {
      case 0:
        return _isStep1Valid;
      case 1:
        return _isStep2Valid(clientsRepo);
      case 2:
        return true;
      default:
        return _isStep1Valid &&
            _isStep2Valid(clientsRepo) &&
            !_isDeadlineBeforeStart;
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.projectsPath);
    }
  }

  Future<void> _pickCategory() async {
    List<String>? categories;
    try {
      categories = SettingsScope.of(context, listen: false).categories;
    } catch (_) {
      // Fallback
    }
    final String? picked = await showCategoryPickerSheet(
      context: context,
      selectedCategory: _category,
      categories: categories,
    );
    if (picked != null && mounted) {
      setState(() => _category = picked);
    }
  }

  Future<void> _pickClient(ClientsRepository clientsRepo) async {
    final String? pickedId = await showClientPickerSheet(
      context: context,
      clients: clientsRepo.clients,
      selectedClientId: _selectedClientId,
    );
    if (pickedId != null && mounted) {
      setState(() => _selectedClientId = pickedId);
    }
  }

  void _handleQuickAddClient(ClientsRepository clientsRepo) {
    final String name = _quickClientNameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    final String newId = 'c_${DateTime.now().microsecondsSinceEpoch}';
    final int nextColorIndex = clientsRepo.clients.length % 4;
    final Client created = Client(
      id: newId,
      name: name,
      createdAt: DateTime.now(),
      avatarColorIndex: nextColorIndex,
    );
    clientsRepo.add(created);
    setState(() {
      _selectedClientId = created.id;
      _quickClientNameController.clear();
      _isQuickAddClient = false;
    });
  }

  void _addDraftTask() {
    final String text = _taskInputController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _draftTasks.add(text);
      _taskInputController.clear();
    });
  }

  void _removeDraftTask(int index) {
    setState(() {
      _draftTasks.removeAt(index);
    });
  }

  Future<void> _pickStatus() async {
    final ProjectStatus? picked = await showStatusPickerSheet(
      context: context,
      selectedStatus: _status,
    );
    if (picked != null && mounted) {
      setState(() {
        _status = picked;
        if (picked.forcesFullProgress) {
          _progress = 100;
        }
      });
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = DateUtils.dateOnly(picked);
      });
    }
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _onPrimaryAction(
    ClientsRepository clientsRepo,
    ProjectsRepository projectsRepo,
  ) {
    if (!_canAdvance(clientsRepo)) {
      return;
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    // Step 4: Save project and tasks
    final String projectId = 'p_${DateTime.now().microsecondsSinceEpoch}';
    final ProjectItem newProject = ProjectItem(
      id: projectId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      clientId: _selectedClientId!,
      price: _parsedBudget!.toDouble(),
      status: _status,
      progress: _progress,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: DateTime.now(),
    );

    final List<ProjectTask> createdTasks = List<ProjectTask>.generate(
      _draftTasks.length,
      (int i) => ProjectTask(
        id: 't_${projectId}_${i + 1}',
        projectId: projectId,
        name: _draftTasks[i],
        status: TaskStatus.nextUp,
      ),
    );

    projectsRepo.add(newProject, tasks: createdTasks);
    showAppToast(context, ProjectStrings.projectAddedToast);
    _close();
  }

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ProjectStrings.addNewProjectTitle, style: AppText.title),
              const SizedBox(height: 4),
              Text(
                _stepSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        RoundIconButton(icon: Icons.close_rounded, onPressed: _close),
      ],
    );
  }

  Widget _buildHintBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.seg,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
      ),
      child: Text(
        message,
        style: AppText.bodyMedium.copyWith(color: AppColors.mute, height: 1.4),
      ),
    );
  }

  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: ProjectStrings.projectNameLabel,
          placeholder: ProjectStrings.projectNamePlaceholder,
          controller: _nameController,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProjectSelectField(
          label: ProjectStrings.categoryLabel,
          value: _category,
          onTap: _pickCategory,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: ProjectStrings.descriptionLabel,
          placeholder: ProjectStrings.descriptionPlaceholder,
          controller: _descriptionController,
          multiline: true,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildStep2ClientAndCost(ClientsRepository clientsRepo) {
    final Client? selectedClient = _selectedClientId != null
        ? clientsRepo.byId(_selectedClientId!)
        : null;
    final bool canAddQuickClient = _quickClientNameController.text
        .trim()
        .isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                ProjectStrings.clientRequiredLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.label,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              onTap: () => setState(() {
                _isQuickAddClient = !_isQuickAddClient;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Text(
                  _isQuickAddClient
                      ? ProjectStrings.selectClientToggle
                      : ProjectStrings.quickAddClientToggle,
                  style: AppText.label.copyWith(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_isQuickAddClient) ...[
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  placeholder: ProjectStrings.quickAddClientPlaceholder,
                  controller: _quickClientNameController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleQuickAddClient(clientsRepo),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                height: AppSpacing.inputHeight,
                child: Material(
                  color: canAddQuickClient
                      ? AppColors.ink
                      : AppColors.ink.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: canAddQuickClient
                        ? () => _handleQuickAddClient(clientsRepo)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Center(
                        child: Text(
                          ProjectStrings.addAction,
                          style: AppText.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ProjectStrings.quickAddClientHint,
            style: AppText.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: ProjectStrings.projectBudgetRequiredLabel,
            placeholder: ProjectStrings.budgetPlaceholder,
            controller: _budgetController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ] else ...[
          ProjectSelectField(
            value: selectedClient?.name,
            placeholder: ProjectStrings.selectClientPlaceholder,
            leading: selectedClient != null
                ? InitialAvatar(
                    initial: selectedClient.name,
                    color: projectClientAvatarColor(
                      selectedClient.avatarColorIndex,
                    ),
                    size: 34,
                  )
                : null,
            onTap: () => _pickClient(clientsRepo),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: ProjectStrings.projectBudgetRequiredLabel,
            placeholder: ProjectStrings.budgetPlaceholder,
            controller: _budgetController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildHintBox(ProjectStrings.budgetHint),
        ],
      ],
    );
  }

  Widget _buildStep3Tasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ProjectStrings.addSubTasksLabel, style: AppText.label),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                placeholder: ProjectStrings.subTaskPlaceholder,
                controller: _taskInputController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addDraftTask(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: AppSpacing.inputHeight,
              height: AppSpacing.inputHeight,
              child: Material(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.input),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _addDraftTask,
                  child: const Center(
                    child: Icon(Icons.add, size: 26, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_draftTasks.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < _draftTasks.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            Container(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.inputHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 10,
              ),
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
                  Text(
                    ProjectStrings.taskIndexLabel(i),
                    style: AppText.bodyBold.copyWith(
                      fontSize: 14,
                      color: AppColors.mute,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _draftTasks[i],
                      style: AppText.bodyBold.copyWith(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _removeDraftTask(i),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStep4StatusAndDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProjectSelectField(
          label: ProjectStrings.projectStatusLabel,
          value: _status.label,
          onTap: _pickStatus,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProjectProgressSlider(
          label: ProjectStrings.progressPercentageLabel,
          progress: _progress,
          onChanged: (int value) => setState(() => _progress = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProjectSelectField(
                label: ProjectStrings.startDateLabel,
                value: formatMediumDate(_startDate),
                showArrow: false,
                onTap: _pickStartDate,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ProjectSelectField(
                label: ProjectStrings.deadlineLabel,
                value: formatMediumDate(_endDate),
                showArrow: false,
                hasError: _isDeadlineBeforeStart,
                onTap: _pickDeadline,
              ),
            ),
          ],
        ),
        if (_isDeadlineBeforeStart) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            ProjectStrings.deadlineBeforeStartError,
            style: AppText.captionSm.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _buildHintBox(ProjectStrings.statusAutoProgressHint),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final bool canAdvance = _canAdvance(clientsRepo);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: ProjectFormBottomBar(
        secondaryLabel: _currentStep > 0 ? ProjectStrings.back : null,
        onSecondaryPressed: _currentStep > 0
            ? () => setState(() => _currentStep--)
            : null,
        primaryLabel: _currentStep == 3
            ? ProjectStrings.saveProject
            : ProjectStrings.next,
        onPrimaryPressed: canAdvance
            ? () => _onPrimaryAction(clientsRepo, projectsRepo)
            : null,
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
              const SizedBox(height: AppSpacing.xl),
              ProjectStepIndicator(
                currentStep: _currentStep,
                labels: const <String>[
                  ProjectStrings.stepDetails,
                  ProjectStrings.stepClientAndCost,
                  ProjectStrings.stepTasks,
                  ProjectStrings.stepStatus,
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_currentStep == 0)
                _buildStep1Details()
              else if (_currentStep == 1)
                _buildStep2ClientAndCost(clientsRepo)
              else if (_currentStep == 2)
                _buildStep3Tasks()
              else
                _buildStep4StatusAndDates(),
            ],
          ),
        ),
      ),
    );
  }
}
