import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

class _Probe extends StatelessWidget {
  const _Probe({required this.onBuild});

  final void Function(KaiTokens) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(KaiTheme.of(context));
    return const SizedBox.shrink();
  }
}

Future<KaiTokens> _pump(WidgetTester tester, ThemeMode mode) async {
  KaiTokens? captured;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: _Probe(onBuild: (t) => captured = t),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(captured, isNotNull, reason: 'KaiTheme.of must populate tokens');
  return captured!;
}

void main() {
  testWidgets('KaiTheme exposes light tokens when themeMode is light',
      (tester) async {
    final tokens = await _pump(tester, ThemeMode.light);
    expect(tokens.colors.bg, KaiColors.light.bg);
    expect(tokens.colors.ink1, KaiColors.light.ink1);
  });

  testWidgets('KaiTheme exposes dark tokens when themeMode is dark',
      (tester) async {
    final tokens = await _pump(tester, ThemeMode.dark);
    expect(tokens.colors.bg, KaiColors.dark.bg);
    expect(tokens.colors.ink1, KaiColors.dark.ink1);
  });
}
