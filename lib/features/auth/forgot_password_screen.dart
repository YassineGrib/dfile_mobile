import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';
import 'data/auth_service.dart';

/// Screen 7: Forgot password screen.
///
/// Back button, orange MascotPanel, email field, [Send code] button,
/// and "Back to sign in" link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendCode() async {
    final String email = _emailController.text.trim();

    bool isValid = true;
    if (email.isEmpty) {
      _emailError = AuthStrings.emailRequired;
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = AuthStrings.emailInvalid;
      isValid = false;
    } else {
      _emailError = null;
    }

    setState(() {});

    if (!isValid || _busy) return;
    setState(() => _busy = true);
    final AuthResult result = await AuthScope.of(context)
        .sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sent = result.isOk;
    });
    if (!result.isOk) showAppToast(context, result.error!);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.signInPath);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        const MascotPanel(color: AppColors.orange, height: 210),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          AuthStrings.forgotPasswordTitle,
                          style: AppText.title,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AuthStrings.forgotPasswordSubtitle,
                          style: AppText.body.copyWith(color: AppColors.mute),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          label: AuthStrings.emailLabel,
                          placeholder: AuthStrings.emailPlaceholder,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        if (_sent) ...[
                          Text(
                            AuthStrings.resetLinkSent(
                              _emailController.text.trim(),
                            ),
                            style: AppText.body.copyWith(color: AppColors.mute),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        PrimaryButton(
                          label: _sent
                              ? AuthStrings.backToSignIn
                              : AuthStrings.sendResetLink,
                          onPressed: _busy
                              ? null
                              : (_sent ? _onBack : _onSendCode),
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: GestureDetector(
                            onTap: _onBack,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                AuthStrings.backToSignIn,
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
