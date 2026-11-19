import 'package:flutter/material.dart';

enum BrushPattern {
  solid,
  glitter,
  polkaDot,
  rainbowStripe,
  eraser,
}

enum ColoringToolMode {
  tapFill,
  freehandBrush,
  sticker,
}

class RegionFill {
  const RegionFill({
    required this.color,
    this.pattern = BrushPattern.solid,
  });

  final Color color;
  final BrushPattern pattern;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionFill &&
        other.color == color &&
        other.pattern == pattern;
  }

  @override
  int get hashCode => Object.hash(color, pattern);
}

class BrushStroke {
  const BrushStroke({
    required this.regionId,
    required this.points,
    required this.color,
    required this.pattern,
    required this.strokeWidth,
  });

  final String regionId;
  final List<Offset> points;
  final Color color;
  final BrushPattern pattern;
  final double strokeWidth;

  BrushStroke copyWith({
    List<Offset>? points,
  }) {
    return BrushStroke(
      regionId: regionId,
      points: points ?? this.points,
      color: color,
      pattern: pattern,
      strokeWidth: strokeWidth,
    );
  }
}

class ColorableRegion {
  ColorableRegion({
    required this.id,
    required this.path,
    required this.pathData,
    required this.zIndex,
    this.fixedColor,
    this.previewColor,
  }) : bounds = path.getBounds();

  final String id;
  final Path path;
  final String pathData;
  final int zIndex;
  final Color? fixedColor;
  final Color? previewColor;
  final Rect bounds;

  bool get isFixed => fixedColor != null;
  bool get isColorable => fixedColor == null;

  bool hitTest(Offset svgPoint) {
    if (!bounds.contains(svgPoint)) return false;
    return path.contains(svgPoint);
  }
}

class ParsedSvgDrawing {
  const ParsedSvgDrawing({
    required this.viewBox,
    required this.regions,
  });

  final Rect viewBox;
  final List<ColorableRegion> regions;

  List<ColorableRegion> get colorableRegions =>
      regions.where((r) => r.isColorable).toList(growable: false);

  ColorableRegion? hitTestColorable(Offset svgPoint) {
    // Check in reverse paint order (top-most region first)
    for (int i = regions.length - 1; i >= 0; i--) {
      final region = regions[i];
      if (region.isColorable && region.hitTest(svgPoint)) {
        return region;
      }
    }
    return null;
  }
}
