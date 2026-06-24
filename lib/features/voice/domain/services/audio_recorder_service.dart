/// Abstract audio recorder service.
abstract class AudioRecorderService {
  /// Requests microphone permission and starts recording to [path].
  Future<void> start(String path);

  /// Stops recording and returns the path to the recorded file.
  Future<String?> stop();

  /// Whether the recorder is currently recording.
  Future<bool> isRecording();
}
