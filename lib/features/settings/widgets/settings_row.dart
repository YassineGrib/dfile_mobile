import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Interactive or informational row inside a [SettingsGroupCard].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.iconLetter,
    this.iconBgColor,
    this.iconTextColor,
    this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.last = false,
  });

  final String? iconLetter;
  final Color? iconBgColor;
  final Color? iconTextColor;
  final Widget? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (icon != null) {
      leading = icon;
    } else if (iconLetter != null) {
      leading = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor ?? AppColors.seg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          iconLetter!,
          style: AppText.bodyMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: iconTextColor ?? AppColors.ink,
          ),
        ),
      );
    }

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppText.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppText.caption.copyWith(
                      color: AppColors.mute,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null && value!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              value!,
              style: AppText.bodyMedium.copyWith(
                color: AppColors.mute,
                fontSize: 14,
              ),
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.placeholder,
              size: 22,
            ),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onTap != null)
          InkWell(
            onTap: onTap,
            child: content,
          )
        else
          content,
        if (!last)
          Padding(
            padding: EdgeInsets.only(
              left: leading != null ? 70.0 : AppSpacing.lg,
            ),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.line,
            ),
          ),
      ],
    );
  }
}
