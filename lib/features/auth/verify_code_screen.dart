import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';

/// Screen 8: Verify code (OTP) screen.
///
/// 6 single-digit boxes with auto-advance, backspace support, paste support,
/// purple focus border, 30-second resend countdown timer, [Verify] button
/// enabled only when all 6 digits are entered, and "Change email" link.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, this.email});

  final String? email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _codeLength = 6;
  static const int _countdownDuration = 30;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _timer;
  int _secondsLeft = _countdownDuration;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(
      _codeLength,
      (int index) => FocusNode(debugLabel: 'OTP-$index'),
    );

    for (int i = 0; i < _codeLength; i++) {
      final int index = i;
      _focusNodes[index].addListener(() {
        if (mounted) setState(() {});
      });

      _focusNodes[index].onKeyEvent = (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_controllers[index].text.isEmpty && index > 0) {
            _controllers[index - 1].clear();
            _focusNodes[index - 1].requestFocus();
            _updateComplete();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final TextEditingController c in _controllers) {
      c.dispose();
    }
    for (final FocusNode f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _countdownDuration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      }
    });
  }

  void _updateComplete() {
    final bool complete = _controllers.every((c) => c.text.isNotEmpty);
    if (complete != _isComplete) {
      setState(() => _isComplete = complete);
    }
  }

  void _handleInput(int index, String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= _codeLength) {
      // Pasted 6 or more digits
      for (int j = 0; j < _codeLength; j++) {
        _controllers[j].text = digits[j];
      }
      _focusNodes[_codeLength - 1].requestFocus();
      _updateComplete();
      return;
    }

    if (digits.length > 1) {
      // Typing when a digit already existed: use latest character
      final String char = digits.characters.last;
      _controllers[index].text = char;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (digits.length == 1) {
      _controllers[index].text = digits;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      _controllers[index].clear();
    }

    _updateComplete();
  }

  void _onVerify() {
    context.go(AppRoutes.signInPath);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.forgotPasswordPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String targetEmail =
        widget.email ??
        (GoRouterState.of(context).extra as String?) ??
        AuthStrings.emailPlaceholder;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        RoundIconButton(
                          icon: Icons.arrow_back,
                          onPressed: _onBack,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const MascotPanel(color: AppColors.purple, height: 210),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(AuthStrings.checkYourEmail, style: AppText.title),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${AuthStrings.verifySubtitlePrefix}$targetEmail${AuthStrings.verifySubtitleSuffix}',
                          style: AppText.body.copyWith(color: AppColors.mute),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // 6 OTP single-digit boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_codeLength, (int i) {
                            final bool isFocused = _focusNodes[i].hasFocus;
                            return Container(
                              width: 48,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.otp,
                                ),
                                border: Border.all(
                                  color: isFocused
                                      ? AppColors.purple
                                      : AppColors.line,
                                  width: isFocused
                                      ? 2.0
                                      : AppSpacing.borderWidth,
                                ),
                              ),
                              child: TextField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                cursorColor: AppColors.purple,
                                style: AppText.sectionTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  counterText: '',
                                ),
                                onChanged: (String value) =>
                                    _handleInput(i, value),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // Resend countdown or action
                        Center(
                          child: _secondsLeft > 0
                              ? Text(
                                  '${AuthStrings.didNotGetIt}  ${AuthStrings.resendIn}0:${_secondsLeft.toString().padLeft(2, '0')}',
                                  style: AppText.body.copyWith(
                                    color: AppColors.mute,
                                  ),
                                )
                              : Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      '${AuthStrings.didNotGetIt} ',
                                      style: AppText.body.copyWith(
                                        color: AppColors.mute,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _startTimer,
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: Text(
                                          AuthStrings.resendCode,
                                          style: AppText.bodyMedium.copyWith(
                                            color: AppColors.purple,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        PrimaryButton(
                          label: AuthStrings.verify,
                          onPressed: _isComplete ? _onVerify : null,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.forgotPasswordPath);
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                AuthStrings.changeEmail,
                                style: AppText.bodyMedium.copyWith(
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
