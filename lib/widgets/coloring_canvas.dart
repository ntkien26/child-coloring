import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/colorable_region.dart';
import '../models/placed_sticker.dart';

class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.drawing,
    required this.regionFills,
    required this.strokes,
    required this.activeStroke,
    required this.stickers,
    required this.toolMode,
    required this.selectedPattern,
    required this.onRegionTap,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
    required this.onAddSticker,
    required this.onStickerDragStart,
    required this.onStickerDragUpdate,
    required this.onStickerRemove,
  });

  final ParsedSvgDrawing drawing;
  final Map<String, RegionFill> regionFills;
  final List<BrushStroke> strokes;
  final BrushStroke? activeStroke;
  final List<PlacedSticker> stickers;
  final ColoringToolMode toolMode;
  final BrushPattern selectedPattern;

  final void Function(ColorableRegion region, Offset localPosition) onRegionTap;
  final void Function(ColorableRegion region, Offset svgPoint, Offset localPosition)
      onStrokeStart;
  final void Function(Offset svgPoint, Offset localPosition) onStrokeUpdate;
  final VoidCallback onStrokeEnd;
  final void Function(Offset svgPoint, Offset localPosition) onAddSticker;
  final VoidCallback onStickerDragStart;
  final void Function(String stickerId, Offset newSvgPoint) onStickerDragUpdate;
  final void Function(String stickerId) onStickerRemove;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _RegionFillTransition {
  const _RegionFillTransition({
    required this.origin,
    required this.previousFill,
    required this.startTimeMs,
  });

  final Offset origin;
  final RegionFill? previousFill;
  final int startTimeMs;
}

class _StickerSpawnTransition {
  const _StickerSpawnTransition({
    required this.startTimeMs,
  });

  final int startTimeMs;
}

