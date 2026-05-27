import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/entities/settings.dart';
import '../../core/storage/hive_setup.dart';
import '../../design_system/atoms/kai_tide_curve.dart';
import '../../design_system/organisms/onboarding_card.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// 4-step onboarding flow matching `new-design/onboarding.html`.
///
/// Full-screen layout: SafeArea > Stack.
///   - Bottom layer: PageView of [OnboardingCard]s (each fills all available space).
///   - Overlay: tide curve positioned at the top, shown on steps 1–3 only.
///
/// On completion writes `onboarded = true` to Hive and navigates to `/room`.
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
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: KaiMotion.standard,
      curve: KaiMotion.standardCurve,
    );
  }

  /// Maps onboarding step index to the appropriate tide state.
  ///
  /// Matches `new-design/onboarding.html` step-by-step:
  /// - Step 0 (welcome): no tide overlay — hidden via AnimatedOpacity.
  /// - Step 1 (tide intro): `responding` — live dashed stream.
  /// - Steps 2-3 (gestures / context): `muted` — static gradient at 0.4
  ///   opacity (canon: `stroke-width="1.8" opacity="0.4"`). NOT idle, which
  ///   in the tide-states canon is a solid-gray breathing curve.
  KaiTideState _tideForStep(int step) {
    switch (step) {
      case 1:
        return KaiTide.responding;
      case 2:
      case 3:
        return KaiTide.muted;
      default:
        return KaiTide.idle;
    }
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
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // ── Content: full-screen PageView inside SafeArea ──────────────────
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                OnboardingCard(stepIndex: 0, onComplete: _nextPage),
                OnboardingCard(stepIndex: 1, onComplete: _nextPage),
                OnboardingCard(stepIndex: 2, onComplete: _nextPage),
                OnboardingCard(stepIndex: 3, onComplete: _finish),
              ],
            ),
          ),

          // ── Tide curve overlay: absolute, top = safe-area + 4px ──────────
          // Matches CLAUDE.md § Layout: tide curve 4px below safe area,
          // height: 16px per design canon.
          // Step 0 (welcome): hidden — no tide overlay in onboarding.html canon.
          // Steps 1–3: shown; step 1 uses KaiTide.responding (live stream).
          Positioned(
            top: topInset + 4,
            left: 16,
            right: 16,
            height: 16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: KaiTideCurve(
                  state: _tideForStep(_currentPage),
                  height: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
