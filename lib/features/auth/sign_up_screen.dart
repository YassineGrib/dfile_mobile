import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';

/// Screen 6: Sign up screen.
///
/// Full name, email, password inputs, light validation (name not empty,
/// email contains @, password >= 8 characters), [Create account] button,
/// [Continue with Google] button, and "Already have an account? Sign in" link.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    bool isValid = true;

    if (name.isEmpty) {
      _nameError = AuthStrings.nameRequired;
      isValid = false;
    } else {
      _nameError = null;
    }

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
    } else if (password.length < 8) {
      _passwordError = AuthStrings.passwordMinLength;
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});

    if (isValid) {
      context.go(AppRoutes.clientsPath);
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
                        Text(AuthStrings.createAccount, style: AppText.title),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AuthStrings.signUpSubtitle,
                          style: AppText.body.copyWith(color: AppColors.mute),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        AppTextField(
                          label: AuthStrings.fullNameLabel,
                          placeholder: AuthStrings.fullNamePlaceholder,
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
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
                          placeholder: AuthStrings.passwordSignUpPlaceholder,
                          controller: _passwordController,
                          obscureText: true,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: AuthStrings.createAccount,
                          onPressed: _onCreateAccount,
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
                          onPressed: () => context.go(AppRoutes.clientsPath),
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.push(AppRoutes.signInPath);
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      '${AuthStrings.alreadyHaveAccountPrompt} ',
                                  style: AppText.body.copyWith(
                                    color: AppColors.mute,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AuthStrings.signInLink,
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
