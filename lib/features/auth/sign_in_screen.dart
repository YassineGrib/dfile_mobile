import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';
import 'data/auth_service.dart';

/// Screen 5: Sign in screen.
///
/// Email + password inputs, inline validation, show/hide password toggle,
/// "Forgot password?" link, [Sign in] button, [Continue with Google] button,
/// and "New here? Create an account" link.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

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

    if (password.isEmpty) {
      _passwordError = AuthStrings.passwordRequired;
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});

    if (isValid) {
      await _run(AuthScope.of(context).signInWithEmail(email, password));
    }
  }

  Future<void> _onGoogle() => _run(AuthScope.of(context).signInWithGoogle());

  Future<void> _run(Future<AuthResult> call) async {
    if (_busy) return;
    setState(() => _busy = true);
    final AuthResult result = await call;
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isOk) {
      context.go(AppRoutes.homePath);
    } else {
      showAppToast(context, result.error!);
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
                        const SizedBox(height: AppSpacing.xxl),
                        Text(AuthStrings.welcomeBack, style: AppText.title),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AuthStrings.signInSubtitle,
                          style: AppText.body.copyWith(color: AppColors.mute),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
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
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: AuthStrings.passwordLabel,
                          placeholder: AuthStrings.passwordPlaceholder,
                          controller: _passwordController,
                          obscureText: true,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () =>
                                context.push(AppRoutes.forgotPasswordPath),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                AuthStrings.forgotPasswordLink,
                                style: AppText.bodyMedium.copyWith(
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: AuthStrings.signIn,
                          onPressed: _busy ? null : _onSignIn,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: Text(
                            AuthStrings.orDivider,
                            style: AppText.caption.copyWith(
                              color: AppColors.mute,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SecondaryButton(
                          label: AuthStrings.continueWithGoogle,
                          leading: SvgPicture.asset(
                            'assets/images/google_g.svg',
                            width: 22,
                            height: 22,
                          ),
                          onPressed: _busy ? null : _onGoogle,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.signUpPath),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '${AuthStrings.newHere} ',
                                  style: AppText.body.copyWith(
                                    color: AppColors.mute,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AuthStrings.createAccountLink,
                                      style: AppText.bodyMedium.copyWith(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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
