import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_prefs_strings.dart';
import 'widgets/settings_header.dart';

/// Screen for managing legal clauses template (ST7).
class LegalClausesScreen extends StatefulWidget {
  const LegalClausesScreen({super.key});

  @override
  State<LegalClausesScreen> createState() => _LegalClausesScreenState();
}

class _LegalClausesScreenState extends State<LegalClausesScreen> {
  late final TextEditingController _controller;
  int _characterCount = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final SettingsRepository repo = SettingsScope.of(context, listen: false);
      _controller.text = repo.legalClauses;
      _characterCount = _controller.text.length;
    }
  }

  void _onTextChanged() {
    final int count = _controller.text.length;
    if (count != _characterCount) {
      setState(() {
        _characterCount = count;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context, SettingsRepository repo) {
    repo.setLegalClauses(_controller.text);
    showAppToast(context, SettingsPrefsStrings.legalClausesUpdatedToast);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settingsPreferencesPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                  AppSpacing.pageGutter,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsHeader(
                      title: SettingsPrefsStrings.legalClausesTitle,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Subtitle
                    Text(
                      SettingsPrefsStrings.legalClausesSubtitle,
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.mute,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Editor container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: AppColors.line,
                          width: AppSpacing.borderWidth,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        style: AppText.bodyMedium.copyWith(
                          color: AppColors.ink,
                          height: 1.5,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Character counter
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        SettingsPrefsStrings.charactersCount(_characterCount),
                        style: AppText.caption.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar with Save button
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                12,
                AppSpacing.pageGutter,
                12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(
                  top: BorderSide(color: AppColors.line, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: SettingsPrefsStrings.saveClausesButton,
                  onPressed: () => _handleSave(context, repo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
