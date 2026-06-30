import 'dart:typed_data';

/// Client-side speech detection used for barge-in during TTS playback.
///
/// Feeds the same PCM16 frames already being streamed to the voice-gateway
/// WS into a local Silero VAD model, so the app can interrupt Kai's reply
/// the moment the user starts talking over it — without waiting on a
/// round-trip to the server.
abstract class VoiceVadService {
  /// Loads the VAD model. Must complete before [feed] has any effect.
  Future<void> init();

  /// Feeds one PCM16 mono 16kHz frame into the detector.
  void feed(Uint8List pcm16);

  /// Fires when sustained speech (not a brief misfire) is detected.
  Stream<void> get onRealSpeechStart;

  /// Resets detector state (call between turns).
  void reset();

  /// Releases native resources.
  void dispose();
}
