import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/data.dart';
import '../project_strings.dart';
import 'project_form_fields.dart';

/// Opens the Record payment modal bottom sheet (P18) via [showAppSheet].
Future<bool?> showRecordPaymentSheet({
  required BuildContext context,
  required ProjectItem project,
  required String clientName,
}) {
  return showAppSheet<bool>(
    context: context,
    builder: (BuildContext sheetContext) {
      return RecordPaymentSheet(
        project: project,
        clientName: clientName,
      );
    },
  );
}

/// Modal bottom sheet form for recording a payment against a project (screen P18).
class RecordPaymentSheet extends StatefulWidget {
  const RecordPaymentSheet({
    super.key,
    required this.project,
    required this.clientName,
  });

  final ProjectItem project;
  final String clientName;

  @override
  State<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<RecordPaymentSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  late DateTime _paymentDate;

  @override
  void initState() {
    super.initState();
    _paymentDate = DateUtils.dateOnly(DateTime.now());
    _amountController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onChanged);
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  int? get _parsedAmount {
    final String raw = _amountController.text.replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return int.tryParse(raw);
  }

  bool get _isValid {
    final int? amount = _parsedAmount;
    return amount != null && amount > 0;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        _paymentDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _save(ProjectsRepository repo, ProjectItem liveProject) {
    if (!_isValid) {
      return;
    }
    final double amount = _parsedAmount!.toDouble();
    final ProjectPayment payment = ProjectPayment(
      id: 'pay_${DateTime.now().microsecondsSinceEpoch}',
      projectId: liveProject.id,
      date: _paymentDate,
      reference: _referenceController.text.trim(),
      amount: amount,
    );

    repo.addPayment(payment);
    showAppToast(context, ProjectStrings.paymentRecordedToast);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository repo = ProjectsScope.of(context);
    final ProjectItem liveProject =
        repo.byId(widget.project.id) ?? widget.project;
    final double currentRemaining = repo.remaining(liveProject);
    final double enteredAmount = (_parsedAmount ?? 0).toDouble();
    final double remainingAfter = currentRemaining - enteredAmount;

    final String previewLabel = remainingAfter > 0
        ? ProjectStrings.remainingAfterPayment(formatMoney(remainingAfter))
        : ProjectStrings.fullyPaidAfterPayment;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ProjectStrings.recordPaymentTitle,
            style: AppText.sectionTitleLg.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            '${liveProject.name} • ${widget.clientName}',
            style: AppText.body.copyWith(
              fontSize: 15,
              color: AppColors.mute,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: ProjectStrings.amountRequiredLabel,
            placeholder: ProjectStrings.amountPlaceholder,
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          ProjectSelectField(
            label: ProjectStrings.paymentDateLabel,
            value: formatDate(_paymentDate),
            showArrow: false,
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: ProjectStrings.referenceOptionalLabel,
            placeholder: ProjectStrings.referencePlaceholder,
            controller: _referenceController,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Live remaining balance preview banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(
              previewLabel,
              style: AppText.bodyBold.copyWith(
                fontSize: 15,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            label: ProjectStrings.savePayment,
            onPressed: _isValid ? () => _save(repo, liveProject) : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: ProjectStrings.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
