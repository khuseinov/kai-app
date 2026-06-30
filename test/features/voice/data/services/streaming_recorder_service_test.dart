import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';

void main() {
  group('StreamingRecorderService._applyGain', () {
    test('boosts samples by ~2.5x and clamps to int16 range', () {
      // 1000 -> 2500
      final input = _int16ToBytes([1000, -1000, 20000, -20000, 32767, -32768]);
      final output = StreamingRecorderService.applyGainForTest(input);
      final samples = _bytesToInt16(output);

      expect(samples[0], 2500);
      expect(samples[1], -2500);
      expect(samples[2], 32767); // clamped: 20000 * 2.5 = 50000 > 32767
      expect(samples[3], -32768); // clamped: -20000 * 2.5 = -50000 < -32768
      expect(samples[4], 32767); // clamped
      expect(samples[5], -32768); // clamped
    });

    test('preserves zero samples', () {
      final input = _int16ToBytes([0, 0, 0]);
      final output = StreamingRecorderService.applyGainForTest(input);
      expect(_bytesToInt16(output), [0, 0, 0]);
    });

    test('handles empty buffer', () {
      final input = Uint8List(0);
      final output = StreamingRecorderService.applyGainForTest(input);
      expect(output, isEmpty);
    });
  });

  group('StreamingRecorderService.buildRecordConfig', () {
    test('always disables record-plugin AVAudioSession ownership', () {
      // audio_session is the single owner of the shared iOS session (configured
      // in VoiceNotifier before the mic opens); the `record` plugin must not
      // also try to manage it, or the two fight over category/active state and
      // the mic goes silent after a few frames.
      final config = StreamingRecorderService.buildRecordConfig();
      expect(config.iosConfig.manageAudioSession, isFalse);
    });
  });
}

Uint8List _int16ToBytes(List<int> samples) {
  final bytes = Uint8List(samples.length * 2);
  final view = ByteData.sublistView(bytes);
  for (var i = 0; i < samples.length; i++) {
    view.setInt16(i * 2, samples[i], Endian.little);
  }
  return bytes;
}

List<int> _bytesToInt16(Uint8List bytes) {
  final view = ByteData.sublistView(bytes);
  final samples = <int>[];
  for (var i = 0; i < bytes.length; i += 2) {
    samples.add(view.getInt16(i, Endian.little));
  }
  return samples;
}
