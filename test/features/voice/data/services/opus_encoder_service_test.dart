import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/voice/data/services/opus_encoder_service.dart';

Uint8List _pcm16(int nSamples, {int value = 100}) {
  final samples = Int16List(nSamples)..fillRange(0, nSamples, value);
  return samples.buffer.asUint8List();
}

void main() {
  group('OpusEncoderService windowing', () {
    test('buffers a short chunk without encoding until a full window forms', () {
      final calls = <Int16List>[];
      final service = OpusEncoderService(
        frameEncoder: (window) {
          calls.add(window);
          return Uint8List(1);
        },
      );

      // 100 samples < 320-sample window — nothing to encode yet.
      final packets = service.encode(_pcm16(100));

      expect(packets, isEmpty);
      expect(calls, isEmpty);
    });

    test('encodes exactly one packet once 320 samples have accumulated', () {
      final calls = <Int16List>[];
      final service = OpusEncoderService(
        frameEncoder: (window) {
          calls.add(window);
          return Uint8List(1);
        },
      );

      service.encode(_pcm16(200));
      final packets = service.encode(_pcm16(120)); // 200+120 = 320

      expect(packets, hasLength(1));
      expect(calls, hasLength(1));
      expect(calls.single, hasLength(OpusEncoderService.windowSamples));
    });

    test('carries over leftover samples across calls (no data dropped)', () {
      final windows = <Int16List>[];
      final service = OpusEncoderService(
        frameEncoder: (window) {
          windows.add(Int16List.fromList(window));
          return Uint8List(1);
        },
      );

      // 1600 samples (record plugin's real 100ms chunk size) -> 5 full
      // 320-sample windows, no leftover.
      final packets = service.encode(_pcm16(1600, value: 42));

      expect(packets, hasLength(5));
      for (final w in windows) {
        expect(w.every((s) => s == 42), isTrue);
      }
    });

    test('a chunk that is not a multiple of 320 leaves a remainder buffered', () {
      var callCount = 0;
      final service = OpusEncoderService(
        frameEncoder: (window) {
          callCount++;
          return Uint8List(1);
        },
      );

      // 1601 samples -> 5 full windows (1600) + 1 leftover sample buffered.
      final packets = service.encode(_pcm16(1601));
      expect(packets, hasLength(5));
      expect(callCount, 5);

      // Feeding 319 more completes the 6th window (1 + 319 = 320).
      final morePackets = service.encode(_pcm16(319));
      expect(morePackets, hasLength(1));
      expect(callCount, 6);
    });

    test('empty input produces no packets and does not call the encoder', () {
      var called = false;
      final service = OpusEncoderService(
        frameEncoder: (window) {
          called = true;
          return Uint8List(1);
        },
      );

      final packets = service.encode(Uint8List(0));

      expect(packets, isEmpty);
      expect(called, isFalse);
    });
  });
}
