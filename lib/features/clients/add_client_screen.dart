import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'client_strings.dart';
import 'data/data.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  int _mode = 0; // 0: Quick, 1: Advanced

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      return false;
    }
    final String email = _emailController.text.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      return false;
    }
    return true;
  }

  void _popOrGoClients() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.clientsPath);
    }
  }

  void _submit() {
    if (!_isValid) {
      return;
    }
    final ClientsRepository repo = ClientsScope.of(context, listen: false);

    final String newId = 'c_${DateTime.now().millisecondsSinceEpoch}';
    final int nextColorIndex = repo.clients.length % 4;

    final Client newClient = Client(
      id: newId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      linkedin: _linkedinController.text.trim(),
      twitter: _twitterController.text.trim(),
      github: _githubController.text.trim(),
      website: _websiteController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
      avatarColorIndex: nextColorIndex,
    );

    repo.add(newClient);
    _popOrGoClients();
    showAppToast(context, ClientStrings.clientAddedToast);
  }

  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ClientStrings.addNewClientTitle, style: AppText.title),
              const SizedBox(height: 4),
              Text(
                ClientStrings.addNewClientSubtitle,
                style: AppText.body.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ),
        RoundIconButton(icon: Icons.close_rounded, onPressed: _popOrGoClients),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.sm,
        AppSpacing.pageGutter,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: _mode == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: ClientStrings.addClient,
                  onPressed: _isValid ? _submit : null,
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: ClientStrings.cancel,
                  onPressed: _popOrGoClients,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: ClientStrings.cancel,
                    onPressed: _popOrGoClients,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: ClientStrings.addClient,
                    onPressed: _isValid ? _submit : null,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: _buildBottomBar(),
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
              _buildTopHeader(),
              const SizedBox(height: AppSpacing.xl),
              SegmentedToggle(
                options: const <String>[
                  ClientStrings.quickMode,
                  ClientStrings.advancedMode,
                ],
                selectedIndex: _mode,
                onChanged: (int index) => setState(() => _mode = index),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Client name * (Both modes)
              AppTextField(
                label: ClientStrings.clientNameLabel,
                placeholder: ClientStrings.clientNamePlaceholder,
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_mode == 0) ...[
                // Quick mode hint panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.seg,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                  ),
                  child: Text(
                    ClientStrings.quickModeHint,
                    style: AppText.bodyMedium.copyWith(
                      color: AppColors.mute,
                      height: 1.4,
                    ),
                  ),
                ),
              ] else ...[
                // Advanced mode fields
                AppTextField(
                  label: ClientStrings.emailLabel,
                  placeholder: ClientStrings.emailPlaceholder,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: ClientStrings.phoneLabel,
                  placeholder: ClientStrings.phonePlaceholder,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: ClientStrings.addressLabel,
                  placeholder: ClientStrings.addressPlaceholder,
                  controller: _addressController,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Social media links 2x2 grid
                Text(ClientStrings.socialLinksLabel, style: AppText.label),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        placeholder: ClientStrings.linkedinPlaceholder,
                        controller: _linkedinController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        placeholder: ClientStrings.twitterPlaceholder,
                        controller: _twitterController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        placeholder: ClientStrings.githubPlaceholder,
                        controller: _githubController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        placeholder: ClientStrings.websitePlaceholder,
                        controller: _websiteController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Notes multiline
                AppTextField(
                  label: ClientStrings.notesLabel,
                  placeholder: ClientStrings.notesPlaceholder,
                  controller: _notesController,
                  multiline: true,
                  maxLines: 4,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
