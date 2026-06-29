import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real-time duplex voice client over WebSocket.
///
/// Binary frames → outgoing PCM16 audio chunks to server.
/// Text frames → JSON control events (both directions).
///
/// Usage:
///   final client = WsVoiceClient(wsUrl: '...', apiKey: '...');
///   await client.connect(userId: '...', sessionId: '...', language: 'ru');
///   client.events.listen((event) { ... });
///   client.sendPcm(pcmBytes);
///   await client.close();
class WsVoiceClient {
  WsVoiceClient({required this.wsUrl, required this.apiKey, this.hfToken});

  final String wsUrl;
  final String apiKey;

  /// HF token for the edge proxy on a private Space. Sent as
  /// `Authorization: Bearer <hfToken>` — mirrors AuthInterceptor for HTTP.
  final String? hfToken;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final _eventsController = StreamController<dynamic>.broadcast();

  /// Incoming events: Map<String, dynamic> for JSON, Uint8List for audio PCM.
  Stream<dynamic> get events => _eventsController.stream;

  bool get isConnected => _channel != null;

  Future<void> connect({
    required String userId,
    required String sessionId,
    required String language,
  }) async {
    final uri = Uri.parse(wsUrl).replace(queryParameters: {
      'api_key': apiKey,
      'user_id': userId,
      'session_id': sessionId,
      'language': language,
    },);
    // Private HF Spaces gate the WS handshake at the edge on the HF token.
    // IOWebSocketChannel carries the header on iOS/Android; browsers can't set
    // WS headers (web is out of v1 scope — storybook only).
    final token = hfToken;
    if (token != null && token.isNotEmpty) {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      _channel = WebSocketChannel.connect(uri);
    }
    await _channel!.ready;

    _sub = _channel!.stream.listen(
      (msg) {
        if (msg is String) {
          try {
            _eventsController.add(json.decode(msg) as Map<String, dynamic>);
          } catch (_) {}
        } else if (msg is List<int>) {
          _eventsController.add(Uint8List.fromList(msg));
        }
      },
      onError: _eventsController.addError,
      onDone: () {
        if (!_eventsController.isClosed) {
          _eventsController.add({'event': 'disconnected'});
        }
      },
    );
  }

  void sendPcm(Uint8List pcm) {
    _channel?.sink.add(pcm);
  }

  void sendEvent(Map<String, dynamic> event) {
    _channel?.sink.add(json.encode(event));
  }

  Future<void> close() async {
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    close();
    _eventsController.close();
  }
}
