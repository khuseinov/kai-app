import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/room/data/repositories/mock_chat_repository.dart';
import 'package:kai_app/features/room/presentation/pages/room_page.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_chat_list.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// Test wrapper with provider overrides and a stable container ref.
class _RoomTestHarness extends StatelessWidget {
  const _RoomTestHarness({required this.onContainer});

  final void Function(ProviderContainer) onContainer;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(() => _MockThemeModeNotifier(ThemeMode.light)),
        chatRepositoryProvider.overrideWith((ref) => MockChatRepository()),
      ],
      child: _ContainerCapture(
        onContainer: onContainer,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: [Locale('ru'), Locale('en')],
          locale: Locale('ru'),
          home: KaiTheme(
            child: Scaffold(body: RoomPage()),
          ),
        ),
      ),
    );
  }
}

/// Utility widget that captures the ProviderContainer from the nearest scope.
class _ContainerCapture extends ConsumerWidget {
  const _ContainerCapture({required this.onContainer, required this.child});

  final void Function(ProviderContainer) onContainer;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Capture container on first build.
    onContainer(ProviderScope.containerOf(context));
    return child;
  }
}

void main() {
  group('RoomScreen', () {
    testWidgets('starts in empty frame', (tester) async {
      ProviderContainer? container;
      await tester.pumpWidget(
        _RoomTestHarness(onContainer: (c) => container = c),
      );
      await tester.pump();

      // In empty frame, ChatList shows the invitation title.
      expect(find.text('Куда едем сегодня?'), findsOneWidget);
      expect(container!.read(roomNotifierProvider).currentFrame, RoomFrame.empty);
    });

    testWidgets('after sendMessage: transitions to live frame', (tester) async {
      ProviderContainer? container;
      await tester.pumpWidget(
        _RoomTestHarness(onContainer: (c) => container = c),
      );
      await tester.pump();

      final notifier = container!.read(roomNotifierProvider.notifier);

      // Send a message — don't await the future (stream runs async).
      notifier.sendMessage('hello');
      await tester.pump();

      // Frame immediately transitions to streaming (streaming begins).
      expect(container!.read(roomNotifierProvider).currentFrame, RoomFrame.streaming);

      // Pump through the full mock stream (State1: 800ms + State2: 800ms + chunks + done ≈ 3000ms).
      await tester.pump(const Duration(milliseconds: 3500));

      // After done event, frame should be live and not streaming.
      final finalState = container!.read(roomNotifierProvider);
      expect(finalState.currentFrame, RoomFrame.live);
      expect(finalState.isStreaming, isFalse);
    });

    testWidgets('while streaming: frame is streaming', (tester) async {
      ProviderContainer? container;
      await tester.pumpWidget(
        _RoomTestHarness(onContainer: (c) => container = c),
      );
      await tester.pump();

      final notifier = container!.read(roomNotifierProvider.notifier);

      // Start sending — don't await.
      notifier.sendMessage('stream me');

      // Pump enough to get past state events but before done.
      // MockChatRepository: 80ms + 800ms (State1) + 800ms (State2) before first chunk.
      await tester.pump(const Duration(milliseconds: 1000));

      final midState = container!.read(roomNotifierProvider);
      expect(midState.isStreaming, isTrue);

      // Drain remaining mock timers so the test closes cleanly.
      // Total mock stream ≈2700ms; we've pumped 1000ms, so pump 2500ms more.
      await tester.pump(const Duration(milliseconds: 2500));
    });
  });
}

class _MockThemeModeNotifier extends ThemeModeNotifier {
  _MockThemeModeNotifier(this._initialMode);
  final ThemeMode _initialMode;
  @override
  ThemeMode build() => _initialMode;
}
