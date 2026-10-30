import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/initial_avatar.dart';
import 'data/data.dart';
import 'settings_account_strings.dart';
import 'widgets/account_action_bar.dart';
import 'widgets/settings_group_card.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_row.dart';

/// Screen for editing user profile (Agent A) per `docs/design/SPEC.md` (ST2).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _designationFocusNode = FocusNode();

  bool _initialized = false;
  bool _nameTouched = false;
  bool _designationTouched = false;
  bool _saveAttempted = false;
  Object? _lastHandledExtra;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final SettingsRepository repo = SettingsScope.of(context, listen: false);
      final UserProfile profile = repo.profile;

      _nameController.text = profile.name;
      _designationController.text = profile.designation;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address;

      _nameController.addListener(_onNameChanged);
      _designationController.addListener(_onDesignationChanged);
      _nameFocusNode.addListener(_onNameFocusChanged);
      _designationFocusNode.addListener(_onDesignationFocusChanged);

      _initialized = true;
    }
    _handleIncomingExtra();
  }

  void _handleIncomingExtra() {
    Object? extra;
    try {
      extra = GoRouterState.of(context).extra;
    } catch (_) {
      // In case GoRouter is not available in test harness.
    }

    if (extra != null && !identical(extra, _lastHandledExtra)) {
      _lastHandledExtra = extra;
      String? message;
      if (extra is String) {
        message = extra;
      } else if (extra is Map) {
        final Object? toastValue = extra['toast'];
        if (toastValue is String) {
          message = toastValue;
        }
      }

      if (message != null && message.trim().isNotEmpty) {
        final String toastMessage = message;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context, toastMessage);
          }
        });
      }
    }
  }

  void _onNameChanged() {
    if (!_nameTouched && _nameController.text.trim().isNotEmpty) {
      _nameTouched = true;
    }
    setState(() {});
  }

  void _onDesignationChanged() {
    if (!_designationTouched && _designationController.text.trim().isNotEmpty) {
      _designationTouched = true;
    }
    setState(() {});
  }

  void _onNameFocusChanged() {
    if (!_nameFocusNode.hasFocus) {
      _nameTouched = true;
      setState(() {});
    }
  }

  void _onDesignationFocusChanged() {
    if (!_designationFocusNode.hasFocus) {
      _designationTouched = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _designationController.removeListener(_onDesignationChanged);
    _nameFocusNode.removeListener(_onNameFocusChanged);
    _designationFocusNode.removeListener(_onDesignationFocusChanged);

    _nameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _nameFocusNode.dispose();
    _designationFocusNode.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;
  bool get _isDesignationValid => _designationController.text.trim().isNotEmpty;

  bool get _showNameError => (_saveAttempted || _nameTouched) && !_isNameValid;
  bool get _showDesignationError =>
      (_saveAttempted || _designationTouched) && !_isDesignationValid;

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPath);
    }
  }

  void _onSave(SettingsRepository repo) {
    setState(() {
      _saveAttempted = true;
    });

    if (!_isNameValid || !_isDesignationValid) {
      return;
    }

    final UserProfile updated = repo.profile.copyWith(
      name: _nameController.text.trim(),
      designation: _designationController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    repo.updateProfile(updated);
    context.go(
      AppRoutes.settingsPath,
      extra: <String, Object?>{
        'toast': SettingsAccountStrings.profileUpdatedToast,
      },
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              SettingsAccountStrings.businessEmailLabel,
              style: AppText.label,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    SettingsAccountStrings.verifiedPill,
                    style: AppText.captionSm.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: _emailController,
          enabled: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);
    final String initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: AccountActionBar(
        primaryLabel: SettingsAccountStrings.saveDetails,
        onPrimaryPressed: () => _onSave(repo),
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
                title: SettingsAccountStrings.editProfileTitle,
                onBack: _onCancel,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Centred avatar initial
              Center(
                child: InitialAvatar(
                  initial: initial,
                  color: AppColors.orange,
                  size: 72,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Display name * (required)
              AppTextField(
                label: SettingsAccountStrings.displayNameLabel,
                controller: _nameController,
                focusNode: _nameFocusNode,
                errorText: _showNameError
                    ? SettingsAccountStrings.nameRequiredError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Professional designation * (required)
              AppTextField(
                label: SettingsAccountStrings.designationLabel,
                controller: _designationController,
                focusNode: _designationFocusNode,
                errorText: _showDesignationError
                    ? SettingsAccountStrings.designationRequiredError
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Business email (read-only with Verified pill)
              _buildEmailField(),
              const SizedBox(height: AppSpacing.lg),

              // Mobile / phone (optional)
              AppTextField(
                label: SettingsAccountStrings.phoneLabel,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Business address (optional)
              AppTextField(
                label: SettingsAccountStrings.addressLabel,
                controller: _addressController,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Change password row
              SettingsGroupCard(
                children: [
                  SettingsRow(
                    title: SettingsAccountStrings.changePasswordRow,
                    onTap: () => context.push(AppRoutes.settingsPasswordPath),
                    last: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
