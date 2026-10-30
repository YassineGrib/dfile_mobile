import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../settings_account_strings.dart';

/// Password input field with Show/Hide toggle and error styling per ST3 and ST4.
class AccountPasswordField extends StatefulWidget {
  const AccountPasswordField({
    super.key,
    required this.label,
    this.placeholder = '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
    this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  State<AccountPasswordField> createState() => _AccountPasswordFieldState();
}

class _AccountPasswordFieldState extends State<AccountPasswordField> {
  bool _isObscured = true;

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: AppSpacing.borderWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    final OutlineInputBorder borderStyle = _border(
      hasError ? AppColors.red : AppColors.line,
    );
    final OutlineInputBorder focusedBorderStyle = _border(
      hasError ? AppColors.red : AppColors.ink,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: AppText.label),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          obscureText: _isObscured,
          obscuringCharacter: '\u2022',
          style: AppText.body,
          cursorColor: AppColors.ink,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.card,
            hintText: widget.placeholder,
            hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
            suffixIcon: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    _isObscured
                        ? SettingsAccountStrings.showToggle
                        : SettingsAccountStrings.hideToggle,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 17,
            ),
            constraints: const BoxConstraints(
              minHeight: AppSpacing.inputHeight,
            ),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: focusedBorderStyle,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppText.captionSm.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
