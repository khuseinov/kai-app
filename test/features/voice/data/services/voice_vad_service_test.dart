import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/voice/data/services/voice_vad_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
// ignore: implementation_imports
import 'package:vad/src/vad_iterator_base.dart';
import 'package:vad/vad.dart';

class _FakeVadIterator implements VadIteratorBase {
  String? initializedModelPath;
  final processedChunks = <List<int>>[];
  bool released = false;
  bool wasReset = false;
  VadEventCallback? callback;

  @override
  Future<void> initModel(String modelPath) async {
    initializedModelPath = modelPath;
  }

  @override
  void setVadEventCallback(VadEventCallback callback) {
    this.callback = callback;
  }

  @override
  Future<void> processAudioData(List<int> data) async {
    processedChunks.add(data);
  }

  @override
  void reset() => wasReset = true;

  @override
  void release() => released = true;

  @override
  void forceEndSpeech() {}

  void emit(VadEventType type) {
    callback?.call(VadEvent(type: type, timestamp: 0, message: ''));
  }
}

void main() {
  late _FakeVadIterator iterator;
  late VoiceVadService service;

  setUp(() {
    iterator = _FakeVadIterator();
    service = VoiceVadServiceImpl(iterator: iterator);
  });

  tearDown(() => service.dispose());

  test('init() loads the model and registers the event callback', () async {
    await service.init();
    expect(iterator.initializedModelPath, isNotEmpty);
    expect(iterator.callback, isNotNull);
  });

  test('feed() before init() is a no-op (model not loaded yet)', () {
    service.feed(Uint8List.fromList([1, 2, 3, 4]));
    expect(iterator.processedChunks, isEmpty);
  });

  test('feed() after init() forwards PCM bytes to the iterator', () async {
    await service.init();
    final chunk = Uint8List.fromList([1, 2, 3, 4]);
    service.feed(chunk);
    expect(iterator.processedChunks, [chunk]);
  });

  test('onRealSpeechStart fires only for VadEventType.realStart', () async {
    await service.init();
    final events = <void>[];
    final sub = service.onRealSpeechStart.listen(events.add);

    iterator
      ..emit(VadEventType.start)
      ..emit(VadEventType.frameProcessed)
      ..emit(VadEventType.misfire)
      ..emit(VadEventType.error)
      ..emit(VadEventType.end);
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty, reason: 'non-realStart events must not trigger barge-in');

    iterator.emit(VadEventType.realStart);
    await Future<void>.delayed(Duration.zero);
    expect(events, hasLength(1));

    await sub.cancel();
  });

  test('reset() resets the underlying iterator', () {
    service.reset();
    expect(iterator.wasReset, isTrue);
  });

  test('dispose() releases the iterator', () {
    service.dispose();
    expect(iterator.released, isTrue);
  });
}
