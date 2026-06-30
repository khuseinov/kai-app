import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';

/// Audio player implementation using `flutter_soloud`.
///
/// Replaces the prior just_audio-backed service's per-clause temp-file write
/// + AVPlayer reload (file I/O + player-init latency on every clause) with
/// `loadMem` —
/// soloud decodes MP3/WAV straight from the in-memory buffer, no disk round
/// trip. `setBufferStream`/`addAudioDataStream` (true continuous streaming
/// across clauses, replacing voice_notifier's discrete clause queue) is a
/// further step, not done here — this is the in-memory-playback swap only.
class SoloudPlayerService implements AudioPlayerService {
  SoloudPlayerService({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;
  bool _initialized = false;
  SoundHandle? _activeHandle;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _soloud.init();
    _initialized = true;
  }

  @override
  Future<void> playBytes(Uint8List bytes) async {
    await _ensureInitialized();
    final source = await _soloud.loadMem(
      'kai-voice-clause-${DateTime.now().microsecondsSinceEpoch}',
      bytes,
      autoDispose: true,
    );
    final handle = _soloud.play(source);
    _activeHandle = handle;
    AppLogger.i('[VOICE] soloud playing ${bytes.length} bytes from memory');

    // Resolve on natural end OR on stop() — a barge-in stop() must not hang
    // the caller's await forever, stalling the progressive play queue.
    await source.soundEvents.firstWhere(
      (e) => e.event == SoundEventType.handleIsNoMoreValid,
    );
    if (identical(_activeHandle, handle)) {
      _activeHandle = null;
    }
  }

  @override
  Future<void> stop() async {
    final handle = _activeHandle;
    _activeHandle = null;
    if (handle == null) return;
    if (_soloud.getIsValidVoiceHandle(handle)) {
      await _soloud.stop(handle);
    }
  }

  @override
  Future<bool> isPlaying() async {
    final handle = _activeHandle;
    if (handle == null) return false;
    return _soloud.getIsValidVoiceHandle(handle);
  }
}
