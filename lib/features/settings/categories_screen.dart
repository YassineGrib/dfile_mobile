import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'data/data.dart';
import 'settings_prefs_strings.dart';
import 'widgets/settings_header.dart';

/// Screen for managing project categories (ST6).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleAddCategory(BuildContext context, SettingsRepository repo) {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final bool added = repo.addCategory(text);
    if (!added) {
      showAppToast(
        context,
        SettingsPrefsStrings.categoryExistsToast,
      );
    } else {
      _textController.clear();
      showAppToast(
        context,
        SettingsPrefsStrings.categoryAddedToast,
      );
    }
  }

  Widget _buildChip(
    BuildContext context,
    SettingsRepository repo,
    String category,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: AppText.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              repo.removeCategory(category);
              showAppToast(
                context,
                SettingsPrefsStrings.categoryRemovedToast,
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsRepository repo = SettingsScope.of(context);
    final List<String> categories = repo.categories;

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
                      title: SettingsPrefsStrings.categoriesTitle,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Subtitle
                    Text(
                      SettingsPrefsStrings.categoriesSubtitle,
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.mute,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Category chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        for (final String cat in categories)
                          _buildChip(context, repo, cat),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Tip box
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            SettingsPrefsStrings.tipTitle,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SettingsPrefsStrings.categoriesTip,
                            style: AppText.bodyMedium.copyWith(
                              color: AppColors.ink,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar with text field and add button
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
                  top: BorderSide(
                    color: AppColors.line,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _textController,
                        placeholder:
                            SettingsPrefsStrings.addCategoryPlaceholder,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleAddCategory(context, repo),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Material(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _handleAddCategory(context, repo),
                        child: const SizedBox(
                          width: AppSpacing.inputHeight,
                          height: AppSpacing.inputHeight,
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