class _ColoringCanvasState extends State<ColoringCanvas>
    with SingleTickerProviderStateMixin {
  String? _draggingStickerId;
  bool _isDrawingStroke = false;

  late final AnimationController _animController;
  final Map<String, _RegionFillTransition> _fillAnimations = {};
  final Map<String, _StickerSpawnTransition> _stickerAnimations = {};
  Offset? _lastTappedSvgPoint;
  String? _lastTappedRegionId;

  static const int _fillAnimDurationMs = 460;
  static const int _stickerAnimDurationMs = 420;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _fillAnimations.removeWhere(
      (_, anim) => now - anim.startTimeMs >= _fillAnimDurationMs,
    );
    _stickerAnimations.removeWhere(
      (_, anim) => now - anim.startTimeMs >= _stickerAnimDurationMs,
    );
    if (_fillAnimations.isEmpty && _stickerAnimations.isEmpty) {
      _animController.stop();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _ensureTickerRunning() {
    if (!_animController.isAnimating) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawing != widget.drawing) {
      _fillAnimations.clear();
      _stickerAnimations.clear();
      _animController.stop();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    bool addedAnim = false;

    // Detect region fill changes (tap-fill, erase, undo/redo)
    final allRegionIds = <String>{
      ...oldWidget.regionFills.keys,
      ...widget.regionFills.keys,
    };
    for (final regionId in allRegionIds) {
      final oldFill = oldWidget.regionFills[regionId];
      final newFill = widget.regionFills[regionId];
      if (oldFill != newFill) {
        Offset? origin;
        if (_lastTappedRegionId == regionId && _lastTappedSvgPoint != null) {
          origin = _lastTappedSvgPoint;
        } else {
          for (final r in widget.drawing.regions) {
            if (r.id == regionId) {
              origin = r.bounds.center;
              break;
            }
          }
        }
        _fillAnimations[regionId] = _RegionFillTransition(
          origin: origin ?? widget.drawing.viewBox.center,
          previousFill: oldFill,
          startTimeMs: now,
        );
        addedAnim = true;
      }
    }
    _lastTappedRegionId = null;
    _lastTappedSvgPoint = null;

    // Detect newly placed stickers for elastic pop-in animation
    if (widget.stickers.length > oldWidget.stickers.length) {
      final oldIds = oldWidget.stickers.map((s) => s.id).toSet();
      for (final s in widget.stickers) {
        if (!oldIds.contains(s.id)) {
          _stickerAnimations[s.id] = _StickerSpawnTransition(startTimeMs: now);
          addedAnim = true;
        }
      }
    }

    if (addedAnim) {
      _ensureTickerRunning();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  _CanvasTransform _computeTransform(Size size) {
    final vb = widget.drawing.viewBox;
    final scale = math.min(size.width / vb.width, size.height / vb.height);
    final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
    final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;
    final visibleSvgRect = scale > 0
        ? Rect.fromLTWH(
            -dx / scale,
            -dy / scale,
            size.width / scale,
            size.height / scale,
          )
        : vb;
    return _CanvasTransform(
      scale: scale,
      dx: dx,
      dy: dy,
      visibleSvgRect: visibleSvgRect,
    );
  }

  PlacedSticker? _hitTestSticker(Offset svgPoint) {
    for (int i = widget.stickers.length - 1; i >= 0; i--) {
      final sticker = widget.stickers[i];
      if ((sticker.position - svgPoint).distance <= 32.0 * sticker.scale) {
        return sticker;
      }
    }
    return null;
  }

  ColorableRegion? _hitTestColorableOrBackground(Offset svgPoint) {
    final hit = widget.drawing.hitTestColorable(svgPoint);
    if (hit != null) return hit;

    // If the user taps outside the 500x500 viewBox (e.g. in the top/bottom or
    // left/right margin of a non-square canvas stage), check if a full-width
    // horizon/ground region extends into that margin; otherwise hit the background!
    final vb = widget.drawing.viewBox;
    for (int i = widget.drawing.regions.length - 1; i >= 0; i--) {
      final r = widget.drawing.regions[i];
      if (!r.isColorable || r.isBackground) continue;
      final isHorizon = r.bounds.left <= vb.left + 2.0 &&
          r.bounds.right >= vb.right - 2.0 &&
          r.bounds.bottom >= vb.bottom - 2.0;
      if (!isHorizon) continue;
      final clampedPoint = Offset(
        svgPoint.dx.clamp(vb.left + 1.0, vb.right - 1.0),
        svgPoint.dy.clamp(vb.top + 1.0, vb.bottom - 1.0),
      );
      if (svgPoint.dy >= r.bounds.top && r.path.contains(clampedPoint)) {
        return r;
      }
    }

    for (final r in widget.drawing.regions) {
      if (r.isBackground) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final transform = _computeTransform(canvasSize);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final local = details.localPosition;
            final svgPoint = transform.toSvg(local);

            // Eraser can also remove a tapped sticker
            if (widget.selectedPattern == BrushPattern.eraser) {
              final hitSticker = _hitTestSticker(svgPoint);
              if (hitSticker != null) {
                widget.onStickerRemove(hitSticker.id);
                return;
              }
            }

            if (widget.toolMode == ColoringToolMode.sticker) {
              if (_hitTestSticker(svgPoint) == null) {
                widget.onAddSticker(svgPoint, local);
              }
              return;
            }

            final hitRegion = _hitTestColorableOrBackground(svgPoint);
            if (hitRegion != null) {
              _lastTappedRegionId = hitRegion.id;
              _lastTappedSvgPoint = svgPoint;
              widget.onRegionTap(hitRegion, local);
            }
          },
          onPanStart: (details) {
            final local = details.localPosition;
            final svgPoint = transform.toSvg(local);

            // Allow dragging any placed sticker seamlessly in any mode
            final hitSticker = _hitTestSticker(svgPoint);
            if (hitSticker != null) {
              _draggingStickerId = hitSticker.id;
              _isDrawingStroke = false;
              widget.onStickerDragStart();
              return;
            }

            if (widget.toolMode == ColoringToolMode.freehandBrush) {
              final hitRegion = _hitTestColorableOrBackground(svgPoint);
              if (hitRegion != null) {
                _isDrawingStroke = true;
                widget.onStrokeStart(hitRegion, svgPoint, local);
              }
            }
          },
          onPanUpdate: (details) {
            final local = details.localPosition;
            final svgPoint = transform.toSvg(local);
            if (_draggingStickerId != null) {
              widget.onStickerDragUpdate(_draggingStickerId!, svgPoint);
              return;
            }
            if (_isDrawingStroke) {
              widget.onStrokeUpdate(svgPoint, local);
            }
          },
          onPanEnd: (_) {
            if (_draggingStickerId != null) {
              _draggingStickerId = null;
              return;
            }
            if (_isDrawingStroke) {
              _isDrawingStroke = false;
              widget.onStrokeEnd();
            }
          },
          onPanCancel: () {
            _draggingStickerId = null;
            if (_isDrawingStroke) {
              _isDrawingStroke = false;
              widget.onStrokeEnd();
            }
          },
          child: CustomPaint(
            size: canvasSize,
            painter: _ColoringCanvasPainter(
              drawing: widget.drawing,
              regionFills: widget.regionFills,
              strokes: widget.strokes,
              activeStroke: widget.activeStroke,
              stickers: widget.stickers,
              transform: transform,
              usePreviewColors: false,
              fillAnimations: _fillAnimations,
              stickerAnimations: _stickerAnimations,
              nowMs: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        );
      },
    );
  }
}

/// Reusable colorful miniature preview of any coloring SVG using `data-preview-color`.
class DrawingThumbnail extends StatelessWidget {
  const DrawingThumbnail({
    super.key,
    required this.drawing,
    this.showColorPreview = true,
    this.transparentBackground = false,
    this.stickerStyle = false,
  });

  final ParsedSvgDrawing drawing;
  final bool showColorPreview;
  final bool transparentBackground;

  /// Die-cut sticker look: white halo + soft shadow, full-width backdrops skipped.
  final bool stickerStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final vb = drawing.viewBox;
        final scale = math.min(size.width / vb.width, size.height / vb.height);
        final dx = (size.width - vb.width * scale) / 2 - vb.left * scale;
        final dy = (size.height - vb.height * scale) / 2 - vb.top * scale;

        final visibleSvgRect = scale > 0
            ? Rect.fromLTWH(
                -dx / scale,
                -dy / scale,
                size.width / scale,
                size.height / scale,
              )
            : vb;

        return RepaintBoundary(
          child: CustomPaint(
            size: size,
            isComplex: true,
            willChange: false,
            painter: _ColoringCanvasPainter(
              drawing: drawing,
              regionFills: const {},
              strokes: const [],
              activeStroke: null,
              stickers: const [],
              transform: _CanvasTransform(
                scale: scale,
                dx: dx,
                dy: dy,
                visibleSvgRect: visibleSvgRect,
              ),
              usePreviewColors: showColorPreview,
              transparentBackground: transparentBackground,
              stickerStyle: stickerStyle,
              isThumbnail: true,
            ),
          ),
        );
      },
    );
  }
}

