import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../projects/data/data.dart';
import 'payment_strings.dart';
import 'record_payment_strings.dart';
import 'widgets/record_payment_client_sheet.dart';
import 'widgets/record_payment_fields.dart';
import 'widgets/record_payment_project_sheet.dart';
import 'widgets/record_payment_type_sheet.dart';

Color _clientAvatarColor(int index) {
  const List<Color> palette = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];
  return palette[index % palette.length];
}

/// Screen for recording a client payment (PY9..PY12).
class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({
    super.key,
    this.projectId,
  });

  final String? projectId;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  String? _selectedClientId;
  String? _selectedProjectId;
  PaymentMethod _selectedMethod = PaymentMethod.baridimob;
  PaymentType _selectedType = PaymentType.milestone;
  late DateTime _selectedDate;

  bool _initialized = false;
  bool _amountTouched = false;
  bool _saveAttempted = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _amountController.addListener(_onAmountChanged);
    _amountFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        final ProjectsRepository projectsRepo =
            ProjectsScope.of(context, listen: false);
        final ProjectItem? project = projectsRepo.byId(widget.projectId!);
        if (project != null) {
          _selectedProjectId = project.id;
          _selectedClientId = project.clientId;
        }
      }
      _initialized = true;
    }
  }

  void _onAmountChanged() {
    if (!_amountTouched && _amountController.text.isNotEmpty) {
      _amountTouched = true;
    }
    setState(() {});
  }

  void _onFocusChanged() {
    if (_amountFocusNode.hasFocus && !_amountTouched) {
      _amountTouched = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountFocusNode.removeListener(_onFocusChanged);
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  int? get _parsedAmount {
    final String raw = _amountController.text.replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  bool get _isAmountValid {
    final int? amount = _parsedAmount;
    return amount != null && amount > 0;
  }

  bool get _showAmountError =>
      (_saveAttempted || _amountTouched) && !_isAmountValid;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.paymentsPath);
    }
  }

  Future<void> _pickClient(ClientsRepository clientsRepo) async {
    final String? picked = await showRecordPaymentClientSheet(
      context: context,
      clients: clientsRepo.clients,
      selectedClientId: _selectedClientId,
    );
    if (picked != null && picked != _selectedClientId && mounted) {
      setState(() {
        _selectedClientId = picked;
        _selectedProjectId = null;
      });
    }
  }

  Future<void> _pickProject(
    ProjectsRepository projectsRepo,
    ClientsRepository clientsRepo,
  ) async {
    String? clientId = _selectedClientId;
    if (clientId == null) {
      clientId = await showRecordPaymentClientSheet(
        context: context,
        clients: clientsRepo.clients,
        selectedClientId: null,
      );
      if (clientId == null) {
        return;
      }
      setState(() {
        _selectedClientId = clientId;
        _selectedProjectId = null;
      });
    }

    final Client? client = clientsRepo.byId(clientId);
    if (client == null || !mounted) {
      return;
    }

    final String? picked = await showRecordPaymentProjectSheet(
      context: context,
      projectsRepo: projectsRepo,
      client: client,
      selectedProjectId: _selectedProjectId,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedProjectId = picked;
      });
    }
  }

  Future<void> _pickPaymentType() async {
    final PaymentType? picked = await showRecordPaymentTypeSheet(
      context: context,
      selectedType: _selectedType,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedType = picked;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _fillRemaining(ProjectsRepository projectsRepo) {
    _amountTouched = true;
    if (_selectedProjectId == null) {
      return;
    }
    final ProjectItem? project = projectsRepo.byId(_selectedProjectId!);
    if (project == null) {
      return;
    }
    final double remaining = projectsRepo.remaining(project);
    _amountController.text = formatAmount(remaining.round());
    setState(() {});
  }

  void _onSave(
    ClientsRepository clientsRepo,
    ProjectsRepository projectsRepo,
  ) {
    setState(() {
      _saveAttempted = true;
    });

    final bool isClientValid =
        _selectedClientId != null && _selectedClientId!.isNotEmpty;
    final bool isProjectValid =
        _selectedProjectId != null && _selectedProjectId!.isNotEmpty;

    if (!isClientValid || !isProjectValid || !_isAmountValid) {
      return;
    }

    final String paymentId = 'pay_${DateTime.now().microsecondsSinceEpoch}';
    final ProjectPayment payment = ProjectPayment(
      id: paymentId,
      projectId: _selectedProjectId!,
      clientId: _selectedClientId!,
      date: _selectedDate,
      reference: _referenceController.text.trim(),
      amount: _parsedAmount!.toDouble(),
      type: _selectedType,
      method: _selectedMethod,
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    projectsRepo.addPayment(payment);

    context.go(
      AppRoutes.paymentsPath,
      extra: <String, Object?>{
        'toast': RecordPaymentStrings.paymentRecordedToast,
      },
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
                RecordPaymentStrings.title,
                style: AppText.title,
              ),
              const SizedBox(height: 4),
              Text(
                RecordPaymentStrings.subtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const SizedBox(
          width: 0,
          height: 0,
          child: Text(
            'RecordPaymentScreen',
            style: TextStyle(fontSize: 0, color: AppColors.transparent),
          ),
        ),
        RoundIconButton(
          icon: Icons.close_rounded,
          onPressed: _close,
        ),
      ],
    );
  }

  Widget _buildMethodTile(PaymentMethod method) {
    final bool isSelected = _selectedMethod == method;
    return Material(
      color: isSelected ? AppColors.waitingClientBg : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.purple : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          height: AppSpacing.inputHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            PaymentStrings.methodLabel(method),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyBold.copyWith(
              fontSize: 16,
              color: isSelected ? AppColors.purple : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClientsRepository clientsRepo = ClientsScope.of(context);
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);

    final Client? selectedClient = _selectedClientId != null
        ? clientsRepo.byId(_selectedClientId!)
        : null;

    final ProjectItem? selectedProject = _selectedProjectId != null
        ? projectsRepo.byId(_selectedProjectId!)
        : null;

    final double projectRemaining = selectedProject != null
        ? projectsRepo.remaining(selectedProject)
        : 0.0;

    final bool hasClientError =
        _saveAttempted && (_selectedClientId == null || selectedClient == null);
    final bool hasProjectError = _saveAttempted &&
        (_selectedProjectId == null || selectedProject == null);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: RecordPaymentBottomBar(
        secondaryLabel: RecordPaymentStrings.cancel,
        onSecondaryPressed: _close,
        primaryLabel: RecordPaymentStrings.recordPaymentAction,
        onPrimaryPressed: () => _onSave(clientsRepo, projectsRepo),
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

              // Paying client selector
              RecordPaymentSelectField(
                label: RecordPaymentStrings.payingClientLabel,
                value: selectedClient?.name,
                placeholder: RecordPaymentStrings.selectClientPlaceholder,
                leading: selectedClient != null
                    ? InitialAvatar(
                        initial: selectedClient.name,
                        color: _clientAvatarColor(
                          selectedClient.avatarColorIndex,
                        ),
                        size: 34,
                      )
                    : null,
                hasError: hasClientError,
                errorText: RecordPaymentStrings.clientRequiredError,
                onTap: () => _pickClient(clientsRepo),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Linked project selector
              RecordPaymentSelectField(
                label: RecordPaymentStrings.linkedProjectLabel,
                trailingLabel: selectedProject != null
                    ? (projectRemaining > 0
                        ? Text(
                            RecordPaymentStrings.due(
                              formatMoney(projectRemaining),
                            ),
                            style: AppText.captionSm.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            RecordPaymentStrings.cleared,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ))
                    : null,
                value: selectedProject?.name,
                placeholder: RecordPaymentStrings.selectProjectPlaceholder,
                hasError: hasProjectError,
                errorText: RecordPaymentStrings.projectRequiredError,
                onTap: () => _pickProject(projectsRepo, clientsRepo),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Amount received with 100% full chip
              AppTextField(
                label: RecordPaymentStrings.amountLabel,
                placeholder: RecordPaymentStrings.amountPlaceholder,
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                ],
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () => _fillRemaining(projectsRepo),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.seg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        RecordPaymentStrings.fullChip,
                        style: AppText.captionSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                errorText:
                    _showAmountError ? RecordPaymentStrings.amountError : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4 Method tiles in 2x2 grid
              Text(
                RecordPaymentStrings.paymentMethodLabel,
                style: AppText.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: _buildMethodTile(PaymentMethod.baridimob)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildMethodTile(PaymentMethod.ccp)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildMethodTile(PaymentMethod.bank)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildMethodTile(PaymentMethod.cash)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Type select and Date select row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RecordPaymentSelectField(
                      label: RecordPaymentStrings.paymentTypeLabel,
                      value: PaymentStrings.typeLabel(_selectedType),
                      onTap: _pickPaymentType,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RecordPaymentSelectField(
                      label: RecordPaymentStrings.dateReceivedLabel,
                      value: formatDateYyyyMmDd(_selectedDate),
                      showArrow: false,
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reference (optional)
              AppTextField(
                label: RecordPaymentStrings.referenceLabel,
                placeholder: RecordPaymentStrings.referencePlaceholder,
                controller: _referenceController,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notes (optional)
              AppTextField(
                label: RecordPaymentStrings.notesLabel,
                placeholder: RecordPaymentStrings.notesPlaceholder,
                controller: _notesController,
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
