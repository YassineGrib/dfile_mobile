import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../../projects/data/data.dart';
import '../payment_strings.dart';

/// Single payment card in the payments list matching screen PY2.
class PaymentsListCard extends StatelessWidget {
  const PaymentsListCard({
    super.key,
    required this.payment,
    required this.client,
    required this.project,
  });

  final ProjectPayment payment;
  final Client? client;
  final ProjectItem? project;

  static const List<Color> _avatarColors = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];

  Color get _avatarColor {
    if (client != null) {
      return _avatarColors[client!.avatarColorIndex % _avatarColors.length];
    }
    return _avatarColors[0];
  }

  (Color textColor, Color bgColor) get _methodColors {
    switch (payment.method) {
      case PaymentMethod.baridimob:
        return (AppColors.purple, AppColors.waitingClientBg);
      case PaymentMethod.ccp:
        return (AppColors.ink, AppColors.ccpBg);
      case PaymentMethod.bank:
        return (AppColors.orange, AppColors.inProgressBg);
      case PaymentMethod.cash:
        return (AppColors.green, AppColors.greenBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String clientName = client?.name ?? 'Unknown Client';
    final String projectName = project?.name ?? 'Unknown Project';
    final (Color methodTextColor, Color methodBgColor) = _methodColors;
    final String referenceText =
        payment.reference.trim().isNotEmpty ? payment.reference.trim() : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.line,
            width: AppSpacing.borderWidth,
          ),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => context.push('${AppRoutes.paymentsPath}/${payment.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar, Client + Project, Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InitialAvatar(
                        initial: clientName,
                        color: _avatarColor,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              projectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.label.copyWith(
                                color: AppColors.mute,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '+${formatAmount(payment.amount)} DZ',
                        style: AppText.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Middle Row: Method badge + Type pill
                  Row(
                    children: [
                      _buildBadge(
                        label: PaymentStrings.methodLabel(payment.method),
                        textColor: methodTextColor,
                        backgroundColor: methodBgColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildBadge(
                        label: PaymentStrings.typeLabel(payment.type),
                        textColor: AppColors.ink,
                        backgroundColor: AppColors.seg,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bottom Row: Date + Reference
                  Row(
                    children: [
                      Text(
                        formatDate(payment.date),
                        style: AppText.label.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          referenceText,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(
                            color: AppColors.mute,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppText.captionSm.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }
}
