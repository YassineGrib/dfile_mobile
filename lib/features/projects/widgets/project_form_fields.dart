import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../clients/data/data.dart';
import '../../settings/data/data.dart';
import '../data/project.dart';
import '../project_strings.dart';
import 'project_status_chip.dart';

/// Palette cycle matching client avatars across `ClientsListScreen` and `ProjectDetailScreen`.
Color projectClientAvatarColor(int index) {
  const List<Color> palette = <Color>[
    AppColors.orange,
    AppColors.purple,
    AppColors.yellow,
    AppColors.coral,
  ];
  return palette[index % palette.length];
}

/// Labelled tappable input-styled selector field (height 56, radius 16, white fill, 1.5px border).
class ProjectSelectField extends StatelessWidget {
  const ProjectSelectField({
    super.key,
    this.label,
    this.value,
    this.placeholder,
    required this.onTap,
    this.leading,
    this.showArrow = true,
    this.hasError = false,
  });

  final String? label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final Widget? leading;
  final bool showArrow;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.trim().isNotEmpty;

    final Widget box = Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: hasError ? AppColors.red : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.inputHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  hasValue ? value! : (placeholder ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hasValue
                      ? AppText.body
                      : AppText.body.copyWith(color: AppColors.placeholder),
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 22,
                  color: AppColors.mute,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (label == null) {
      return box;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label!, style: AppText.label),
        const SizedBox(height: AppSpacing.sm),
        box,
      ],
    );
  }
}

/// Progress percentage slider (0..100) with live `%` readout matching P16 and P17.
class ProjectProgressSlider extends StatelessWidget {
  const ProjectProgressSlider({
    super.key,
    required this.label,
    required this.progress,
    required this.onChanged,
  });

  final String label;
  final int progress;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final int clamped = progress.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.label,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$clamped%',
              style: AppText.cardTitle,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: AppColors.purple,
            inactiveTrackColor: AppColors.seg,
            thumbColor: AppColors.card,
            overlayColor: AppColors.purple.withValues(alpha: 0.14),
            trackShape: const _FlushRoundedSliderTrackShape(),
            thumbShape: const _OutlinedCircleThumbShape(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: SizedBox(
            height: 36,
            child: Slider(
              value: clamped.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (double value) => onChanged(value.round()),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlushRoundedSliderTrackShape extends RoundedRectSliderTrackShape {
  const _FlushRoundedSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 8;
    final double thumbRadius = 12;
    final double trackLeft = offset.dx + thumbRadius;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = math.max(
      0.0,
      parentBox.size.width - thumbRadius * 2,
    );
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _OutlinedCircleThumbShape extends SliderComponentShape {
  const _OutlinedCircleThumbShape();

  static const double _radius = 12;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(_radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint fillPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, _radius - 1.5, fillPaint);
    canvas.drawCircle(center, _radius - 1.5, borderPaint);
  }
}

/// Fixed bottom action bar that stays visible above the software keyboard (P12..P17).
class ProjectFormBottomBar extends StatelessWidget {
  const ProjectFormBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.md,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: secondaryLabel == null
              ? PrimaryButton(
                  label: primaryLabel,
                  onPressed: onPrimaryPressed,
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SecondaryButton(
                        label: secondaryLabel!,
                        onPressed: onSecondaryPressed,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: primaryLabel,
                        onPressed: onPrimaryPressed,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

Widget _buildRadioIndicator(bool isSelected) {
  return Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected ? AppColors.ink : AppColors.line,
        width: AppSpacing.borderWidth,
      ),
      color: isSelected ? AppColors.ink : AppColors.transparent,
    ),
    alignment: Alignment.center,
    child: isSelected
        ? const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.white,
          )
        : null,
  );
}

/// Opens a bottom sheet picker for choosing a project category.
Future<String?> showCategoryPickerSheet({
  required BuildContext context,
  required String selectedCategory,
  List<String>? categories,
}) {
  List<String>? scopeCategories = categories;
  if (scopeCategories == null) {
    try {
      scopeCategories = SettingsScope.of(context, listen: false).categories;
    } catch (_) {
      // Fallback if SettingsScope is not available.
    }
  }
  final List<String> options = List<String>.of(
    scopeCategories ?? ProjectStrings.projectCategories,
  );
  if (selectedCategory.trim().isNotEmpty &&
      !options.contains(selectedCategory)) {
    options.insert(0, selectedCategory);
  }

  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProjectStrings.selectCategoryTitle,
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _PickerOptionRow(
                onTap: () => Navigator.of(sheetContext).pop(options[i]),
                isSelected: options[i] == selectedCategory,
                child: Text(
                  options[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyBold.copyWith(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

/// Opens a bottom sheet picker listing clients from [ClientsRepository].
Future<String?> showClientPickerSheet({
  required BuildContext context,
  required List<Client> clients,
  required String? selectedClientId,
}) {
  return showAppSheet<String>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProjectStrings.selectClientTitle,
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < clients.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _PickerOptionRow(
                onTap: () => Navigator.of(sheetContext).pop(clients[i].id),
                isSelected: clients[i].id == selectedClientId,
                child: Row(
                  children: [
                    InitialAvatar(
                      initial: clients[i].name,
                      color: projectClientAvatarColor(
                        clients[i].avatarColorIndex,
                      ),
                      size: 34,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        clients[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bodyBold.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

/// Opens a bottom sheet picker for choosing one of the 6 [ProjectStatus] values.
Future<ProjectStatus?> showStatusPickerSheet({
  required BuildContext context,
  required ProjectStatus selectedStatus,
}) {
  return showAppSheet<ProjectStatus>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProjectStrings.selectStatusTitle,
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < ProjectStatus.values.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _PickerOptionRow(
                onTap: () =>
                    Navigator.of(sheetContext).pop(ProjectStatus.values[i]),
                isSelected: ProjectStatus.values[i] == selectedStatus,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ProjectStatusChip(status: ProjectStatus.values[i]),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _PickerOptionRow extends StatelessWidget {
  const _PickerOptionRow({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        side: BorderSide(
          color: isSelected ? AppColors.ink : AppColors.line,
          width: AppSpacing.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(child: child),
              const SizedBox(width: AppSpacing.sm),
              _buildRadioIndicator(isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
