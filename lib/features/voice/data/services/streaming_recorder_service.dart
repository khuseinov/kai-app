import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:record/record.dart';

/// Streams 16-bit PCM mono 16kHz frames from the microphone.
///
/// Call [startStream] to begin; listen to the returned [Stream<Uint8List>].
/// Call [stop] to end recording. Permission must be granted externally.
class StreamingRecorderService {
  StreamingRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  /// Start streaming PCM16 frames. Caller must ensure mic permission.
  Future<Stream<Uint8List>> startStream() async {
    // iOS: AVAudioSession.Mode.voiceChat already applies hardware AEC/AGC.
    // Enabling record-plugin voice processing on top of it causes double
    // suppression and very low RMS, so we leave echoCancel/noiseSuppress off
    // on iOS. Android still benefits from software preprocessing.
    final enableVoiceProcessing = !Platform.isIOS;
    final stream = await _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: enableVoiceProcessing,
        noiseSuppress: enableVoiceProcessing,
      ),
    );
    return stream.map(Uint8List.fromList);
  }

  Future<void> stop() => _recorder.stop();

  Future<bool> hasPermission() => _recorder.hasPermission();
}
