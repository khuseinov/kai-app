import 'dart:async';
import 'dart:typed_data';

import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
// VadIteratorBase/VadEventCallback are not re-exported by package:vad/vad.dart
// despite the package's own docs calling this the supported lower-level seam
// ("can be used directly for more control over the VAD process").
// ignore: implementation_imports
import 'package:vad/src/vad_iterator_base.dart';
import 'package:vad/vad.dart';

/// [VoiceVadService] backed by the `vad` package's Silero ONNX iterator.
///
/// Deliberately bypasses [VadHandlerBase] (the package's high-level API):
/// that handler opens its own independent `AudioRecorder` mic stream, which
/// would fight the already-open [StreamingRecorderService] session and the
/// AVAudioSession it owns. [VadIteratorBase] is the package's documented
/// lower-level seam for feeding externally-captured PCM directly — so this
/// reuses the one mic stream already running for the WS upload.
class VoiceVadServiceImpl implements VoiceVadService {
  VoiceVadServiceImpl({VadIteratorBase? iterator})
      : _iterator = iterator ?? _defaultIterator();

  static const _modelPath = 'packages/vad/assets/silero_vad_legacy.onnx';

  static VadIteratorBase _defaultIterator() => VadIterator.create(
        isDebug: false,
        sampleRate: 16000,
        frameSamples: 1536,
        positiveSpeechThreshold: 0.5,
        negativeSpeechThreshold: 0.35,
        redemptionFrames: 8,
        preSpeechPadFrames: 1,
        minSpeechFrames: 3,
        submitUserSpeechOnPause: false,
        model: 'legacy',
      );

  final VadIteratorBase _iterator;
  final _onRealSpeechStartController = StreamController<void>.broadcast();
  bool _initialized = false;

  @override
  Stream<void> get onRealSpeechStart => _onRealSpeechStartController.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    _iterator.setVadEventCallback(_handleEvent);
    await _iterator.initModel(_modelPath);
    _initialized = true;
  }

  void _handleEvent(VadEvent event) {
    if (event.type == VadEventType.realStart) {
      _onRealSpeechStartController.add(null);
    }
  }

  @override
  void feed(Uint8List pcm16) {
    if (!_initialized) return;
    unawaited(_iterator.processAudioData(pcm16));
  }

  @override
  void reset() => _iterator.reset();

  @override
  void dispose() {
    _iterator.release();
    unawaited(_onRealSpeechStartController.close());
  }
}
