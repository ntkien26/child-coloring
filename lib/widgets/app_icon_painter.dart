import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import 'game_ui_kit.dart';

/// App icon painter that renders the exact same artist mascot and storybook
/// backdrop as the splash screen into a full-bleed square suitable for
/// Android and iOS launcher icons (1024x1024 master).
class AppIconPainter extends CustomPainter {
  const AppIconPainter({this.phase = 0.0});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1. Full-bleed sky & warm meadow gradient from splash screen
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5CC6F5),
          Color(0xFFAEE6FC),
          Color(0xFFFFF4C8),
          Color(0xFFFDE39B),
        ],
        stops: [0.0, 0.45, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Soft glowing sunbeam aura behind mascot
    final auraCenter = Offset(w * 0.5, h * 0.48);
    final auraRadius = w * 0.44;
    canvas.drawCircle(
      auraCenter,
      auraRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.65),
            const Color(0xFFFFF3B0).withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: auraCenter, radius: auraRadius)),
    );

    // 3. Cheerful rainbow arc across the sky
    const bands = [
      Color(0xFFFF5E62),
      Color(0xFFFFA93A),
      Color(0xFFFFE14D),
      Color(0xFF6DD660),
      Color(0xFF4FB3FF),
    ];
    final arcCenter = Offset(w * 0.5, h * 0.58);
    final arcBaseR = w * 0.45;
    for (int i = 0; i < bands.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: arcCenter, radius: arcBaseR - i * (w * 0.035)),
        math.pi * 1.08,
        math.pi * 0.84,
        false,
        Paint()
          ..color = bands[i].withValues(alpha: 0.88)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.035
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Soft clouds
    _drawCloud(canvas, Offset(w * 0.16, h * 0.22), w / 450);
    _drawCloud(canvas, Offset(w * 0.84, h * 0.24), w / 430);

    // 5. Twinkling golden & pastel stars
    _drawStar(canvas, Offset(w * 0.13, h * 0.44), w * 0.046, const Color(0xFFFFCA28));
    _drawStar(canvas, Offset(w * 0.87, h * 0.42), w * 0.048, const Color(0xFFFF6B8B));
    _drawStar(canvas, Offset(w * 0.18, h * 0.74), w * 0.040, const Color(0xFF59D355));
    _drawStar(canvas, Offset(w * 0.82, h * 0.72), w * 0.042, const Color(0xFF4DABF7));
    _drawStar(canvas, Offset(w * 0.26, h * 0.13), w * 0.036, const Color(0xFFFFEA00));
    _drawStar(canvas, Offset(w * 0.74, h * 0.13), w * 0.038, const Color(0xFFB77CFF));

    // 6. Center Artist Panda Mascot (exact painter from splash screen)
    // Scaled to fit comfortably inside the safe launcher zone (72% diameter)
    final mascotSize = Size(w * 0.72, h * 0.72);
    canvas.save();
    canvas.translate((w - mascotSize.width) / 2, (h - mascotSize.height) / 2 + h * 0.02);
    SplashArtistMascotPainter(phase: phase).paint(canvas, mascotSize);
    canvas.restore();
  }

  void _drawCloud(Canvas canvas, Offset c, double scale) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    final path = Path()
      ..moveTo(-36, 14)
      ..cubicTo(-52, 14, -55, -4, -40, -10)
      ..cubicTo(-40, -24, -18, -30, -6, -18)
      ..cubicTo(2, -34, 28, -30, 32, -12)
      ..cubicTo(50, -10, 52, 12, 36, 14)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.94));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF5FA8D3).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.restore();
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * 0.45;
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
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = kComicInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant AppIconPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