class _CanvasTransform {
  const _CanvasTransform({
    required this.scale,
    required this.dx,
    required this.dy,
    required this.visibleSvgRect,
  });

  final double scale;
  final double dx;
  final double dy;
  final Rect visibleSvgRect;

  Offset toSvg(Offset local) {
    if (scale == 0) return Offset.zero;
    return Offset((local.dx - dx) / scale, (local.dy - dy) / scale);
  }
}

class _ColoringCanvasPainter extends CustomPainter {
  _ColoringCanvasPainter({
    required this.drawing,
    required this.regionFills,
    required this.strokes,
    required this.activeStroke,
    required this.stickers,
    required this.transform,
    required this.usePreviewColors,
    this.transparentBackground = false,
    this.stickerStyle = false,
    this.isThumbnail = false,
    this.fillAnimations = const {},
    this.stickerAnimations = const {},
    this.nowMs = 0,
  });

  final ParsedSvgDrawing drawing;
  final Map<String, RegionFill> regionFills;
  final List<BrushStroke> strokes;
  final BrushStroke? activeStroke;
  final List<PlacedSticker> stickers;
  final _CanvasTransform transform;
  final bool usePreviewColors;
  final bool transparentBackground;
  final bool stickerStyle;
  final bool isThumbnail;
  final Map<String, _RegionFillTransition> fillAnimations;
  final Map<String, _StickerSpawnTransition> stickerAnimations;
  final int nowMs;

  static const Color _outlineColor = Color(0xFF3B2314);

  bool _isHorizonGroundRegion(ColorableRegion region) {
    return region.isColorable &&
        !region.isBackground &&
        region.bounds.left <= drawing.viewBox.left + 2.0 &&
        region.bounds.right >= drawing.viewBox.right - 2.0 &&
        region.bounds.bottom >= drawing.viewBox.bottom - 2.0;
  }

