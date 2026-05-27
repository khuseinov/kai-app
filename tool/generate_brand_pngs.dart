// Brand PNG generator — direct Canvas/PictureRecorder rendering (no widget
// tree, no RepaintBoundary.toImage which timed out in TestWidgetsBinding).
// Reproduces the canon curve paths from `brand.html § 02.1–02.2` and exports
// 1024×1024 PNG masters for `flutter_launcher_icons` + `flutter_native_splash`.
//
// Usage:
//   flutter test tool/generate_brand_pngs.dart
//
// Outputs:
//   brand/icon-1024.png        (primary — tide-gradient corner + white curve)
//   brand/icon-1024-dark.png   (dark slate + tide-gradient curve)
//   brand/icon-1024-mono.png   (#111114 + white curve)
//   brand/splash-glyph-1024.png (rounded glyph with built-in radius 22%)

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

enum _Variant { primary, dark, mono, splashGlyph }

const int _size = 1024;

final _assets = <(_Variant, String)>[
  (_Variant.primary, 'brand/icon-1024.png'),
  (_Variant.dark, 'brand/icon-1024-dark.png'),
  (_Variant.mono, 'brand/icon-1024-mono.png'),
  (_Variant.splashGlyph, 'brand/splash-glyph-1024.png'),
];

void main() {
  test(
    'generate brand PNGs from canon paths',
    () async {
      // ensureInitialized — `test` (not `testWidgets`) doesn't pre-init bindings.
      TestWidgetsFlutterBinding.ensureInitialized();
      for (final (variant, target) in _assets) {
        final bytes = await _renderTile(variant, _size);
        await File(target).writeAsBytes(bytes);
        // ignore: avoid_print
        print(
          '  ✓ $target  '
          '$_size×$_size  '
          '(${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB)',
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<Uint8List> _renderTile(_Variant variant, int size) async {
  final s = size.toDouble();
  final isSplash = variant == _Variant.splashGlyph;
  final fullRect = Rect.fromLTWH(0, 0, s, s);

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Splash glyph bakes in the iOS round-rect radius (22% on 64 = 14;
  // scaled to 1024 = 224). Icon variants stay square — platform applies mask.
  if (isSplash) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(fullRect, Radius.circular(s * 0.22)),
    );
  }

  // Background.
  final bgPaint = Paint();
  switch (variant) {
    case _Variant.primary:
    case _Variant.splashGlyph:
      bgPaint.shader = KaiTide.gradientCorner.createShader(fullRect);
    case _Variant.dark:
      bgPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0E0E11), Color(0xFF1E1E23)],
      ).createShader(fullRect);
    case _Variant.mono:
      bgPaint.color = const Color(0xFF111114);
  }
  canvas.drawRect(fullRect, bgPaint);

  // Curve.
  _drawCurve(canvas, s, variant, fullRect);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  if (byteData == null) {
    throw StateError('toByteData returned null for $variant');
  }
  return byteData.buffer.asUint8List();
}

void _drawCurve(Canvas canvas, double s, _Variant variant, Rect fullRect) {
  final isSplash = variant == _Variant.splashGlyph;
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Dark variant: curve renders with tide-gradient shader instead of white.
  if (variant == _Variant.dark) {
    paint.shader = KaiTide.gradientCorner.createShader(fullRect);
  } else {
    paint.color = const Color(0xFFFFFFFF);
  }

  canvas.save();

  if (isSplash) {
    // 64-glyph canon: SVG 36×18 sits centered. On 1024:
    //   inner box = 1024 * (36/64) × (18/64) = 576 × 288, at offset (224, 368).
    canvas.translate(s * 14 / 64, s * 23 / 64);
    final scale = s / 64;
    canvas.scale(scale);
    paint.strokeWidth = 2.5;
    // Canon path M 2 11 Q 9 3, 18 11 T 34 7
    final path = Path()
      ..moveTo(2, 11)
      ..quadraticBezierTo(9, 3, 18, 11)
      // T 34,7 — reflected control = 2*(18,11) - (9,3) = (27, 19)
      ..quadraticBezierTo(27, 19, 34, 7);
    canvas.drawPath(path, paint);
  } else {
    // Icon canon: inset 22% top, 16% l/r, 24% bottom; curve viewBox 60×16
    // placed at xMidYMid meet inside the inner box.
    // On 1024: inner box = 696×553 at (164, 225). With 60:16 aspect (3.75:1)
    // the curve renders at 696×186, vertically centered: y = 225 + (553-186)/2 = 408.
    canvas.translate(s * 164 / 1024, s * 408 / 1024);
    final scale = s * 696 / 1024 / 60;
    canvas.scale(scale);
    paint.strokeWidth = 3;
    // Canon path M 2 10 Q 14 2, 28 10 T 56 6
    final path = Path()
      ..moveTo(2, 10)
      ..quadraticBezierTo(14, 2, 28, 10)
      // T 56,6 — reflected control = 2*(28,10) - (14,2) = (42, 18)
      ..quadraticBezierTo(42, 18, 56, 6);
    canvas.drawPath(path, paint);
  }

  canvas.restore();
}
