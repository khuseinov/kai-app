import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:path_provider/path_provider.dart';

/// Audio player implementation using the `just_audio` plugin.
class JustAudioPlayerService implements AudioPlayerService {
  JustAudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> playBytes(Uint8List bytes) async {
    await _player.stop();

    // sniff format: edge-tts → MP3, Piper fallback → WAV
    final isWav = bytes.length >= 4 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46;
    final ext = isWav ? 'wav' : 'mp3';

    // iOS AVPlayer does not reliably play data-URIs; write to a temp file.
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/kai_voice_${DateTime.now().millisecondsSinceEpoch}.$ext');
    await file.writeAsBytes(bytes);
    AppLogger.i('[VOICE] playing ${bytes.length} bytes from ${file.path}');

    await _player.setAudioSource(AudioSource.file(file.path));
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
