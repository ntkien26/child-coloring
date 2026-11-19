import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../models/game_theme.dart';

class ThemedEffectGame extends FlameGame {
  ThemedEffectGame({required GameTheme initialTheme}) : _theme = initialTheme;

  GameTheme _theme;
  final math.Random _rng = math.Random();
  MascotComponent? _mascot;

  GameTheme get theme => _theme;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _mascot = MascotComponent(theme: _theme);
    add(_mascot!);
  }

  void updateTheme(GameTheme newTheme) {
    _theme = newTheme;
    _mascot?.updateTheme(newTheme);
  }

  void spawnBurst(Offset localPosition, {Color? accentColor}) {
    if (!isMounted) return;
    final origin = Vector2(localPosition.dx, localPosition.dy);
    final colors = [
      ?accentColor,
      ..._theme.particleColors,
    ];

    final particle = Particle.generate(
      count: 16,
      lifespan: 0.78,
      generator: (i) {
        final angle = (math.pi * 2 * i / 16) + (_rng.nextDouble() - 0.5) * 0.35;
        final speed = 70 + _rng.nextDouble() * 145;
        final vx = math.cos(angle) * speed;
        final vy = math.sin(angle) * speed - 35;
        final color = colors[_rng.nextInt(colors.length)];
        final radius = 4.5 + _rng.nextDouble() * 5.5;
        final shape = _theme.particleShape;

        return AcceleratedParticle(
          position: origin.clone(),
          speed: Vector2(vx, vy),
          acceleration: Vector2(0, shape == ParticleShape.bubble ? -120 : 210),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
              final scale = 1.0 - particle.progress * 0.35;
              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;
              canvas.save();
              canvas.scale(scale);
              _drawParticleShape(canvas, shape, radius, paint, opacity);
              canvas.restore();
            },
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));

    // Expanding shockwave ring + paint splatter droplets at tap point
    final ringColor = accentColor ?? _theme.primaryColor;
    final shockwave = ComputedParticle(
      lifespan: 0.42,
      renderer: (canvas, p) {
        final t = Curves.easeOutCubic.transform(p.progress);
        final alpha = (1.0 - p.progress).clamp(0.0, 1.0);
        final radius = 10.0 + t * 54.0;
        final ringPaint = Paint()
          ..color = ringColor.withValues(alpha: alpha * 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0 * (1.0 - t * 0.65);
        canvas.drawCircle(
          Offset(origin.x, origin.y),
          radius,
          ringPaint,
        );
      },
    );
    add(ParticleSystemComponent(particle: shockwave));

    _mascot?.triggerHappyHop();
  }

  void spawnBrushTrail(
    Offset localPosition, {
    Color? accentColor,
    bool isSpecialPattern = false,
  }) {
    if (!isMounted) return;
    final origin = Vector2(localPosition.dx, localPosition.dy);
    final colors = [
      ?accentColor,
      ..._theme.particleColors,
    ];
    final count = isSpecialPattern ? 5 : 3;

    final particle = Particle.generate(
      count: count,
      lifespan: 0.48,
      generator: (i) {
        final angle = _rng.nextDouble() * math.pi * 2;
        final speed = 28 + _rng.nextDouble() * 68;
        final vx = math.cos(angle) * speed;
        final vy = math.sin(angle) * speed - 22;
        final color = colors[_rng.nextInt(colors.length)];
        final radius = 3.2 + _rng.nextDouble() * 3.8;
        final shape = isSpecialPattern
            ? ParticleShape.sparkle
            : _theme.particleShape;

        return AcceleratedParticle(
          position: origin.clone(),
          speed: Vector2(vx, vy),
          acceleration: Vector2(0, 95),
          child: ComputedParticle(
            renderer: (canvas, p) {
              final opacity = (1.0 - p.progress).clamp(0.0, 1.0);
              final scale = 1.0 - p.progress * 0.4;
              final paint = Paint()
                ..color = color.withValues(alpha: opacity * 0.9)
                ..style = PaintingStyle.fill;
              canvas.save();
              canvas.scale(scale);
              _drawParticleShape(canvas, shape, radius, paint, opacity);
              canvas.restore();
            },
          ),
        );
      },
    );
    add(ParticleSystemComponent(particle: particle));
  }

  void triggerCelebration() {
    if (!isMounted) return;
    _mascot?.triggerCelebrate();

    final w = size.x > 0 ? size.x : 400.0;
    final h = size.y > 0 ? size.y : 500.0;
    final spots = [
      Offset(w * 0.22, h * 0.25),
      Offset(w * 0.50, h * 0.20),
      Offset(w * 0.78, h * 0.25),
      Offset(w * 0.35, h * 0.45),
      Offset(w * 0.65, h * 0.45),
    ];

    for (final spot in spots) {
      spawnBurst(spot);
    }
  }

  static void _drawParticleShape(
    Canvas canvas,
    ParticleShape shape,
    double r,
    Paint paint,
    double opacity,
  ) {
    switch (shape) {
      case ParticleShape.bubble:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        canvas.drawCircle(Offset.zero, r, paint);
        final shine = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.8);
        canvas.drawCircle(Offset(-r * 0.3, -r * 0.3), r * 0.25, shine);
      case ParticleShape.heart:
        final path = Path()
          ..moveTo(0, r * 0.75)
          ..cubicTo(-r * 1.1, r * 0.1, -r * 1.0, -r * 0.8, 0, -r * 0.2)
          ..cubicTo(r * 1.0, -r * 0.8, r * 1.1, r * 0.1, 0, r * 0.75)
          ..close();
        canvas.drawPath(path, paint);
      case ParticleShape.leaf:
        final path = Path()
          ..moveTo(0, -r)
          ..quadraticBezierTo(r * 0.9, 0, 0, r)
          ..quadraticBezierTo(-r * 0.9, 0, 0, -r)
          ..close();
        canvas.drawPath(path, paint);
      case ParticleShape.planet:
        canvas.drawCircle(Offset.zero, r * 0.75, paint);
        final ringPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: r * 2.2, height: r * 0.75),
          ringPaint,
        );
      case ParticleShape.sparkle:
        final path = Path()
          ..moveTo(0, -r * 1.2)
          ..quadraticBezierTo(0, 0, r * 1.2, 0)
          ..quadraticBezierTo(0, 0, 0, r * 1.2)
          ..quadraticBezierTo(0, 0, -r * 1.2, 0)
          ..quadraticBezierTo(0, 0, 0, -r * 1.2)
          ..close();
        canvas.drawPath(path, paint);
      case ParticleShape.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final rad = i.isEven ? r * 1.15 : r * 0.48;
          final a = -math.pi / 2 + i * math.pi / 5;
          final x = rad * math.cos(a);
          final y = rad * math.sin(a);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
    }
  }
}

