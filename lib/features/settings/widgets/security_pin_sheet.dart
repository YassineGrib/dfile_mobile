import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/data.dart';
import '../settings_security_strings.dart';

/// Shows the PIN bottom sheet per `docs/design/SPEC.md` (ST9).
Future<bool?> showSecurityPinSheet(
  BuildContext context, {
  bool isChanging = false,
  ValueChanged<String>? onSave,
}) {
  return showAppSheet<bool>(
    context: context,
    builder: (BuildContext sheetContext) =>
        SecurityPinSheet(isChanging: isChanging, onSave: onSave),
  );
}

/// 4-digit PIN creation and modification sheet matching ST9.
class SecurityPinSheet extends StatefulWidget {
  const SecurityPinSheet({super.key, this.isChanging = false, this.onSave});

  final bool isChanging;
  final ValueChanged<String>? onSave;

  @override
  State<SecurityPinSheet> createState() => _SecurityPinSheetState();
}

class _SecurityPinSheetState extends State<SecurityPinSheet> {
  final FocusNode _focusNode = FocusNode();
  String _pin = '';

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _handleSave() {
    if (_pin.length != 4) return;

    if (widget.onSave != null) {
      widget.onSave!(_pin);
      return;
    }

    try {
      final SettingsRepository repo = SettingsScope.of(context, listen: false);
      repo.setPin(_pin);
      repo.setPinEnabled(true);
    } catch (_) {
      // In case SettingsScope is not in context tree.
    }

    Navigator.of(context).pop(true);
    showAppToast(context, SettingsSecurityStrings.pinSavedToast);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final String? character = event.character;
    if (character != null && RegExp(r'^[0-9]$').hasMatch(character)) {
      _handleDigit(character);
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _handleBackspace();
    } else if (event.logicalKey == LogicalKeyboardKey.enter &&
        _pin.length == 4) {
      _handleSave();
    }
  }

  Widget _buildDot(int index) {
    final bool isFilled = index < _pin.length;
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isFilled ? AppColors.ink : AppColors.seg,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildKeyButton({required Widget child, required VoidCallback onTap}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Material(
        color: AppColors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildDigitKey(String digit) {
    return _buildKeyButton(
      onTap: () => _handleDigit(digit),
      child: Text(
        digit,
        style: AppText.cardTitle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return _buildKeyButton(
      onTap: _handleBackspace,
      child: const Icon(
        Icons.backspace_outlined,
        color: AppColors.ink,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isChanging
        ? SettingsSecurityStrings.changePinTitle
        : SettingsSecurityStrings.choosePinTitle;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.cardTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              SettingsSecurityStrings.pinSheetSubtitle,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                fontSize: 14,
                color: AppColors.mute,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4 Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(4, _buildDot),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Keypad (4 rows)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigitKey('1'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('2'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('3'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigitKey('4'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('5'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('6'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigitKey('7'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('8'),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('9'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 64, height: 64),
                const SizedBox(width: AppSpacing.xl),
                _buildDigitKey('0'),
                const SizedBox(width: AppSpacing.xl),
                _buildBackspaceKey(),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Save PIN button
            PrimaryButton(
              label: SettingsSecurityStrings.savePin,
              onPressed: _pin.length == 4 ? _handleSave : null,
            ),
          ],
        ),
      ),
    );
  }
}
