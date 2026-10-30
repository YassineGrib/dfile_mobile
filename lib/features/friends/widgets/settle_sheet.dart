import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_sheet.dart';
import '../data/data.dart';
import 'settle_sheet_content.dart';

/// Displays the settlement modal bottom sheet per `docs/design/SPEC.md` (FD13).
///
/// Signature is strictly preserved: `showSettleSheet(BuildContext context, {required String transactionId})`.
Future<void> showSettleSheet(
  BuildContext context, {
  required String transactionId,
}) {
  final FriendsRepository repo = FriendsScope.of(context, listen: false);
  final FriendTransaction? transaction = repo.transactionById(transactionId);
  if (transaction == null) {
    return Future<void>.value();
  }

  final Friend? friend = repo.friendById(transaction.friendId);
  final String friendName = friend?.name ?? '';

  return showAppSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SettleSheet(transaction: transaction, friendName: friendName);
    },
  );
}
