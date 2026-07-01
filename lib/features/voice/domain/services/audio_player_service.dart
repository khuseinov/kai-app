import 'dart:typed_data';

/// Continuous audio playback for one assistant turn at a time.
///
/// One persistent stream per turn: [startStream] once, [feed] every chunk
/// as it arrives, [endStream] when no more is coming. [stop] is the hard
/// interrupt (barge-in) — discards whatever is buffered/playing immediately.
abstract class AudioPlayerService {
  /// Begin a new playback stream. Call once per assistant turn, before any
  /// [feed] calls for that turn.
  Future<void> startStream();

  /// Feed one chunk of audio data (format autodetected: MP3/OGG/WAV) into
  /// the active stream.
  void feed(Uint8List chunk);

  /// Signal no more data is coming for the current turn. Already-buffered
  /// audio keeps playing until it naturally drains.
  Future<void> endStream();

  /// Immediately stop and discard playback (barge-in).
  Future<void> stop();

  /// Whether audio is currently audible.
  Future<bool> isPlaying();
}
