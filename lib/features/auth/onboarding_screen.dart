import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import 'auth_strings.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final String title;
  final String subtitle;
}

/// Screen 2-4: Onboarding carousel.
///
/// 3-page PageView (orange / purple / coral MascotPanel),
/// active dot indicator (24px ink pill, others 8px line),
/// Next / "Let's start" button, and Skip button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      color: AppColors.orange,
      title: AuthStrings.onboardingTitle1,
      subtitle: AuthStrings.onboardingSubtitle1,
    ),
    _OnboardingPageData(
      color: AppColors.purple,
      title: AuthStrings.onboardingTitle2,
      subtitle: AuthStrings.onboardingSubtitle2,
    ),
    _OnboardingPageData(
      color: AppColors.coral,
      title: AuthStrings.onboardingTitle3,
      subtitle: AuthStrings.onboardingSubtitle3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.push(AppRoutes.signUpPath);
    }
  }

  void _onSkipPressed() {
    context.push(AppRoutes.signInPath);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
                vertical: AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _onSkipPressed,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      AuthStrings.skip,
                      style: AppText.bodyMedium.copyWith(color: AppColors.mute),
                    ),
                  ),
                ),
              ),
            ),
            // Carousel content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  final _OnboardingPageData page = _pages[index];
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageGutter,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xs),
                          MascotPanel(
                            color: page.color,
                            height: 330,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          Text(
                            page.title,
                            style: AppText.sectionTitleLg,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            page.subtitle,
                            style: AppText.body.copyWith(color: AppColors.mute),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (int index) {
                final bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.ink : AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // Next / Let's start button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: PrimaryButton(
                label: isLastPage ? AuthStrings.letsStart : AuthStrings.next,
                onPressed: _onNextPressed,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
