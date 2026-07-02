import 'dart:async';

import 'package:dio/dio.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

/// Normalized events out of a LiveKit voice session. The notifier maps these
/// onto the same `VoiceFlowState` machine the WS transport drives.
sealed class LivekitSessionEvent {
  const LivekitSessionEvent();
}

/// Agent lifecycle state from the `lk.agent.state` participant attribute:
/// `initializing` / `listening` / `thinking` / `speaking`.
class LkAgentState extends LivekitSessionEvent {
  const LkAgentState(this.state);
  final String state;
}

/// The user's own speech transcribed server-side (agent STT).
class LkUserTranscript extends LivekitSessionEvent {
  const LkUserTranscript(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

/// Kai's reply text as the agent speaks it.
class LkAgentTranscript extends LivekitSessionEvent {
  const LkAgentTranscript(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

/// Room connection dropped (server close, network loss).
class LkDisconnected extends LivekitSessionEvent {
  const LkDisconnected();
}

/// LiveKit transport can't be used right now — token endpoint disabled
/// (503), missing config, or unreachable. Callers fall back to WS.
class LivekitUnavailableException implements Exception {
  LivekitUnavailableException(this.reason);
  final String reason;

  @override
  String toString() => 'LivekitUnavailableException: $reason';
}

/// One live LiveKit voice session. Unlike the WS transport, the platform
/// WebRTC stack owns the entire audio path (mic capture with AEC/NS, opus,
/// playback) — there is no client-side recorder/encoder/player to manage.
abstract class LivekitVoiceSession {
  Stream<LivekitSessionEvent> get events;
  Future<void> close();
}

class LivekitVoiceSessionImpl implements LivekitVoiceSession {
  LivekitVoiceSessionImpl._(this._room, this._listener, this._localIdentity);

  static const _agentStateAttr = 'lk.agent.state';
  static const _transcriptionTopic = 'lk.transcription';
  static const _finalAttr = 'lk.transcription.final';

  final lk.Room _room;
  final lk.EventsListener<lk.RoomEvent> _listener;
  final String _localIdentity;
  final _events = StreamController<LivekitSessionEvent>.broadcast();
  bool _closed = false;

  @override
  Stream<LivekitSessionEvent> get events => _events.stream;

  /// Fetch a room token from voice-gateway, join the room, enable the mic.
  ///
  /// Throws [LivekitUnavailableException] when the token endpoint says no
  /// (LIVEKIT_ENABLED off → 503) so the caller can fall back to WS.
  static Future<LivekitVoiceSessionImpl> connect({
    required Dio dio,
    required String gatewayBaseUrl,
    required String apiKey,
    required String userId,
    required String sessionId,
    String? hfToken,
  }) async {
    final Map<String, dynamic> body;
    try {
      final resp = await dio.post<Map<String, dynamic>>(
        '$gatewayBaseUrl/voice/livekit/token',
        data: {'user_id': userId, 'session_id': sessionId},
        options: Options(headers: {
          'X-Internal-API-Key': apiKey,
          // HF edge needs the Space token when the Space is private —
          // mirrors WsVoiceClient / AuthInterceptor.
          if (hfToken != null && hfToken.isNotEmpty)
            'Authorization': 'Bearer $hfToken',
        },),
      );
      body = resp.data ?? const {};
    } on DioException catch (e) {
      throw LivekitUnavailableException(
        'token request failed: ${e.response?.statusCode ?? e.type.name}',
      );
    }

    final url = body['url'] as String? ?? '';
    final token = body['token'] as String? ?? '';
    if (url.isEmpty || token.isEmpty) {
      throw LivekitUnavailableException('token response missing url/token');
    }

    // From here on failures are real errors, not "transport unavailable":
    // the transport was offered, so surface them instead of silently
    // degrading to WS.
    final room = lk.Room();
    await room.connect(url, token);
    await room.localParticipant?.setMicrophoneEnabled(true);

    return LivekitVoiceSessionImpl._(room, room.createListener(), userId)
      .._wire();
  }

  void _wire() {
    _listener
      ..on<lk.ParticipantAttributesChanged>((event) {
        final agentState = event.attributes[_agentStateAttr];
        if (agentState != null && event.participant.identity != _localIdentity) {
          _events.add(LkAgentState(agentState));
        }
      })
      ..on<lk.RoomDisconnectedEvent>((_) {
        if (!_closed) _events.add(const LkDisconnected());
      });
    _room.registerTextStreamHandler(_transcriptionTopic, _onTranscription);
  }

  Future<void> _onTranscription(
    lk.TextStreamReader reader,
    String participantIdentity,
  ) async {
    try {
      final text = await reader.readAll();
      if (text.isEmpty || _closed) return;
      final isFinal = reader.info?.attributes[_finalAttr] == 'true';
      _events.add(
        participantIdentity == _localIdentity
            ? LkUserTranscript(text, isFinal: isFinal)
            : LkAgentTranscript(text, isFinal: isFinal),
      );
    } catch (e, st) {
      AppLogger.e('[VOICE] LiveKit transcription read failed', e, st);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      _room.unregisterTextStreamHandler(_transcriptionTopic);
      await _listener.dispose();
      await _room.disconnect();
      await _room.dispose();
    } catch (e, st) {
      AppLogger.e('[VOICE] LiveKit room close failed', e, st);
    }
    await _events.close();
  }
}
