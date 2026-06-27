import 'dart:io';
import 'dart:typed_data';

/// Return true if [file] looks like a finalized MPEG-4 audio container:
/// it must contain a top-level `moov` box whose declared size fits inside
/// the file. This is used to wait for iOS `AVAudioRecorder` to finish
/// writing the `moov` atom after `stop()` returns.
bool m4aFileHasMoovAtom(File file) {
  final length = file.lengthSync();
  if (length < 8) return false;

  final raf = file.openSync();
  try {
    var position = 0;
    while (position + 8 <= length) {
      raf.setPositionSync(position);
      final header = raf.readSync(8);
      if (header.length < 8) return false;

      final data = ByteData.sublistView(Uint8List.fromList(header));
      var boxSize = data.getUint32(0);
      final boxType = String.fromCharCodes(header.sublist(4, 8));

      if (boxSize == 1) {
        // Extended size uses the next 8 bytes.
        raf.setPositionSync(position + 8);
        final extHeader = raf.readSync(8);
        if (extHeader.length < 8) return false;
        final extData = ByteData.sublistView(Uint8List.fromList(extHeader));
        boxSize = extData.getUint64(0);
        position += boxSize;
      } else if (boxSize == 0) {
        // Box extends to the end of the file.
        return boxType == 'moov';
      } else {
        if (boxType == 'moov') {
          return position + boxSize <= length;
        }
        position += boxSize;
      }

      if (boxSize < 8) break;
    }
    return false;
  } finally {
    raf.closeSync();
  }
}
