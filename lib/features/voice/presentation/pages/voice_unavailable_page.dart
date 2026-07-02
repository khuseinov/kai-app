import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// Shown instead of [VoicePage] on web builds: the live-voice pipeline is
/// mobile-only (dart:io mic streaming + FFI opus/soloud would throw on web).
class VoiceUnavailablePage extends StatelessWidget {
  const VoiceUnavailablePage({super.key});

  /// Whether the live-voice pipeline can run on this platform.
  /// Injectable-by-constant: widget tests pump this page directly, and the
  /// router checks this getter, so the guard has a single source of truth.
  static bool get voiceSupported => !kIsWeb;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.voiceErrorWebUnsupported,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: c.ink1,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/room'),
                child: Text(loc.commonBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
