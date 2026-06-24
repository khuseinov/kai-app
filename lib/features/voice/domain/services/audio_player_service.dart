import 'dart:typed_data';

/// Abstract audio player service.
abstract class AudioPlayerService {
  /// Plays audio from [bytes]. Returns when playback completes.
  Future<void> playBytes(Uint8List bytes);

  /// Stops playback.
  Future<void> stop();

  /// Whether audio is currently playing.
  Future<bool> isPlaying();
}
