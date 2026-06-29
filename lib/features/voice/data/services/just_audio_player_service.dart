import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';

/// Audio player implementation using the `just_audio` plugin.
class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> playBytes(Uint8List bytes) async {
    await _player.stop();
    // ponytail: a data-URI needs a real audio MIME or browsers / AVPlayer reject
    // it ("Failed to load URL"). Default Uri.dataFromBytes is octet-stream.
    // edge-tts → MP3, Piper fallback → WAV (RIFF header) — sniff and label.
    final isWav = bytes.length >= 4 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46;
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.dataFromBytes(bytes, mimeType: isWav ? 'audio/wav' : 'audio/mpeg'),
      ),
    );
    await _player.play();
    // Resolve on natural end OR on stop()/idle — otherwise a barge-in stop()
    // (which sets idle, never completed) would hang the caller's await forever,
    // stalling the progressive play queue.
    await _player.processingStateStream.firstWhere(
      (state) =>
          state == ProcessingState.completed || state == ProcessingState.idle,
    );
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<bool> isPlaying() async => _player.playing;
}
