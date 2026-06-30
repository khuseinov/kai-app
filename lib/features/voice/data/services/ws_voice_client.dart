import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kai_app/core/logger/app_logger.dart';
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
    final token = hfToken;
    final query = <String, String>{
      'api_key': apiKey,
      'user_id': userId,
      'session_id': sessionId,
      'language': language,
    };
    // Browsers cannot set WebSocket headers, so on web pass the HF token via
    // query (best effort). Native sends it as an Authorization header below.
    if (kIsWeb && token != null && token.isNotEmpty) {
      query['hf_token'] = token;
    }
    final uri = Uri.parse(wsUrl).replace(queryParameters: query);

    // IOWebSocketChannel (header auth) only works on dart:io platforms.
    // On web it throws `Platform._version` — use the plain channel there.
    if (!kIsWeb && token != null && token.isNotEmpty) {
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      _channel = WebSocketChannel.connect(uri);
    }
    await _channel!.ready;
    AppLogger.i('[VOICE] WebSocket connected to $wsUrl');

    _sub = _channel!.stream.listen(
      (msg) {
        if (msg is String) {
          try {
            final decoded = json.decode(msg) as Map<String, dynamic>;
            final event = decoded['event'] as String? ?? '';
            // DEBUG: log control events from server.
            AppLogger.i('[VOICE] WS text event: $event');
            if (event == 'ping') {
              // Application-level keepalive: respond immediately.
              sendEvent({'event': 'pong'});
              return;
            }
            _eventsController.add(decoded);
          } catch (_) {}
        } else if (msg is List<int>) {
          final bytes = Uint8List.fromList(msg);
          AppLogger.i('[VOICE] WS binary audio frame: ${bytes.length} bytes');
          _eventsController.add(bytes);
        }
      },
      onError: (Object e) {
        AppLogger.e('[VOICE] WS error', e);
        _eventsController.addError(e);
      },
      onDone: () {
        final closeCode = _channel?.closeCode;
        final closeReason = _channel?.closeReason;
        AppLogger.i('[VOICE] WS connection closed code=$closeCode reason=$closeReason');
        if (!_eventsController.isClosed) {
          _eventsController.add({'event': 'disconnected', 'code': closeCode, 'reason': closeReason});
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
