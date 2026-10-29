import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../record_payment_strings.dart';

Color _clientAvatarColor(int index) {
  const List<Color> palette = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];
  return palette[index % palette.length];
}

/// Opens a bottom sheet picker listing clients from [ClientsRepository].
Future<String?> showRecordPaymentClientSheet({
  required BuildContext context,
  required List<Client> clients,
  required String? selectedClientId,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              RecordPaymentStrings.selectClientTitle,
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < clients.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ClientOptionRow(
                client: clients[i],
                isSelected: clients[i].id == selectedClientId,
                onTap: () => Navigator.of(sheetContext).pop(clients[i].id),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _ClientOptionRow extends StatelessWidget {
  const _ClientOptionRow({
    required this.client,
    required this.isSelected,
    required this.onTap,
  });

  final Client client;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            children: [
              InitialAvatar(
                initial: client.name,
                color: _clientAvatarColor(client.avatarColorIndex),
                size: 34,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyBold.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
