import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_toast.dart';
import 'data/data.dart';
import 'settings_account_strings.dart';
import 'widgets/account_action_bar.dart';
import 'widgets/account_password_field.dart';
import 'widgets/settings_header.dart';

/// Screen for changing account password (Agent A) per `docs/design/SPEC.md` (ST3, ST4).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final FocusNode _currentFocusNode = FocusNode();
  final FocusNode _newFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();

  bool _currentTouched = false;
  bool _newTouched = false;
  bool _confirmTouched = false;
  bool _saveAttempted = false;

  @override
  void initState() {
    super.initState();
    _currentController.addListener(_onCurrentChanged);
    _newController.addListener(_onNewChanged);
    _confirmController.addListener(_onConfirmChanged);

    _currentFocusNode.addListener(_onCurrentFocusChanged);
    _newFocusNode.addListener(_onNewFocusChanged);
    _confirmFocusNode.addListener(_onConfirmFocusChanged);
  }

  void _onCurrentChanged() {
    if (!_currentTouched && _currentController.text.isNotEmpty) {
      _currentTouched = true;
    }
    setState(() {});
  }

  void _onNewChanged() {
    if (!_newTouched && _newController.text.isNotEmpty) {
      _newTouched = true;
    }
    setState(() {});
  }

  void _onConfirmChanged() {
    if (!_confirmTouched && _confirmController.text.isNotEmpty) {
      _confirmTouched = true;
    }
    setState(() {});
  }

  void _onCurrentFocusChanged() {
    if (!_currentFocusNode.hasFocus) {
      _currentTouched = true;
      setState(() {});
    }
  }

  void _onNewFocusChanged() {
    if (!_newFocusNode.hasFocus) {
      _newTouched = true;
      setState(() {});
    }
  }

  void _onConfirmFocusChanged() {
    if (!_confirmFocusNode.hasFocus) {
      _confirmTouched = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _currentController.removeListener(_onCurrentChanged);
    _newController.removeListener(_onNewChanged);
    _confirmController.removeListener(_onConfirmChanged);

    _currentFocusNode.removeListener(_onCurrentFocusChanged);
    _newFocusNode.removeListener(_onNewFocusChanged);
    _confirmFocusNode.removeListener(_onConfirmFocusChanged);

    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();

    _currentFocusNode.dispose();
    _newFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  bool _isCurrentValid(SettingsRepository repo) =>
      _currentController.text.isNotEmpty &&
      repo.checkPassword(_currentController.text);

  bool get _isNewValid => _newController.text.length >= 6;

  bool get _isConfirmValid =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text == _newController.text;

  bool _showCurrentError(SettingsRepository repo) =>
      (_saveAttempted || _currentTouched) && !_isCurrentValid(repo);

  bool get _showNewError => (_saveAttempted || _newTouched) && !_isNewValid;

  bool get _showConfirmError =>
      (_saveAttempted || _confirmTouched) && !_isConfirmValid;

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
  }

  void _onUpdate(SettingsRepository repo) {
    setState(() {
      _saveAttempted = true;
    });

    if (!_isCurrentValid(repo) || !_isNewValid || !_isConfirmValid) {
      return;
    }

    final String newPassword = _newController.text;
    repo.changePassword(newPassword);

    if (context.canPop()) {
      context.pop();
      showAppToast(context, SettingsAccountStrings.passwordUpdatedToast);
    } else {
      context.go(
        AppRoutes.settingsProfilePath,
        extra: <String, Object?>{
          'toast': SettingsAccountStrings.passwordUpdatedToast,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: AccountActionBar(
        primaryLabel: SettingsAccountStrings.updatePassword,
        onPrimaryPressed: () => _onUpdate(repo),
        secondaryLabel: SettingsAccountStrings.cancel,
        onSecondaryPressed: _onCancel,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(
                title: SettingsAccountStrings.changePasswordTitle,
                onBack: _onCancel,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                SettingsAccountStrings.changePasswordSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Current password
              AccountPasswordField(
                label: SettingsAccountStrings.currentPasswordLabel,
                controller: _currentController,
                focusNode: _currentFocusNode,
                errorText: _showCurrentError(repo)
                    ? SettingsAccountStrings.currentPasswordIncorrectError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // New password
              AccountPasswordField(
                label: SettingsAccountStrings.newPasswordLabel,
                controller: _newController,
                focusNode: _newFocusNode,
                errorText: _showNewError
                    ? SettingsAccountStrings.passwordTooShortError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Confirm new password
              AccountPasswordField(
                label: SettingsAccountStrings.confirmPasswordLabel,
                controller: _confirmController,
                focusNode: _confirmFocusNode,
                errorText: _showConfirmError
                    ? SettingsAccountStrings.passwordsDoNotMatchError
                    : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
