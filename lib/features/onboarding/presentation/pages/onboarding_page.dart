import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_onboarding_card.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_onboarding_scale.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_step_indicator.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// 4-step onboarding flow matching `new-design/onboarding.html`.
///
/// Full-screen layout: SafeArea > Stack.
///   - Bottom layer: Column of PageView (transitioning content) + fixed footer.
///   - Overlay: tide curve positioned at the top, shown on steps 1–3 only.
///
/// On completion writes `onboarded = true` to Hive and navigates to `/room`.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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

  Widget _buildFixedCTA(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String label;
    final VoidCallback callback;

    switch (_currentPage) {
      case 1:
        label = l10n.onboardingStep1CTA; // "Понятно"
        callback = _nextPage;
      case 3:
        label = l10n.onboardingStart; // "Начать использовать Kai"
        callback = _finish;
      default:
        label = l10n.onboardingNext; // "Продолжить"
        callback = _nextPage;
    }

    return KaiButton.tide(
      onPressed: callback,
      label: label,
      size: KaiButtonSize.lg,
      neutralAtRest: true,
      fullWidth: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaiTheme.of(context).colors;
    final topInset = MediaQuery.of(context).padding.top;
    final scale = onboardingScale(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Stack(
            children: [
              // ── Content: full-screen transition PageView + static footer ──────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          KaiOnboardingCard(stepIndex: 0, scale: scale),
                          KaiOnboardingCard(stepIndex: 1, scale: scale),
                          KaiOnboardingCard(stepIndex: 2, scale: scale),
                          KaiOnboardingCard(stepIndex: 3, scale: scale),
                        ],
                      ),
                    ),
                    // Fixed Footer: step dots + CTA button in stationary flow
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24 * scale,
                        16 * scale,
                        24 * scale,
                        28 * scale,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: KaiStepIndicator(
                              count: 4,
                              active: _currentPage,
                              scale: scale,
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          _buildFixedCTA(context),
                        ],
                      ),
                    ),
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
                left: 16 * scale,
                right: 16 * scale,
                height: 16 * scale,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: KaiTideCurve(
                      state: _tideForStep(_currentPage),
                      height: 16 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
