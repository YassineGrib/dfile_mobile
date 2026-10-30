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

/// Single scrolling form screen for `/projects/:id/edit` matching screen P17.
class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  late final TextEditingController _descriptionController;

  bool _initialized = false;
  ProjectItem? _originalProject;

  String? _selectedClientId;
  String _category = ProjectStrings.categoryDevelopment;
  ProjectStatus _status = ProjectStatus.planned;
  int _progress = 0;
  DateTime _startDate = DateTime(2026, 1, 1);
  DateTime? _endDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final ProjectsRepository repo = ProjectsScope.of(context, listen: false);
      _originalProject = repo.byId(widget.projectId);

      _nameController = TextEditingController(
        text: _originalProject?.name ?? '',
      );
      _budgetController = TextEditingController(
        text: _originalProject != null
            ? _originalProject!.price.round().toString()
            : '',
      );
      _descriptionController = TextEditingController(
        text: _originalProject?.description ?? '',
      );

      if (_originalProject != null) {
        _selectedClientId = _originalProject!.clientId;
        _category = _originalProject!.category;
        _status = _originalProject!.status;
        _progress = _originalProject!.progress;
        _startDate = DateUtils.dateOnly(_originalProject!.startDate);
        _endDate = _originalProject!.endDate != null
            ? DateUtils.dateOnly(_originalProject!.endDate!)
            : null;
      }

      _nameController.addListener(_onFieldChanged);
      _budgetController.addListener(_onFieldChanged);
      _initialized = true;
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameController.removeListener(_onFieldChanged);
      _budgetController.removeListener(_onFieldChanged);
      _nameController.dispose();
      _budgetController.dispose();
      _descriptionController.dispose();
    }
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.projectsPath);
    }
  }

  int? get _parsedBudget {
    final String raw = _budgetController.text.replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  bool get _isDeadlineBeforeStart {
    if (_endDate == null) {
      return false;
    }
    return DateUtils.dateOnly(
      _endDate!,
    ).isBefore(DateUtils.dateOnly(_startDate));
  }

  bool _isValid(ClientsRepository clientsRepo) {
    if (_nameController.text.trim().isEmpty) {
      return false;
    }
    if (_selectedClientId == null ||
        clientsRepo.byId(_selectedClientId!) == null) {
      return false;
    }
    final int? budget = _parsedBudget;
    if (budget == null || budget <= 0) {
      return false;
    }
    if (_isDeadlineBeforeStart) {
      return false;
    }
    return true;
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
      initialDate: _endDate ?? _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _save(ClientsRepository clientsRepo, ProjectsRepository projectsRepo) {
    if (!_isValid(clientsRepo) || _originalProject == null) {
      return;
    }

    final ProjectItem updated = _originalProject!.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      clientId: _selectedClientId!,
      price: _parsedBudget!.toDouble(),
      status: _status,
      progress: _progress,
      startDate: _startDate,
      endDate: _endDate,
      clearEndDate: _endDate == null,
    );

    projectsRepo.update(updated);
    showAppToast(context, ProjectStrings.changesSavedToast);
    _close();
  }

  Widget _buildNotFoundScreen() {
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

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ProjectStrings.editProjectTitle,
                style: AppText.title,
              ),
              const SizedBox(height: 4),
              Text(
                ProjectStrings.editProjectSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        RoundIconButton(
          icon: Icons.close_rounded,
          onPressed: _close,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);

    if (_originalProject == null ||
        projectsRepo.byId(widget.projectId) == null) {
      return _buildNotFoundScreen();
    }

    final Client? selectedClient = _selectedClientId != null
        ? clientsRepo.byId(_selectedClientId!)
        : null;
    final bool isValid = _isValid(clientsRepo);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: ProjectFormBottomBar(
        secondaryLabel: ProjectStrings.cancel,
        onSecondaryPressed: _close,
        primaryLabel: ProjectStrings.saveChanges,
        onPrimaryPressed: isValid
            ? () => _save(clientsRepo, projectsRepo)
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
              const SizedBox(height: AppSpacing.xxl),

              AppTextField(
                label: ProjectStrings.projectNameLabel,
                placeholder: ProjectStrings.projectNamePlaceholder,
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),

              ProjectSelectField(
                label: ProjectStrings.clientLabel,
                value: selectedClient?.name,
                placeholder: ProjectStrings.selectClientPlaceholder,
                onTap: () => _pickClient(clientsRepo),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProjectSelectField(
                      label: ProjectStrings.categoryLabel,
                      value: _category,
                      showArrow: false,
                      onTap: _pickCategory,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: ProjectStrings.budgetShortLabel,
                      placeholder: ProjectStrings.budgetPlaceholder,
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

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
                      value: _endDate != null
                          ? formatMediumDate(_endDate!)
                          : null,
                      placeholder: ProjectStrings.noDeadline,
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

              AppTextField(
                label: ProjectStrings.descriptionLabel,
                placeholder: ProjectStrings.descriptionPlaceholder,
                controller: _descriptionController,
                multiline: true,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
