import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/audio_service.dart';
import '../providers/catalog_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/game_ui_kit.dart';
import 'home_screen.dart';

/// Screen 0: Animated storybook splash screen that pre-warms the SVG catalog
/// and transitions smoothly into [HomeScreen].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
  });

  final Duration duration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navTimer;
  bool _navigated = false;

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
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Pre-warm the coloring catalog while the splash screen is playing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(catalogProvider);
      }
    });

    _navTimer = Timer(widget.duration, _goToHome);
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    AudioService.instance.playSparkle();
    Navigator.of(context).pushReplacement(
      bouncyGameRoute<void>(const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToHome,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full edge-to-edge storybook sky & warm meadow backdrop
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5CC6F5),
                    Color(0xFFAEE6FC),
                    Color(0xFFFFF4C8),
                    Color(0xFFFDE39B),
                  ],
                  stops: [0.0, 0.45, 0.78, 1.0],
                ),
              ),
            ),

            // Animated rainbow, clouds, sparkles & floating crayons backdrop
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: SplashBackdropPainter(phase: _controller.value),
                  size: Size.infinite,
                );
              },
            ),

            // Safe area content so nothing overlaps the status bar or home indicator
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxHeight < 560;
                  final mascotSize = isCompact ? 136.0 : 178.0;
                  final titleSize1 = isCompact ? 34.0 : 44.0;
                  final titleSize2 = isCompact ? 38.0 : 50.0;

                  return Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouncing Cute Artist Panda Mascot with Palette & Brush
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                final t = _controller.value * math.pi * 2;
                                final dy = math.sin(t) * 7.0;
                                final tilt = math.sin(t * 0.5) * 0.035;
                                return Transform.translate(
                                  offset: Offset(0, dy),
                                  child: Transform.rotate(
                                    angle: tilt,
                                    child: CustomPaint(
                                      size: Size(mascotSize, mascotSize),
                                      painter: SplashArtistMascotPainter(
                                        phase: _controller.value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: isCompact ? 12 : 18),

                            // Rainbow Comic Game Title
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RainbowComicText(
                                    s.appTitleLine1,
                                    fontSize: titleSize1,
                                    colors: _line1Colors,
                                    strokeWidth: 7.5,
                                    haloExtra: 6.5,
                                  ),
                                  const SizedBox(height: 4),
                                  RainbowComicText(
                                    s.appTitleLine2,
                                    fontSize: titleSize2,
                                    colors: _line2Colors,
                                    strokeWidth: 8.0,
                                    haloExtra: 6.5,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Subtitle Wooden Signboard
                            WoodenSignboard(
                              label: s.splashSubtitle,
                              fontSize: isCompact ? 14 : 15.5,
                            ),

                            SizedBox(height: isCompact ? 18 : 28),

                            // Animated Rainbow Crayon Progress Bar
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.08, end: 1.0),
                              duration: widget.duration,
                              curve: Curves.easeInOutCubic,
                              builder: (context, progress, _) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 240,
                                      height: 24,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7B4A22),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: kComicInk,
                                          width: 3.0,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x333B2314),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FractionallySizedBox(
                                            widthFactor:
                                                progress.clamp(0.05, 1.0),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF5E62),
                                                    Color(0xFFFFA93A),
                                                    Color(0xFFFFE14D),
                                                    Color(0xFF6DD660),
                                                    Color(0xFF4FB3FF),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedComicText(
                                      s.splashLoading,
                                      fontSize: 13.5,
                                      fillColor: Colors.white,
                                      strokeWidth: 3.4,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashBackdropPainter extends CustomPainter {
  SplashBackdropPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = phase * math.pi * 2;

    // Soft glowing sunbeam aura behind the mascot
    final center = Offset(w * 0.5, h * 0.36);
    final auraRadius = math.min(w, h) * 0.44;
    canvas.drawCircle(
      center,
      auraRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.55),
            const Color(0xFFFFF3B0).withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: auraRadius)),
    );

    // Big cheerful rainbow arc across the sky
    const bands = [
      Color(0xFFFF5E62),
      Color(0xFFFFA93A),
      Color(0xFFFFE14D),
      Color(0xFF6DD660),
      Color(0xFF4FB3FF),
    ];
    final arcCenter = Offset(w * 0.5, h * 0.48);
    final arcBaseR = math.min(w * 0.48, 230.0);
    for (int i = 0; i < bands.length; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: arcCenter, radius: arcBaseR - i * 10.0),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = bands[i].withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Fluffy drifting clouds
    _drawCloud(
      canvas,
      Offset(w * 0.14 + math.sin(t) * 6, h * 0.20),
      1.05,
    );
    _drawCloud(
      canvas,
      Offset(w * 0.86 - math.sin(t) * 6, h * 0.22),
      1.1,
    );

    // Floating twinkling stars & paint drops
    final stars = [
      (Offset(w * 0.14, h * 0.42), 11.0, const Color(0xFFFFCA28), 0.0),
      (Offset(w * 0.86, h * 0.40), 12.0, const Color(0xFFFF6B8B), 1.4),
      (Offset(w * 0.20, h * 0.72), 10.0, const Color(0xFF59D355), 2.5),
      (Offset(w * 0.82, h * 0.70), 11.0, const Color(0xFF4DABF7), 3.8),
      (Offset(w * 0.28, h * 0.14), 9.0, const Color(0xFFFFEA00), 4.9),
      (Offset(w * 0.72, h * 0.13), 9.5, const Color(0xFFB77CFF), 5.6),
    ];
    for (final s in stars) {
      final pulse = 0.85 + 0.22 * math.sin(t + s.$4);
      _drawStar(
        canvas,
        s.$1.translate(0, math.sin(t + s.$4) * 5),
        s.$2 * pulse,
        s.$3,
      );
    }
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
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.92));
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
        ..strokeWidth = 2.0
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant SplashBackdropPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class SplashArtistMascotPainter extends CustomPainter {
  SplashArtistMascotPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.shortestSide / 170.0;
    final t = phase * math.pi * 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // Circular badge medallion behind the panda artist
    canvas.drawCircle(
      const Offset(0, 8),
      66,
      Paint()..color = kComicInk.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      const Offset(0, 4),
      66,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(0, 4),
      59,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE57F), Color(0xFFFFB74D)],
        ).createShader(Rect.fromCircle(center: const Offset(0, 4), radius: 59)),
    );
    canvas.drawCircle(
      const Offset(0, 4),
      66,
      Paint()
        ..color = kComicInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2,
    );

    const dark = Color(0xFF3E3A47);
    final darkFill = Paint()..color = dark;
    final whiteFill = Paint()..color = Colors.white;
    final ink = Paint()
      ..color = kComicInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Chubby body
    final bodyRect =
        Rect.fromCenter(center: const Offset(0, 38), width: 54, height: 42);
    canvas.drawOval(bodyRect, whiteFill);
    canvas.drawOval(bodyRect, ink);

    // Cute round ears
    for (final dx in [-30.0, 30.0]) {
      canvas.drawCircle(Offset(dx, -28), 14, darkFill);
      canvas.drawCircle(
        Offset(dx * 0.96, -27),
        7,
        Paint()..color = const Color(0xFFFFADC2),
      );
      canvas.drawCircle(Offset(dx, -28), 14, ink);
    }

    // Chubby panda head
    final headRect =
        Rect.fromCenter(center: const Offset(0, -2), width: 82, height: 68);
    canvas.drawOval(headRect, whiteFill);
    canvas.drawOval(headRect, ink);

    // Artist beret hat on top!
    final beretPath = Path()
      ..moveTo(-28, -28)
      ..cubicTo(-34, -50, 26, -54, 34, -30)
      ..quadraticBezierTo(4, -22, -28, -28)
      ..close();
    canvas.drawPath(beretPath, Paint()..color = const Color(0xFFFF4D6D));
    canvas.drawPath(beretPath, ink);
    // Beret pom-pom
    canvas.drawCircle(
      const Offset(4, -47),
      5.5,
      Paint()..color = const Color(0xFFFFD43B),
    );
    canvas.drawCircle(const Offset(4, -47), 5.5, ink);

    // Eye patches & sparkling eyes
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(17 * side, -3);
      canvas.rotate(0.28 * side);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 20, height: 24),
        darkFill,
      );
      canvas.restore();

      final ex = 16 * side;
      canvas.drawCircle(Offset(ex, -4), 6.8, whiteFill);
      canvas.drawCircle(
        Offset(ex - 0.5 * side, -4),
        5.0,
        Paint()..color = const Color(0xFF1F1B24),
      );
      canvas.drawCircle(Offset(ex - 2.0, -6.2), 2.3, whiteFill);
    }

    // Rosy cheeks
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(28 * side, 10),
          width: 14,
          height: 8.5,
        ),
        Paint()..color = const Color(0xFFFF85A8),
      );
    }

    // Button nose & happy smile
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 5), width: 10, height: 7),
      darkFill,
    );
    final smile = Path()
      ..moveTo(-9, 12)
      ..quadraticBezierTo(0, 22, 9, 12);
    canvas.drawPath(smile, ink);

    // Left hand holding a mini colorful paint palette
    canvas.save();
    canvas.translate(-42, 34);
    final paletteRect =
        Rect.fromCenter(center: Offset.zero, width: 38, height: 28);
    canvas.drawOval(paletteRect, Paint()..color = const Color(0xFFF3C68F));
    canvas.drawOval(paletteRect, ink);
    const dotColors = [
      (Offset(-10, -4), Color(0xFFFF3B30)),
      (Offset(0, -7), Color(0xFF3A86FF)),
      (Offset(10, -3), Color(0xFF59D355)),
      (Offset(4, 5), Color(0xFFFFCA28)),
    ];
    for (final d in dotColors) {
      canvas.drawCircle(d.$1, 3.8, Paint()..color = d.$2);
    }
    canvas.restore();

    // Right waving arm holding a magic paintbrush
    final waveAngle = math.sin(t) * 0.22;
    canvas.save();
    canvas.translate(36, 26);
    canvas.rotate(waveAngle);
    // Brush handle
    final handle = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, -26, 8, 28),
      const Radius.circular(4),
    );
    canvas.drawRRect(handle, Paint()..color = const Color(0xFFFF922B));
    canvas.drawRRect(handle, ink);
    // Brush tip
    final tip = Path()
      ..moveTo(0, -26)
      ..quadraticBezierTo(6, -42, 12, -26)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFF9B5DE5));
    canvas.drawPath(tip, ink);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SplashArtistMascotPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
