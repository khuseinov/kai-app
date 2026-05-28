import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/network/connectivity_listener.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/repositories/chat_repository.dart';
import 'package:kai_app/core/repositories/mock_chat_repository.dart';
import 'package:kai_app/design_system/v3/organisms/kai_chat_list.dart';
import 'package:kai_app/features/room/room_state.dart';

// ─── Custom mock helpers ──────────────────────────────────────────────────────

/// A [ChatRepository] that emits exactly the given [events] in sequence,
/// with no delays (suitable for synchronous-ish testing).
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

ProviderContainer _makeContainer({ChatRepository? chatRepo}) {
  final overrides = <Override>[
    if (chatRepo != null)
      chatRepositoryProvider.overrideWith((ref) => chatRepo),
  ];
  return ProviderContainer(overrides: overrides);
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // Allow fake-async timers to fire in tests using testWidgets.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Edge state surfaces', () {
    // T6.12 Test 1 — Offline detection
    test('isOnlineProvider false → isOffline becomes true', () async {
      final container = ProviderContainer(
        overrides: [
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
        ],
      );
      addTearDown(container.dispose);

      // Read roomNotifierProvider to initialise the notifier (triggers ref.listen).
      container.read(roomNotifierProvider);

      // Allow the stream event + listen callback to propagate.
      await Future<void>.delayed(Duration.zero);

      final state = container.read(roomNotifierProvider);
      expect(state.isOffline, isTrue);
    });

    // T6.12 Test 2 — Rate limit: ChatEventRateLimit → isRateLimited + retryAfter set
    test('ChatEventRateLimit → isRateLimited is true and retryAfter is set',
        () async {
      final mock = _EventMockRepository([
        const ChatEventRateLimit(retryAfter: Duration(seconds: 5)),
      ]);
      final container = _makeContainer(chatRepo: mock);
      addTearDown(container.dispose);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await container.read(roomNotifierProvider.notifier).sendMessage('hi');
      // Let stream events propagate.
      await Future<void>.delayed(Duration.zero);

      final state = container.read(roomNotifierProvider);
      expect(state.isRateLimited, isTrue);
      expect(state.rateLimitRetryAfter, isNotNull);
    });

    // T6.12 Test 3 — Crisis: ChatEventMetadata with crisis:true → isCrisis true
    test('ChatEventMetadata crisis:true → isCrisis is true', () async {
      final mock = _EventMockRepository([
        const ChatEventMetadata(data: {'crisis': true}),
        const ChatEventDone(),
      ]);
      final container = _makeContainer(chatRepo: mock);
      addTearDown(container.dispose);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(roomNotifierProvider);
      expect(state.isCrisis, isTrue);
    });

    // T6.12 Test 4 — Error: ChatEventError → RoomFrame.error + KaiTide.error
    test('ChatEventError → currentFrame is error and tideState is error',
        () async {
      final mock = _EventMockRepository([
        const ChatEventError(message: 'boom'),
      ]);
      final container = _makeContainer(chatRepo: mock);
      addTearDown(container.dispose);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      await container.read(roomNotifierProvider.notifier).sendMessage('hi');
      await Future<void>.delayed(Duration.zero);

      final state = container.read(roomNotifierProvider);
      expect(state.currentFrame, RoomFrame.error);
      expect(state.tideState.name, 'error');
    });
  });

  group('Edge state: MockChatRepository error path', () {
    // Sanity: error session path works as before.
    test(':error session → error frame', () async {
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider
              .overrideWith((ref) => MockChatRepository()),
        ],
      );
      addTearDown(container.dispose);

      container.read(roomNotifierProvider);
      await Future<void>.delayed(Duration.zero);

      // MockChatRepository treats session id ending in ':error' as error.
      container
          .read(roomNotifierProvider.notifier)
          .switchSession('default-session:error');

      await container
          .read(roomNotifierProvider.notifier)
          .sendMessage('trigger');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final state = container.read(roomNotifierProvider);
      expect(state.currentFrame, RoomFrame.error);
    });
  });
}
