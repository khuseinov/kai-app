import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';

/// Represents a pending message waiting to be sent.
class PendingMessage {
  final String id;
  final String text;
  final String sessionId;
  final DateTime queuedAt;

  const PendingMessage({
    required this.id,
    required this.text,
    required this.sessionId,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'session_id': sessionId,
        'queued_at': queuedAt.toIso8601String(),
      };

  factory PendingMessage.fromJson(Map<String, dynamic> json) => PendingMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        sessionId: json['session_id'] as String,
        queuedAt: DateTime.parse(json['queued_at'] as String),
      );
}

/// Queue for messages that could not be sent due to offline state.
/// Automatically flushes when connectivity is restored.
class OfflineQueue {
  final Box _pendingBox;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _connectivitySub;

  /// Callback to flush a single message. Returns true if sent successfully.
  Future<bool> Function(PendingMessage message)? onFlushMessage;

  OfflineQueue({
    required Box pendingBox,
    required ConnectivityService connectivity,
  })  : _pendingBox = pendingBox,
        _connectivity = connectivity {
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) flush();
    });
  }

  bool get isOnline => _connectivity.isOnline;

  Future<void> enqueue(PendingMessage message) async {
    await _pendingBox.put(message.id, message.toJson());
  }

  List<PendingMessage> get pendingMessages {
    return _pendingBox.values
        .map((e) => PendingMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt)); // FIFO
  }

  int get pendingCount => _pendingBox.length;

  Future<void> flush() async {
    if (onFlushMessage == null) return;

    final messages = pendingMessages;
    for (final msg in messages) {
      final success = await onFlushMessage!(msg);
      if (success) {
        await _pendingBox.delete(msg.id);
      } else {
        break; // Stop flushing on first failure
      }
    }
  }

  Future<void> remove(String id) async {
    await _pendingBox.delete(id);
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  final queue = OfflineQueue(
    pendingBox: Hive.box('pending_messages'),
    connectivity: ref.watch(connectivityServiceProvider),
  );
  ref.onDispose(() => queue.dispose());
  return queue;
});