  Path _expandHorizonRegionToVisibleCanvas(ColorableRegion region) {
    final vis = transform.visibleSvgRect;
    final vb = drawing.viewBox;
    if (vis.left >= vb.left - 0.5 &&
        vis.right <= vb.right + 0.5 &&
        vis.bottom <= vb.bottom + 0.5) {
      return region.path;
    }

    // Approximate left/right horizon y at x=0 and x=500 by probing the region path
    double leftTopY = region.bounds.top;
    for (double y = region.bounds.top; y <= vb.bottom; y += 2.0) {
      if (region.path.contains(Offset(vb.left + 1.0, y))) {
        leftTopY = y;
        break;
      }
    }
    double rightTopY = region.bounds.top;
    for (double y = region.bounds.top; y <= vb.bottom; y += 2.0) {
      if (region.path.contains(Offset(vb.right - 1.0, y))) {
        rightTopY = y;
        break;
      }
    }

    final extended = Path.from(region.path);
    if (vis.left < vb.left) {
      extended.addRect(
        Rect.fromLTRB(vis.left, leftTopY, vb.left + 1.0, vis.bottom),
      );
    }
    if (vis.right > vb.right) {
      extended.addRect(
        Rect.fromLTRB(vb.right - 1.0, rightTopY, vis.right, vis.bottom),
      );
    }
    if (vis.bottom > vb.bottom) {
      extended.addRect(
        Rect.fromLTRB(vis.left, vb.bottom - 1.0, vis.right, vis.bottom),
      );
    }
    return extended;
  }

  bool _isBackdrop(ColorableRegion region) {
    return stickerStyle &&
        region.isColorable &&
        region.bounds.width >= drawing.viewBox.width * 0.95;
  }

