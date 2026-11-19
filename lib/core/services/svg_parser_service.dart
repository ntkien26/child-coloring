import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import '../../models/colorable_region.dart';

class SvgParserService {
  SvgParserService();

  final Map<String, ParsedSvgDrawing> _cache = {};

  Future<ParsedSvgDrawing> loadAndParse(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    final cached = _cache[assetPath];
    if (cached != null) return cached;

    final targetBundle = bundle ?? rootBundle;
    final rawSvg = await targetBundle.loadString(assetPath, cache: false);
    final parsed = parseSvgString(rawSvg);
    _cache[assetPath] = parsed;
    return parsed;
  }

  ParsedSvgDrawing parseSvgString(String rawSvg) {
    final document = XmlDocument.parse(rawSvg);
    final svgElement = document.rootElement;
    final viewBox = _parseViewBox(svgElement.getAttribute('viewBox'));

    final regions = <ColorableRegion>[];
    int pathIndex = 0;

    // Prepend a full-canvas colorable background region so children can also
    // tap-fill or freehand-brush the sky/backdrop behind the main illustration.
    final bgPath = Path()..addRect(viewBox);
    regions.add(
      ColorableRegion(
        id: 'region_background',
        path: bgPath,
        pathData:
            'M ${viewBox.left} ${viewBox.top} H ${viewBox.right} V ${viewBox.bottom} H ${viewBox.left} Z',
        zIndex: 0,
        isBackground: true,
      ),
    );

    for (final pathElement in svgElement.findAllElements('path')) {
      final pathData = pathElement.getAttribute('d');
      if (pathData == null || pathData.trim().isEmpty) {
        continue;
      }

      final id = pathElement.getAttribute('id') ?? 'region_${pathIndex + 1}';
      final fixedColor = _parseHexColor(
        pathElement.getAttribute('data-fixed-color'),
      );
      final previewColor = _parseHexColor(
        pathElement.getAttribute('data-preview-color'),
      );

      final path = parseSvgPathData(pathData);
      regions.add(
        ColorableRegion(
          id: id,
          path: path,
          pathData: pathData,
          zIndex: pathIndex + 1,
          fixedColor: fixedColor,
          previewColor: previewColor,
        ),
      );
      pathIndex++;
    }

    return ParsedSvgDrawing(viewBox: viewBox, regions: regions);
  }

  Rect _parseViewBox(String? rawViewBox) {
    if (rawViewBox == null || rawViewBox.trim().isEmpty) {
      return const Rect.fromLTWH(0, 0, 500, 500);
    }
    final parts = rawViewBox
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.tryParse)
        .whereType<double>()
        .toList();
    if (parts.length == 4 && parts[2] > 0 && parts[3] > 0) {
      return Rect.fromLTWH(parts[0], parts[1], parts[2], parts[3]);
    }
    return const Rect.fromLTWH(0, 0, 500, 500);
  }

  Color? _parseHexColor(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var hex = raw.trim().replaceFirst('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void clearCache() => _cache.clear();
}
