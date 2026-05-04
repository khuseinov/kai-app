import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/settings/presentation/sections/language_section.dart';

import '../../../test_helpers/fake_settings.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await initHiveForTest();
  });

  tearDownAll(() async {
    await tearDownHiveForTest(tempDir);
  });

  testWidgets('language section renders three choices', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: LanguageSection()),
        ),
      ),
    );

    expect(find.text('Авто'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