  void _paintStickerHalo(Canvas canvas) {
    final visible = drawing.regions.where((r) => !_isBackdrop(r)).toList();

    canvas.save();
    canvas.translate(0, 7);
    final shadow = Paint()
      ..color = const Color(0xFF3B2314).withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeJoin = StrokeJoin.round;
    if (!isThumbnail) {
      shadow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    }
    for (final r in visible) {
      canvas.drawPath(r.path, shadow);
    }
    canvas.restore();

    final halo = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeJoin = StrokeJoin.round;
    final haloFill = Paint()..color = Colors.white;
    for (final r in visible) {
      canvas.drawPath(r.path, halo);
      canvas.drawPath(r.path, haloFill);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(transform.dx, transform.dy);
    canvas.scale(transform.scale);

    // Soft bright paper backdrop covering the entire visible canvas stage
    final paperPaint = Paint()..color = const Color(0xFFFFFFFF);
    if (!transparentBackground) {
      canvas.drawRect(transform.visibleSvgRect, paperPaint);
    }

    if (stickerStyle) {
      _paintStickerHalo(canvas);
    }

    // Thumbnails have neither strokes nor an active stroke. Avoid allocating
    // a map for every paint of those gallery previews.
    Map<String, List<BrushStroke>>? strokesByRegion;
    if (strokes.isNotEmpty || activeStroke != null) {
      strokesByRegion = <String, List<BrushStroke>>{};
      for (final s in strokes) {
        strokesByRegion.putIfAbsent(s.regionId, () => []).add(s);
      }
      if (activeStroke != null) {
        strokesByRegion
            .putIfAbsent(activeStroke!.regionId, () => [])
            .add(activeStroke!);
      }
    }

    // 1. Paint all colorable regions (base fill + pattern + 3D Auto-Shading + clipped strokes + outline)
    final outlinePaint = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = usePreviewColors ? 3.8 : 3.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (final region in drawing.regions) {
      if (region.isFixed) continue;
      if (_isBackdrop(region)) continue;

      final isBg = region.isBackground;
      final isHorizon =
          !isBg && !stickerStyle && !isThumbnail && _isHorizonGroundRegion(region);
      final Path effectivePath = isBg
          ? (Path()..addRect(transform.visibleSvgRect))
          : (isHorizon
              ? _expandHorizonRegionToVisibleCanvas(region)
              : region.path);
      final Rect effectiveBounds = isBg
          ? transform.visibleSvgRect
          : (isHorizon ? effectivePath.getBounds() : region.bounds);

      final RegionFill? fill = usePreviewColors
          ? (region.previewColor != null
              ? RegionFill(color: region.previewColor!)
              : null)
          : regionFills[region.id];

      final regionStrokes = strokesByRegion?[region.id];
      final fillAnim = usePreviewColors ? null : fillAnimations[region.id];

      // White base inside region
      canvas.drawPath(effectivePath, paperPaint);

      if (fillAnim != null) {
        final rawT = ((nowMs - fillAnim.startTimeMs) /
                _ColoringCanvasState._fillAnimDurationMs)
            .clamp(0.0, 1.0);
        final easedT = Curves.easeOutCubic.transform(rawT);

        // Paint previous fill beneath the expanding ripple if transitioning between fills
        if (fillAnim.previousFill != null) {
          _paintFilledRegionWithAutoShading(
            canvas,
            effectivePath,
            effectiveBounds,
            region.id.hashCode,
            fillAnim.previousFill!,
          );
        }

        final maxR = _maxDistanceToBounds(fillAnim.origin, effectiveBounds);
        final radius = math.max(2.0, maxR * easedT);
        final ripplePath = Path()
          ..addOval(Rect.fromCircle(center: fillAnim.origin, radius: radius));

        canvas.save();
        canvas.clipPath(effectivePath);
        canvas.save();
        canvas.clipPath(ripplePath);
        if (fill != null) {
          _paintFilledRegionWithAutoShading(
            canvas,
            effectivePath,
            effectiveBounds,
            region.id.hashCode,
            fill,
          );
        } else {
          // Erase ripple wave spreading white paper over the old color
          canvas.drawPath(effectivePath, paperPaint);
        }
        canvas.restore();

        // Luminous wave ring at the expanding color edge
        if (rawT < 0.96) {
          final ringAlpha = (1.0 - rawT) * 0.78;
          final wavePaint = Paint()
            ..color = Colors.white.withValues(alpha: ringAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7.5 * (1.0 - rawT * 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
          canvas.drawCircle(fillAnim.origin, radius, wavePaint);
        }
        canvas.restore();
      } else if (fill != null) {
        _paintFilledRegionWithAutoShading(
          canvas,
          effectivePath,
          effectiveBounds,
          region.id.hashCode,
          fill,
        );
      }

      // Freehand strokes strictly clipped to this region (zero bleeding!)
      if (regionStrokes != null && regionStrokes.isNotEmpty) {
        canvas.save();
        canvas.clipPath(effectivePath);
        for (final stroke in regionStrokes) {
          _paintBrushStroke(canvas, stroke);
        }
        canvas.restore();
      }

      // Crisp outline for foreground regions (skip outer border on full-bleed background)
      if (!isBg) {
        if (isHorizon) {
          // Extend the top horizon line cleanly out to the left/right canvas edges
          // while hiding the artificial box sides/bottom of the 500x500 viewBox.
          canvas.save();
          canvas.clipRect(
            Rect.fromLTRB(
              drawing.viewBox.left + 2.0,
              drawing.viewBox.top - 20.0,
              drawing.viewBox.right - 2.0,
              drawing.viewBox.bottom - 2.0,
            ),
          );
          canvas.drawPath(region.path, outlinePaint);
          canvas.restore();

          final vis = transform.visibleSvgRect;
          final vb = drawing.viewBox;
          if (vis.left < vb.left || vis.right > vb.right) {
            double leftTopY = region.bounds.top;
            for (double y = region.bounds.top; y <= vb.bottom; y += 2.0) {
              if (region.path.contains(Offset(vb.left + 1.0, y))) {
                leftTopY = y;
                break;
              }
            }
            double rightTopY = region.bounds.top;
            for (double y = region.bounds.top; y <= vb.bottom; y += 2.0) {
              if (region.path.contains(Offset(vb.right - 1.0, y))) {
                rightTopY = y;
                break;
              }
            }
            if (vis.left < vb.left) {
              canvas.drawLine(
                Offset(vis.left, leftTopY),
                Offset(vb.left + 2.5, leftTopY),
                outlinePaint,
              );
            }
            if (vis.right > vb.right) {
              canvas.drawLine(
                Offset(vb.right - 2.5, rightTopY),
                Offset(vis.right, rightTopY),
                outlinePaint,
              );
            }
          }
        } else {
          canvas.drawPath(region.path, outlinePaint);
        }
        if (fillAnim != null && fill != null) {
          final rawT = ((nowMs - fillAnim.startTimeMs) /
                  _ColoringCanvasState._fillAnimDurationMs)
              .clamp(0.0, 1.0);
          final pulse = math.sin(rawT * math.pi);
          if (pulse > 0.05) {
            final glowPaint = Paint()
              ..color = Colors.white.withValues(alpha: pulse * 0.65)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.5 * pulse
              ..strokeJoin = StrokeJoin.round
              ..strokeCap = StrokeCap.round;
            canvas.drawPath(region.path, glowPaint);
          }
        }
      }
    }

    // 2. Paint fixed expressive details on top (sparkling eyes, eye-shine, cheeks, smiles)
    for (final region in drawing.regions) {
      if (!region.isFixed) continue;
      final fixedPaint = Paint()
        ..color = region.fixedColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(region.path, fixedPaint);
    }

    // 3. Paint placed vector stickers (with elastic bounce-in on placement)
    for (final sticker in stickers) {
      double animScale = 1.0;
      double animRotation = 0.0;
      final stickerAnim = stickerAnimations[sticker.id];
      if (stickerAnim != null) {
        final rawT = ((nowMs - stickerAnim.startTimeMs) /
                _ColoringCanvasState._stickerAnimDurationMs)
            .clamp(0.0, 1.0);
        animScale = Curves.elasticOut.transform(rawT).clamp(0.1, 1.35);
        animRotation = math.sin(rawT * math.pi * 2) * (1.0 - rawT) * 0.25;
      }

      StickerPainterHelper.drawSticker(
        canvas,
        sticker.type,
        sticker.position,
        radius: 26.0 * sticker.scale * animScale,
        rotation: sticker.rotation + animRotation,
      );
    }

    // 4. Live animated brush tip halo while drawing freehand strokes
    if (activeStroke != null && activeStroke!.points.isNotEmpty) {
      final tip = activeStroke!.points.last;
      final pulse = 1.0 + 0.14 * math.sin(nowMs * 0.018);
      final tipRadius = (activeStroke!.strokeWidth * 0.62) * pulse;
      final isEraser = activeStroke!.pattern == BrushPattern.eraser;
      final ringColor = isEraser ? const Color(0xFF64748B) : activeStroke!.color;

      canvas.drawCircle(
        tip,
        tipRadius + 4,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5,
      );
      canvas.drawCircle(
        tip,
        tipRadius + 4,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    canvas.restore();
  }

  static double _maxDistanceToBounds(Offset origin, Rect bounds) {
    final d1 = (origin - bounds.topLeft).distance;
    final d2 = (origin - bounds.topRight).distance;
    final d3 = (origin - bounds.bottomLeft).distance;
    final d4 = (origin - bounds.bottomRight).distance;
    return math.max(math.max(d1, d2), math.max(d3, d4)) + 8.0;
  }

  void _paintFilledRegionWithAutoShading(
    Canvas canvas,
    Path path,
    Rect bounds,
    int seed,
    RegionFill fill,
  ) {
    final basePaint = Paint()
      ..color = fill.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, basePaint);

    // Thumbnails skip expensive per-region clipPath + Gaussian blur + gradient passes
    if (isThumbnail && fill.pattern == BrushPattern.solid) {
      return;
    }

    canvas.save();
    canvas.clipPath(path);

    // Special pattern overlay
    switch (fill.pattern) {
      case BrushPattern.glitter:
        _paintGlitterPattern(canvas, bounds, seed, fill.color);
      case BrushPattern.polkaDot:
        _paintPolkaDotPattern(canvas, bounds, fill.color);
      case BrushPattern.rainbowStripe:
        _paintRainbowStripePattern(canvas, bounds);
      case BrushPattern.solid:
      case BrushPattern.eraser:
        break;
    }

    // Auto-Shading Layer 1: Inner shadow (12% darker)
    final darker = _shiftLightness(fill.color, -0.12);
    final innerShadowPaint = Paint()
      ..color = darker.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawPath(path, innerShadowPaint);

    // Auto-Shading Layer 2: Soft top-left 3D highlight (15% lighter)
    final lighter = _shiftLightness(fill.color, 0.15);
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        bounds.topLeft,
        Offset(
          bounds.left + bounds.width * 0.65,
          bounds.top + bounds.height * 0.65,
        ),
        [
          lighter.withValues(alpha: 0.58),
          lighter.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRect(bounds, highlightPaint);

    canvas.restore();
  }

  void _paintGlitterPattern(
    Canvas canvas,
    Rect bounds,
    int seed,
    Color baseColor,
  ) {
    final rng = math.Random(seed);
    final area = bounds.width * bounds.height;
    final count = (area / 520).round().clamp(10, 65);
    final bright = _shiftLightness(baseColor, 0.3);

    for (int i = 0; i < count; i++) {
      final x = bounds.left + rng.nextDouble() * bounds.width;
      final y = bounds.top + rng.nextDouble() * bounds.height;
      final r = 2.2 + rng.nextDouble() * 4.5;
      final isStar = i % 3 == 0;
      final paint = Paint()
        ..color = (i.isEven ? Colors.white : bright)
            .withValues(alpha: 0.55 + rng.nextDouble() * 0.4);
      if (isStar) {
        final path = Path()
          ..moveTo(x, y - r * 1.4)
          ..quadraticBezierTo(x, y, x + r * 1.4, y)
          ..quadraticBezierTo(x, y, x, y + r * 1.4)
          ..quadraticBezierTo(x, y, x - r * 1.4, y)
          ..quadraticBezierTo(x, y, x, y - r * 1.4)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(x, y), r * 0.55, paint);
      }
    }
  }

  void _paintPolkaDotPattern(Canvas canvas, Rect bounds, Color baseColor) {
    final dotColor = _shiftLightness(baseColor, 0.26).withValues(alpha: 0.72);
    final dotPaint = Paint()..color = dotColor;
    const step = 22.0;
    int row = 0;
    for (double y = bounds.top - step; y <= bounds.bottom + step; y += step) {
      final xOffset = row.isOdd ? step / 2 : 0.0;
      for (double x = bounds.left - step + xOffset;
          x <= bounds.right + step;
          x += step) {
        canvas.drawCircle(Offset(x, y), 4.6, dotPaint);
      }
      row++;
    }
  }

  void _paintRainbowStripePattern(Canvas canvas, Rect bounds) {
    const rainbow = [
      Color(0xFFFF595E),
      Color(0xFFFF924C),
      Color(0xFFFFCA3A),
      Color(0xFF8AC926),
      Color(0xFF1982C4),
      Color(0xFF9B5DE5),
    ];
    final stripePaint = Paint()
      ..shader = ui.Gradient.linear(
        bounds.topLeft,
        bounds.bottomRight,
        [
          for (final c in rainbow) c.withValues(alpha: 0.72),
          rainbow.first.withValues(alpha: 0.72),
        ],
        const [0.0, 0.16, 0.32, 0.5, 0.68, 0.84, 1.0],
        TileMode.repeated,
      );
    canvas.drawRect(bounds, stripePaint);
  }

  void _paintBrushStroke(Canvas canvas, BrushStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (stroke.pattern == BrushPattern.rainbowStripe) {
      paint.shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(500, 500),
        const [
          Color(0xFFFF3B30),
          Color(0xFFFF9500),
          Color(0xFFFFCC00),
          Color(0xFF34C759),
          Color(0xFF007AFF),
          Color(0xFFAF52DE),
        ],
        const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      );
    }

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
    } else {
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    if (stroke.pattern == BrushPattern.glitter) {
      final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      for (int i = 0; i < stroke.points.length; i += 2) {
        final p = stroke.points[i];
        canvas.drawCircle(p.translate(-4, -3), 2.5, sparklePaint);
        canvas.drawCircle(p.translate(4, 3), 1.8, sparklePaint);
      }
    } else if (stroke.pattern == BrushPattern.polkaDot) {
      final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (int i = 0; i < stroke.points.length; i += 3) {
        canvas.drawCircle(stroke.points[i], stroke.strokeWidth * 0.22, dotPaint);
      }
    }
  }

  static Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.05, 0.96)).toColor();
  }

