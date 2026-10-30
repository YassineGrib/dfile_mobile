import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/round_icon_button.dart';

/// Top bar used across settings screens with a back button and centred title.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.title,
    this.rightAction,
    this.onBack,
  });

  final String title;
  final Widget? rightAction;
  final VoidCallback? onBack;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.iconButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: RoundIconButton(
              icon: Icons.arrow_back,
              onPressed: () => _handleBack(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              title,
              style: AppText.cardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (rightAction != null)
            Align(alignment: Alignment.centerRight, child: rightAction!),
        ],
      ),
    );
  }
}
