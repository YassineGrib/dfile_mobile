import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/theme.dart';
import '../friend_strings.dart';

/// Coloured stadium chip displaying a friend's net debt status per `docs/design/SPEC.md`.
class FriendNetChip extends StatelessWidget {
  const FriendNetChip({
    super.key,
    required this.net,
    this.label,
  });

  /// Net balance in DZD (positive: owed to me, negative: you owe, zero: settled).
  final double net;

  /// Optional explicit display label. If omitted, formats as:
  /// - `Owed 45,000 DZ` (net > 0)
  /// - `You owe 12,000 DZ` (net < 0)
  /// - `Settled` (net == 0)
  final String? label;

  (Color bg, Color fg, String text) get _chipProps {
    if (net > 0) {
      return (
        AppColors.greenBg,
        AppColors.green,
        label ?? FriendStrings.owedAmount(formatMoney(net)),
      );
    }
    if (net < 0) {
      return (
        AppColors.redBg,
        AppColors.red,
        label ?? FriendStrings.youOweAmount(formatMoney(net.abs())),
      );
    }
    return (
      AppColors.seg,
      AppColors.mute,
      label ?? FriendStrings.settledChip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String text) = _chipProps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: AppText.captionSm.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
