import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../clients/data/data.dart';
import '../expenses/data/data.dart';
import '../friends/data/data.dart';
import '../projects/data/data.dart';
import 'data/account_deletion.dart';
import 'data/settings_scope.dart';
import 'settings_privacy_strings.dart';

/// Progress screen displaying staged account deletion steps per `docs/design/SPEC.md` (PS6).
class DeleteAccountProgressScreen extends StatefulWidget {
  const DeleteAccountProgressScreen({
    super.key,
    this.stepDuration = const Duration(milliseconds: 500),
  });

  /// Duration for each of the 5 deletion stages. In widget tests, can be set
  /// to a short duration or `Duration.zero` for instantaneous ticks.
  final Duration stepDuration;

  @override
  State<DeleteAccountProgressScreen> createState() =>
      _DeleteAccountProgressScreenState();
}

class _DeleteAccountProgressScreenState
    extends State<DeleteAccountProgressScreen> {
  int _completedSteps = 0;
  Timer? _timer;

  static const List<String> _steps = <String>[
    SettingsPrivacyStrings.stepClients,
    SettingsPrivacyStrings.stepProjects,
    SettingsPrivacyStrings.stepPayments,
    SettingsPrivacyStrings.stepFriends,
    SettingsPrivacyStrings.stepProfile,
  ];

  @override
  void initState() {
    super.initState();
    _startStagedDeletion();
  }

  void _startStagedDeletion() {
    if (widget.stepDuration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        wipeAllUserData(context);
        if (mounted) {
          setState(() {
            _completedSteps = _steps.length;
          });
          context.go(AppRoutes.accountDeletedPath);
        }
      });
      return;
    }

    _timer = Timer.periodic(widget.stepDuration, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        _timer = null;
        return;
      }

      final int nextStep = _completedSteps + 1;

      // Incrementally clear the corresponding data as each staged row ticks
      switch (nextStep) {
        case 1:
          ClientsScope.of(context, listen: false).clearAll();
          break;
        case 2:
          ProjectsScope.of(context, listen: false).clearAll();
          break;
        case 3:
          ExpensesScope.of(context, listen: false).clearAll();
          break;
        case 4:
          FriendsScope.of(context, listen: false).clearAll();
          break;
        case 5:
          SettingsScope.of(context, listen: false).clearAll();
          break;
      }

      setState(() {
        _completedSteps = nextStep;
      });

      if (_completedSteps >= _steps.length) {
        timer.cancel();
        _timer = null;
        wipeAllUserData(context);
        if (mounted) {
          context.go(AppRoutes.accountDeletedPath);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Widget _buildStepRow(int index, String title) {
    final bool isFinished = index < _completedSteps;
    final bool isCurrent = index == _completedSteps;

    Widget leading;
    if (isFinished) {
      leading = const Icon(
        Icons.check_circle_rounded,
        color: AppColors.green,
        size: 20,
      );
    } else if (isCurrent) {
      leading = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.ink,
        ),
      );
    } else {
      leading = Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.line,
            width: 2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppText.bodyMedium.copyWith(
                color: isFinished
                    ? AppColors.ink
                    : (isCurrent ? AppColors.ink : AppColors.mute),
                fontWeight: isFinished || isCurrent
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppColors.ink,
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    SettingsPrivacyStrings.deletingAccountTitle,
                    style: AppText.title.copyWith(fontSize: 26),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    SettingsPrivacyStrings.deletingAccountSubtitle,
                    style: AppText.body.copyWith(
                      color: AppColors.mute,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Staged rows card
                  Container(
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
                      children: List<Widget>.generate(
                        _steps.length,
                        (int i) => _buildStepRow(i, _steps[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
