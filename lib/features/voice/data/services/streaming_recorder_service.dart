import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
    // iOS: measured RMS on iPhone is ~0.03-0.04 even when speaking normally,
    // so apply a small software gain boost to bring speech comfortably above
    // the backend VAD threshold. Android uses the platform voice processing
    // path and does not need extra gain.
    final applyGain = Platform.isIOS;
    final stream = await _recorder.startStream(buildRecordConfig());
    if (applyGain) {
      return stream.map(_applyGain).map(Uint8List.fromList);
    }
    return stream.map(Uint8List.fromList);
  }

  /// Recorder configuration shared by both platforms.
  ///
  /// `iosConfig.manageAudioSession: false` is load-bearing: VoiceNotifier's
  /// `audio_session` configuration is the single owner of the shared
  /// AVAudioSession. If `record` also manages it (the package default), the
  /// two fight over category/active state and the mic goes silent after a
  /// few frames.
  @visibleForTesting
  static RecordConfig buildRecordConfig() {
    final enableVoiceProcessing = !Platform.isIOS;
    return RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
      autoGain: true,
      echoCancel: enableVoiceProcessing,
      noiseSuppress: enableVoiceProcessing,
      iosConfig: const IosRecordConfig(manageAudioSession: false),
    );
  }

  Future<void> stop() => _recorder.stop();

  Future<bool> hasPermission() => _recorder.hasPermission();

  /// Test hook for [_applyGain].
  @visibleForTesting
  static Uint8List applyGainForTest(Uint8List pcm16) => _applyGain(pcm16);

  /// Boost iOS mic signal by ~8 dB (linear gain 2.5) so speech RMS lands
  /// above the backend energy-VAD threshold. Values are clamped to Int16
  /// range to avoid clipping artifacts.
  static Uint8List _applyGain(Uint8List pcm16) {
    const gain = 2.5;
    final view = ByteData.sublistView(pcm16);
    final out = Uint8List(pcm16.length);
    final outView = ByteData.sublistView(out);
    for (var i = 0; i < pcm16.length; i += 2) {
      final sample = view.getInt16(i, Endian.little);
      final boosted = (sample * gain).clamp(-32768, 32767).toInt();
      outView.setInt16(i, boosted, Endian.little);
    }
    return out;
  }
}
