import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/data.dart';
import '../friend_strings.dart';
import '../transaction_detail_strings.dart';

/// Modal bottom sheet form for recording a debt settlement per `docs/design/SPEC.md` (FD13).
class SettleSheet extends StatefulWidget {
  const SettleSheet({
    super.key,
    required this.transaction,
    required this.friendName,
  });

  final FriendTransaction transaction;
  final String friendName;

  @override
  State<SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<SettleSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late DateTime _settlementDate;
  FriendSettleMethod _selectedMethod = FriendSettleMethod.baridimob;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _settlementDate = DateUtils.dateOnly(DateTime.now());
    _amountController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFieldChanged);
    _notesController.removeListener(_onFieldChanged);
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? get _parsedAmount {
    final String raw = _amountController.text.replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  String? _getAmountError(double remaining) {
    if (!_submitted) return null;
    final double? amount = _parsedAmount;
    if (amount == null || amount <= 0) {
      return TransactionDetailStrings.errorValidAmount;
    }
    if (amount > remaining) {
      return TransactionDetailStrings.errorExceedsRemaining;
    }
    return null;
  }

  String? _getNotesError() {
    if (!_submitted) return null;
    if (_selectedMethod == FriendSettleMethod.serviceOffset) {
      if (_notesController.text.trim().isEmpty) {
        return TransactionDetailStrings.errorDescribeServiceOffset;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _settlementDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.ink,
              onPrimary: AppColors.white,
              surface: AppColors.card,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _settlementDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _fill100Percent(double remaining) {
    setState(() {
      // Format with integer digits if no decimals
      final int remainingInt = remaining.round();
      _amountController.text = remainingInt.toString();
    });
  }

  void _submit(FriendsRepository repo, FriendTransaction liveTx) {
    setState(() {
      _submitted = true;
    });

    final String? amountErr = _getAmountError(liveTx.remaining);
    final String? notesErr = _getNotesError();

    if (amountErr != null || notesErr != null) {
      return;
    }

    final double amount = _parsedAmount!;
    try {
      repo.settle(
        liveTx.id,
        amount,
        _selectedMethod,
        _notesController.text.trim(),
        _settlementDate,
      );
      Navigator.of(context).pop();
      showAppToast(context, TransactionDetailStrings.settlementRecordedToast);
    } catch (_) {
      // ArgumentError handled gracefully if any race occurred
    }
  }

  @override
  Widget build(BuildContext context) {
    final FriendsRepository repo = FriendsScope.of(context);
    final FriendTransaction liveTx =
        repo.transactionById(widget.transaction.id) ?? widget.transaction;

    final double remaining = liveTx.remaining;
    final String? amountError = _getAmountError(remaining);
    final String? notesError = _getNotesError();

    final (Color dirBg, Color dirFg, String dirLabel) =
        liveTx.direction == FriendTxDirection.lent
            ? (AppColors.greenBg, AppColors.green, FriendStrings.owedToYou)
            : (AppColors.redBg, AppColors.red, FriendStrings.youOwe);

    final bool isOffset = _selectedMethod == FriendSettleMethod.serviceOffset;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Title
          Text(
            TransactionDetailStrings.recordSettlementTitle,
            style: AppText.sectionTitleLg.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),

          // Subtitle "With: <friend> • <description>"
          Text(
            TransactionDetailStrings.settleWithSubtitle(
              widget.friendName,
              liveTx.description,
            ),
            style: AppText.caption.copyWith(
              color: AppColors.mute,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Summary Card (Total, Paid, Remaining with direction pill)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dirBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        dirLabel,
                        style: AppText.captionSm.copyWith(
                          color: dirFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    // Total
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TransactionDetailStrings.total,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatMoney(liveTx.amount),
                            style: AppText.bodyBold.copyWith(
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Paid
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TransactionDetailStrings.summaryPaid,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatMoney(liveTx.paidAmount),
                            style: AppText.bodyBold.copyWith(
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Remaining
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TransactionDetailStrings.summaryRemaining,
                            style: AppText.captionSm.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatMoney(remaining),
                            style: AppText.bodyBold.copyWith(
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Settlement amount field with "100% full" chip
          AppTextField(
            label: TransactionDetailStrings.settlementAmountLabel,
            placeholder: TransactionDetailStrings.settlementAmountPlaceholder,
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            errorText: amountError,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: UnconstrainedBox(
                child: Material(
                  color: AppColors.seg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: InkWell(
                    onTap: () => _fill100Percent(remaining),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        TransactionDetailStrings.full100Percent,
                        style: AppText.captionSm.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Settlement Method selection (4 tiles)
          Text(
            TransactionDetailStrings.settlementMethodLabel,
            style: AppText.caption.copyWith(
              color: AppColors.mute,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildMethodTile(FriendSettleMethod.baridimob),
              const SizedBox(width: AppSpacing.sm),
              _buildMethodTile(FriendSettleMethod.cash),
              const SizedBox(width: AppSpacing.sm),
              _buildMethodTile(FriendSettleMethod.serviceOffset),
              const SizedBox(width: AppSpacing.sm),
              _buildMethodTile(FriendSettleMethod.bank),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Settlement Notes
          AppTextField(
            label: isOffset
                ? TransactionDetailStrings.notesOffsetRequiredLabel
                : TransactionDetailStrings.notesOptionalLabel,
            placeholder: isOffset
                ? TransactionDetailStrings.notesOffsetPlaceholder
                : TransactionDetailStrings.notesPlaceholder,
            controller: _notesController,
            errorText: notesError,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Settlement Date field (clickable picker)
          Text(
            TransactionDetailStrings.settlementDateLabel,
            style: AppText.caption.copyWith(
              color: AppColors.mute,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Container(
              height: AppSpacing.inputHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: AppColors.line,
                  width: AppSpacing.borderWidth,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(_settlementDate),
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.mute,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons: [Confirm settlement] and [Cancel]
          PrimaryButton(
            label: TransactionDetailStrings.confirmSettlement,
            onPressed: () => _submit(repo, liveTx),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: TransactionDetailStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(FriendSettleMethod method) {
    final bool isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: isSelected ? AppColors.purple : AppColors.line,
              width: AppSpacing.borderWidth,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            method.label,
            style: AppText.captionSm.copyWith(
              color: isSelected ? AppColors.white : AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
