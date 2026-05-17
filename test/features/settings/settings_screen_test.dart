import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/settings/presentation/settings_screen.dart';

import '../../test_helpers/fake_settings.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await initHiveForTest();
  });

  tearDownAll(() async {
    await tearDownHiveForTest(tempDir);
  });

  testWidgets('SettingsScreen renders section headers', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Внешний вид'), findsOneWidget);
    expect(find.text('Голос'), findsOneWidget);
    expect(find.text('Аккаунт'), findsOneWidget);
    expect(find.text('Данные'), findsOneWidget);
    expect(find.text('О приложении'), findsOneWidget);
  });
}
