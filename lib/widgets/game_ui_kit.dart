import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/l10n/app_strings.dart';

/// Signature warm dark-chocolate cartoon ink used across all borders & strokes.
const Color kComicInk = Color(0xFF3B2314);
const Color kParchmentTop = Color(0xFFFFF5CC);
const Color kParchmentBottom = Color(0xFFFDE6A6);

/// Playful elastic scale + fade transition between game screens.
Route<T> bouncyGameRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.93, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Color darkenColor(Color color, [double amount = 0.16]) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.06, 0.95))
      .toColor();
}

Color lightenColor(Color color, [double amount = 0.14]) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.06, 0.98))
      .toColor();
}

/// Bold cartoon text with crisp dark-chocolate ink stroke + comic drop shadow.
class OutlinedComicText extends StatelessWidget {
  const OutlinedComicText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.fillColor,
    this.strokeColor = kComicInk,
    this.strokeWidth = 4.5,
    this.letterSpacing = 0.5,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.shadowOffset = const Offset(0, 2.5),
  });

  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double letterSpacing;
  final TextAlign textAlign;
  final int maxLines;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle grounded comic shadow
        Transform.translate(
          offset: shadowOffset,
          child: Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: letterSpacing,
              height: 1.05,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = strokeColor.withValues(alpha: 0.35),
            ),
          ),
        ),
        // Crisp dark ink stroke
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: letterSpacing,
            height: 1.05,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        // Bright vibrant fill
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: letterSpacing,
            height: 1.05,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}

/// Warm butter-yellow cartoon parchment canvas with playful subtle doodles.
class WarmCartoonBackground extends StatelessWidget {
  const WarmCartoonBackground({
    super.key,
    required this.child,
    this.topColor = kParchmentTop,
    this.bottomColor = kParchmentBottom,
    this.showCrayonFence = false,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final bool showCrayonFence;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            painter: _WarmDoodleBackgroundPainter(),
            size: Size.infinite,
          ),
        ),
        if (showCrayonFence)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 76,
            child: IgnorePointer(child: BottomCrayonFence()),
          ),
        child,
      ],
    );
  }
}

class _WarmDoodleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft pastel decorative sparkles in corners (very subtle, never noisy)
    final stars = [
      (Offset(w * 0.08, h * 0.16), 9.0, const Color(0xFFFFCA28)),
      (Offset(w * 0.92, h * 0.22), 10.0, const Color(0xFFFF80AB)),
      (Offset(w * 0.06, h * 0.64), 8.0, const Color(0xFF7BD5F5)),
      (Offset(w * 0.94, h * 0.72), 9.0, const Color(0xFF9BE564)),
    ];
    for (final s in stars) {
      _drawCartoonStar(canvas, s.$1, s.$2, s.$3);
    }
  }

  void _drawCartoonStar(Canvas canvas, Offset c, double r, Color fill) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.46;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill.withValues(alpha: 0.72));
    canvas.drawPath(
      path,
      Paint()
        ..color = kComicInk.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Multi-color per-letter cartoon title: white halo + dark ink outline + rainbow fill.
class RainbowComicText extends StatelessWidget {
  const RainbowComicText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.colors,
    this.strokeWidth = 7.0,
    this.haloExtra = 6.0,
    this.letterSpacing = 0.8,
  });

  final String text;
  final double fontSize;
  final List<Color> colors;
  final double strokeWidth;
  final double haloExtra;
  final double letterSpacing;

  TextStyle _strokeStyle(Color color, double width) => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: letterSpacing,
        height: 1.0,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    int letterIndex = 0;
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      final isSpace = ch.trim().isEmpty;
      spans.add(
        TextSpan(
          text: ch,
          style: TextStyle(
            color: isSpace ? null : colors[letterIndex % colors.length],
          ),
        ),
      );
      if (!isSpace) letterIndex++;
    }

    final fillBase = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: letterSpacing,
      height: 1.0,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft grounded shadow
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(
            text,
            maxLines: 1,
            style: _strokeStyle(
              kComicInk.withValues(alpha: 0.28),
              strokeWidth + haloExtra,
            ),
          ),
        ),
        // White sticker halo
        Text(
          text,
          maxLines: 1,
          style: _strokeStyle(Colors.white, strokeWidth + haloExtra),
        ),
        // Dark ink outline
        Text(
          text,
          maxLines: 1,
          style: _strokeStyle(kComicInk, strokeWidth),
        ),
        // Rainbow letters
        Text.rich(
          TextSpan(style: fillBase, children: spans),
          maxLines: 1,
        ),
      ],
    );
  }
}

