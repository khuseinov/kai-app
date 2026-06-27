import 'package:flutter/foundation.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:record/record.dart';

/// Audio recorder implementation using the `record` plugin.
class RecordAudioRecorderService implements AudioRecorderService {
  RecordAudioRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<void> start(String path) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }
    await _recorder.start(
      RecordConfig(
        // ponytail: compressed AAC on mobile — uncompressed WAV makes long
        // clips multi-MB and the upload drops mid-body (ClientDisconnect) over
        // a mobile link. Whisper decodes m4a/aac via PyAV. Web keeps opus.
        encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<bool> isRecording() async {
    final state = await _recorder.onStateChanged().first;
    return state == RecordState.record;
  }
}
