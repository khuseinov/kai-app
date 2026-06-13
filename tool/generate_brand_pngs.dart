// Brand PNG generator — direct Canvas/PictureRecorder rendering (no widget
// tree, no RepaintBoundary.toImage which timed out in TestWidgetsBinding).
// Reproduces the canon curve paths from `brand.html § 02.1–02.2` and exports
// 1024×1024 PNG masters for `flutter_launcher_icons` + `flutter_native_splash`,
// plus the 1200×630 OG card from `brand.html § 02.2`.
//
// Usage:
//   flutter test tool/generate_brand_pngs.dart
//
// Outputs:
//   brand/icon-1024.png              (primary — tide-gradient corner + white curve)
//   brand/icon-1024-dark.png         (dark slate + tide-gradient curve)
//   brand/icon-1024-mono.png         (#111114 + white curve)
//   brand/icon-1024-mono-tinted.png  (transparent + white curve — iOS 18 tinted)
//   brand/splash-glyph-1024.png      (rounded glyph with built-in radius 22%)
//   brand/og-default.png             (1200×630 OG card)
//   web/og-default.png               (copy for web OpenGraph meta tags)

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

enum _Variant { primary, dark, mono, monoTinted, splashGlyph, ogCard }

const int _size = 1024;

final _assets = <(_Variant, String)>[
  (_Variant.primary, 'brand/icon-1024.png'),
  (_Variant.dark, 'brand/icon-1024-dark.png'),
  (_Variant.mono, 'brand/icon-1024-mono.png'),
  (_Variant.monoTinted, 'brand/icon-1024-mono-tinted.png'),
  (_Variant.splashGlyph, 'brand/splash-glyph-1024.png'),
  (_Variant.ogCard, 'brand/og-default.png'),
];