/// Warm sand-colored rounded panel that holds the theme cards (like the reference mockup).
class SandPanel extends StatelessWidget {
  const SandPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBE7B5), Color(0xFFF3D08A)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF9C6A35), width: 3.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC99A57),
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Storybook hero: bright sky, big rainbow, fluffy clouds, a waving panda sitting on a
/// cloud, floating music notes and the multi-color game title.
class StorybookHeroHeader extends StatelessWidget {
  const StorybookHeroHeader({
    super.key,
    required this.line1,
    required this.line2,
    required this.leftAction,
    required this.rightAction,
    this.bottomAction,
  });

  final String line1;
  final String line2;
  final Widget leftAction;
  final Widget rightAction;

  /// Optional callout displayed beside the panda, within the hero artwork.
  final Widget? bottomAction;

  static const List<Color> _line1Colors = [
    Color(0xFFFFB02E),
    Color(0xFFFFE14D),
    Color(0xFF7BD95B),
    Color(0xFF4FB3FF),
    Color(0xFFB77CFF),
    Color(0xFFFF8A3D),
  ];

  static const List<Color> _line2Colors = [
    Color(0xFFFF5E62),
    Color(0xFFFF8A3D),
    Color(0xFFFFD43B),
    Color(0xFFFF6B8B),
    Color(0xFFFF5E62),
    Color(0xFFFFA93A),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cw = math.min(w, 460.0);
        final h = cw * 0.54;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _HeroSkyPainter()),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: cw,
                  height: h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _HeroSceneryPainter()),
                      ),
                      Positioned(
                        left: cw * 0.16,
                        right: cw * 0.16,
                        top: h * 0.10,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RainbowComicText(
                                line1,
                                fontSize: h * 0.20,
                                colors: _line1Colors,
                              ),
                              SizedBox(height: h * 0.01),
                              RainbowComicText(
                                line2,
                                fontSize: h * 0.225,
                                colors: _line2Colors,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (bottomAction != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: h * 0.65,
                          child: Align(
                            alignment: Alignment.center,
                            child: bottomAction!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(top: 8, left: 12, child: leftAction),
              Positioned(top: 8, right: 12, child: rightAction),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sky = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.84)
      ..quadraticBezierTo(w * 0.75, h * 0.94, w * 0.5, h * 0.86)
      ..quadraticBezierTo(w * 0.25, h * 0.78, 0, h * 0.86)
      ..close();
    canvas.drawPath(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF63C9F6), Color(0xFFA9E4FB), Color(0xFFDDF5FF)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroSceneryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Big 5-band rainbow
    final center = Offset(w * 0.5, h * 0.90);
    final baseR = w * 0.44;
    const bands = [
      Color(0xFFFF5E62),
      Color(0xFFFFA93A),
      Color(0xFFFFE14D),
      Color(0xFF6DD660),
      Color(0xFF4FB3FF),
    ];
    for (int i = 0; i < bands.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: baseR - i * 9.0),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = bands[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9.6,
      );
    }

    // Clouds hiding the rainbow feet
    final leftCloud = Offset(w * 0.10, h * 0.78);
    final rightCloud = Offset(w * 0.865, h * 0.80);
    _drawCloud(canvas, leftCloud, 1.15);
    _drawCloud(canvas, rightCloud, 1.2);

    // Panda sitting on the right cloud, waving at the title
    _drawPanda(
      canvas,
      Offset(rightCloud.dx - w * 0.015, rightCloud.dy - 46),
      1.18,
    );

    // Music notes + stars
    _drawNote(canvas, Offset(w * 0.07, h * 0.36), const Color(0xFF9B5DE5), true);
    _drawNote(canvas, Offset(w * 0.075, h * 0.52), const Color(0xFFFF5E62), false);
    _drawNote(canvas, Offset(w * 0.955, h * 0.40), const Color(0xFF59D355), true);
    _drawStar(canvas, Offset(w * 0.26, h * 0.10), 9.5);
    _drawStar(canvas, Offset(w * 0.72, h * 0.09), 9.0);
    _drawStar(canvas, Offset(w * 0.045, h * 0.70), 8.0);
  }

  void _drawCloud(Canvas canvas, Offset c, double scale) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);

    final path = Path()
      ..moveTo(-42, 18)
      ..cubicTo(-60, 18, -64, -4, -46, -10)
      ..cubicTo(-46, -28, -22, -36, -8, -22)
      ..cubicTo(2, -40, 32, -36, 36, -14)
      ..cubicTo(58, -12, 62, 14, 42, 18)
      ..quadraticBezierTo(20, 24, 0, 20)
      ..quadraticBezierTo(-22, 24, -42, 18)
      ..close();

    canvas.save();
    canvas.translate(0, 4);
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF5FA8D3).withValues(alpha: 0.25),
    );
    canvas.restore();

    canvas.drawPath(path, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      const Rect.fromLTWH(-70, 4, 140, 26),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00D9F2FF), Color(0xFFB5E3FA)],
        ).createShader(const Rect.fromLTWH(-70, 4, 140, 26)),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5FA8D3).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  void _drawPanda(Canvas canvas, Offset c, double scale) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    canvas.rotate(-0.05);

    const dark = Color(0xFF3E3A47);
    final darkFill = Paint()..color = dark;
    final whiteFill = Paint()..color = Colors.white;
    final ink = Paint()
      ..color = kComicInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Tiny chubby body (chibi proportions: big head, small body)
    final bodyRect =
        Rect.fromCenter(center: const Offset(0, 29), width: 32, height: 26);
    canvas.drawOval(bodyRect, whiteFill);
    canvas.drawOval(bodyRect, ink);
    // Round belly patch
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 31), width: 17, height: 14),
      Paint()..color = const Color(0xFFF1F1F6),
    );

    // Stubby feet
    for (final dx in [-10.0, 10.0]) {
      final foot =
          Rect.fromCenter(center: Offset(dx, 41), width: 14, height: 10);
      canvas.drawOval(foot, darkFill);
      canvas.drawOval(foot, ink);
      canvas.drawCircle(
        Offset(dx, 42),
        2.4,
        Paint()..color = const Color(0xFFFF9EB5),
      );
    }

    // Arms: right resting, left waving hello
    void arm(Offset from, Offset to) {
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = kComicInk
          ..strokeWidth = 11.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = dark
          ..strokeWidth = 8.4
          ..strokeCap = StrokeCap.round,
      );
    }

    arm(const Offset(13, 24), const Offset(19, 33));
    arm(const Offset(-13, 23), const Offset(-27, 8));

    // Round ears with cute pink inner ear pads
    for (final dx in [-21.0, 21.0]) {
      canvas.drawCircle(Offset(dx, -22), 9.5, darkFill);
      canvas.drawCircle(
        Offset(dx * 0.96, -21.5),
        4.6,
        Paint()..color = const Color(0xFFFFADC2),
      );
      canvas.drawCircle(Offset(dx, -22), 9.5, ink);
    }

    // Mochi-shaped chubby baby panda head (fuller at the cheeks!)
    final headPath = Path()
      ..moveTo(0, -27)
      ..cubicTo(22, -27, 30, -12, 31, 2)
      ..cubicTo(32, 16, 19, 23, 0, 23)
      ..cubicTo(-19, 23, -32, 16, -31, 2)
      ..cubicTo(-30, -12, -22, -27, 0, -27)
      ..close();
    canvas.drawPath(headPath, whiteFill);

    // Soft cheek bottom shading on the head
    canvas.save();
    canvas.clipPath(headPath);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 17), width: 64, height: 16),
      Paint()..color = const Color(0xFFF2EFF8),
    );
    canvas.restore();
    canvas.drawPath(headPath, ink);

    // Large tilted panda eye patches
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(12.5 * side, -3.5);
      canvas.rotate(0.32 * side);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 15.5, height: 18.5),
        darkFill,
      );
      canvas.restore();
    }

    // Big glossy sparkling anime/cartoon eyes
    for (final side in [-1.0, 1.0]) {
      final ex = 11.8 * side;
      canvas.drawCircle(Offset(ex, -4.2), 5.2, whiteFill);
      canvas.drawCircle(
        Offset(ex - 0.3 * side, -4.0),
        3.9,
        Paint()..color = const Color(0xFF1F1B24),
      );
      // Big top-left star shine + tiny bottom-right shine
      canvas.drawCircle(Offset(ex - 1.5, -5.8), 1.9, whiteFill);
      canvas.drawCircle(Offset(ex + 1.3, -2.3), 1.0, whiteFill);
    }

    // Rosy pink blush cheeks with tiny white gloss dot
    final blush = Paint()..color = const Color(0xFFFF85A8).withValues(alpha: 0.92);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(21.5 * side, 7.5), width: 10.5, height: 6.2),
        blush,
      );
      canvas.drawCircle(Offset(21.5 * side - 1.8, 6.5), 1.1, whiteFill);
    }

    // Tiny cute button nose
    final nose = Path()
      ..moveTo(-3.4, 2.2)
      ..quadraticBezierTo(0, 0.8, 3.4, 2.2)
      ..quadraticBezierTo(2.2, 5.4, 0, 5.6)
      ..quadraticBezierTo(-2.2, 5.4, -3.4, 2.2)
      ..close();
    canvas.drawPath(nose, darkFill);

    // Cheerful open smile with cute pink tongue + "w" upper lip
    final mouthBg = Path()
      ..moveTo(-6.2, 7.5)
      ..quadraticBezierTo(-3.1, 10.2, 0, 7.6)
      ..quadraticBezierTo(3.1, 10.2, 6.2, 7.5)
      ..quadraticBezierTo(4.8, 16.2, 0, 16.2)
      ..quadraticBezierTo(-4.8, 16.2, -6.2, 7.5)
      ..close();
    canvas.drawPath(mouthBg, Paint()..color = const Color(0xFF8C2D46));

    // Pink tongue clipped inside mouth
    canvas.save();
    canvas.clipPath(mouthBg);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 14.5), width: 10, height: 7),
      Paint()..color = const Color(0xFFFF789E),
    );
    canvas.restore();

    canvas.drawPath(
      mouthBg,
      Paint()
        ..color = kComicInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.restore();
  }

  void _drawNote(Canvas canvas, Offset c, Color fill, bool isDouble) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1.15);
    final fillPaint = Paint()..color = fill;
    final stroke = Paint()
      ..color = kComicInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    if (isDouble) {
      final beam = Path()
        ..moveTo(-6, 6)
        ..lineTo(-6, -10)
        ..lineTo(9, -14)
        ..lineTo(9, 2)
        ..lineTo(6, 2)
        ..lineTo(6, -8)
        ..lineTo(-3, -5.5)
        ..lineTo(-3, 6)
        ..close();
      canvas.drawPath(beam, fillPaint);
      canvas.drawPath(beam, stroke);
      for (final head in [
        Rect.fromCenter(center: const Offset(-8, 6.5), width: 8, height: 6),
        Rect.fromCenter(center: const Offset(6, 3.5), width: 8, height: 6),
      ]) {
        canvas.drawOval(head, fillPaint);
        canvas.drawOval(head, stroke);
      }
    } else {
      final stem = Path()
        ..moveTo(0, 6)
        ..lineTo(0, -11)
        ..quadraticBezierTo(9, -9, 8, -2)
        ..quadraticBezierTo(5, -5, 3, -5)
        ..lineTo(3, 6)
        ..close();
      canvas.drawPath(stem, fillPaint);
      canvas.drawPath(stem, stroke);
      final head =
          Rect.fromCenter(center: const Offset(-2, 6.5), width: 8.5, height: 6.2);
      canvas.drawOval(head, fillPaint);
      canvas.drawOval(head, stroke);
    }
    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.46;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + rad * math.cos(a), c.dy + rad * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD43B));
    canvas.drawPath(
      path,
      Paint()
        ..color = kComicInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hand-drawn cartoon wooden signboard ("CHỌN CHỦ ĐỀ!" / "CHOOSE THEME!").
class WoodenSignboard extends StatelessWidget {
  const WoodenSignboard({
    super.key,
    required this.label,
    this.fontSize = 18.5,
    this.showRopes = false,
  });

  final String label;
  final double fontSize;
  final bool showRopes;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showRopes)
          SizedBox(
            width: 170,
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA05B23),
                    border: Border.all(color: kComicInk, width: 1.8),
                  ),
                ),
                Container(
                  width: 6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA05B23),
                    border: Border.all(color: kComicInk, width: 1.8),
                  ),
                ),
              ],
            ),
          ),
        Container(
          constraints: const BoxConstraints(minWidth: 210, maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD98E45), Color(0xFFB86B27)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kComicInk, width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF7D4514),
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle wood-grain horizontal lines & nail dots
              Positioned(
                top: 2,
                left: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D4514),
                    shape: BoxShape.circle,
                    border: Border.all(color: kComicInk, width: 1.2),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7D4514),
                    shape: BoxShape.circle,
                    border: Border.all(color: kComicInk, width: 1.2),
                  ),
                ),
              ),
              OutlinedComicText(
                label,
                fontSize: fontSize,
                fillColor: Colors.white,
                strokeWidth: 4.5,
                letterSpacing: 0.7,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chunky cartoon game button with bold `#3B2314` ink outline, 3D ledge & bounce press.
class JuicyButton extends StatefulWidget {
  const JuicyButton({
    super.key,
    required this.color,
    required this.child,
    required this.onTap,
    this.borderRadius = 22,
    this.depth = 5,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderColor = kComicInk,
    this.borderWidth = 2.8,
    this.enabled = true,
  });

  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final double borderWidth;
  final bool enabled;

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = widget.enabled && widget.onTap != null;
    final baseColor = effectiveEnabled ? widget.color : const Color(0xFFD6CEC2);
    final ledgeColor = darkenColor(baseColor, 0.22);
    final pressOffset = _pressed && effectiveEnabled ? widget.depth - 1.5 : 0.0;

    return GestureDetector(
      onTapDown: effectiveEnabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: effectiveEnabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: effectiveEnabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        scale: _pressed && effectiveEnabled ? 0.96 : 1.0,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.depth),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Cartoon Ink-Outlined 3D Bottom Ledge
              Positioned.fill(
                top: widget.depth,
                bottom: -widget.depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ledgeColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kComicInk.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // Glossy Top Cartoon Surface
              Transform.translate(
                offset: Offset(0, pressOffset),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lightenColor(baseColor, 0.10),
                        baseColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.borderColor,
                      width: widget.borderWidth,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 6,
                        right: 6,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.36),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Center(child: widget.child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chunky circular cartoon icon button with bold `#3B2314` ink outline.
class JuicyCircleButton extends StatelessWidget {
  const JuicyCircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 46,
    this.iconSize = 23,
    this.iconColor = Colors.white,
    this.tooltip,
    this.enabled = true,
    this.selected = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final String? tooltip;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size + 4,
      child: JuicyButton(
        color: color,
        onTap: onTap,
        enabled: enabled,
        borderRadius: size / 2,
        depth: 4,
        borderWidth: selected ? 3.5 : 2.6,
        borderColor: kComicInk,
        padding: EdgeInsets.zero,
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? iconColor : Colors.grey.shade600,
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Cute cartoon VI / EN language toggle pill with bold ink border.
class LanguageTogglePill extends StatelessWidget {
  const LanguageTogglePill({
    super.key,
    required this.language,
    required this.onToggle,
    this.tooltip,
  });

  final AppLanguage language;
  final VoidCallback onToggle;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isVi = language == AppLanguage.vi;
    final pill = JuicyButton(
      color: isVi ? const Color(0xFFFF6B6B) : const Color(0xFF4DABF7),
      onTap: onToggle,
      borderRadius: 22,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kComicInk, width: 1.6),
            ),
            child: Icon(
              Icons.translate_rounded,
              size: 13,
              color: isVi ? const Color(0xFFE03131) : const Color(0xFF1971C2),
            ),
          ),
          const SizedBox(width: 5),
          OutlinedComicText(
            isVi ? 'VI' : 'EN',
            fontSize: 13.5,
            fillColor: Colors.white,
            strokeWidth: 3.0,
          ),
        ],
      ),
    );
    if (tooltip == null) return pill;
    return Tooltip(message: tooltip!, child: pill);
  }
}

