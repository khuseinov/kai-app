import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';

/// Audio player implementation using `flutter_soloud`'s continuous buffer
/// stream — one persistent [AudioSource] per assistant turn, fed directly
/// from incoming WS binary frames as they arrive. Replaces the discrete
/// per-clause loadMem-and-await-completion queue: gapless cross-clause
/// playback instead of a stop/reload between each one.
///
/// `BufferType.auto` autodetects MP3/OGG/Vorbis, so the server's wire format
/// (whole-clause MP3 blobs) doesn't need to change for this to work.
class SoloudPlayerService implements AudioPlayerService {
  SoloudPlayerService({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;
  bool _initialized = false;
  AudioSource? _activeSource;
  SoundHandle? _activeHandle;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _soloud.init();
    _initialized = true;
  }

  @override
  Future<void> startStream() async {
    await _ensureInitialized();
    await _disposeActive(); // safety: clear any leftover stream from a prior turn

    final source = _soloud.setBufferStream(
      format: BufferType.auto,
      // ponytail: each feed() call already delivers a whole clause (several
      // seconds of audio), not small continuous chunks, so a large buffering
      // margin only adds startup latency here. Re-tune on-device if underrun
      // stutter shows up once clauses get genuinely chunked server-side.
      bufferingTimeNeeds: 0.2,
    );
    _activeSource = source;
    _activeHandle = _soloud.play(source);
  }

  @override
  void feed(Uint8List chunk) {
    final source = _activeSource;
    if (source == null || chunk.isEmpty) return;
    try {
      _soloud.addAudioDataStream(source, chunk);
    } catch (e, st) {
      // Stream may already have been torn down by a concurrent stop()
      // (barge-in racing an in-flight WS frame) — drop the frame, not fatal.
      AppLogger.e('[VOICE] soloud feed failed', e, st);
    }
  }

  @override
  Future<void> endStream() async {
    final source = _activeSource;
    if (source == null) return;
    _soloud.setDataIsEnded(source);
  }

  @override
  Future<void> stop() async {
    await _disposeActive();
  }

  /// Hard-stops the active handle (resetBufferStream alone does NOT do this —
  /// per its docs it only resets the buffer for *future* addAudioDataStream
  /// calls; already-playing audio keeps playing) and disposes the source so
  /// the next startStream() begins clean.
  Future<void> _disposeActive() async {
    final handle = _activeHandle;
    final source = _activeSource;
    _activeHandle = null;
    _activeSource = null;
    if (handle != null && _soloud.getIsValidVoiceHandle(handle)) {
      await _soloud.stop(handle);
    }
    if (source != null) {
      await _soloud.disposeSource(source);
    }
  }

  @override
  Future<bool> isPlaying() async {
    final handle = _activeHandle;
    if (handle == null) return false;
    return _soloud.getIsValidVoiceHandle(handle);
  }
}