void main() {
  test(
    'generate brand PNGs from canon paths',
    () async {
      // ensureInitialized — `test` (not `testWidgets`) doesn't pre-init bindings.
      TestWidgetsFlutterBinding.ensureInitialized();
      await _loadBrandFont();
      for (final (variant, target) in _assets) {
        final bytes = variant == _Variant.ogCard
            ? await _renderOgCard()
            : await _renderTile(variant, _size);
        // Flatten opaque icon variants to 24-bit RGB so store icons have no
        // alpha channel. Keep the iOS 18 tinted stencil transparent.
        final finalBytes = (variant == _Variant.primary ||
                variant == _Variant.dark ||
                variant == _Variant.mono)
            ? _flattenAlpha(bytes)
            : bytes;
        await File(target).writeAsBytes(finalBytes);
        if (variant == _Variant.ogCard) {
          await File('web/og-default.png').writeAsBytes(bytes);
        }
        // ignore: avoid_print
        print(
          '  ✓ $target  '
          '${variant == _Variant.ogCard ? '1200×630' : '$_size×$_size'}  '
          '(${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB)',
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _loadBrandFont() async {
  final file = File('assets/fonts/Manrope.ttf');
  if (!file.existsSync()) {
    throw StateError('Brand font not found at assets/fonts/Manrope.ttf');
  }
  final bytes = await file.readAsBytes();
  final byteData =
      bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);
  final loader = FontLoader('Manrope')..addFont(Future.value(byteData));
  await loader.load();
}

Future<Uint8List> _renderTile(_Variant variant, int size) async {
  final s = size.toDouble();
  final isSplash = variant == _Variant.splashGlyph;
  final fullRect = Rect.fromLTWH(0, 0, s, s);

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Splash glyph bakes in the splash-glyph radius (20 px on 64 = 31.25%;
  // scaled to 1024 = 320), matching brand/splash-glyph.svg rx="320".
  // Icon variants stay square — platform applies mask.
  if (isSplash) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(fullRect, Radius.circular(s * (20 / 64))),
    );
  }

  // Background.
  final bgPaint = Paint();
  switch (variant) {
    case _Variant.primary:
    case _Variant.splashGlyph:
      bgPaint.shader = KaiTide.gradientCorner.createShader(fullRect);
      canvas.drawRect(fullRect, bgPaint);
    case _Variant.dark:
      bgPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0E0E11), Color(0xFF1E1E23)],
      ).createShader(fullRect);
      canvas.drawRect(fullRect, bgPaint);
    case _Variant.mono:
      bgPaint.color = const Color(0xFF111114);
      canvas.drawRect(fullRect, bgPaint);
    case _Variant.monoTinted:
      // Transparent background — iOS 18 tinted mode applies its own colour.
      break;
    case _Variant.ogCard:
      throw UnsupportedError('Use _renderOgCard() for the OG card variant');
  }

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
  // Mono + tinted variants: white curve (tinted mode lets iOS recolour it).
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

Future<Uint8List> _renderOgCard() async {
  const width = 1200;
  const height = 630;
  const paddingX = 64.0;
  const paddingY = 56.0;
  const ink1 = Color(0xFF111114);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final cardRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());

  // Ink-1 background.
  canvas.drawRect(cardRect, Paint()..color = ink1);

  // Soft blurred radial bg-curve (sea-glass glow).
  // HTML: right:-100px; top:50%; width/height:700px; blur:20px;
  //        radial-gradient(circle, rgba(43,168,201,0.4), transparent 65%).
  const glowCenter = Offset(width - 100 - 350, height / 2);
  const glowRadius = 350.0;
  final glowPaint = Paint()
    ..shader = ui.Gradient.radial(
      glowCenter,
      glowRadius,
      [const Color(0x662BA8C9), const Color(0x002BA8C9)],
      [0.0, 0.65],
    )
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
  canvas.drawCircle(glowCenter, glowRadius, glowPaint);

  // Top mark: tide-gradient curve + "kai" wordmark.
  const markHeight = 22.0;
  const curveW = 40.0;
  const curveH = 8.0;
  const markGap = 14.0;
  const markY = paddingY + (markHeight - curveH) / 2;

  final curvePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..shader = KaiTide.gradient.createShader(
      const Rect.fromLTWH(paddingX, markY, curveW, curveH),
    );
  final curvePath = Path()
    ..moveTo(2, 4)
    ..quadraticBezierTo(10, 0, 20, 4)
    // Reflected control for T 38,3: 2*(20,4) - (10,0) = (30,8).
    ..quadraticBezierTo(30, 8, 38, 3);
  canvas.save();
  canvas.translate(paddingX, markY);
  canvas.drawPath(curvePath, curvePaint);
  canvas.restore();

  final wordmarkParagraph = _buildParagraph(
    text: 'kai',
    color: const Color(0xFFFFFFFF),
    fontSize: markHeight,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * markHeight,
  );
  canvas.drawParagraph(
    wordmarkParagraph,
    const Offset(paddingX + curveW + markGap, paddingY),
  );

  // Title block laid out with CSS flex "space-between" logic:
  // available content height = 630 - 2*56 = 518.
  // content = mark(22) + title(2*67.2) + footer(16) = 172.4.
  // two gaps = (518 - 172.4)/2 = 172.8.
  const titleFontSize = 64.0;
  const titleLineHeight = titleFontSize * 1.05;
  const titleTop = paddingY + markHeight + 172.8;

  final line1 = _buildParagraph(
    text: 'Тихая система,',
    color: const Color(0xFFFFFFFF),
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03 * titleFontSize,
    height: 1.05,
  );
  canvas.drawParagraph(line1, const Offset(paddingX, titleTop));

  // Second line: "с " (white) + "моментами прилива." (gradient italic).
  const line2Top = titleTop + titleLineHeight;
  const prefix = 'с ';

  // Measure prefix width to place the gradient italic fragment.
  final prefixMeasure = _buildParagraph(
    text: prefix,
    color: const Color(0x00FFFFFF),
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03 * titleFontSize,
    height: 1.05,
  );
  final prefixWidth = prefixMeasure.maxIntrinsicWidth;

  final prefixParagraph = _buildParagraph(
    text: prefix,
    color: const Color(0xFFFFFFFF),
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03 * titleFontSize,
    height: 1.05,
  );
  canvas.drawParagraph(prefixParagraph, const Offset(paddingX, line2Top));

  // Gradient italic text — shader matches the fragment's bounding box.
  const italicText = 'моментами прилива.';
  final italicMeasure = _buildParagraph(
    text: italicText,
    color: const Color(0x00FFFFFF),
    fontSize: titleFontSize,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.03 * titleFontSize,
    height: 1.05,
  );
  final italicWidth = italicMeasure.maxIntrinsicWidth;
  final gradientRect = Rect.fromLTWH(
    paddingX + prefixWidth,
    line2Top,
    italicWidth,
    titleLineHeight,
  );
  final gradientPaint = Paint()
    ..shader = KaiTide.gradient.createShader(gradientRect);
  final italicParagraph = _buildParagraph(
    text: italicText,
    fontSize: titleFontSize,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.03 * titleFontSize,
    height: 1.05,
    foreground: gradientPaint,
  );
  canvas.drawParagraph(
    italicParagraph,
    Offset(paddingX + prefixWidth, line2Top),
  );

  // Footer.
  const footerFontSize = 16.0;
  const footerTop = height - paddingY - footerFontSize;
  final leftFooter = _buildParagraph(
    text: 'kai.wize.ai',
    color: const Color(0x99FFFFFF),
    fontSize: footerFontSize,
    fontWeight: FontWeight.w400,
  );
  canvas.drawParagraph(leftFooter, const Offset(paddingX, footerTop));

  final rightFooter = _buildParagraph(
    text: 'путешествия · компаньон · AI',
    color: const Color(0x99FFFFFF),
    fontSize: footerFontSize,
    fontWeight: FontWeight.w400,
  );
  canvas.drawParagraph(
    rightFooter,
    Offset(width - paddingX - rightFooter.maxIntrinsicWidth, footerTop),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  if (byteData == null) {
    throw StateError('toByteData returned null for OG card');
  }
  return byteData.buffer.asUint8List();
}

/// Strip the alpha channel from an already-opaque icon tile.
///
/// `ui.ImageByteFormat.png` always emits RGBA, but App Store icons must be
/// opaque RGB. This helper drops the alpha channel and exports a true 24-bit
/// RGB PNG. It assumes the tile already fully covers the canvas (true for
/// primary, dark and mono variants).
Uint8List _flattenAlpha(Uint8List pngBytes) {
  final decoded = img.decodePng(pngBytes);
  if (decoded == null) {
    throw StateError('Could not decode PNG for alpha removal');
  }
  final background = img.ColorRgba8(14, 14, 17, 255);
  final flattened = img.Image(
    width: decoded.width,
    height: decoded.height,
    numChannels: 3,
  );
  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final src = decoded.getPixel(x, y);
      final alpha = src.a / 255.0;
      final r = (src.r * alpha + background.r * (1 - alpha)).round();
      final g = (src.g * alpha + background.g * (1 - alpha)).round();
      final b = (src.b * alpha + background.b * (1 - alpha)).round();
      flattened.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  final encoded = img.encodePng(flattened, level: 9);
  return Uint8List.fromList(encoded);
}

ui.Paragraph _buildParagraph({
  required String text,
  Color? color,
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
  Paint? foreground,
}) {
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
    fontSize: fontSize,
    height: height,
  ));
  final style = ui.TextStyle(
    color: foreground == null ? color : null,
    foreground: foreground,
    fontFamily: 'Manrope',
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    fontSize: fontSize,
    letterSpacing: letterSpacing,
    height: height,
  );
  builder.pushStyle(style);
  builder.addText(text);
  final paragraph = builder.build();
  paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));
  return paragraph;
}