/// Chunky cartoon pink Back pill button (inspired by Screen 3 of the reference!).
class CartoonBackPill extends StatelessWidget {
  const CartoonBackPill({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return JuicyButton(
      color: const Color(0xFFFF7A96),
      borderRadius: 24,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.reply_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 5),
          OutlinedComicText(
            label,
            fontSize: 14,
            fillColor: Colors.white,
            strokeWidth: 3.4,
          ),
        ],
      ),
    );
  }
}

/// Cute golden cartoon padlock badge (`Khóa` / `Lock`) with dark ink outline.
class CartoonPadlockBadge extends StatelessWidget {
  const CartoonPadlockBadge({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Padlock shackle arch
        Container(
          width: 18,
          height: 11,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: const Border(
              top: BorderSide(color: kComicInk, width: 3.2),
              left: BorderSide(color: kComicInk, width: 3.2),
              right: BorderSide(color: kComicInk, width: 3.2),
            ),
          ),
        ),
        // Golden lock body
        Transform.translate(
          offset: const Offset(0, -2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE066), Color(0xFFFFB020)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kComicInk, width: 2.3),
              boxShadow: [
                BoxShadow(
                  color: kComicInk.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: kComicInk,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Chunky cartoon green-on-brown progress bar (`1/3`, `2/3`, etc.) like the reference!
class CartoonProgressBar extends StatelessWidget {
  const CartoonProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF8D572B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kComicInk, width: 2.4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio > 0 ? math.max(0.18, ratio) : 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF7BE86B), Color(0xFF42B839)],
                  ),
                ),
              ),
            ),
            Center(
              child: OutlinedComicText(
                '$completed/$total',
                fontSize: 12,
                fillColor: Colors.white,
                strokeWidth: 3.0,
                shadowOffset: Offset.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Giant colorful standing cartoon crayons peeking up from the bottom edge!
class BottomCrayonFence extends StatelessWidget {
  const BottomCrayonFence({super.key});

  static const List<Color> _crayonColors = [
    Color(0xFFFF595E),
    Color(0xFFFF924C),
    Color(0xFFFFCA3A),
    Color(0xFF8AC926),
    Color(0xFF4CC9F0),
    Color(0xFF9B5DE5),
    Color(0xFFFF70A6),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BottomCrayonFencePainter(_crayonColors),
      size: Size.infinite,
    );
  }
}

class _BottomCrayonFencePainter extends CustomPainter {
  _BottomCrayonFencePainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final count = math.max(7, (size.width / 56).round());
    final slotW = size.width / count;

    for (int i = 0; i < count; i++) {
      final color = colors[i % colors.length];
      final x = i * slotW + slotW * 0.08;
      final w = slotW * 0.84;
      final tipY = (i.isEven ? 6.0 : 12.0);
      final bodyY = tipY + 26.0;

      // Tip cone
      final tip = Path()
        ..moveTo(x + w * 0.16, bodyY + 2)
        ..lineTo(x + w * 0.40, tipY)
        ..quadraticBezierTo(x + w * 0.50, tipY - 3, x + w * 0.60, tipY)
        ..lineTo(x + w * 0.84, bodyY + 2)
        ..close();

      canvas.drawPath(tip, Paint()..color = color);
      canvas.drawPath(
        tip,
        Paint()
          ..color = kComicInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeJoin = StrokeJoin.round,
      );

      // Body
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTRB(x, bodyY, x + w, size.height + 6),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              lightenColor(color, 0.12),
              color,
              darkenColor(color, 0.14),
            ],
          ).createShader(rect.outerRect),
      );

      // Wrapper stripes
      final stripeY = bodyY + 14;
      canvas.drawLine(
        Offset(x + 2, stripeY),
        Offset(x + w - 2, stripeY),
        Paint()
          ..color = kComicInk
          ..strokeWidth = 3.0,
      );
      canvas.drawLine(
        Offset(x + 2, stripeY + 7),
        Offset(x + w - 2, stripeY + 7),
        Paint()
          ..color = kComicInk
          ..strokeWidth = 2.4,
      );

      // Gloss
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + w * 0.15, bodyY + 4, w * 0.14, size.height - bodyY),
          const Radius.circular(3),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );

      // Outline
      canvas.drawRRect(
        rect,
        Paint()
          ..color = kComicInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
