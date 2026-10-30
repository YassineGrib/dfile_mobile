import 'package:flutter/material.dart';

import '../sync_status.dart';
import '../theme/theme.dart';
import 'app_icons.dart';

/// Wraps the app and shows a slim bar on top when the cloud is unreachable or
/// a sync failed. Renders [child] untouched when everything is fine.
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key, required this.status, required this.child});

  final SyncStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: status,
      builder: (BuildContext context, Widget? _) {
        final String? message = status.message;
        if (message == null) return child;
        final bool isOffline = status.offline;
        return Column(
          children: <Widget>[
            Material(
              color: isOffline ? AppColors.orangeBg : AppColors.redBg,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isOffline ? AppIcons.wifiOff : AppIcons.triangleAlert,
                        size: 18,
                        color: isOffline ? AppColors.orange : AppColors.red,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          message,
                          style: AppText.caption.copyWith(
                            color: AppColors.ink,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}
