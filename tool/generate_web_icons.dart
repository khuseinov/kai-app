// Generate Kai-branded web PWA icons from brand/icon-1024.png.
//
// Usage:
//   dart run tool/generate_web_icons.dart
//
// Outputs:
//   web/favicon.png                 32×32
//   web/icons/Icon-192.png          192×192
//   web/icons/Icon-512.png          512×512
//   web/icons/Icon-maskable-192.png 192×192 with centered content
//   web/icons/Icon-maskable-512.png 512×512 with centered content
//   brand/favicon-32.png            32×32 brand deliverable
//   brand/favicon-16.png            16×16 gradient square (curve invisible at this size)

import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

const _source = 'brand/icon-1024.png';

final _outputs = <_Output>[
  const _Output(path: 'web/favicon.png', size: 32, maskable: false),
  const _Output(path: 'web/icons/Icon-192.png', size: 192, maskable: false),
  const _Output(path: 'web/icons/Icon-512.png', size: 512, maskable: false),
  const _Output(path: 'web/icons/Icon-maskable-192.png', size: 192, maskable: true),
  const _Output(path: 'web/icons/Icon-maskable-512.png', size: 512, maskable: true),
  const _Output(path: 'brand/favicon-32.png', size: 32, maskable: false),
  const _Output(path: 'brand/favicon-16.png', size: 16, maskable: false),
];

// Maskable safe zone: keep content within 80% of the canvas so OS-shaped
// masks (circle, rounded square, teardrop, etc.) never clip the curve.
const _maskableContentRatio = 0.80;

void main() {
  final sourceBytes = File(_source).readAsBytesSync();
  final source = img.decodePng(sourceBytes);
  if (source == null) {
    throw StateError('Failed to decode $_source');
  }

  for (final out in _outputs) {
    final canvas = img.Image(width: out.size, height: out.size);

    final contentSize = (out.size * (out.maskable ? _maskableContentRatio : 1.0)).round();
    final resized = img.copyResize(
      source,
      width: contentSize,
      height: contentSize,
      interpolation: img.Interpolation.cubic,
    );

    final offsetX = (out.size - contentSize) ~/ 2;
    final offsetY = (out.size - contentSize) ~/ 2;

    img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);

    final encoded = img.encodePng(canvas);
    File(out.path).writeAsBytesSync(encoded);

    // ignore: avoid_print
    print(
      '  ✓ ${out.path}  '
      '${out.size}×${out.size}  '
      '(${(encoded.lengthInBytes / 1024).toStringAsFixed(1)} KB)'
      '${out.maskable ? ' maskable' : ''}',
    );
  }

  // ignore: avoid_print
  print('Done. Web PWA icons generated from $_source.');
}

class _Output {
  final String path;
  final int size;
  final bool maskable;

  const _Output({
    required this.path,
    required this.size,
    required this.maskable,
  });
}