  @override
  bool shouldRepaint(covariant _ColoringCanvasPainter oldDelegate) {
    return oldDelegate.drawing != drawing ||
        oldDelegate.regionFills != regionFills ||
        oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.stickers != stickers ||
        oldDelegate.transform.scale != transform.scale ||
        oldDelegate.transform.dx != transform.dx ||
        oldDelegate.transform.dy != transform.dy ||
        oldDelegate.usePreviewColors != usePreviewColors ||
        oldDelegate.transparentBackground != transparentBackground ||
        oldDelegate.stickerStyle != stickerStyle ||
        oldDelegate.isThumbnail != isThumbnail ||
        fillAnimations.isNotEmpty ||
        stickerAnimations.isNotEmpty ||
        oldDelegate.fillAnimations.isNotEmpty ||
        oldDelegate.stickerAnimations.isNotEmpty;
  }
}

class StickerPainterHelper {
  StickerPainterHelper._();

  static void drawSticker(
    Canvas canvas,
    StickerType type,
    Offset center, {
    double radius = 24.0,
    double rotation = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Die-cut glossy white sticker halo + subtle drop shadow
    canvas.drawCircle(
      const Offset(0, 3),
      radius * 1.12,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 1.12,
      Paint()..color = Colors.white,
    );

    final outline = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    switch (type) {
      case StickerType.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final r = i.isEven ? radius * 0.92 : radius * 0.42;
          final a = -math.pi / 2 + i * math.pi / 5;
          final x = r * math.cos(a);
          final y = r * math.sin(a);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFCA28));
        canvas.drawPath(path, outline);

      case StickerType.heart:
        final r = radius * 0.85;
        final path = Path()
          ..moveTo(0, r * 0.78)
          ..cubicTo(-r * 1.15, r * 0.12, -r * 1.05, -r * 0.82, 0, -r * 0.22)
          ..cubicTo(r * 1.05, -r * 0.82, r * 1.15, r * 0.12, 0, r * 0.78)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFF4D6D));
        canvas.drawPath(path, outline);
        canvas.drawCircle(
          Offset(-r * 0.35, -r * 0.25),
          r * 0.14,
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );

      case StickerType.crown:
        final r = radius * 0.85;
        final path = Path()
          ..moveTo(-r * 0.85, r * 0.5)
          ..lineTo(-r * 0.95, -r * 0.35)
          ..lineTo(-r * 0.35, r * 0.05)
          ..lineTo(0, -r * 0.65)
          ..lineTo(r * 0.35, r * 0.05)
          ..lineTo(r * 0.95, -r * 0.35)
          ..lineTo(r * 0.85, r * 0.5)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFFFFB300));
        canvas.drawPath(path, outline);
        canvas.drawCircle(
          Offset(0, r * 0.18),
          r * 0.16,
          Paint()..color = const Color(0xFFFF4D6D),
        );

      case StickerType.rainbow:
        const bands = [
          Color(0xFFFF3B30),
          Color(0xFFFFCA28),
          Color(0xFF38B000),
          Color(0xFF3A86FF),
        ];
        for (int i = 0; i < bands.length; i++) {
          final rad = radius * (0.85 - i * 0.16);
          canvas.drawArc(
            Rect.fromCircle(center: Offset(0, radius * 0.25), radius: rad),
            math.pi,
            math.pi,
            false,
            Paint()
              ..color = bands[i]
              ..style = PaintingStyle.stroke
              ..strokeWidth = radius * 0.17
              ..strokeCap = StrokeCap.round,
          );
        }

      case StickerType.flower:
        final petalPaint = Paint()..color = const Color(0xFFFF70A6);
        for (int i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          final c = Offset(
            math.cos(a) * radius * 0.45,
            math.sin(a) * radius * 0.45,
          );
          canvas.drawCircle(c, radius * 0.34, petalPaint);
          canvas.drawCircle(c, radius * 0.34, outline);
        }
        canvas.drawCircle(
          Offset.zero,
          radius * 0.32,
          Paint()..color = const Color(0xFFFFD60A),
        );
        canvas.drawCircle(Offset.zero, radius * 0.32, outline);

      case StickerType.butterfly:
        final wingPaint = Paint()..color = const Color(0xFFAB47BC);
        final accentWing = Paint()..color = const Color(0xFFFF80AB);
        canvas.drawCircle(Offset(-radius * 0.42, -radius * 0.18), radius * 0.42, wingPaint);
        canvas.drawCircle(Offset(radius * 0.42, -radius * 0.18), radius * 0.42, wingPaint);
        canvas.drawCircle(Offset(-radius * 0.32, radius * 0.32), radius * 0.30, accentWing);
        canvas.drawCircle(Offset(radius * 0.32, radius * 0.32), radius * 0.30, accentWing);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: radius * 0.24, height: radius * 0.95),
            const Radius.circular(6),
          ),
          Paint()..color = const Color(0xFF2B2D42),
        );

      case StickerType.sparkle:
        final r = radius * 0.9;
        final path = Path()
          ..moveTo(0, -r)
          ..quadraticBezierTo(0, 0, r, 0)
          ..quadraticBezierTo(0, 0, 0, r)
          ..quadraticBezierTo(0, 0, -r, 0)
          ..quadraticBezierTo(0, 0, 0, -r)
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF26C6DA));
        canvas.drawPath(path, outline);

      case StickerType.ribbon:
        final bowPaint = Paint()..color = const Color(0xFFEC407A);
        final left = Path()
          ..moveTo(0, 0)
          ..lineTo(-radius * 0.85, -radius * 0.5)
          ..lineTo(-radius * 0.85, radius * 0.5)
          ..close();
        final right = Path()
          ..moveTo(0, 0)
          ..lineTo(radius * 0.85, -radius * 0.5)
          ..lineTo(radius * 0.85, radius * 0.5)
          ..close();
        canvas.drawPath(left, bowPaint);
        canvas.drawPath(right, bowPaint);
        canvas.drawPath(left, outline);
        canvas.drawPath(right, outline);
        canvas.drawCircle(Offset.zero, radius * 0.24, bowPaint);
        canvas.drawCircle(Offset.zero, radius * 0.24, outline);
    }

    canvas.restore();
  }
}
