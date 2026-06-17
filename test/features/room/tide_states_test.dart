import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';

// ─── Custom mock helpers ──────────────────────────────────────────────────────

/// A [ChatRepository] that emits exactly the given [events] in sequence,
/// with no delays.
class _EventMockRepository implements ChatRepository {
  _EventMockRepository(this._events);

  final List<ChatEvent> _events;

  @override
  Stream<ChatEvent> sendMessage(String text, String sessionId) async* {
    for (final event in _events) {
      yield event;
    }
  }

  @override
  Future<void> cancelStreaming(String sessionId) async {}
}

/// A [ChatRepository] that holds the stream open indefinitely until cancelled,
/// used to test mid-stream state transitions.
class _HoldingMockRepository implements ChatRepository {
  final StreamController<ChatEvent> _controller =
      StreamController<ChatEvent>();

  void emit(ChatEvent e) => _controller.add(e);

  @override
  Stream<ChatEvent> sendMessage(String text, String sessionId) =>
      _controller.stream;

  @override
  Future<void> cancelStreaming(String sessionId) async {
    if (!_controller.isClosed) await _controller.close();
  }
}

// ─── Test utilities ───────────────────────────────────────────────────────────

ProviderContainer _makeContainer(ChatRepository repo) {
  return ProviderContainer(
    overrides: [chatRepositoryProvider.overrideWith((ref) => repo)],
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tide state transitions', () {
    // T6.13 Test 1 — Initial state is idle
    test('initial tideState is idle', () {
      final container = _makeContainer(_EventMockRepository([]));
      addTearDown(container.dispose);

      final state = container.read(roomNotifierProvider);
      expect(state.tideState.name, 'idle');
    });

    // T6.13 Test 2 — sendMessage → thinking
    test('sendMessage → tideState becomes thinking', () async {
      final repo = _HoldingMockRepository();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);
      addTearDown(repo._controller.close);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      // Fire and forget — don't await, we want to inspect mid-stream.
      container.read(roomNotifierProvider.notifier).sendMessage('hello');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(roomNotifierProvider);
      expect(state.tideState.name, 'thinking');
    });

    // T6.13 Test 3 — ChatEventState('responding') → responding
    test('ChatEventState(responding) → tideState is responding', () async {
      final repo = _HoldingMockRepository();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);
      addTearDown(repo._controller.close);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await Future<void>.delayed(Duration.zero);

      repo.emit(const ChatEventState(state: 'responding'));
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(roomNotifierProvider).tideState.name,
        'responding',
      );
    });

    // T6.13 Test 4 — ChatEventDone → success then idle after 1200ms
    testWidgets('ChatEventDone → success, then idle after 1200ms',
        (tester) async {
      final repo = _EventMockRepository([
        const ChatEventDone(),
      ]);
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWith((ref) => repo),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await tester.pump();

      // Right after done: success
      expect(
        container.read(roomNotifierProvider).tideState.name,
        'success',
      );

      // After 1200ms flash timer: idle
      await tester.pump(const Duration(milliseconds: 1300));
      expect(
        container.read(roomNotifierProvider).tideState.name,
        'idle',
      );
    });

    // T6.13 Test 5 — ChatEventError → error
    test('ChatEventError → tideState is error', () async {
      final container = _makeContainer(
        _EventMockRepository([const ChatEventError(message: 'x')]),
      );
      addTearDown(container.dispose);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(roomNotifierProvider).tideState.name,
        'error',
      );
    });

    // T6.13 Test 6 — memory_saved metadata → memory ephemeral
    testWidgets('ChatEventMetadata memory_saved → memory, then reverts',
        (tester) async {
      // Use a holding repo so we can control when events arrive.
      final repo = _HoldingMockRepository();
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWith((ref) => repo),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Kick off the stream (don't await — stream stays open).
      container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await tester.pump();

      // Emit responding then memory_saved — no done yet.
      repo.emit(const ChatEventState(state: 'responding'));
      await tester.pump();

      repo.emit(const ChatEventMetadata(data: {'memory_saved': true}));
      await tester.pump();

      // Right after metadata: memory
      expect(
        container.read(roomNotifierProvider).tideState.name,
        'memory',
      );

      // After 900ms memory timer: should revert to 'responding' (previousTide).
      await tester.pump(const Duration(milliseconds: 950));
      expect(
        container.read(roomNotifierProvider).tideState.name,
        'responding',
      );
    });

    // T6.13 Test 7 — 60s inactivity → sleep
    testWidgets('60s inactivity → tideState becomes sleep', (tester) async {
      final repo = _EventMockRepository([]);
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWith((ref) => repo),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Trigger the notifier build so inactivity timer starts.
      container.read(roomNotifierProvider);
      await tester.pump();

      // Advance fake time by 61 seconds.
      await tester.pump(const Duration(seconds: 61));

      expect(
        container.read(roomNotifierProvider).tideState.name,
        'sleep',
      );
    });

    // T6.13 Test 8 — cancelStreaming → idle
    test('cancelStreaming → tideState becomes idle', () async {
      final repo = _HoldingMockRepository();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);
      addTearDown(repo._controller.close);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await Future<void>.delayed(Duration.zero);

      // Mid-stream: thinking
      expect(
        container.read(roomNotifierProvider).tideState.name,
        'thinking',
      );

      await container.read(roomNotifierProvider.notifier).cancelStreaming();
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(roomNotifierProvider).tideState.name,
        'idle',
      );
    });
  });
}
