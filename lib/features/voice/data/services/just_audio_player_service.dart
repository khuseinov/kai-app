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
    await _player.setAudioSource(AudioSource.uri(Uri.dataFromBytes(bytes)));
    await _player.play();
    await _player.processingStateStream.firstWhere(
      (state) => state == ProcessingState.completed,
    );
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<bool> isPlaying() async => _player.playing;
}
