import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_bottom_sheet.dart';

/// Displays the settlement modal bottom sheet per `docs/design/SPEC.md` (FD13).
///
/// Placeholder implementation for TASK 7.0; Agent 7D replaces this body
/// with the full interactive settlement form. Keep this signature stable.
Future<void> showSettleSheet(
  BuildContext context, {
  required String transactionId,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'Settle sheet',
          style: AppText.cardTitle.copyWith(color: AppColors.ink),
        ),
      );
    },
  );
}
