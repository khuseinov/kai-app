import 'dart:typed_data';

import 'package:opus_dart/opus_dart.dart' as opus;
// initOpus() takes whatever `DynamicLibrary` its own platform-conditional
// export resolves to (dart:ffi on mobile, package:web_ffi on web) — importing
// the public dart:ffi directly here mismatches that on some analyzer
// resolutions, so import the same private proxy opus_dart itself uses.
// ignore: implementation_imports
import 'package:opus_dart/src/proxy_ffi.dart' show DynamicLibrary;
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

/// Encodes exactly one 20ms (320-sample @ 16kHz) PCM16 window into an Opus
/// packet. Injectable seam so [OpusEncoderService]'s windowing logic is
/// testable without loading the real native libopus encoder.
typedef OpusFrameEncoder = Uint8List Function(Int16List window);

/// Buffers arbitrary-size PCM16 mono chunks into fixed 20ms (320-sample)
/// windows and encodes each one to Opus.
///
/// Opus requires fixed-duration frames (2.5/5/10/20/40/60ms); the `record`
/// plugin's chunk size (100ms/1600 samples in practice) never lines up with
/// Opus's window exactly for partial chunks, so leftover samples are
/// buffered and carried over to the next [encode] call.
class OpusEncoderService {
  OpusEncoderService({required this.frameEncoder, void Function()? onDispose})
      : _onDispose = onDispose;

  static const sampleRate = 16000;
  static const windowSamples = 320; // 20ms @ 16kHz

  final OpusFrameEncoder frameEncoder;
  final void Function()? _onDispose;
  Int16List _pending = Int16List(0);

  /// Feeds one PCM16 mono chunk; returns zero or more complete Opus packets.
  List<Uint8List> encode(Uint8List pcm16) {
    if (pcm16.isEmpty) return const [];

    final samples = pcm16.buffer.asInt16List(
      pcm16.offsetInBytes,
      pcm16.lengthInBytes ~/ 2,
    );
    final combined = Int16List(_pending.length + samples.length)
      ..setAll(0, _pending)
      ..setAll(_pending.length, samples);

    final packets = <Uint8List>[];
    var offset = 0;
    while (offset + windowSamples <= combined.length) {
      final window = Int16List.sublistView(combined, offset, offset + windowSamples);
      packets.add(frameEncoder(window));
      offset += windowSamples;
    }
    _pending = Int16List.sublistView(combined, offset);
    return packets;
  }

  /// Releases the underlying native encoder (no-op for injected test fakes).
  void dispose() => _onDispose?.call();
}

bool _opusInitialized = false;

/// Loads the native libopus library once (idempotent) and constructs a real
/// [OpusEncoderService] backed by `SimpleOpusEncoder` in VOIP mode (tuned
/// for speech, matches this app's use case).
Future<OpusEncoderService> createOpusEncoderService() async {
  if (!_opusInitialized) {
    // opus_flutter.load() returns `dynamic` (shared native/web signature);
    // this service targets mobile only, where it's always a DynamicLibrary.
    opus.initOpus(await opus_flutter.load() as DynamicLibrary);
    _opusInitialized = true;
  }
  final encoder = opus.SimpleOpusEncoder(
    sampleRate: OpusEncoderService.sampleRate,
    channels: 1,
    application: opus.Application.voip,
  );
  return OpusEncoderService(
    frameEncoder: (window) => encoder.encode(input: window),
    onDispose: encoder.destroy,
  );
}
