import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/entities/settings.dart';
import '../../core/storage/hive_setup.dart';
import '../../design_system/atoms/kai_button.dart';
import '../../design_system/atoms/kai_tide_curve.dart';
import '../../design_system/organisms/onboarding_card.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// 4-step onboarding flow.
///
/// Drives a [PageView] of [OnboardingCard]s. The dots indicator tracks
/// the current page. On completion, writes `onboarded = true` to Hive
/// and navigates to `/room`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: KaiMotion.standard,
      curve: KaiMotion.standardCurve,
    );
  }

  Future<void> _finish() async {
    final box = HiveSetup.settings;
    final current =
        box.get(HiveSetup.settingsKey) ?? const AppSettings();
    await box.put(HiveSetup.settingsKey, current.copyWith(onboarded: true));
    if (mounted) context.go('/room');
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaiTheme.of(context).colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const KaiTideCurve(state: KaiTide.idle, height: 48),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Page(
                    child: OnboardingCard(
                      stepIndex: 0,
                      onComplete: _nextPage,
                    ),
                  ),
                  _Page(
                    child: OnboardingCard(
                      stepIndex: 1,
                      onComplete: _nextPage,
                    ),
                  ),
                  _Page(
                    child: OnboardingCard(
                      stepIndex: 2,
                      onComplete: _nextPage,
                    ),
                  ),
                  _Page(
                    child: OnboardingCard(
                      stepIndex: 3,
                      onComplete: _finish,
                    ),
                  ),
                ],
              ),
            ),
            _DotsIndicator(count: 4, active: _currentPage),
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpace.s5,
                ),
                child: KaiButton.tide(
                  onPressed: _nextPage,
                  label: AppLocalizations.of(context).onboardingNext,
                ),
              ),
            const SizedBox(height: KaiSpace.s6),
          ],
        ),
      ),
    );
  }
}

/// Centres its child in a padded page.
class _Page extends StatelessWidget {
  const _Page({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaiSpace.s5),
      child: Center(child: child),
    );
  }
}

/// Simple row of 4 dot indicators.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final colors = KaiTheme.of(context).colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? colors.accent
                : colors.ink4.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
