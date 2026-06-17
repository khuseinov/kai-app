// Generate Kai-branded web PWA icons from brand/icon-1024.png.
//
// Usage:
//   dart run tool/generate_web_icons.dart
//
// Outputs:
//   web/favicon.png                 32×32
//   web/favicon-16.png              16×16 gradient square (curve invisible at this size)
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
  const _Output(path: 'web/favicon.png', size: 32),
  const _Output(path: 'web/favicon-16.png', size: 16, gradientSquare: true),
  const _Output(path: 'web/icons/Icon-192.png', size: 192),
  const _Output(path: 'web/icons/Icon-512.png', size: 512),
  const _Output(
      path: 'web/icons/Icon-maskable-192.png', size: 192, maskable: true,),
  const _Output(
      path: 'web/icons/Icon-maskable-512.png', size: 512, maskable: true,),
  const _Output(path: 'brand/favicon-32.png', size: 32),
  const _Output(path: 'brand/favicon-16.png', size: 16, gradientSquare: true),
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
    final img.Image canvas;
    if (out.gradientSquare) {
      canvas = _renderGradientSquare(out.size);
    } else {
      canvas = img.Image(width: out.size, height: out.size);

      final contentSize =
          (out.size * (out.maskable ? _maskableContentRatio : 1.0)).round();
      final resized = img.copyResize(
        source,
        width: contentSize,
        height: contentSize,
        interpolation: img.Interpolation.cubic,
      );

      final offsetX = (out.size - contentSize) ~/ 2;
      final offsetY = (out.size - contentSize) ~/ 2;

      img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
    }

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

  const _Output({
    required this.path,
    required this.size,
    this.maskable = false,
    this.gradientSquare = false,
  });
  final String path;
  final int size;
  final bool maskable;
  final bool gradientSquare;
}

// Canonical KaiTide.gradientCorner stops for the 16×16 favicon:
// 135° diagonal (top-left → bottom-right), #1B4FB0 → #2BA8C9 55% → #F4B589.
img.Image _renderGradientSquare(int size) {
  final stop1 = img.ColorRgba8(0x1B, 0x4F, 0xB0, 0xFF);
  final stop2 = img.ColorRgba8(0x2B, 0xA8, 0xC9, 0xFF);
  final stop3 = img.ColorRgba8(0xF4, 0xB5, 0x89, 0xFF);
  const stops = <double>[0, 0.55, 1];

  final image = img.Image(width: size, height: size);
  final max = 2 * (size - 1);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final t = (x + y) / max;
      final color = _lerpStops(t, [stop1, stop2, stop3], stops);
      image.setPixelRgba(x, y, color.r, color.g, color.b, color.a);
    }
  }

  return image;
}

img.ColorRgba8 _lerpStops(
  double t,
  List<img.ColorRgba8> colors,
  List<double> stops,
) {
  assert(colors.length == stops.length && colors.length >= 2);

  var segment = 0;
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1]) {
      segment = i;
      break;
    }
  }

  final t0 = stops[segment];
  final t1 = stops[segment + 1];
  final localT = t1 == t0 ? 0.0 : (t - t0) / (t1 - t0);
  final c1 = colors[segment];
  final c2 = colors[segment + 1];

  int lerp(int v1, int v2, double f) => (v1 + (v2 - v1) * f).round();

  return img.ColorRgba8(
    lerp(c1.r.toInt(), c2.r.toInt(), localT),
    lerp(c1.g.toInt(), c2.g.toInt(), localT),
    lerp(c1.b.toInt(), c2.b.toInt(), localT),
    lerp(c1.a.toInt(), c2.a.toInt(), localT),
  );
}
