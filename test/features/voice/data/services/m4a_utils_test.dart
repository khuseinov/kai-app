import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/voice/data/services/m4a_utils.dart';

Uint8List _ftypBox() {
  // ftyp box: size(4) + type(4) + major_brand(4) + minor_version(4) + compatible_brands(4)
  final bytes = BytesBuilder();
  bytes.add(Uint8List(4)..buffer.asByteData().setUint32(0, 20, Endian.big));
  bytes.add('ftyp'.codeUnits);
  bytes.add('M4A '.codeUnits);
  bytes.add(Uint8List(4)); // minor version 0
  bytes.add('M4A '.codeUnits);
  return bytes.toBytes();
}

Uint8List _moovBox() {
  final payload = Uint8List(8);
  final size = 8 + payload.length;
  final bytes = BytesBuilder();
  bytes.add(Uint8List(4)..buffer.asByteData().setUint32(0, size, Endian.big));
  bytes.add('moov'.codeUnits);
  bytes.add(payload);
  return bytes.toBytes();
}

Uint8List _mdatBox() {
  final payload = Uint8List(8);
  final size = 8 + payload.length;
  final bytes = BytesBuilder();
  bytes.add(Uint8List(4)..buffer.asByteData().setUint32(0, size, Endian.big));
  bytes.add('mdat'.codeUnits);
  bytes.add(payload);
  return bytes.toBytes();
}

void main() {
  group('m4aFileHasMoovAtom', () {
    test('returns false for an empty file', () async {
      final file = File('${Directory.systemTemp.path}/empty.m4a');
      await file.writeAsBytes(Uint8List(0));
      addTearDown(file.deleteSync);

      expect(m4aFileHasMoovAtom(file), isFalse);
    });

    test('returns false for m4a without moov', () async {
      final file = File('${Directory.systemTemp.path}/truncated.m4a');
      final builder = BytesBuilder()..add(_ftypBox())..add(_mdatBox());
      await file.writeAsBytes(builder.toBytes());
      addTearDown(file.deleteSync);

      expect(m4aFileHasMoovAtom(file), isFalse);
    });

    test('returns true for m4a with moov', () async {
      final file = File('${Directory.systemTemp.path}/finalized.m4a');
      final builder = BytesBuilder()
        ..add(_ftypBox())
        ..add(_mdatBox())
        ..add(_moovBox());
      await file.writeAsBytes(builder.toBytes());
      addTearDown(file.deleteSync);

      expect(m4aFileHasMoovAtom(file), isTrue);
    });

    test('returns false when moov size exceeds file length', () async {
      final file = File('${Directory.systemTemp.path}/incomplete_moov.m4a');
      final moov = _moovBox();
      // Write only the moov header, truncate the payload.
      await file.writeAsBytes(_ftypBox() + moov.sublist(0, 10));
      addTearDown(file.deleteSync);

      expect(m4aFileHasMoovAtom(file), isFalse);
    });
  });
}
