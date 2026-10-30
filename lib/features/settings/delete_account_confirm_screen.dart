import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/settings_repository.dart';
import 'data/settings_scope.dart';
import 'settings_privacy_strings.dart';
import 'widgets/privacy_danger_button.dart';
import 'widgets/privacy_reason_sheet.dart';
import 'widgets/settings_header.dart';

/// Step 2 of the account deletion flow per `docs/design/SPEC.md` (PS4, PS5).
class DeleteAccountConfirmScreen extends StatefulWidget {
  const DeleteAccountConfirmScreen({super.key});

  @override
  State<DeleteAccountConfirmScreen> createState() =>
      _DeleteAccountConfirmScreenState();
}

class _DeleteAccountConfirmScreenState
    extends State<DeleteAccountConfirmScreen> {
  final TextEditingController _deleteTextController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedReason;
  String? _deleteTextError;
  String? _passwordError;
  bool _understandChecked = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _deleteTextController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsDeleteAccountPath);
    }
  }

  Future<void> _pickReason() async {
    final String? picked = await showPrivacyReasonSheet(
      context: context,
      currentReason: _selectedReason,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedReason = picked;
      });
    }
  }

  void _onSubmit() {
    final SettingsRepository settingsRepo =
        SettingsScope.of(context, listen: false);

    bool isValid = true;

    if (_deleteTextController.text != 'DELETE') {
      _deleteTextError = SettingsPrivacyStrings.typeDeleteError;
      isValid = false;
    } else {
      _deleteTextError = null;
    }

    if (!settingsRepo.checkPassword(_passwordController.text)) {
      _passwordError = SettingsPrivacyStrings.passwordError;
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});

    if (isValid && _understandChecked) {
      context.go(AppRoutes.settingsDeleteAccountProgressPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: AppSpacing.md,
              ),
              child: SettingsHeader(
                title: SettingsPrivacyStrings.confirmDeletionTitle,
                onBack: () => _handleBack(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.sm,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                children: [
                  // Optional Reason selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SettingsPrivacyStrings.reasonLabel,
                        style: AppText.caption.copyWith(
                          color: AppColors.mute,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        onTap: _pickReason,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        child: Container(
                          height: AppSpacing.inputHeight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                                BorderRadius.circular(AppRadius.input),
                            border: Border.all(
                              color: AppColors.line,
                              width: AppSpacing.borderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedReason ??
                                      SettingsPrivacyStrings.reasonPlaceholder,
                                  style: AppText.bodyMedium.copyWith(
                                    color: _selectedReason == null
                                        ? AppColors.placeholder
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.placeholder,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // "Type DELETE to confirm" input
                  AppTextField(
                    label: SettingsPrivacyStrings.typeDeleteLabel,
                    placeholder: SettingsPrivacyStrings.typeDeletePlaceholder,
                    controller: _deleteTextController,
                    errorText: _deleteTextError,
                    onChanged: (_) {
                      if (_deleteTextError != null) {
                        setState(() => _deleteTextError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password input with show/hide toggle
                  AppTextField(
                    label: SettingsPrivacyStrings.passwordLabel,
                    placeholder: SettingsPrivacyStrings.passwordPlaceholder,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.placeholder,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // "I understand..." checkbox row
                  InkWell(
                    onTap: () {
                      setState(() {
                        _understandChecked = !_understandChecked;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 2, right: 12),
                            decoration: BoxDecoration(
                              color: _understandChecked
                                  ? AppColors.red
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _understandChecked
                                    ? AppColors.red
                                    : AppColors.line,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _understandChecked
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: AppColors.white,
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              SettingsPrivacyStrings.understandCheckbox,
                              style: AppText.body.copyWith(
                                color: AppColors.ink,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // Bottom action buttons: [Cancel] and [Delete my account]
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  top: BorderSide(
                    color: AppColors.line,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: SettingsPrivacyStrings.cancelButton,
                      onPressed: () => _handleBack(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrivacyDangerButton(
                      label: SettingsPrivacyStrings.deleteMyAccountButton,
                      onPressed: _understandChecked ? _onSubmit : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
