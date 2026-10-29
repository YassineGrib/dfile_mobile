import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../clients/data/data.dart';
import '../projects/data/data.dart';
import 'payment_receipt_strings.dart';

/// Payment receipt detail screen matching screens PY5..PY8.
class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.paymentId,
  });

  final String paymentId;

  void _popOrGoPayments(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.paymentsPath);
    }
  }

  void _openActionsSheet({
    required BuildContext context,
    required ProjectPayment payment,
    required String clientName,
    required ProjectsRepository repo,
  }) {
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.greenBg,
                      borderRadius: BorderRadius.circular(AppRadius.otp),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      r'$',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 20,
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
                          '+${formatMoney(payment.amount)}',
                          style: AppText.cardTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$clientName • ${formatDate(payment.date)}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionItem(
                label: PaymentReceiptStrings.copyReference,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (payment.reference.trim().isNotEmpty) {
                    Clipboard.setData(
                      ClipboardData(text: payment.reference.trim()),
                    );
                    showAppToast(
                      context,
                      PaymentReceiptStrings.copiedReferenceToast,
                    );
                  } else {
                    showAppToast(
                      context,
                      PaymentReceiptStrings.noReferenceToCopyToast,
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: PaymentReceiptStrings.goToProject,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/projects/${payment.projectId}');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: PaymentReceiptStrings.shareReceipt,
                textColor: AppColors.ink,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showAppToast(context, PaymentReceiptStrings.demoNotAvailable);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildActionItem(
                label: PaymentReceiptStrings.deletePayment,
                textColor: AppColors.red,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openDeleteConfirmSheet(
                    context: context,
                    payment: payment,
                    clientName: clientName,
                    repo: repo,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDeleteConfirmSheet({
    required BuildContext context,
    required ProjectPayment payment,
    required String clientName,
    required ProjectsRepository repo,
  }) {
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
                          PaymentReceiptStrings.deletePaymentTitle,
                          style: AppText.sectionTitle.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PaymentReceiptStrings.deletePaymentSubtitle,
                          style: AppText.caption.copyWith(
                            color: AppColors.red,
                          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PaymentReceiptStrings.deleteWarningAmountClient(
                        formatAmount(payment.amount),
                        clientName,
                      ),
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.red,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      PaymentReceiptStrings.deleteWarningRecalculate,
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.red,
                        height: 1.45,
                      ),
                    ),
                  ],
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
                      repo.deletePayment(payment.id);
                      Navigator.of(confirmContext).pop();
                      context.go(
                        AppRoutes.paymentsPath,
                        extra: <String, Object?>{
                          'toast': PaymentReceiptStrings.paymentDeletedToast,
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        PaymentReceiptStrings.confirmDelete,
                        style: AppText.button,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: PaymentReceiptStrings.cancel,
                onPressed: () => Navigator.of(confirmContext).pop(),
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
        height: 52,
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

  Widget _buildTopBar({
    required VoidCallback onBack,
    required VoidCallback onMore,
  }) {
    return Row(
      children: [
        RoundIconButton(
          icon: Icons.arrow_back,
          tooltip: PaymentReceiptStrings.back,
          onPressed: onBack,
        ),
        Expanded(
          child: Center(
            child: Text(
              PaymentReceiptStrings.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sectionTitle.copyWith(fontSize: 20),
            ),
          ),
        ),
        RoundIconButton(
          icon: Icons.more_horiz,
          tooltip: PaymentReceiptStrings.moreOptions,
          onPressed: onMore,
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required Widget value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppText.bodyMedium.copyWith(color: AppColors.mute),
        ),
        const Spacer(),
        Flexible(child: value),
      ],
    );
  }

  Widget _buildTextDetailRow({
    required String label,
    required String value,
    Color valueColor = AppColors.ink,
  }) {
    return _buildDetailRow(
      label: label,
      value: Text(
        value,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: AppText.bodyMedium.copyWith(
          color: valueColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: PrimaryButton(
            label: PaymentReceiptStrings.shareReceipt,
            onPressed: () => showAppToast(
              context,
              PaymentReceiptStrings.demoNotAvailable,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard({
    required ProjectPayment payment,
    required String clientName,
    required String projectName,
    required double budget,
    required double paidToDate,
    required double remaining,
  }) {
    final bool isCleared = remaining <= 0.0001;
    final String remainingText = isCleared
        ? PaymentReceiptStrings.cleared
        : formatMoney(remaining);
    final Color remainingColor = isCleared ? AppColors.green : AppColors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
          // Header: Check circle + "Official payment receipt" + Date, right: PAY-xxxx code
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.greenBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PaymentReceiptStrings.officialReceipt,
                      style: AppText.bodyBold.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(payment.date),
                      style: AppText.caption.copyWith(color: AppColors.mute),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.seg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  PaymentReceiptStrings.receiptCode(payment.id),
                  style: AppText.captionSm.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.lg),

          // Amount received & type pill
          Text(
            PaymentReceiptStrings.amountReceived,
            style: AppText.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '+${formatMoney(payment.amount)}',
            style: AppText.title.copyWith(
              color: AppColors.green,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.seg,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              PaymentReceiptStrings.typePaymentLabel(payment.type.label),
              style: AppText.captionSm.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.lg),

          // Metadata rows
          _buildTextDetailRow(
            label: PaymentReceiptStrings.client,
            value: clientName,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: PaymentReceiptStrings.project,
            value: projectName,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            label: PaymentReceiptStrings.method,
            value: _PaymentMethodBadge(method: payment.method),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: PaymentReceiptStrings.reference,
            value: payment.reference.trim().isNotEmpty
                ? payment.reference.trim()
                : PaymentReceiptStrings.emptyReferenceDash,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: PaymentReceiptStrings.date,
            value: formatDate(payment.date),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.lg),

          // Project budget, paid to date, remaining
          _buildTextDetailRow(
            label: PaymentReceiptStrings.projectBudget,
            value: formatMoney(budget),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: PaymentReceiptStrings.paidToDate,
            value: formatMoney(paidToDate),
            valueColor: AppColors.green,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextDetailRow(
            label: PaymentReceiptStrings.remaining,
            value: remainingText,
            valueColor: remainingColor,
          ),

          // Notes (only when non-empty)
          if (payment.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, thickness: 1, color: AppColors.line),
            const SizedBox(height: AppSpacing.lg),
            Text(
              PaymentReceiptStrings.notes,
              style: AppText.caption.copyWith(color: AppColors.mute),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              payment.notes.trim(),
              style: AppText.bodyMedium.copyWith(color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsRepository projectsRepo = ProjectsScope.of(context);
    final ClientsRepository clientsRepo = ClientsScope.of(context);

    final ProjectPayment? payment = projectsRepo.paymentById(paymentId);

    // Unknown payment id -> friendly "Payment not found" screen with a back button
    if (payment == null) {
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
                  tooltip: PaymentReceiptStrings.back,
                  onPressed: () => context.go(AppRoutes.paymentsPath),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        PaymentReceiptStrings.paymentNotFound,
                        style: AppText.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: PaymentReceiptStrings.backToPayments,
                        onPressed: () => context.go(AppRoutes.paymentsPath),
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

    final ProjectItem? project = projectsRepo.byId(payment.projectId);
    final String resolvedClientId = payment.clientId.isNotEmpty
        ? payment.clientId
        : (project?.clientId ?? '');
    final Client? client = clientsRepo.byId(resolvedClientId);
    final String clientName =
        client?.name ??
        (resolvedClientId.isNotEmpty
            ? resolvedClientId
            : PaymentReceiptStrings.unknownClient);
    final String projectName =
        project?.name ??
        (payment.projectId.isNotEmpty
            ? payment.projectId
            : PaymentReceiptStrings.unknownProject);

    final double budget = project?.price ?? 0.0;
    final double paidToDate =
        project != null ? projectsRepo.paid(project) : payment.amount;
    final double remaining =
        project != null ? projectsRepo.remaining(project) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _buildBottomBar(context),
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
              const SizedBox.shrink(
                child: Text(
                  'PaymentReceiptScreen',
                  style: TextStyle(fontSize: 0, color: AppColors.transparent),
                ),
              ),
              _buildTopBar(
                onBack: () => _popOrGoPayments(context),
                onMore: () => _openActionsSheet(
                  context: context,
                  payment: payment,
                  clientName: clientName,
                  repo: projectsRepo,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildReceiptCard(
                payment: payment,
                clientName: clientName,
                projectName: projectName,
                budget: budget,
                paidToDate: paidToDate,
                remaining: remaining,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coloured stadium pill displaying a [PaymentMethod] per `docs/design/SPEC.md`.
class _PaymentMethodBadge extends StatelessWidget {
  const _PaymentMethodBadge({required this.method});

  final PaymentMethod method;

  (Color bg, Color fg) get _colors {
    switch (method) {
      case PaymentMethod.baridimob:
        return (AppColors.waitingClientBg, AppColors.purple);
      case PaymentMethod.ccp:
        return (
          Color.lerp(AppColors.white, AppColors.yellow, 0.3)!,
          AppColors.ink,
        );
      case PaymentMethod.bank:
        return (AppColors.inProgressBg, AppColors.orange);
      case PaymentMethod.cash:
        return (AppColors.greenBg, AppColors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        method.label,
        maxLines: 1,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
