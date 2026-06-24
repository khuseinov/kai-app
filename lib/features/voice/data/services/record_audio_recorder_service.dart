import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Audio recorder implementation using the `record` plugin.
class RecordAudioRecorderService implements AudioRecorderService {
  RecordAudioRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<void> start(String path) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
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
