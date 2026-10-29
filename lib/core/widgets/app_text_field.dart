import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Labelled text input matching SPEC.md (height 56 single-line, radius 16, white fill, 1.5px border).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.multiline = false,
    this.maxLines = 4,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.errorText,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool multiline;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: color, width: AppSpacing.borderWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = widget.multiline && !widget.obscureText;
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    Widget? trailing = widget.suffixIcon;
    if (widget.obscureText) {
      trailing = IconButton(
        onPressed: widget.enabled
            ? () => setState(() => _isObscured = !_isObscured)
            : null,
        tooltip: _isObscured ? 'Show password' : 'Hide password',
        icon: Icon(
          _isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: AppColors.mute,
        ),
      );
    }

    final OutlineInputBorder borderStyle = _border(
      hasError ? AppColors.red : AppColors.line,
    );
    final OutlineInputBorder focusedBorderStyle = _border(
      hasError ? AppColors.red : AppColors.ink,
    );

    final Widget field = TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      obscureText: widget.obscureText && _isObscured,
      keyboardType:
          widget.keyboardType ??
          (isMultiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: widget.textInputAction,
      minLines: isMultiline ? widget.maxLines : 1,
      maxLines: isMultiline ? widget.maxLines : 1,
      style: AppText.body,
      cursorColor: AppColors.ink,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.card,
        hintText: widget.placeholder,
        hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
        prefixIcon: widget.prefixIcon,
        suffixIcon: trailing,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: isMultiline ? AppSpacing.lg : 17,
        ),
        constraints: isMultiline
            ? null
            : const BoxConstraints(minHeight: AppSpacing.inputHeight),
        border: borderStyle,
        enabledBorder: borderStyle,
        disabledBorder: _border(AppColors.line),
        focusedBorder: focusedBorderStyle,
      ),
    );

    if (widget.label == null && !hasError) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
        ],
        field,
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