/// Cute cheering vector mascot anchored in the bottom-right corner of the canvas overlay.
class MascotComponent extends PositionComponent with HasGameReference<ThemedEffectGame> {
  MascotComponent({required GameTheme theme})
      : _theme = theme,
        super(size: Vector2(68, 72), anchor: Anchor.bottomRight);

  GameTheme _theme;
  double _time = 0;
  double _hopTimer = 0;
  double _celebrateTimer = 0;

  void updateTheme(GameTheme newTheme) {
    _theme = newTheme;
  }

  void triggerHappyHop() {
    if (_celebrateTimer <= 0) {
      _hopTimer = 0.45;
    }
  }

  void triggerCelebrate() {
    _celebrateTimer = 4.2;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(
      math.max(80, size.x - 12),
      math.max(88, size.y - 10),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_hopTimer > 0) {
      _hopTimer = math.max(0, _hopTimer - dt);
    }
    if (_celebrateTimer > 0) {
      _celebrateTimer = math.max(0, _celebrateTimer - dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final isCelebrating = _celebrateTimer > 0;
    final bounce = isCelebrating
        ? -math.sin(_time * 14).abs() * 14
        : (_hopTimer > 0
            ? -math.sin((_hopTimer / 0.45) * math.pi) * 10
            : math.sin(_time * 2.6) * 2.2);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2 + bounce);

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.14);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 29 - bounce * 0.4),
        width: 44,
        height: 10,
      ),
      shadowPaint,
    );

    final primary = Paint()..color = _theme.mascotPrimary;
    final accent = Paint()..color = _theme.mascotAccent;
    final outline = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    // Waving arms (clap when celebrating!)
    final armAngle = isCelebrating
        ? math.sin(_time * 18) * 0.65
        : math.sin(_time * 3.0) * 0.14;

    canvas.save();
    canvas.translate(-22, 6);
    canvas.rotate(-0.45 + armAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -5, 14, 10),
        const Radius.circular(5),
      ),
      primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -5, 14, 10),
        const Radius.circular(5),
      ),
      outline,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(22, 6);
    canvas.rotate(0.45 - armAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, -5, 14, 10),
        const Radius.circular(5),
      ),
      primary,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-2, -5, 14, 10),
        const Radius.circular(5),
      ),
      outline,
    );
    canvas.restore();

    // Cute round ears
    canvas.drawCircle(const Offset(-16, -20), 9, primary);
    canvas.drawCircle(const Offset(16, -20), 9, primary);
    canvas.drawCircle(const Offset(-16, -20), 5, accent);
    canvas.drawCircle(const Offset(16, -20), 5, accent);
    canvas.drawCircle(const Offset(-16, -20), 9, outline);
    canvas.drawCircle(const Offset(16, -20), 9, outline);

    // Chubby body/head
    final bodyRect = Rect.fromCenter(center: const Offset(0, 2), width: 48, height: 48);
    canvas.drawOval(bodyRect, primary);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 11), width: 28, height: 22),
      accent,
    );
    canvas.drawOval(bodyRect, outline);

    // Sparkling eyes
    final eyePaint = Paint()..color = const Color(0xFF1E293B);
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-9, -3), 4.2, eyePaint);
    canvas.drawCircle(const Offset(9, -3), 4.2, eyePaint);
    canvas.drawCircle(const Offset(-10.3, -4.4), 1.5, shinePaint);
    canvas.drawCircle(const Offset(7.7, -4.4), 1.5, shinePaint);

    // Rosy cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF8FAB);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-15, 4), width: 8, height: 5),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15, 4), width: 8, height: 5),
      cheekPaint,
    );

    // Big happy smile
    final smilePaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 5), width: 14, height: 10),
      0.2,
      math.pi - 0.4,
      false,
      smilePaint,
    );

    // Celebration stars floating over mascot head
    if (isCelebrating) {
      final starPaint = Paint()..color = const Color(0xFFFFCA28);
      for (int i = -1; i <= 1; i++) {
        final dy = -34 - (math.sin(_time * 10 + i).abs() * 8);
        canvas.save();
        canvas.translate(i * 18.0, dy);
        ThemedEffectGame._drawParticleShape(
          canvas,
          ParticleShape.star,
          6,
          starPaint,
          1.0,
        );
        canvas.restore();
      }
    }

    canvas.restore();
  }
}
