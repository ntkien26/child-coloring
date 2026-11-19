import 'dart:io';
import 'dart:math' as math;

class SvgPathDef {
  const SvgPathDef({
    required this.d,
    this.fixedColor,
    this.previewColor,
  });

  final String d;
  final String? fixedColor;
  final String? previewColor;
}

String _f(double v) => v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

String circle(double cx, double cy, double r) => oval(cx, cy, r, r);

String oval(double cx, double cy, double rx, double ry) {
  final x1 = _f(cx - rx);
  final x2 = _f(cx + rx);
  final y = _f(cy);
  final rxS = _f(rx);
  final ryS = _f(ry);
  return 'M $x1 $y A $rxS $ryS 0 1 0 $x2 $y A $rxS $ryS 0 1 0 $x1 $y Z';
}

String roundRect(double x, double y, double w, double h, double r) {
  final cr = math.min(r, math.min(w / 2, h / 2));
  return 'M ${_f(x + cr)} ${_f(y)} '
      'L ${_f(x + w - cr)} ${_f(y)} '
      'Q ${_f(x + w)} ${_f(y)} ${_f(x + w)} ${_f(y + cr)} '
      'L ${_f(x + w)} ${_f(y + h - cr)} '
      'Q ${_f(x + w)} ${_f(y + h)} ${_f(x + w - cr)} ${_f(y + h)} '
      'L ${_f(x + cr)} ${_f(y + h)} '
      'Q ${_f(x)} ${_f(y + h)} ${_f(x)} ${_f(y + h - cr)} '
      'L ${_f(x)} ${_f(y + cr)} '
      'Q ${_f(x)} ${_f(y)} ${_f(x + cr)} ${_f(y)} Z';
}

String star(double cx, double cy, double outerR, double innerR,
    {int points = 5, double startAngle = -math.pi / 2}) {
  final buf = StringBuffer();
  final total = points * 2;
  for (int i = 0; i < total; i++) {
    final r = i.isEven ? outerR : innerR;
    final angle = startAngle + (math.pi * i / points);
    final x = cx + r * math.cos(angle);
    final y = cy + r * math.sin(angle);
    buf.write(i == 0 ? 'M ${_f(x)} ${_f(y)} ' : 'L ${_f(x)} ${_f(y)} ');
  }
  buf.write('Z');
  return buf.toString();
}

String heart(double cx, double cy, double size) {
  final s = size;
  return 'M ${_f(cx)} ${_f(cy + s * 0.85)} '
      'C ${_f(cx - s * 1.15)} ${_f(cy + s * 0.15)} '
      '${_f(cx - s * 1.1)} ${_f(cy - s * 0.85)} '
      '${_f(cx)} ${_f(cy - s * 0.25)} '
      'C ${_f(cx + s * 1.1)} ${_f(cy - s * 0.85)} '
      '${_f(cx + s * 1.15)} ${_f(cy + s * 0.15)} '
      '${_f(cx)} ${_f(cy + s * 0.85)} Z';
}

String cloud(double cx, double cy, double scale) {
  final s = scale;
  return 'M ${_f(cx - 52 * s)} ${_f(cy + 18 * s)} '
      'C ${_f(cx - 72 * s)} ${_f(cy + 18 * s)} ${_f(cx - 74 * s)} ${_f(cy - 12 * s)} ${_f(cx - 48 * s)} ${_f(cy - 14 * s)} '
      'C ${_f(cx - 46 * s)} ${_f(cy - 40 * s)} ${_f(cx - 12 * s)} ${_f(cy - 46 * s)} ${_f(cx + 2 * s)} ${_f(cy - 26 * s)} '
      'C ${_f(cx + 16 * s)} ${_f(cy - 44 * s)} ${_f(cx + 50 * s)} ${_f(cy - 34 * s)} ${_f(cx + 50 * s)} ${_f(cy - 12 * s)} '
      'C ${_f(cx + 72 * s)} ${_f(cy - 10 * s)} ${_f(cx + 72 * s)} ${_f(cy + 18 * s)} ${_f(cx + 48 * s)} ${_f(cy + 18 * s)} Z';
}

String flower(double cx, double cy, double petalR, {int petals = 6}) {
  final buf = StringBuffer();
  for (int i = 0; i < petals; i++) {
    final a1 = (2 * math.pi * i) / petals;
    final a2 = (2 * math.pi * (i + 1)) / petals;
    final mid = (a1 + a2) / 2;
    final x1 = cx + petalR * 0.45 * math.cos(a1);
    final y1 = cy + petalR * 0.45 * math.sin(a1);
    final cpx = cx + petalR * 1.55 * math.cos(mid);
    final cpy = cy + petalR * 1.55 * math.sin(mid);
    final x2 = cx + petalR * 0.45 * math.cos(a2);
    final y2 = cy + petalR * 0.45 * math.sin(a2);
    if (i == 0) {
      buf.write('M ${_f(x1)} ${_f(y1)} ');
    }
    buf.write('Q ${_f(cpx)} ${_f(cpy)} ${_f(x2)} ${_f(y2)} ');
  }
  buf.write('Z');
  return buf.toString();
}

String scallopedRing(
    double cx, double cy, double outerR, double innerR, int bumps) {
  final buf = StringBuffer();
  for (int i = 0; i < bumps; i++) {
    final a1 = (2 * math.pi * i) / bumps;
    final a2 = (2 * math.pi * (i + 1)) / bumps;
    final mid = (a1 + a2) / 2;
    final x1 = cx + innerR * math.cos(a1);
    final y1 = cy + innerR * math.sin(a1);
    final cpx = cx + outerR * math.cos(mid);
    final cpy = cy + outerR * math.sin(mid);
    final x2 = cx + innerR * math.cos(a2);
    final y2 = cy + innerR * math.sin(a2);
    if (i == 0) {
      buf.write('M ${_f(x1)} ${_f(y1)} ');
    }
    buf.write('Q ${_f(cpx)} ${_f(cpy)} ${_f(x2)} ${_f(y2)} ');
  }
  buf.write('Z');
  return buf.toString();
}

String smile(double cx, double cy, double w, double depth,
    {double thick = 5.5}) {
  return 'M ${_f(cx - w)} ${_f(cy)} '
      'Q ${_f(cx)} ${_f(cy + depth)} ${_f(cx + w)} ${_f(cy)} '
      'Q ${_f(cx + w + 2)} ${_f(cy + thick)} ${_f(cx + w - 2)} ${_f(cy + thick + 2)} '
      'Q ${_f(cx)} ${_f(cy + depth + thick + 3)} ${_f(cx - w + 2)} ${_f(cy + thick + 2)} '
      'Q ${_f(cx - w - 2)} ${_f(cy + thick)} ${_f(cx - w)} ${_f(cy)} Z';
}

String crescentMoon(double cx, double cy, double r) {
  return 'M ${_f(cx + r * 0.25)} ${_f(cy - r)} '
      'A ${_f(r)} ${_f(r)} 0 1 0 ${_f(cx + r * 0.25)} ${_f(cy + r)} '
      'A ${_f(r * 0.78)} ${_f(r * 0.85)} 0 1 1 ${_f(cx + r * 0.25)} ${_f(cy - r)} Z';
}

String sparklingEyes(double lx, double rx, double y, double r) {
  return '${circle(lx, y, r)} ${circle(rx, y, r)}';
}

String eyeShines(double lx, double rx, double y, double r) {
  final big = r * 0.36;
  final small = r * 0.18;
  return '${circle(lx - r * 0.28, y - r * 0.28, big)} '
      '${circle(lx + r * 0.25, y + r * 0.25, small)} '
      '${circle(rx - r * 0.28, y - r * 0.28, big)} '
      '${circle(rx + r * 0.25, y + r * 0.25, small)}';
}

String rosyCheeks(double lx, double rx, double y, double rxSize, double rySize) {
  return '${oval(lx, y, rxSize, rySize)} ${oval(rx, y, rxSize, rySize)}';
}

List<SvgPathDef> cuteFace(
  double lx,
  double rx,
  double eyeY, {
  double eyeR = 16,
  double cheekOffset = 26,
  double cheekYOffset = 24,
  double smileYOffset = 38,
  double smileW = 20,
  double smileDepth = 14,
}) {
  final cx = (lx + rx) / 2;
  return [
    SvgPathDef(
      d: sparklingEyes(lx, rx, eyeY, eyeR),
      fixedColor: '#1E293B',
    ),
    SvgPathDef(
      d: eyeShines(lx, rx, eyeY, eyeR),
      fixedColor: '#FFFFFF',
    ),
    SvgPathDef(
      d: rosyCheeks(
        lx - cheekOffset,
        rx + cheekOffset,
        eyeY + cheekYOffset,
        eyeR * 0.9,
        eyeR * 0.56,
      ),
      fixedColor: '#FF9EB5',
    ),
    SvgPathDef(
      d: smile(cx, eyeY + smileYOffset, smileW, smileDepth, thick: 4.8),
      fixedColor: '#3B2F2F',
    ),
  ];
}

String buildSvg(String title, List<SvgPathDef> paths) {
  assert(
    paths.length >= 12 && paths.length <= 18,
    '$title has ${paths.length} paths (must be 12..18)',
  );
  final buf = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="500" height="500">',
    )
    ..writeln('  <!-- $title (${paths.length} regions) -->');

  for (int i = 0; i < paths.length; i++) {
    final p = paths[i];
    final attrs = StringBuffer('id="region_${i + 1}" d="${p.d}"');
    if (p.fixedColor != null) {
      attrs.write(' data-fixed-color="${p.fixedColor}"');
    }
    if (p.previewColor != null) {
      attrs.write(' data-preview-color="${p.previewColor}"');
    }
    buf.writeln('  <path $attrs />');
  }
  buf.writeln('</svg>');
  return buf.toString();
}

Map<String, List<SvgPathDef>> buildAllDrawings() {
  return {
    // =========================================================================
    // THEME 1: ANIMALS (10 drawings)
    // =========================================================================
    'animals_01_cat.svg': [
      SvgPathDef(
        d: 'M 0 395 Q 140 355 260 380 Q 380 405 500 375 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(82, 82, 42), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(395, 86, 0.85), previewColor: '#E0F7FA'),
      SvgPathDef(d: flower(418, 415, 22), previewColor: '#FF85C0'),
      SvgPathDef(
        d: 'M 325 380 C 395 385 435 320 408 265 C 395 240 368 248 372 272 C 384 308 362 346 318 352 Z',
        previewColor: '#FFA952',
      ),
      SvgPathDef(d: oval(248, 355, 88, 92), previewColor: '#FFB347'),
      SvgPathDef(d: oval(248, 370, 52, 60), previewColor: '#FFF3D6'),
      SvgPathDef(
        d: '${roundRect(184, 272, 128, 22, 11)} ${circle(248, 304, 15)}',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(
        d: 'M 155 182 L 146 95 Q 146 82 158 88 L 222 135 Z',
        previewColor: '#FF9E3D',
      ),
      SvgPathDef(
        d: 'M 341 182 L 350 95 Q 350 82 338 88 L 274 135 Z',
        previewColor: '#FF9E3D',
      ),
      SvgPathDef(d: oval(248, 206, 102, 86), previewColor: '#FFB347'),
      SvgPathDef(
        d: '${roundRect(239, 124, 18, 32, 9)} ${roundRect(212, 130, 14, 24, 7)} ${roundRect(270, 130, 14, 24, 7)}',
        previewColor: '#E07A28',
      ),
      SvgPathDef(
        d: 'M 236 218 L 260 218 L 248 232 Z',
        previewColor: '#FF6B8B',
      ),
      ...cuteFace(204, 292, 198, eyeR: 18),
    ],

    'animals_02_dog.svg': [
      SvgPathDef(
        d: 'M 0 390 Q 150 355 270 385 Q 390 410 500 370 L 500 500 L 0 500 Z',
        previewColor: '#6BCB77',
      ),
      SvgPathDef(d: circle(415, 82, 40), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(108, 86, 0.85), previewColor: '#E3F2FD'),
      SvgPathDef(
        d: 'M 360 422 L 420 422 C 430 408 448 416 442 430 C 448 444 430 452 420 438 L 360 438 C 350 452 332 444 338 430 C 332 416 350 408 360 422 Z',
        previewColor: '#FFF8E7',
      ),
      SvgPathDef(
        d: 'M 332 365 C 390 345 422 292 396 276 C 378 266 364 298 326 336 Z',
        previewColor: '#C68642',
      ),
      SvgPathDef(d: oval(245, 358, 92, 86), previewColor: '#E0A96D'),
      SvgPathDef(
        d: '${oval(245, 376, 52, 54)} ${oval(195, 430, 26, 18)} ${oval(295, 430, 26, 18)}',
        previewColor: '#FFF2DC',
      ),
      SvgPathDef(
        d: '${roundRect(184, 274, 122, 22, 11)} ${circle(245, 304, 14)}',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(
        d: 'M 164 152 C 110 154 96 245 128 286 C 150 310 176 266 174 218 Z',
        previewColor: '#A66A38',
      ),
      SvgPathDef(
        d: 'M 326 152 C 380 154 394 245 362 286 C 340 310 314 266 316 218 Z',
        previewColor: '#A66A38',
      ),
      SvgPathDef(d: oval(245, 200, 96, 86), previewColor: '#E0A96D'),
      SvgPathDef(d: oval(202, 192, 34, 30), previewColor: '#B5763C'),
      SvgPathDef(d: oval(245, 218, 18, 13), previewColor: '#3D2B1F'),
      ...cuteFace(204, 286, 192, eyeR: 17),
    ],

    'animals_03_lion.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 130 370 250 392 Q 380 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#9EF01A',
      ),
      SvgPathDef(d: circle(84, 78, 40), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(405, 82, 0.8), previewColor: '#FFF3E0'),
      SvgPathDef(d: cloud(82, 412, 0.72), previewColor: '#38B000'),
      SvgPathDef(
        d: 'M 326 376 C 392 376 420 326 408 292 C 425 276 416 248 394 256 C 378 262 376 284 388 296 C 392 326 368 352 320 356 Z',
        previewColor: '#D97706',
      ),
      SvgPathDef(d: oval(250, 366, 86, 84), previewColor: '#FBBF24'),
      SvgPathDef(d: oval(250, 380, 50, 56), previewColor: '#FEF3C7'),
      SvgPathDef(
        d: scallopedRing(250, 198, 138, 102, 14),
        previewColor: '#EA580C',
      ),
      SvgPathDef(d: circle(174, 126, 26), previewColor: '#FBBF24'),
      SvgPathDef(d: circle(326, 126, 26), previewColor: '#FBBF24'),
      SvgPathDef(d: circle(250, 200, 84), previewColor: '#FCD34D'),
      SvgPathDef(d: oval(250, 232, 36, 24), previewColor: '#FFFBEB'),
      SvgPathDef(
        d: 'M 234 214 L 266 214 L 250 230 Z',
        previewColor: '#B45309',
      ),
      ...cuteFace(212, 288, 190, eyeR: 16),
    ],

    'animals_04_rabbit.svg': [
      SvgPathDef(
        d: 'M 0 396 Q 150 362 280 390 Q 400 410 500 378 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(86, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 84, 0.82), previewColor: '#E0F7FA'),
      // Fluffy round bunny tail
      SvgPathDef(d: circle(156, 382, 30), previewColor: '#FFFFFF'),
      // Long left & right outer ears
      SvgPathDef(d: oval(202, 104, 28, 74), previewColor: '#FFF5F8'),
      SvgPathDef(d: oval(298, 104, 28, 74), previewColor: '#FFF5F8'),
      // Pink inner ears
      SvgPathDef(
        d: '${oval(202, 108, 14, 52)} ${oval(298, 108, 14, 52)}',
        previewColor: '#FF9EB5',
      ),
      // Bunny body & feet
      SvgPathDef(d: oval(250, 354, 84, 86), previewColor: '#FFF5F8'),
      SvgPathDef(d: oval(250, 368, 48, 52), previewColor: '#FFE4EC'),
      SvgPathDef(
        d: '${oval(194, 428, 32, 20)} ${oval(306, 428, 32, 20)}',
        previewColor: '#FFF5F8',
      ),
      // Bunny head
      SvgPathDef(d: oval(250, 214, 92, 78), previewColor: '#FFF5F8'),
      // Carrot greenery & orange body held by bunny
      SvgPathDef(
        d: 'M 374 282 C 362 246 392 238 394 268 C 408 242 434 256 412 282 Z',
        previewColor: '#38B000',
      ),
      SvgPathDef(
        d: 'M 358 278 L 418 292 L 352 406 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: oval(250, 224, 12, 9), previewColor: '#FF5C8A'),
      ...cuteFace(210, 290, 204, eyeR: 16),
    ],

    'animals_05_elephant.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 160 368 270 392 Q 390 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: circle(414, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(106, 84, 0.8), previewColor: '#E0F7FA'),
      // Huge fan ears
      SvgPathDef(d: oval(128, 210, 62, 78), previewColor: '#90CAF9'),
      SvgPathDef(d: oval(372, 210, 62, 78), previewColor: '#90CAF9'),
      SvgPathDef(
        d: '${oval(132, 214, 38, 52)} ${oval(368, 214, 38, 52)}',
        previewColor: '#F8BBD0',
      ),
      // Elephant body & belly
      SvgPathDef(d: oval(250, 356, 98, 86), previewColor: '#64B5F6'),
      SvgPathDef(d: oval(250, 372, 56, 54), previewColor: '#E3F2FD'),
      // Chubby legs
      SvgPathDef(
        d: '${roundRect(168, 386, 46, 56, 18)} ${roundRect(286, 386, 46, 56, 18)}',
        previewColor: '#42A5F5',
      ),
      // Elephant head
      SvgPathDef(d: circle(250, 206, 88), previewColor: '#64B5F6'),
      // Cute curved trunk
      SvgPathDef(
        d: 'M 234 222 C 234 292 292 312 316 276 C 328 258 304 246 294 262 C 282 276 264 266 266 222 Z',
        previewColor: '#42A5F5',
      ),
      // Water splash heart above trunk
      SvgPathDef(d: heart(326, 216, 22), previewColor: '#4CC9F0'),
      ...cuteFace(208, 292, 188, eyeR: 15, smileYOffset: 46),
    ],

    'animals_06_panda.svg': [
      SvgPathDef(
        d: 'M 0 396 Q 140 364 260 390 Q 380 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(84, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Bamboo stalk & leaves
      SvgPathDef(
        d: '${roundRect(386, 160, 22, 246, 8)} M 386 240 L 348 214 L 364 252 Z M 408 290 L 448 266 L 432 304 Z',
        previewColor: '#38B000',
      ),
      // Dark panda ears
      SvgPathDef(
        d: '${circle(168, 122, 32)} ${circle(332, 122, 32)}',
        previewColor: '#343A40',
      ),
      // Dark arms
      SvgPathDef(
        d: '${oval(144, 322, 42, 28)} ${oval(356, 322, 42, 28)}',
        previewColor: '#343A40',
      ),
      // Dark legs
      SvgPathDef(
        d: '${oval(184, 422, 42, 30)} ${oval(316, 422, 42, 30)}',
        previewColor: '#343A40',
      ),
      // Panda chubby body & white tummy
      SvgPathDef(d: oval(250, 352, 92, 86), previewColor: '#343A40'),
      SvgPathDef(d: oval(250, 364, 62, 62), previewColor: '#FFFFFF'),
      // Panda big round head
      SvgPathDef(d: oval(250, 202, 98, 86), previewColor: '#FFFFFF'),
      // Panda dark eye patches
      SvgPathDef(
        d: '${oval(206, 196, 28, 34)} ${oval(294, 196, 28, 34)}',
        previewColor: '#495057',
      ),
      SvgPathDef(d: oval(250, 220, 14, 10), previewColor: '#212529'),
      ...cuteFace(206, 294, 196, eyeR: 14),
    ],

    'animals_07_giraffe_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 368 270 394 Q 390 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#9EF01A',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(398, 88, 0.8), previewColor: '#E0F7FA'),
      // Giraffe legs
      SvgPathDef(
        d: '${roundRect(184, 366, 32, 78, 12)} ${roundRect(276, 366, 32, 78, 12)}',
        previewColor: '#F59E0B',
      ),
      // Giraffe body & long neck
      SvgPathDef(
        d: '${oval(246, 354, 78, 56)} ${roundRect(222, 186, 48, 156, 22)}',
        previewColor: '#FCD34D',
      ),
      // Giraffe brown spots
      SvgPathDef(
        d: '${circle(246, 238, 14)} ${circle(238, 288, 16)} ${circle(214, 348, 18)} ${circle(276, 356, 16)}',
        previewColor: '#B45309',
      ),
      // Cute horns (ossicones)
      SvgPathDef(
        d: '${roundRect(216, 72, 12, 38, 6)} ${circle(222, 68, 12)} ${roundRect(272, 72, 12, 38, 6)} ${circle(278, 68, 12)}',
        previewColor: '#B45309',
      ),
      // Side ears
      SvgPathDef(
        d: '${oval(162, 134, 28, 14)} ${oval(338, 134, 28, 14)}',
        previewColor: '#F59E0B',
      ),
      // Giraffe head & snout
      SvgPathDef(d: oval(250, 148, 76, 62), previewColor: '#FCD34D'),
      SvgPathDef(d: oval(250, 174, 48, 30), previewColor: '#FEF3C7'),
      // Leafy branch snack
      SvgPathDef(d: cloud(418, 224, 0.65), previewColor: '#38B000'),
      ...cuteFace(218, 282, 138, eyeR: 13, smileYOffset: 34),
    ],

    'animals_08_monkey_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 366 260 390 Q 380 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#6BCB77',
      ),
      SvgPathDef(d: circle(82, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(
        d: 'M 326 376 C 402 372 436 298 402 254 C 384 234 358 256 374 280 C 392 308 372 348 320 352 Z',
        previewColor: '#8D5524',
      ),
      // Big round monkey ears
      SvgPathDef(
        d: '${circle(142, 198, 42)} ${circle(358, 198, 42)}',
        previewColor: '#A66A38',
      ),
      SvgPathDef(
        d: '${circle(142, 198, 26)} ${circle(358, 198, 26)}',
        previewColor: '#FFDCB8',
      ),
      // Monkey body & belly
      SvgPathDef(d: oval(250, 354, 84, 84), previewColor: '#A66A38'),
      SvgPathDef(d: oval(250, 366, 52, 54), previewColor: '#FFDCB8'),
      // Monkey head & peach face mask
      SvgPathDef(d: circle(250, 198, 86), previewColor: '#A66A38'),
      SvgPathDef(
        d: '${oval(222, 186, 44, 48)} ${oval(278, 186, 44, 48)} ${oval(250, 222, 58, 36)}',
        previewColor: '#FFDCB8',
      ),
      // Cute banana
      SvgPathDef(
        d: 'M 102 284 C 72 328 96 388 152 396 C 126 368 116 328 130 292 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: oval(250, 214, 12, 8), previewColor: '#5C3A21'),
      ...cuteFace(214, 286, 188, eyeR: 15),
    ],

    'animals_09_owl_locked.svg': [
      // Night branch & moon
      SvgPathDef(d: roundRect(44, 384, 412, 32, 16), previewColor: '#8D5524'),
      SvgPathDef(
        d: '${oval(96, 370, 24, 14)} ${oval(404, 370, 24, 14)}',
        previewColor: '#38B000',
      ),
      SvgPathDef(d: crescentMoon(92, 96, 42), previewColor: '#FFF07C'),
      SvgPathDef(
        d: '${star(404, 92, 26, 11)} ${star(354, 146, 18, 8)}',
        previewColor: '#FFD60A',
      ),
      // Owl wings
      SvgPathDef(d: oval(146, 294, 42, 72), previewColor: '#7B2CBF'),
      SvgPathDef(d: oval(354, 294, 42, 72), previewColor: '#7B2CBF'),
      // Owl body & belly
      SvgPathDef(d: oval(250, 286, 98, 106), previewColor: '#9B5DE5'),
      SvgPathDef(d: oval(250, 314, 64, 68), previewColor: '#F3E8FF'),
      // Ear tufts
      SvgPathDef(
        d: 'M 158 176 L 138 112 L 204 148 Z M 342 176 L 362 112 L 296 148 Z',
        previewColor: '#7B2CBF',
      ),
      // Owl head & big eye rings
      SvgPathDef(d: oval(250, 192, 96, 78), previewColor: '#9B5DE5'),
      SvgPathDef(
        d: '${circle(206, 192, 38)} ${circle(294, 192, 38)}',
        previewColor: '#FFFFFF',
      ),
      // Owl beak & feet
      SvgPathDef(
        d: 'M 236 212 L 264 212 L 250 236 Z ${oval(212, 386, 22, 12)} ${oval(288, 386, 22, 12)}',
        previewColor: '#FF9F1C',
      ),
      ...cuteFace(206, 294, 192, eyeR: 18, smileYOffset: 48),
    ],

    'animals_10_bear_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 366 260 392 Q 380 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Round bear ears
      SvgPathDef(
        d: '${circle(166, 118, 34)} ${circle(334, 118, 34)}',
        previewColor: '#8D5524',
      ),
      SvgPathDef(
        d: '${circle(166, 118, 18)} ${circle(334, 118, 18)}',
        previewColor: '#E0A96D',
      ),
      // Bear body & tummy
      SvgPathDef(d: oval(236, 352, 94, 88), previewColor: '#A66A38'),
      SvgPathDef(d: oval(236, 366, 56, 56), previewColor: '#F3D5B5'),
      // Bear head & muzzle
      SvgPathDef(d: circle(236, 196, 90), previewColor: '#A66A38'),
      SvgPathDef(d: oval(236, 222, 38, 28), previewColor: '#F3D5B5'),
      SvgPathDef(d: oval(236, 210, 16, 11), previewColor: '#3D2B1F'),
      // Honey pot & golden honey drip
      SvgPathDef(d: oval(392, 376, 52, 46), previewColor: '#FF9F1C'),
      SvgPathDef(d: roundRect(352, 326, 80, 22, 10), previewColor: '#FFD60A'),
      ...cuteFace(196, 276, 182, eyeR: 16),
    ],

    // =========================================================================
    // THEME 2: VEHICLES (10 drawings)
    // =========================================================================
    'vehicles_01_car.svg': [
      SvgPathDef(
        d: 'M 0 385 L 500 385 L 500 500 L 0 500 Z',
        previewColor: '#6C757D',
      ),
      SvgPathDef(
        d: 'M 0 385 Q 120 305 260 350 Q 380 315 500 360 L 500 385 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(86, 84, 42), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(376, 92, 0.9), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: 'M 145 272 C 165 182 205 162 290 162 C 350 162 375 215 390 272 Z',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(d: roundRect(62, 264, 376, 108, 36), previewColor: '#FF3B30'),
      SvgPathDef(
        d: 'M 255 182 L 325 182 C 350 182 365 222 372 260 L 255 260 Z',
        previewColor: '#BAE6FD',
      ),
      SvgPathDef(
        d: 'M 164 260 C 176 212 198 182 238 182 L 238 260 Z',
        previewColor: '#93C5FD',
      ),
      SvgPathDef(d: oval(420, 306, 20, 16), previewColor: '#FFF07C'),
      SvgPathDef(d: roundRect(48, 336, 404, 24, 12), previewColor: '#FFD60A'),
      SvgPathDef(d: circle(148, 376, 52), previewColor: '#343A40'),
      SvgPathDef(d: circle(352, 376, 52), previewColor: '#343A40'),
      SvgPathDef(
        d: '${circle(148, 376, 24)} ${circle(352, 376, 24)}',
        previewColor: '#E2E8F0',
      ),
      ...cuteFace(288, 338, 224, eyeR: 13, cheekOffset: 20, smileYOffset: 84),
    ],

    'vehicles_02_firetruck.svg': [
      SvgPathDef(
        d: 'M 0 392 L 500 392 L 500 500 L 0 500 Z',
        previewColor: '#6C757D',
      ),
      SvgPathDef(d: circle(420, 76, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(110, 82, 0.85), previewColor: '#E3F2FD'),
      SvgPathDef(
        d: 'M 75 186 L 315 130 L 324 162 L 84 218 Z',
        previewColor: '#FDE047',
      ),
      SvgPathDef(
        d: 'M 332 192 C 332 158 378 158 378 192 Z',
        previewColor: '#38BDF8',
      ),
      SvgPathDef(d: roundRect(58, 210, 240, 165, 22), previewColor: '#EF4444'),
      SvgPathDef(
        d: 'M 294 192 L 408 192 Q 436 192 442 230 L 448 375 L 294 375 Z',
        previewColor: '#DC2626',
      ),
      SvgPathDef(d: roundRect(318, 214, 102, 74, 16), previewColor: '#BAE6FD'),
      SvgPathDef(d: circle(168, 290, 44), previewColor: '#FACC15'),
      SvgPathDef(d: roundRect(68, 336, 366, 18, 8), previewColor: '#FFFFFF'),
      SvgPathDef(d: circle(146, 384, 48), previewColor: '#343A40'),
      SvgPathDef(d: circle(368, 384, 48), previewColor: '#343A40'),
      SvgPathDef(
        d: '${circle(146, 384, 22)} ${circle(368, 384, 22)}',
        previewColor: '#CBD5E1',
      ),
      ...cuteFace(348, 394, 250, eyeR: 13, cheekOffset: 18, smileYOffset: 54),
    ],

    'vehicles_03_airplane.svg': [
      SvgPathDef(d: circle(86, 86, 40), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(115, 395, 0.95), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(392, 108, 0.85), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: 'M 42 290 C 65 180 185 118 285 148 L 274 176 C 192 152 94 202 74 294 Z',
        previewColor: '#FF85C0',
      ),
      SvgPathDef(
        d: 'M 218 228 L 280 142 Q 305 132 315 155 L 290 232 Z',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(
        d: 'M 90 250 L 62 175 Q 64 155 86 160 L 146 232 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(
        d: 'M 94 265 C 125 210 270 198 372 224 C 425 238 432 288 378 308 C 282 332 135 322 94 265 Z',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(
        d: 'M 214 296 L 176 382 Q 190 402 216 392 L 296 298 Z',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(
        d: 'M 392 232 C 446 244 446 286 392 300 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: '${oval(440, 224, 12, 34)} ${oval(440, 308, 12, 34)}',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(
        d: 'M 304 222 C 344 218 374 232 384 256 L 304 258 Z',
        previewColor: '#FFF07C',
      ),
      SvgPathDef(
        d: '${circle(182, 260, 17)} ${circle(232, 258, 17)} ${circle(280, 258, 17)}',
        previewColor: '#FFFFFF',
      ),
      SvgPathDef(
        d: 'M 130 288 Q 250 306 378 286 L 372 302 Q 250 320 138 302 Z',
        previewColor: '#FF5C8A',
      ),
      ...cuteFace(328, 362, 242, eyeR: 11, cheekOffset: 16, smileYOffset: 34),
    ],

    'vehicles_04_helicopter.svg': [
      SvgPathDef(d: circle(84, 84, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(118, 412, 0.9), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(402, 108, 0.8), previewColor: '#E0F7FA'),
      // Landing skids & struts
      SvgPathDef(
        d: '${roundRect(156, 358, 220, 18, 9)} ${roundRect(198, 326, 16, 36, 6)} ${roundRect(306, 326, 16, 36, 6)}',
        previewColor: '#64748B',
      ),
      // Top rotor mast & wide blades
      SvgPathDef(d: roundRect(246, 118, 20, 44, 8), previewColor: '#475569'),
      SvgPathDef(d: roundRect(78, 104, 356, 20, 10), previewColor: '#FFD60A'),
      // Tail boom & tail fin
      SvgPathDef(
        d: 'M 68 232 L 176 218 L 176 266 L 68 254 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: circle(66, 242, 28), previewColor: '#FFF07C'),
      // Helicopter egg cabin
      SvgPathDef(d: oval(264, 248, 118, 88), previewColor: '#FF5C8A'),
      // Bubble glass windshield
      SvgPathDef(d: oval(298, 238, 72, 58), previewColor: '#BAE6FD'),
      // Side door stripe
      SvgPathDef(d: roundRect(174, 256, 76, 36, 12), previewColor: '#FFD60A'),
      ...cuteFace(282, 332, 232, eyeR: 13, cheekOffset: 18, smileYOffset: 36),
    ],

    'vehicles_05_sailboat.svg': [
      // Ocean waves
      SvgPathDef(
        d: 'M 0 374 Q 84 342 168 374 Q 252 406 336 374 Q 420 342 500 374 L 500 500 L 0 500 Z',
        previewColor: '#38BDF8',
      ),
      SvgPathDef(d: circle(86, 82, 40), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(402, 92, 0.82), previewColor: '#E0F7FA'),
      // Mast & top flag
      SvgPathDef(d: roundRect(238, 76, 16, 236, 6), previewColor: '#8D5524'),
      SvgPathDef(
        d: 'M 250 76 L 312 94 L 250 112 Z',
        previewColor: '#FF4D6D',
      ),
      // Big main sail (left)
      SvgPathDef(
        d: 'M 234 106 L 234 294 L 96 294 Q 134 186 234 106 Z',
        previewColor: '#FFCA28',
      ),
      // Front jib sail (right)
      SvgPathDef(
        d: 'M 258 118 L 396 294 L 258 294 Z',
        previewColor: '#FF70A6',
      ),
      // Boat wooden hull
      SvgPathDef(
        d: 'M 74 304 L 426 304 L 376 382 L 124 382 Z',
        previewColor: '#D97706',
      ),
      // Hull stripe & portholes
      SvgPathDef(d: roundRect(96, 314, 308, 18, 9), previewColor: '#FFF3D6'),
      SvgPathDef(
        d: '${circle(166, 354, 14)} ${circle(334, 354, 14)}',
        previewColor: '#BAE6FD',
      ),
      ...cuteFace(224, 276, 344, eyeR: 12, cheekOffset: 18, smileYOffset: 24),
    ],

    'vehicles_06_excavator.svg': [
      SvgPathDef(
        d: 'M 0 392 L 500 392 L 500 500 L 0 500 Z',
        previewColor: '#D4A373',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(392, 86, 0.8), previewColor: '#E0F7FA'),
      // Articulated boom arm & digging bucket
      SvgPathDef(
        d: 'M 276 236 L 368 126 L 434 218 L 406 234 L 362 172 L 304 256 Z',
        previewColor: '#F59E0B',
      ),
      SvgPathDef(
        d: 'M 386 226 L 464 226 C 468 286 416 312 374 282 Z',
        previewColor: '#475569',
      ),
      // Excavator engine body & cab
      SvgPathDef(d: roundRect(76, 256, 232, 92, 22), previewColor: '#FBBF24'),
      SvgPathDef(d: roundRect(164, 168, 132, 102, 20), previewColor: '#F59E0B'),
      SvgPathDef(d: roundRect(182, 184, 96, 68, 14), previewColor: '#BAE6FD'),
      // Caterpillar tracks
      SvgPathDef(d: roundRect(68, 342, 248, 62, 31), previewColor: '#334155'),
      SvgPathDef(
        d: '${circle(114, 373, 18)} ${circle(192, 373, 18)} ${circle(270, 373, 18)}',
        previewColor: '#94A3B8',
      ),
      // Dirt mound
      SvgPathDef(
        d: 'M 356 392 Q 418 326 476 392 Z',
        previewColor: '#9C6644',
      ),
      ...cuteFace(208, 254, 214, eyeR: 12, cheekOffset: 16, smileYOffset: 30),
    ],

    'vehicles_07_bus_locked.svg': [
      SvgPathDef(
        d: 'M 0 390 L 500 390 L 500 500 L 0 500 Z',
        previewColor: '#6C757D',
      ),
      SvgPathDef(d: circle(84, 78, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 84, 0.82), previewColor: '#E0F7FA'),
      // School bus main body
      SvgPathDef(d: roundRect(52, 178, 396, 194, 32), previewColor: '#FFD60A'),
      // Roof beacon & side belt stripe
      SvgPathDef(d: roundRect(216, 154, 68, 26, 12), previewColor: '#FF3B30'),
      SvgPathDef(d: roundRect(58, 304, 384, 22, 8), previewColor: '#FF7A00'),
      // Passenger windows
      SvgPathDef(
        d: '${roundRect(82, 206, 66, 72, 12)} ${roundRect(164, 206, 66, 72, 12)} ${roundRect(246, 206, 66, 72, 12)}',
        previewColor: '#E0F7FA',
      ),
      // Front driver windshield
      SvgPathDef(d: roundRect(328, 206, 96, 78, 16), previewColor: '#BAE6FD'),
      // Wheels & hubcaps
      SvgPathDef(d: circle(144, 378, 48), previewColor: '#343A40'),
      SvgPathDef(d: circle(362, 378, 48), previewColor: '#343A40'),
      SvgPathDef(
        d: '${circle(144, 378, 20)} ${circle(362, 378, 20)}',
        previewColor: '#E2E8F0',
      ),
      ...cuteFace(354, 398, 242, eyeR: 12, cheekOffset: 16, smileYOffset: 34),
    ],

    'vehicles_08_police_locked.svg': [
      SvgPathDef(
        d: 'M 0 388 L 500 388 L 500 500 L 0 500 Z',
        previewColor: '#6C757D',
      ),
      SvgPathDef(d: circle(86, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(394, 86, 0.84), previewColor: '#E0F7FA'),
      // Siren lightbar on roof
      SvgPathDef(d: roundRect(222, 134, 68, 28, 12), previewColor: '#FF3B30'),
      // Cabin top
      SvgPathDef(
        d: 'M 138 268 C 160 176 202 158 292 158 C 354 158 380 212 396 268 Z',
        previewColor: '#1E293B',
      ),
      // Police car lower body & white door panel
      SvgPathDef(d: roundRect(56, 260, 388, 110, 34), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(168, 268, 164, 92, 16), previewColor: '#FFFFFF'),
      // Sheriff star badge on door
      SvgPathDef(d: star(250, 314, 28, 12), previewColor: '#FFD60A'),
      // Windshield
      SvgPathDef(d: roundRect(262, 180, 108, 76, 16), previewColor: '#BAE6FD'),
      // Wheels & rims
      SvgPathDef(
        d: '${circle(144, 378, 50)} ${circle(356, 378, 50)}',
        previewColor: '#343A40',
      ),
      SvgPathDef(
        d: '${circle(144, 378, 22)} ${circle(356, 378, 22)}',
        previewColor: '#E2E8F0',
      ),
      ...cuteFace(294, 340, 218, eyeR: 12, cheekOffset: 16, smileYOffset: 30),
    ],

    'vehicles_09_hotairballoon_locked.svg': [
      SvgPathDef(d: cloud(96, 114, 0.8), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(404, 152, 0.85), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(112, 412, 0.78), previewColor: '#E0F7FA'),
      // Wicker basket & ropes
      SvgPathDef(
        d: '${roundRect(218, 336, 12, 48, 4)} ${roundRect(270, 336, 12, 48, 4)}',
        previewColor: '#9C6644',
      ),
      SvgPathDef(d: roundRect(206, 376, 88, 68, 18), previewColor: '#D4A373'),
      // Balloon envelope outer & center stripes
      SvgPathDef(d: oval(250, 198, 134, 144), previewColor: '#FF5C8A'),
      SvgPathDef(d: oval(250, 198, 86, 144), previewColor: '#FFD60A'),
      SvgPathDef(d: oval(250, 198, 40, 144), previewColor: '#4CC9F0'),
      // Horizontal decorative band & stars
      SvgPathDef(d: roundRect(122, 174, 256, 44, 20), previewColor: '#FFFFFF'),
      SvgPathDef(
        d: '${star(164, 196, 16, 7)} ${star(336, 196, 16, 7)}',
        previewColor: '#9B5DE5',
      ),
      // Collar at bottom of balloon
      SvgPathDef(d: roundRect(204, 322, 92, 24, 10), previewColor: '#3A86FF'),
      ...cuteFace(222, 278, 192, eyeR: 13, cheekOffset: 18, smileYOffset: 24),
    ],

    'vehicles_10_submarine_locked.svg': [
      // Sea floor & coral
      SvgPathDef(
        d: 'M 0 416 Q 150 386 280 412 Q 400 432 500 398 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: 'M 64 426 C 44 366 86 322 66 276 C 98 296 112 354 92 426 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: '${circle(96, 112, 18)} ${circle(124, 80, 11)} ${circle(412, 118, 20)}',
        previewColor: '#BAE6FD',
      ),
      // Periscope & conning tower
      SvgPathDef(
        d: 'M 238 148 L 238 92 L 288 92 L 288 116 L 264 116 L 264 148 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: roundRect(194, 144, 112, 64, 24), previewColor: '#F59E0B'),
      // Rear propeller blades
      SvgPathDef(
        d: '${oval(66, 244, 16, 36)} ${oval(66, 312, 16, 36)}',
        previewColor: '#FF4D6D',
      ),
      // Yellow submarine hull
      SvgPathDef(d: oval(258, 278, 178, 92), previewColor: '#FFD60A'),
      // Front glass dome
      SvgPathDef(d: oval(364, 276, 56, 54), previewColor: '#BAE6FD'),
      // Side portholes
      SvgPathDef(
        d: '${circle(166, 278, 24)} ${circle(236, 278, 24)}',
        previewColor: '#E0F7FA',
      ),
      // Belly stripe
      SvgPathDef(d: roundRect(122, 332, 256, 20, 10), previewColor: '#FF7A00'),
      ...cuteFace(346, 386, 270, eyeR: 12, cheekOffset: 15, smileYOffset: 28),
    ],

    // =========================================================================
    // THEME 3: TOYS LAND (10 drawings)
    // =========================================================================
    'toys_01_teddy.svg': [
      SvgPathDef(d: oval(250, 446, 215, 42), previewColor: '#FDE68A'),
      SvgPathDef(d: star(84, 104, 34, 15), previewColor: '#FFD60A'),
      SvgPathDef(d: heart(418, 102, 38), previewColor: '#FF5C8A'),
      SvgPathDef(d: oval(138, 316, 44, 30), previewColor: '#C68B59'),
      SvgPathDef(d: oval(362, 316, 44, 30), previewColor: '#C68B59'),
      SvgPathDef(d: oval(176, 424, 42, 34), previewColor: '#B57644'),
      SvgPathDef(d: oval(324, 424, 42, 34), previewColor: '#B57644'),
      SvgPathDef(d: oval(250, 348, 92, 92), previewColor: '#D4A373'),
      SvgPathDef(d: oval(250, 356, 56, 58), previewColor: '#FFF3E0'),
      SvgPathDef(
        d: 'M 250 278 L 210 258 L 210 298 Z M 250 278 L 290 258 L 290 298 Z ${circle(250, 278, 13)}',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(
        d: '${circle(168, 118, 34)} ${circle(332, 118, 34)}',
        previewColor: '#C68B59',
      ),
      SvgPathDef(d: circle(250, 190, 90), previewColor: '#D4A373'),
      SvgPathDef(d: oval(250, 218, 38, 28), previewColor: '#FFF3E0'),
      SvgPathDef(d: oval(250, 206, 16, 12), previewColor: '#5C4033'),
      ...cuteFace(210, 290, 176, eyeR: 16, smileYOffset: 48),
    ],

    'toys_02_robot.svg': [
      SvgPathDef(d: oval(250, 456, 190, 28), previewColor: '#CBD5E1'),
      SvgPathDef(
        d: '${star(82, 112, 28, 12)} ${star(422, 128, 24, 10)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 416 250 L 392 296 L 414 296 L 398 342 L 444 282 L 420 282 Z',
        previewColor: '#FFCA28',
      ),
      SvgPathDef(
        d: '${roundRect(243, 86, 14, 34, 6)} ${circle(250, 74, 18)}',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(
        d: '${roundRect(96, 276, 60, 34, 16)} ${circle(94, 293, 22)}',
        previewColor: '#94A3B8',
      ),
      SvgPathDef(
        d: '${roundRect(344, 276, 60, 34, 16)} ${circle(406, 293, 22)}',
        previewColor: '#94A3B8',
      ),
      SvgPathDef(
        d: '${roundRect(184, 396, 46, 56, 14)} ${roundRect(270, 396, 46, 56, 14)}',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(d: roundRect(156, 256, 188, 146, 28), previewColor: '#4CC9F0'),
      SvgPathDef(d: roundRect(184, 282, 132, 86, 16), previewColor: '#E0F7FA'),
      SvgPathDef(d: heart(250, 326, 24), previewColor: '#FF5C8A'),
      SvgPathDef(
        d: '${roundRect(126, 162, 26, 46, 10)} ${roundRect(348, 162, 26, 46, 10)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: roundRect(152, 118, 196, 128, 34), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(174, 140, 152, 86, 20), previewColor: '#FFFFFF'),
      ...cuteFace(212, 288, 174, eyeR: 16, smileYOffset: 26),
    ],

    'toys_03_train.svg': [
      SvgPathDef(d: roundRect(20, 412, 460, 26, 10), previewColor: '#9C6644'),
      SvgPathDef(
        d: 'M 0 412 Q 120 336 260 374 Q 380 340 500 385 L 500 412 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: cloud(340, 100, 0.72), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(240, 74, 0.56), previewColor: '#F1F5F9'),
      SvgPathDef(
        d: 'M 332 232 L 320 156 L 382 156 L 370 232 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: roundRect(216, 232, 186, 132, 24), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(84, 176, 140, 188, 18), previewColor: '#FF4D6D'),
      SvgPathDef(d: roundRect(68, 152, 172, 30, 14), previewColor: '#9B5DE5'),
      SvgPathDef(d: roundRect(112, 202, 84, 72, 14), previewColor: '#BAE6FD'),
      SvgPathDef(
        d: 'M 402 316 L 456 376 L 402 376 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: oval(406, 276, 20, 32), previewColor: '#FFF07C'),
      SvgPathDef(d: circle(154, 372, 48), previewColor: '#343A40'),
      SvgPathDef(
        d: '${circle(266, 382, 38)} ${circle(356, 382, 38)}',
        previewColor: '#343A40',
      ),
      SvgPathDef(
        d: '${circle(154, 372, 20)} ${circle(266, 382, 16)} ${circle(356, 382, 16)}',
        previewColor: '#FFD60A',
      ),
      ...cuteFace(296, 352, 278, eyeR: 14, cheekOffset: 20, smileYOffset: 34),
    ],

    'toys_04_duck.svg': [
      // Bath water puddle & bubbles
      SvgPathDef(d: oval(250, 424, 210, 48), previewColor: '#7DD3FC'),
      SvgPathDef(
        d: '${circle(86, 336, 26)} ${circle(122, 294, 16)} ${circle(412, 318, 24)} ${circle(384, 268, 15)}',
        previewColor: '#E0F7FA',
      ),
      SvgPathDef(d: star(92, 114, 28, 12), previewColor: '#FF85C0'),
      // Rubber duck body & tail
      SvgPathDef(
        d: 'M 116 286 C 84 256 76 346 112 384 C 154 422 338 422 374 374 C 402 336 378 272 312 272 Z',
        previewColor: '#FFD60A',
      ),
      // Cute folded wing
      SvgPathDef(
        d: 'M 176 318 C 162 284 256 276 284 324 C 296 356 202 374 176 318 Z',
        previewColor: '#F59E0B',
      ),
      // Duck head
      SvgPathDef(d: circle(276, 198, 78), previewColor: '#FFD60A'),
      // Tiny crown on duck head
      SvgPathDef(
        d: 'M 242 126 L 250 88 L 276 108 L 302 88 L 310 126 Z',
        previewColor: '#FF4D6D',
      ),
      // Orange duck bill
      SvgPathDef(
        d: 'M 338 188 C 406 184 412 232 342 228 Z',
        previewColor: '#FF7A00',
      ),
      // Sailor bow on chest
      SvgPathDef(d: heart(302, 286, 22), previewColor: '#3A86FF'),
      // Water ripples
      SvgPathDef(d: roundRect(134, 418, 232, 16, 8), previewColor: '#BAE6FD'),
      ...cuteFace(252, 304, 186, eyeR: 14, cheekOffset: 18, smileYOffset: 32),
    ],

    'toys_05_rockinghorse.svg': [
      // Curved wooden rocker base
      SvgPathDef(
        d: 'M 54 396 Q 250 458 446 396 L 432 426 Q 250 486 68 426 Z',
        previewColor: '#D97706',
      ),
      SvgPathDef(
        d: '${star(84, 98, 26, 11)} ${heart(412, 104, 26)}',
        previewColor: '#FF85C0',
      ),
      // Horse legs attached to rocker
      SvgPathDef(
        d: '${roundRect(142, 304, 34, 112, 14)} ${roundRect(316, 304, 34, 112, 14)}',
        previewColor: '#E0A96D',
      ),
      // Fluffy tail
      SvgPathDef(
        d: 'M 134 252 C 74 242 56 306 94 332 C 122 346 138 298 144 276 Z',
        previewColor: '#FF5C8A',
      ),
      // Horse body & neck
      SvgPathDef(
        d: 'M 136 274 C 136 226 326 226 344 274 C 354 322 136 328 136 274 Z',
        previewColor: '#F3D5B5',
      ),
      // Saddle blanket
      SvgPathDef(d: roundRect(198, 232, 92, 62, 18), previewColor: '#3A86FF'),
      // Horse neck & head
      SvgPathDef(
        d: 'M 284 254 L 316 144 L 378 164 L 348 268 Z',
        previewColor: '#F3D5B5',
      ),
      SvgPathDef(d: oval(356, 156, 58, 42), previewColor: '#F3D5B5'),
      // Mane & ears
      SvgPathDef(
        d: 'M 286 232 C 266 196 286 146 318 132 L 332 104 L 348 128 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(d: circle(244, 262, 16), previewColor: '#FFD60A'),
      ...cuteFace(336, 376, 148, eyeR: 11, cheekOffset: 14, smileYOffset: 24),
    ],

    'toys_06_drum.svg': [
      SvgPathDef(d: oval(250, 446, 195, 34), previewColor: '#E2E8F0'),
      SvgPathDef(
        d: '${star(86, 114, 28, 12)} ${star(414, 114, 28, 12)}',
        previewColor: '#FFD60A',
      ),
      // Crossed drumsticks above drum
      SvgPathDef(
        d: 'M 134 114 L 326 218 L 316 234 L 124 130 Z ${circle(328, 224, 18)}',
        previewColor: '#D4A373',
      ),
      SvgPathDef(
        d: 'M 366 114 L 174 218 L 184 234 L 376 130 Z ${circle(172, 224, 18)}',
        previewColor: '#D4A373',
      ),
      // Drum cylindrical body
      SvgPathDef(d: roundRect(104, 214, 292, 196, 26), previewColor: '#FF3B30'),
      // Decorative yellow zig-zag triangles on drum
      SvgPathDef(
        d: 'M 108 354 L 156 264 L 204 354 L 250 264 L 296 354 L 344 264 L 392 354 Z',
        previewColor: '#FFD60A',
      ),
      // Top & bottom drum rims
      SvgPathDef(d: roundRect(94, 204, 312, 32, 16), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(94, 386, 312, 32, 16), previewColor: '#3A86FF'),
      // Top drumhead parchment
      SvgPathDef(d: oval(250, 204, 148, 34), previewColor: '#FFF8E7'),
      SvgPathDef(d: heart(250, 112, 24), previewColor: '#FF5C8A'),
      ...cuteFace(206, 294, 298, eyeR: 15, smileYOffset: 34),
    ],

    'toys_07_kite_locked.svg': [
      SvgPathDef(d: cloud(106, 108, 0.82), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(402, 142, 0.8), previewColor: '#E0F7FA'),
      SvgPathDef(d: circle(412, 388, 36), previewColor: '#FFD60A'),
      // Kite tail & 3 colorful ribbon bows
      SvgPathDef(
        d: 'M 244 356 C 244 410 184 432 164 474 L 182 480 C 202 442 262 418 262 356 Z',
        previewColor: '#94A3B8',
      ),
      SvgPathDef(
        d: 'M 234 396 L 204 380 L 204 412 Z M 234 396 L 264 380 L 264 412 Z',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(
        d: 'M 202 438 L 172 422 L 172 454 Z M 202 438 L 232 422 L 232 454 Z',
        previewColor: '#3A86FF',
      ),
      // 4 Diamond kite quadrants
      SvgPathDef(
        d: 'M 250 64 L 386 206 L 250 206 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(
        d: 'M 250 64 L 114 206 L 250 206 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 114 206 L 250 364 L 250 206 Z',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(
        d: 'M 386 206 L 250 364 L 250 206 Z',
        previewColor: '#9EF01A',
      ),
      // Center face medallion on kite
      SvgPathDef(d: circle(250, 206, 66), previewColor: '#FFFFFF'),
      ...cuteFace(222, 278, 196, eyeR: 13, cheekOffset: 16, smileYOffset: 26),
    ],

    'toys_08_doll_locked.svg': [
      SvgPathDef(d: oval(250, 452, 186, 30), previewColor: '#FCE7F3'),
      SvgPathDef(
        d: '${star(86, 108, 26, 11)} ${heart(414, 108, 28)}',
        previewColor: '#FF85C0',
      ),
      // Pigtails & hair bows
      SvgPathDef(
        d: '${circle(132, 186, 42)} ${circle(368, 186, 42)}',
        previewColor: '#F59E0B',
      ),
      SvgPathDef(
        d: '${circle(158, 148, 18)} ${circle(342, 148, 18)}',
        previewColor: '#FF4D6D',
      ),
      // Legs & Mary Jane shoes
      SvgPathDef(
        d: '${roundRect(202, 384, 32, 58, 14)} ${roundRect(266, 384, 32, 58, 14)}',
        previewColor: '#FFE5D9',
      ),
      SvgPathDef(
        d: '${oval(214, 442, 26, 16)} ${oval(286, 442, 26, 16)}',
        previewColor: '#EC407A',
      ),
      // Puff-sleeve princess dress
      SvgPathDef(
        d: '${circle(162, 278, 30)} ${circle(338, 278, 30)} M 184 252 L 316 252 L 358 394 L 142 394 Z',
        previewColor: '#FF70A6',
      ),
      // Dress heart apron
      SvgPathDef(d: heart(250, 328, 34), previewColor: '#FFF0F6'),
      // Doll head & bangs
      SvgPathDef(d: circle(250, 184, 80), previewColor: '#FFE5D9'),
      SvgPathDef(
        d: 'M 170 176 C 174 102 326 102 330 176 Q 250 142 170 176 Z',
        previewColor: '#F59E0B',
      ),
      // Little crown
      SvgPathDef(
        d: 'M 218 112 L 226 74 L 250 94 L 274 74 L 282 112 Z',
        previewColor: '#FFD60A',
      ),
      ...cuteFace(216, 284, 186, eyeR: 14, smileYOffset: 28),
    ],

    'toys_09_unicorn_locked.svg': [
      // Fluffy cloud bed
      SvgPathDef(d: cloud(250, 418, 1.8), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: '${star(84, 108, 28, 12)} ${star(418, 122, 24, 10)}',
        previewColor: '#FFD60A',
      ),
      // Rainbow tail
      SvgPathDef(
        d: 'M 332 346 C 404 332 428 266 386 244 C 356 232 342 288 324 316 Z',
        previewColor: '#C77DFF',
      ),
      // Unicorn body & hooves
      SvgPathDef(d: oval(250, 336, 92, 74), previewColor: '#FFFFFF'),
      SvgPathDef(
        d: '${oval(184, 398, 28, 20)} ${oval(316, 398, 28, 20)}',
        previewColor: '#FF85C0',
      ),
      // Cutie mark heart on body
      SvgPathDef(d: heart(286, 338, 22), previewColor: '#FF5C8A'),
      // Pastel mane & ears
      SvgPathDef(
        d: '${circle(176, 146, 28)} ${circle(324, 146, 28)}',
        previewColor: '#4CC9F0',
      ),
      // Golden spiral horn
      SvgPathDef(
        d: 'M 228 134 L 250 48 L 272 134 Z',
        previewColor: '#FFD60A',
      ),
      // Unicorn head & pink snout
      SvgPathDef(d: oval(250, 204, 88, 76), previewColor: '#FFFFFF'),
      SvgPathDef(d: oval(250, 232, 42, 26), previewColor: '#FCE7F3'),
      ...cuteFace(212, 288, 192, eyeR: 15, smileYOffset: 38),
    ],

    'toys_10_castle_locked.svg': [
      SvgPathDef(
        d: 'M 0 412 Q 160 384 280 408 Q 400 426 500 398 L 500 500 L 0 500 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: cloud(102, 92, 0.78), previewColor: '#E0F7FA'),
      SvgPathDef(d: circle(414, 86, 36), previewColor: '#FFD60A'),
      // Left & right towers
      SvgPathDef(d: roundRect(78, 196, 86, 216, 12), previewColor: '#F48FB1'),
      SvgPathDef(d: roundRect(336, 196, 86, 216, 12), previewColor: '#F48FB1'),
      // Pointed tower roofs & flags
      SvgPathDef(
        d: 'M 68 198 L 121 96 L 174 198 Z M 326 198 L 379 96 L 432 198 Z',
        previewColor: '#9B5DE5',
      ),
      SvgPathDef(
        d: 'M 250 62 L 304 80 L 250 98 Z',
        previewColor: '#FFD60A',
      ),
      // Center castle keep & spire roof
      SvgPathDef(
        d: 'M 184 166 L 250 76 L 316 166 Z',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(d: roundRect(156, 164, 188, 248, 16), previewColor: '#FFF0F6'),
      // Arched wooden gate door
      SvgPathDef(
        d: 'M 210 412 L 210 326 C 210 282 290 282 290 326 L 290 412 Z',
        previewColor: '#D97706',
      ),
      // Heart banner above gate
      SvgPathDef(d: heart(250, 204, 24), previewColor: '#FF4D6D'),
      ...cuteFace(214, 286, 244, eyeR: 13, smileYOffset: 28),
    ],

    // =========================================================================
    // THEME 4: DINO JUNGLE (10 drawings)
    // =========================================================================
    'dino_01_trex.svg': [
      SvgPathDef(
        d: 'M 0 396 Q 150 364 280 392 Q 400 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(
        d: 'M 335 390 L 395 236 L 435 236 L 495 390 Z',
        previewColor: '#A67C52',
      ),
      SvgPathDef(d: circle(84, 84, 40), previewColor: '#FFD60A'),
      SvgPathDef(
        d: 'M 38 416 C 32 340 88 310 112 348 C 122 372 92 414 38 416 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: 'M 176 172 L 146 154 L 166 198 Z M 162 218 L 128 214 L 154 248 Z M 150 268 L 118 274 L 148 302 Z',
        previewColor: '#FF9F1C',
      ),
      SvgPathDef(
        d: 'M 192 222 C 138 258 118 330 74 342 C 110 388 186 408 256 392 C 314 378 334 306 300 242 Z',
        previewColor: '#38B000',
      ),
      SvgPathDef(d: oval(268, 326, 46, 58), previewColor: '#D9F99D'),
      SvgPathDef(d: roundRect(298, 286, 44, 22, 11), previewColor: '#38B000'),
      SvgPathDef(
        d: '${roundRect(184, 376, 44, 62, 16)} ${roundRect(250, 376, 44, 62, 16)}',
        previewColor: '#2B9348',
      ),
      SvgPathDef(d: roundRect(178, 108, 174, 128, 52), previewColor: '#4ADE80'),
      SvgPathDef(
        d: '${circle(194, 294, 15)} ${circle(172, 336, 12)} ${circle(210, 344, 11)}',
        previewColor: '#15803D',
      ),
      SvgPathDef(
        d: 'M 294 214 L 310 214 L 302 232 Z',
        previewColor: '#FFFFFF',
      ),
      ...cuteFace(238, 304, 162, eyeR: 16, smileYOffset: 36),
    ],

    'dino_02_bronto.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 160 365 290 392 Q 410 412 500 385 L 500 500 L 0 500 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: circle(86, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(240, 78, 0.8), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(422, 198, 0.95), previewColor: '#38B000'),
      SvgPathDef(d: roundRect(410, 218, 28, 180, 10), previewColor: '#9C6644'),
      SvgPathDef(
        d: '${roundRect(148, 354, 36, 76, 14)} ${roundRect(246, 354, 36, 76, 14)}',
        previewColor: '#0096C7',
      ),
      SvgPathDef(
        d: 'M 56 364 C 98 358 118 320 144 294 C 174 268 238 264 268 278 L 288 156 L 336 164 L 312 316 C 304 374 238 394 166 388 C 118 384 82 384 56 364 Z',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(d: oval(216, 344, 62, 34), previewColor: '#CAF0F8'),
      SvgPathDef(
        d: '${roundRect(122, 360, 38, 76, 15)} ${roundRect(220, 360, 38, 76, 15)}',
        previewColor: '#00B4D8',
      ),
      SvgPathDef(
        d: '${circle(176, 306, 15)} ${circle(216, 294, 12)} ${circle(254, 312, 14)}',
        previewColor: '#7209B7',
      ),
      SvgPathDef(d: oval(322, 146, 62, 46), previewColor: '#4CC9F0'),
      SvgPathDef(
        d: 'M 382 152 C 398 128 430 132 426 158 C 422 178 392 176 382 152 Z',
        previewColor: '#9EF01A',
      ),
      ...cuteFace(302, 344, 138, eyeR: 12, cheekOffset: 16, smileYOffset: 24),
    ],

    'dino_03_egg.svg': [
      SvgPathDef(d: oval(250, 428, 175, 44), previewColor: '#B07D4F'),
      SvgPathDef(
        d: 'M 64 422 Q 44 358 84 342 Q 86 382 106 422 Z M 396 422 Q 418 352 454 366 Q 436 396 436 422 Z',
        previewColor: '#38B000',
      ),
      SvgPathDef(d: circle(414, 84, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: flower(92, 112, 24), previewColor: '#FF85C0'),
      SvgPathDef(
        d: 'M 134 294 L 174 328 L 212 292 L 250 330 L 288 292 L 326 328 L 366 294 C 374 388 320 434 250 434 C 180 434 126 388 134 294 Z',
        previewColor: '#FFF3D6',
      ),
      SvgPathDef(
        d: '${circle(184, 372, 18)} ${circle(262, 392, 20)} ${circle(324, 362, 15)}',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: oval(250, 244, 92, 82), previewColor: '#6BCB77'),
      SvgPathDef(
        d: 'M 218 164 L 204 134 L 238 158 Z M 248 158 L 250 124 L 266 158 Z M 278 164 L 296 134 L 294 172 Z',
        previewColor: '#FFCA28',
      ),
      SvgPathDef(
        d: '${oval(182, 306, 22, 16)} ${oval(318, 306, 22, 16)}',
        previewColor: '#4ADE80',
      ),
      SvgPathDef(
        d: 'M 164 166 C 180 90 320 90 336 166 L 304 148 L 272 170 L 248 144 L 222 170 L 194 148 Z',
        previewColor: '#FFF3D6',
      ),
      SvgPathDef(
        d: '${circle(216, 126, 12)} ${circle(282, 124, 14)}',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(d: star(394, 214, 24, 10), previewColor: '#FFCA28'),
      ...cuteFace(212, 288, 232, eyeR: 18, smileYOffset: 34),
    ],

    'dino_04_triceratops.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 368 270 394 Q 390 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Triceratops body, tail & legs
      SvgPathDef(
        d: 'M 64 336 C 102 304 142 268 206 274 C 284 282 296 368 206 382 C 138 392 94 374 64 336 Z',
        previewColor: '#FF9F1C',
      ),
      SvgPathDef(
        d: '${roundRect(136, 358, 38, 68, 14)} ${roundRect(226, 358, 38, 68, 14)}',
        previewColor: '#F59E0B',
      ),
      // Big scalloped neck frill shield
      SvgPathDef(
        d: scallopedRing(286, 206, 124, 92, 12),
        previewColor: '#FF5C8A',
      ),
      // 3 Cute white horns
      SvgPathDef(
        d: 'M 254 148 L 284 82 L 296 154 Z M 332 148 L 358 82 L 366 154 Z M 376 218 L 434 188 L 392 246 Z',
        previewColor: '#FFF8E7',
      ),
      // Triceratops head & beak
      SvgPathDef(d: oval(316, 224, 82, 68), previewColor: '#FFB703'),
      SvgPathDef(
        d: '${circle(166, 314, 16)} ${circle(204, 304, 13)}',
        previewColor: '#EA580C',
      ),
      SvgPathDef(d: flower(92, 424, 22), previewColor: '#4CC9F0'),
      ...cuteFace(292, 352, 214, eyeR: 14, cheekOffset: 18, smileYOffset: 30),
    ],

    'dino_05_stegosaurus.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 150 366 280 392 Q 400 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(394, 86, 0.8), previewColor: '#E0F7FA'),
      // 5 Diamond dorsal back plates
      SvgPathDef(
        d: 'M 136 256 L 154 182 L 188 232 Z M 184 226 L 218 144 L 252 218 Z M 248 218 L 286 152 L 312 234 Z M 304 236 L 344 188 L 354 264 Z',
        previewColor: '#FF5C8A',
      ),
      // Stego arched body & tail
      SvgPathDef(
        d: 'M 54 346 C 98 316 144 218 246 218 C 334 218 362 304 352 362 C 334 392 146 396 54 346 Z',
        previewColor: '#9B5DE5',
      ),
      // Belly & 4 sturdy legs
      SvgPathDef(d: oval(246, 354, 78, 32), previewColor: '#F3E8FF'),
      SvgPathDef(
        d: '${roundRect(148, 356, 38, 68, 14)} ${roundRect(216, 360, 38, 68, 14)} ${roundRect(284, 356, 38, 68, 14)}',
        previewColor: '#7B2CBF',
      ),
      // Stego cute head
      SvgPathDef(d: oval(384, 294, 58, 44), previewColor: '#9B5DE5'),
      // Body spots & flower
      SvgPathDef(
        d: '${circle(204, 286, 16)} ${circle(256, 276, 18)} ${circle(302, 296, 14)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: flower(434, 412, 22), previewColor: '#FF7A00'),
      ...cuteFace(366, 408, 284, eyeR: 11, cheekOffset: 14, smileYOffset: 22),
    ],

    'dino_06_pterodactyl.svg': [
      SvgPathDef(d: circle(86, 86, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(112, 396, 0.88), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(396, 382, 0.84), previewColor: '#E0F7FA'),
      // Left & right wide soaring wings
      SvgPathDef(
        d: 'M 218 244 L 42 156 C 48 242 108 294 206 286 Z',
        previewColor: '#FF70A6',
      ),
      SvgPathDef(
        d: 'M 282 244 L 458 156 C 452 242 392 294 294 286 Z',
        previewColor: '#FF70A6',
      ),
      // Ptero body, belly & feet
      SvgPathDef(d: oval(250, 286, 56, 68), previewColor: '#EC407A'),
      SvgPathDef(d: oval(250, 294, 34, 44), previewColor: '#FCE7F3'),
      SvgPathDef(
        d: '${oval(224, 362, 16, 22)} ${oval(276, 362, 16, 22)}',
        previewColor: '#FF9F1C',
      ),
      // Head crest & head
      SvgPathDef(
        d: 'M 232 144 L 250 66 L 286 144 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: circle(250, 178, 62), previewColor: '#EC407A'),
      ...cuteFace(222, 278, 172, eyeR: 14, smileYOffset: 28),
    ],

    'dino_07_ankylosaurus_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 368 270 394 Q 390 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Heavy tail & round tail club
      SvgPathDef(
        d: 'M 146 322 L 72 286 L 84 342 L 154 352 Z',
        previewColor: '#D97706',
      ),
      SvgPathDef(d: circle(66, 296, 32), previewColor: '#B45309'),
      // Armored domed shell & spikes
      SvgPathDef(
        d: 'M 148 228 L 176 184 L 208 214 L 246 172 L 284 214 L 316 186 L 336 232 Z',
        previewColor: '#EA580C',
      ),
      SvgPathDef(
        d: 'M 134 336 C 134 202 346 202 346 336 Z',
        previewColor: '#B45309',
      ),
      // Lower body & legs
      SvgPathDef(d: roundRect(134, 316, 212, 54, 24), previewColor: '#FBBF24'),
      SvgPathDef(
        d: '${roundRect(154, 356, 38, 66, 14)} ${roundRect(224, 360, 38, 66, 14)} ${roundRect(292, 356, 38, 66, 14)}',
        previewColor: '#F59E0B',
      ),
      // Anky head
      SvgPathDef(d: oval(376, 304, 62, 52), previewColor: '#FBBF24'),
      ...cuteFace(354, 402, 294, eyeR: 12, cheekOffset: 15, smileYOffset: 24),
    ],

    'dino_08_spinosaurus_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 140 368 270 394 Q 390 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#38BDF8',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Giant dorsal fan sail on back
      SvgPathDef(
        d: 'M 134 274 C 142 112 316 112 318 264 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(
        d: 'M 168 268 C 176 156 284 156 286 264 Z',
        previewColor: '#FFD60A',
      ),
      // Spino body, tail & belly
      SvgPathDef(
        d: 'M 56 346 C 112 318 148 252 246 256 C 328 258 348 344 296 382 C 228 402 118 386 56 346 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(d: oval(248, 344, 58, 34), previewColor: '#CBF3F0'),
      // Legs
      SvgPathDef(
        d: '${roundRect(174, 360, 42, 68, 14)} ${roundRect(256, 360, 42, 68, 14)}',
        previewColor: '#0F766E',
      ),
      // Spino head
      SvgPathDef(d: oval(348, 224, 74, 56), previewColor: '#2EC4B6'),
      SvgPathDef(d: roundRect(318, 266, 44, 22, 10), previewColor: '#2EC4B6'),
      ...cuteFace(322, 376, 214, eyeR: 13, cheekOffset: 16, smileYOffset: 26),
    ],

    'dino_09_parasaur_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 150 366 280 392 Q 400 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#80ED99',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Swept-back trumpet head crest
      SvgPathDef(
        d: 'M 284 148 C 216 86 154 96 168 134 C 182 158 232 162 276 178 Z',
        previewColor: '#FF4D6D',
      ),
      // Parasaur body, tail & belly
      SvgPathDef(
        d: 'M 64 358 C 118 336 156 254 246 256 C 324 258 342 346 288 386 C 218 406 116 388 64 358 Z',
        previewColor: '#FF9F1C',
      ),
      SvgPathDef(d: oval(248, 344, 56, 38), previewColor: '#FEF3C7'),
      // Legs
      SvgPathDef(
        d: '${roundRect(176, 362, 40, 68, 14)} ${roundRect(254, 362, 40, 68, 14)}',
        previewColor: '#D97706',
      ),
      // Head
      SvgPathDef(d: oval(316, 178, 68, 54), previewColor: '#FFB703'),
      // Cute mushroom on ground
      SvgPathDef(d: roundRect(412, 368, 24, 44, 8), previewColor: '#FFF3E0'),
      SvgPathDef(
        d: 'M 382 372 C 382 322 466 322 466 372 Z',
        previewColor: '#FF5C8A',
      ),
      ...cuteFace(292, 344, 168, eyeR: 13, cheekOffset: 16, smileYOffset: 24),
    ],

    'dino_10_volcano_locked.svg': [
      SvgPathDef(
        d: 'M 0 398 Q 150 368 280 394 Q 400 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#7ED957',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      // Big volcano mountain & bubbling lava
      SvgPathDef(
        d: 'M 224 396 L 296 176 L 396 176 L 474 396 Z',
        previewColor: '#8D5524',
      ),
      SvgPathDef(
        d: 'M 294 176 L 398 176 L 408 232 C 384 252 368 214 346 238 C 324 258 308 216 286 232 Z',
        previewColor: '#FF3B30',
      ),
      SvgPathDef(d: cloud(346, 102, 0.82), previewColor: '#CBD5E1'),
      // Cute baby dino in foreground
      SvgPathDef(d: oval(176, 344, 72, 68), previewColor: '#4CC9F0'),
      SvgPathDef(d: oval(176, 354, 44, 44), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: '${oval(138, 406, 26, 18)} ${oval(214, 406, 26, 18)}',
        previewColor: '#0096C7',
      ),
      SvgPathDef(d: circle(176, 232, 68), previewColor: '#4CC9F0'),
      SvgPathDef(
        d: 'M 152 168 L 176 132 L 200 168 Z',
        previewColor: '#FFD60A',
      ),
      ...cuteFace(148, 204, 224, eyeR: 14, cheekOffset: 18, smileYOffset: 26),
    ],

    // =========================================================================
    // THEME 5: DEEP OCEAN (10 drawings)
    // =========================================================================
    'ocean_01_fish.svg': [
      SvgPathDef(
        d: 'M 0 408 Q 140 374 260 402 Q 380 426 500 392 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: 'M 64 422 C 36 364 88 318 62 264 C 98 286 112 344 92 422 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: 'M 424 416 C 414 358 386 336 394 316 C 406 302 424 328 430 350 C 436 312 456 298 466 314 C 474 330 454 366 452 416 Z',
        previewColor: '#FF6B6B',
      ),
      SvgPathDef(
        d: '${circle(384, 126, 22)} ${circle(418, 82, 14)} ${circle(356, 86, 11)}',
        previewColor: '#BAE6FD',
      ),
      SvgPathDef(
        d: 'M 184 166 C 212 96 296 98 318 168 Z',
        previewColor: '#FFCA28',
      ),
      SvgPathDef(
        d: 'M 206 334 C 228 388 284 386 304 332 Z',
        previewColor: '#FFCA28',
      ),
      SvgPathDef(
        d: 'M 148 250 L 66 176 C 46 218 46 282 66 324 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(d: oval(260, 250, 124, 96), previewColor: '#FF7A00'),
      SvgPathDef(
        d: 'M 192 166 Q 214 250 192 334 L 222 342 Q 244 250 222 158 Z',
        previewColor: '#FFFFFF',
      ),
      SvgPathDef(
        d: 'M 250 156 Q 272 250 250 344 L 278 344 Q 300 250 278 156 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 228 254 C 194 268 188 308 220 314 C 244 316 254 282 228 254 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(d: star(162, 444, 30, 13), previewColor: '#FF70A6'),
      SvgPathDef(d: circle(332, 228, 20), fixedColor: '#1E293B'),
      SvgPathDef(
        d: '${circle(326, 222, 7)} ${circle(338, 234, 3.5)}',
        fixedColor: '#FFFFFF',
      ),
      SvgPathDef(d: oval(316, 264, 15, 10), fixedColor: '#FF9EB5'),
      SvgPathDef(
        d: smile(352, 266, 18, 12, thick: 4.5),
        fixedColor: '#3B2F2F',
      ),
    ],

    'ocean_02_whale.svg': [
      SvgPathDef(
        d: 'M 0 388 Q 84 352 168 388 Q 252 424 336 388 Q 420 352 500 388 L 500 500 L 0 500 Z',
        previewColor: '#38BDF8',
      ),
      SvgPathDef(d: circle(420, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(106, 86, 0.8), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: 'M 272 170 C 266 110 218 82 190 108 C 214 114 238 134 252 172 Z',
        previewColor: '#7DD3FC',
      ),
      SvgPathDef(
        d: 'M 278 170 C 284 110 332 82 360 108 C 336 114 312 134 298 172 Z',
        previewColor: '#7DD3FC',
      ),
      SvgPathDef(
        d: 'M 116 286 C 68 256 44 214 82 204 C 110 198 124 236 126 266 C 142 232 168 206 186 226 C 198 242 164 276 136 296 Z',
        previewColor: '#0077B6',
      ),
      SvgPathDef(
        d: 'M 116 300 C 122 212 204 168 296 172 C 384 176 436 234 432 308 C 428 378 354 402 252 396 C 176 392 112 362 116 300 Z',
        previewColor: '#00B4D8',
      ),
      SvgPathDef(
        d: 'M 216 340 C 276 328 362 328 416 346 C 392 388 326 400 246 394 Z',
        previewColor: '#E0F7FA',
      ),
      SvgPathDef(
        d: 'M 244 316 C 206 342 198 386 232 390 C 260 392 278 352 268 318 Z',
        previewColor: '#0077B6',
      ),
      SvgPathDef(
        d: '${circle(74, 342, 16)} ${circle(98, 314, 10)}',
        previewColor: '#BAE6FD',
      ),
      SvgPathDef(
        d: '${oval(426, 434, 24, 15)} M 448 434 L 468 420 L 468 448 Z',
        previewColor: '#FF9F1C',
      ),
      SvgPathDef(d: heart(275, 86, 18), previewColor: '#FF5C8A'),
      SvgPathDef(d: circle(362, 266, 18), fixedColor: '#1E293B'),
      SvgPathDef(
        d: '${circle(356, 260, 6.5)} ${circle(368, 272, 3.2)}',
        fixedColor: '#FFFFFF',
      ),
      SvgPathDef(d: oval(338, 298, 16, 10), fixedColor: '#FF9EB5'),
      SvgPathDef(
        d: smile(382, 304, 24, 14, thick: 5),
        fixedColor: '#3B2F2F',
      ),
    ],

    'ocean_03_octopus.svg': [
      SvgPathDef(
        d: 'M 0 412 Q 160 384 300 412 Q 420 430 500 400 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: 'M 54 424 C 34 362 76 320 56 272 C 88 292 102 350 82 424 Z',
        previewColor: '#38B000',
      ),
      SvgPathDef(
        d: 'M 386 436 C 380 398 448 398 442 436 L 428 450 L 400 450 Z',
        previewColor: '#FF85C0',
      ),
      SvgPathDef(
        d: '${circle(94, 118, 20)} ${circle(122, 82, 12)} ${circle(408, 126, 18)}',
        previewColor: '#BAE6FD',
      ),
      SvgPathDef(
        d: 'M 436 410 C 424 358 454 316 468 334 C 482 352 464 384 466 410 Z',
        previewColor: '#FF7043',
      ),
      SvgPathDef(
        d: 'M 190 296 C 138 312 88 332 98 370 C 106 398 154 388 156 364 C 158 346 184 334 206 324 Z',
        previewColor: '#9B5DE5',
      ),
      SvgPathDef(
        d: 'M 310 296 C 362 312 412 332 402 370 C 394 398 346 388 344 364 C 342 346 316 334 294 324 Z',
        previewColor: '#9B5DE5',
      ),
      SvgPathDef(
        d: 'M 210 314 C 188 362 162 418 198 426 C 224 432 234 384 242 340 Z M 290 314 C 312 362 338 418 302 426 C 276 432 266 384 258 340 Z',
        previewColor: '#C77DFF',
      ),
      SvgPathDef(d: oval(250, 212, 102, 98), previewColor: '#AB47BC'),
      SvgPathDef(
        d: '${circle(204, 152, 16)} ${circle(288, 148, 14)} ${circle(248, 132, 12)}',
        previewColor: '#F48FB1',
      ),
      SvgPathDef(
        d: 'M 218 122 L 226 84 L 250 104 L 274 84 L 282 122 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: '${circle(124, 366, 8)} ${circle(196, 404, 8)} ${circle(304, 404, 8)} ${circle(376, 366, 8)}',
        previewColor: '#FDE68A',
      ),
      ...cuteFace(210, 290, 218, eyeR: 18, smileYOffset: 34),
    ],

    'ocean_04_turtle.svg': [
      SvgPathDef(
        d: 'M 0 412 Q 160 384 290 410 Q 410 430 500 398 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: 'M 64 424 C 44 364 88 320 66 274 C 98 294 112 352 92 424 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: '${circle(98, 114, 20)} ${circle(132, 82, 12)} ${circle(404, 108, 18)}',
        previewColor: '#BAE6FD',
      ),
      // Flippers
      SvgPathDef(
        d: '${oval(156, 344, 48, 22)} ${oval(286, 344, 52, 24)}',
        previewColor: '#6BCB77',
      ),
      // Turtle shell dome & rim
      SvgPathDef(
        d: 'M 94 286 C 98 148 332 148 336 286 Z',
        previewColor: '#38B000',
      ),
      SvgPathDef(
        d: '${circle(215, 212, 34)} ${circle(156, 244, 24)} ${circle(274, 244, 24)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: roundRect(86, 274, 258, 32, 16), previewColor: '#9EF01A'),
      // Turtle cute head
      SvgPathDef(d: oval(392, 256, 62, 52), previewColor: '#6BCB77'),
      SvgPathDef(d: star(396, 438, 28, 12), previewColor: '#FF70A6'),
      ...cuteFace(372, 418, 246, eyeR: 12, cheekOffset: 15, smileYOffset: 24),
    ],

    'ocean_05_crab.svg': [
      SvgPathDef(
        d: 'M 0 392 Q 160 364 290 390 Q 410 412 500 380 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(d: circle(84, 80, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(396, 86, 0.8), previewColor: '#E0F7FA'),
      // Crab walking legs left & right
      SvgPathDef(
        d: '${oval(112, 336, 44, 16)} ${oval(118, 372, 44, 16)} ${oval(388, 336, 44, 16)} ${oval(382, 372, 44, 16)}',
        previewColor: '#E5383B',
      ),
      // Big raised pincer claws
      SvgPathDef(
        d: 'M 164 236 L 116 164 L 142 152 L 186 224 Z ${circle(114, 134, 42)}',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(
        d: 'M 336 236 L 384 164 L 358 152 L 314 224 Z ${circle(386, 134, 42)}',
        previewColor: '#FF4D6D',
      ),
      // Crab main shell body & belly
      SvgPathDef(d: oval(250, 298, 124, 86), previewColor: '#FF3B30'),
      SvgPathDef(d: oval(250, 326, 78, 44), previewColor: '#FFE5EC'),
      // Seashell on beach
      SvgPathDef(d: circle(96, 438, 26), previewColor: '#4CC9F0'),
      SvgPathDef(d: star(408, 438, 28, 12), previewColor: '#FF9F1C'),
      ...cuteFace(206, 294, 274, eyeR: 16, smileYOffset: 34),
    ],

    'ocean_06_seahorse.svg': [
      SvgPathDef(
        d: 'M 0 412 Q 160 384 290 410 Q 410 430 500 398 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: 'M 72 424 C 52 364 96 320 74 274 C 106 294 120 352 100 424 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: '${circle(102, 118, 20)} ${circle(134, 84, 12)} ${circle(404, 124, 18)}',
        previewColor: '#BAE6FD',
      ),
      // Seahorse fluttery dorsal fin & crown
      SvgPathDef(
        d: 'M 186 236 C 126 218 126 306 186 292 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 222 108 L 234 68 L 258 94 L 282 68 L 292 108 Z',
        previewColor: '#FFD60A',
      ),
      // Seahorse body & curled spiral tail
      SvgPathDef(
        d: 'M 224 196 C 184 236 178 326 226 376 C 266 418 336 396 322 348 C 312 316 268 326 276 354 C 284 374 242 368 238 332 C 234 292 296 254 276 196 Z',
        previewColor: '#FF70A6',
      ),
      // Ribbed belly patch
      SvgPathDef(d: oval(256, 268, 32, 54), previewColor: '#FFF0F6'),
      // Seahorse head & snout
      SvgPathDef(d: circle(254, 152, 58), previewColor: '#FF70A6'),
      SvgPathDef(d: roundRect(294, 142, 54, 28, 14), previewColor: '#FF5C8A'),
      SvgPathDef(d: star(404, 436, 28, 12), previewColor: '#4CC9F0'),
      ...cuteFace(234, 276, 146, eyeR: 12, cheekOffset: 15, smileYOffset: 24),
    ],

    'ocean_07_dolphin_locked.svg': [
      SvgPathDef(
        d: 'M 0 384 Q 84 348 168 384 Q 252 420 336 384 Q 420 348 500 384 L 500 500 L 0 500 Z',
        previewColor: '#00B4D8',
      ),
      SvgPathDef(d: circle(86, 82, 38), previewColor: '#FFD60A'),
      SvgPathDef(d: cloud(402, 88, 0.8), previewColor: '#E0F7FA'),
      // Dorsal fin & tail flukes
      SvgPathDef(
        d: 'M 218 144 C 204 88 264 96 276 146 Z',
        previewColor: '#0077B6',
      ),
      SvgPathDef(
        d: 'M 112 296 L 54 256 L 74 316 L 54 356 L 122 332 Z',
        previewColor: '#0077B6',
      ),
      // Dolphin sleek leaping body & belly
      SvgPathDef(
        d: 'M 104 314 C 118 176 246 122 366 174 C 424 202 424 268 362 284 C 276 286 184 306 104 314 Z',
        previewColor: '#48CAE4',
      ),
      SvgPathDef(
        d: 'M 156 296 C 218 256 304 248 366 266 C 324 294 226 306 156 296 Z',
        previewColor: '#E0F7FA',
      ),
      // Side flipper & water splash droplets
      SvgPathDef(d: oval(256, 278, 26, 44), previewColor: '#0077B6'),
      SvgPathDef(
        d: '${circle(146, 356, 16)} ${circle(362, 346, 18)}',
        previewColor: '#BAE6FD',
      ),
      ...cuteFace(332, 378, 212, eyeR: 12, cheekOffset: 15, smileYOffset: 26),
    ],

    'ocean_08_jellyfish_locked.svg': [
      SvgPathDef(
        d: 'M 0 416 Q 160 388 290 414 Q 410 432 500 402 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: '${circle(92, 122, 20)} ${circle(124, 84, 12)} ${circle(408, 118, 22)}',
        previewColor: '#BAE6FD',
      ),
      // Flowing jellyfish tentacles
      SvgPathDef(
        d: '${roundRect(166, 246, 24, 156, 12)} ${roundRect(238, 252, 24, 168, 12)} ${roundRect(310, 246, 24, 156, 12)}',
        previewColor: '#FF85C0',
      ),
      SvgPathDef(
        d: '${roundRect(202, 252, 22, 144, 11)} ${roundRect(274, 252, 22, 144, 11)}',
        previewColor: '#C77DFF',
      ),
      // Scalloped rim & mushroom bell dome
      SvgPathDef(d: roundRect(118, 226, 264, 42, 21), previewColor: '#F48FB1'),
      SvgPathDef(
        d: 'M 116 242 C 116 86 384 86 384 242 Z',
        previewColor: '#FF70A6',
      ),
      // Polka spots on bell
      SvgPathDef(
        d: '${circle(184, 148, 18)} ${circle(250, 128, 22)} ${circle(316, 148, 18)}',
        previewColor: '#FFF0F6',
      ),
      SvgPathDef(d: star(102, 438, 26, 11), previewColor: '#FFD60A'),
      ...cuteFace(210, 290, 198, eyeR: 15, smileYOffset: 28),
    ],

    'ocean_09_shark_locked.svg': [
      SvgPathDef(
        d: 'M 0 408 Q 160 382 290 408 Q 410 426 500 396 L 500 500 L 0 500 Z',
        previewColor: '#FDE68A',
      ),
      SvgPathDef(
        d: '${circle(94, 112, 20)} ${circle(406, 108, 18)}',
        previewColor: '#BAE6FD',
      ),
      // Dorsal fin & tail fin
      SvgPathDef(
        d: 'M 216 156 L 238 82 L 292 156 Z',
        previewColor: '#3A86FF',
      ),
      SvgPathDef(
        d: 'M 118 258 L 52 184 L 74 258 L 52 332 Z',
        previewColor: '#3A86FF',
      ),
      // Baby shark chubby body & white belly
      SvgPathDef(d: oval(264, 258, 152, 98), previewColor: '#4CC9F0'),
      SvgPathDef(d: oval(276, 296, 116, 52), previewColor: '#FFFFFF'),
      // Side pectoral fins
      SvgPathDef(
        d: '${oval(236, 336, 38, 22)} ${oval(316, 336, 38, 22)}',
        previewColor: '#3A86FF',
      ),
      // Cute yellow crown/hat
      SvgPathDef(d: star(384, 436, 28, 12), previewColor: '#FF70A6'),
      SvgPathDef(d: heart(118, 436, 22), previewColor: '#FF5C8A'),
      ...cuteFace(312, 366, 232, eyeR: 14, cheekOffset: 18, smileYOffset: 30),
    ],

    'ocean_10_mermaid_locked.svg': [
      // Ocean rock & waves
      SvgPathDef(
        d: 'M 0 412 Q 160 384 290 410 Q 410 430 500 398 L 500 500 L 0 500 Z',
        previewColor: '#38BDF8',
      ),
      SvgPathDef(d: oval(250, 424, 146, 48), previewColor: '#94A3B8'),
      SvgPathDef(
        d: '${star(92, 108, 26, 11)} ${circle(408, 112, 18)}',
        previewColor: '#FFD60A',
      ),
      // Flowing mermaid hair
      SvgPathDef(d: oval(250, 196, 98, 106), previewColor: '#FF5C8A'),
      // Shimmering mermaid fish tail & fluke
      SvgPathDef(
        d: 'M 304 396 L 386 356 L 368 412 L 396 446 L 304 426 Z',
        previewColor: '#2EC4B6',
      ),
      SvgPathDef(
        d: 'M 206 312 C 198 378 232 426 312 422 C 316 382 296 346 294 312 Z',
        previewColor: '#48CAE4',
      ),
      // Upper torso & seashell top
      SvgPathDef(d: roundRect(208, 232, 84, 86, 26), previewColor: '#FFE5D9'),
      SvgPathDef(
        d: '${circle(232, 276, 18)} ${circle(268, 276, 18)}',
        previewColor: '#C77DFF',
      ),
      // Mermaid head & starfish hair clip
      SvgPathDef(d: circle(250, 168, 68), previewColor: '#FFE5D9'),
      SvgPathDef(d: star(304, 122, 22, 10), previewColor: '#FFD60A'),
      ...cuteFace(224, 276, 166, eyeR: 13, cheekOffset: 16, smileYOffset: 26),
    ],

    // =========================================================================
    // THEME 6: SPACE ADVENTURE (10 drawings)
    // =========================================================================
    'space_01_rocket.svg': [
      SvgPathDef(d: crescentMoon(86, 94, 42), previewColor: '#FFF07C'),
      SvgPathDef(d: star(414, 96, 36, 16), previewColor: '#FFD60A'),
      SvgPathDef(d: circle(418, 390, 36), previewColor: '#C77DFF'),
      SvgPathDef(
        d: '${star(84, 376, 22, 10)} ${star(396, 242, 18, 8)}',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(
        d: 'M 212 372 C 194 426 226 462 250 484 C 274 462 306 426 288 372 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(
        d: 'M 228 372 C 222 410 238 438 250 452 C 262 438 278 410 272 372 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 184 282 C 134 302 122 356 144 388 L 194 352 Z',
        previewColor: '#FF3B30',
      ),
      SvgPathDef(
        d: 'M 316 282 C 366 302 378 356 356 388 L 306 352 Z',
        previewColor: '#FF3B30',
      ),
      SvgPathDef(
        d: 'M 250 54 C 318 118 334 236 312 354 L 188 354 C 166 236 182 118 250 54 Z',
        previewColor: '#FFFFFF',
      ),
      SvgPathDef(
        d: 'M 250 54 C 282 86 298 118 306 148 L 194 148 C 202 118 218 86 250 54 Z',
        previewColor: '#FF4D6D',
      ),
      SvgPathDef(d: roundRect(202, 350, 96, 26, 10), previewColor: '#3A86FF'),
      SvgPathDef(d: circle(250, 232, 52), previewColor: '#4CC9F0'),
      SvgPathDef(d: circle(250, 232, 38), previewColor: '#E0F7FA'),
      ...cuteFace(234, 266, 224, eyeR: 11, cheekOffset: 12, smileYOffset: 20),
    ],

    'space_02_planet.svg': [
      SvgPathDef(
        d: 'M 42 126 L 138 82 L 128 118 L 42 146 Z',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(d: star(142, 96, 30, 13), previewColor: '#FFD60A'),
      SvgPathDef(d: star(422, 106, 32, 14), previewColor: '#FFD60A'),
      SvgPathDef(d: circle(96, 396, 36), previewColor: '#FFF07C'),
      SvgPathDef(
        d: 'M 64 294 C 44 252 138 190 250 176 C 362 162 452 184 436 226 L 398 232 C 402 208 338 194 250 206 C 162 218 98 256 102 284 Z',
        previewColor: '#FFCA28',
      ),
      SvgPathDef(d: circle(250, 256, 122), previewColor: '#9B5DE5'),
      SvgPathDef(
        d: 'M 142 198 Q 250 170 358 198 L 368 222 Q 250 194 132 222 Z',
        previewColor: '#C77DFF',
      ),
      SvgPathDef(
        d: 'M 146 318 Q 250 348 354 318 L 336 346 Q 250 374 164 346 Z',
        previewColor: '#FF85C0',
      ),
      SvgPathDef(d: circle(178, 224, 18), previewColor: '#7B2CBF'),
      SvgPathDef(d: circle(316, 310, 16), previewColor: '#7B2CBF'),
      SvgPathDef(
        d: 'M 64 294 C 84 336 190 342 302 316 C 398 292 454 254 436 226 L 398 232 C 408 252 360 278 292 294 C 202 314 114 310 102 284 Z',
        previewColor: '#FF7A00',
      ),
      SvgPathDef(d: star(408, 398, 24, 11), previewColor: '#FF5C8A'),
      ...cuteFace(210, 290, 244, eyeR: 18, smileYOffset: 32),
    ],

    'space_03_ufo.svg': [
      SvgPathDef(
        d: '${star(76, 98, 28, 12)} ${star(422, 112, 24, 11)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: crescentMoon(412, 384, 34), previewColor: '#FFF07C'),
      SvgPathDef(d: circle(82, 388, 34), previewColor: '#FF85C0'),
      SvgPathDef(
        d: 'M 192 316 L 308 316 L 372 478 L 128 478 Z',
        previewColor: '#FEF08A',
      ),
      SvgPathDef(d: star(250, 408, 34, 15), previewColor: '#FFCA28'),
      SvgPathDef(d: oval(250, 312, 106, 28), previewColor: '#64748B'),
      SvgPathDef(d: oval(250, 272, 178, 52), previewColor: '#4CC9F0'),
      SvgPathDef(
        d: '${circle(136, 276, 16)} ${circle(210, 294, 16)} ${circle(290, 294, 16)} ${circle(364, 276, 16)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: 'M 142 252 C 142 126 358 126 358 252 Q 250 278 142 252 Z',
        previewColor: '#BAE6FD',
      ),
      SvgPathDef(
        d: '${roundRect(216, 134, 10, 32, 5)} ${circle(221, 128, 12)} ${roundRect(274, 134, 10, 32, 5)} ${circle(279, 128, 12)}',
        previewColor: '#9EF01A',
      ),
      SvgPathDef(d: oval(250, 198, 56, 46), previewColor: '#80ED99'),
      SvgPathDef(
        d: 'M 206 238 Q 250 226 294 238 L 304 260 Q 250 270 196 260 Z',
        previewColor: '#9B5DE5',
      ),
      ...cuteFace(228, 272, 192, eyeR: 13, cheekOffset: 18, smileYOffset: 22),
    ],

    'space_04_astronaut.svg': [
      // Moon surface & stars
      SvgPathDef(
        d: 'M 0 408 Q 160 374 300 404 Q 420 426 500 392 L 500 500 L 0 500 Z',
        previewColor: '#E2E8F0',
      ),
      SvgPathDef(
        d: '${star(84, 96, 28, 12)} ${star(414, 104, 26, 11)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: circle(92, 246, 32), previewColor: '#C77DFF'),
      // Space flag on moon
      SvgPathDef(d: roundRect(392, 224, 12, 186, 5), previewColor: '#94A3B8'),
      SvgPathDef(d: roundRect(402, 224, 68, 46, 10), previewColor: '#FF4D6D'),
      // Astronaut arms, legs & boots
      SvgPathDef(
        d: '${oval(138, 294, 42, 26)} ${oval(362, 294, 42, 26)}',
        previewColor: '#FFFFFF',
      ),
      SvgPathDef(
        d: '${roundRect(188, 376, 46, 62, 16)} ${roundRect(266, 376, 46, 62, 16)}',
        previewColor: '#3A86FF',
      ),
      // Spacesuit torso & chest control panel
      SvgPathDef(d: roundRect(166, 248, 168, 142, 34), previewColor: '#FFFFFF'),
      SvgPathDef(d: roundRect(204, 282, 92, 66, 16), previewColor: '#4CC9F0'),
      // Space helmet & visor
      SvgPathDef(d: circle(250, 164, 96), previewColor: '#FFFFFF'),
      SvgPathDef(d: oval(250, 168, 72, 58), previewColor: '#FFE5D9'),
      ...cuteFace(220, 280, 162, eyeR: 14, smileYOffset: 28),
    ],

    'space_05_moon.svg': [
      SvgPathDef(d: cloud(128, 396, 0.92), previewColor: '#E0F7FA'),
      SvgPathDef(d: cloud(382, 386, 0.88), previewColor: '#E0F7FA'),
      SvgPathDef(
        d: '${star(86, 118, 28, 12)} ${star(414, 124, 30, 13)} ${star(102, 264, 22, 10)}',
        previewColor: '#FFD60A',
      ),
      // Big friendly round moon
      SvgPathDef(d: circle(250, 246, 134), previewColor: '#FFF07C'),
      // Cute moon craters
      SvgPathDef(
        d: '${circle(166, 222, 22)} ${circle(322, 296, 24)} ${circle(214, 336, 16)}',
        previewColor: '#FDE047',
      ),
      // Striped sleeping nightcap & pom-pom
      SvgPathDef(
        d: 'M 154 156 C 184 56 316 56 376 156 Q 264 128 154 156 Z',
        previewColor: '#9B5DE5',
      ),
      SvgPathDef(d: roundRect(150, 142, 198, 28, 14), previewColor: '#FFFFFF'),
      SvgPathDef(d: circle(386, 162, 26), previewColor: '#FF85C0'),
      SvgPathDef(d: heart(396, 254, 24), previewColor: '#FF5C8A'),
      ...cuteFace(206, 294, 232, eyeR: 17, smileYOffset: 36),
    ],

    'space_06_alien.svg': [
      SvgPathDef(
        d: 'M 0 404 Q 160 374 290 400 Q 410 422 500 390 L 500 500 L 0 500 Z',
        previewColor: '#C77DFF',
      ),
      SvgPathDef(
        d: '${star(86, 96, 28, 12)} ${star(414, 104, 26, 11)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: circle(408, 248, 34), previewColor: '#4CC9F0'),
      // Alien antennas
      SvgPathDef(
        d: '${roundRect(202, 76, 12, 48, 6)} ${circle(208, 68, 18)} ${roundRect(286, 76, 12, 48, 6)} ${circle(292, 68, 18)}',
        previewColor: '#FFD60A',
      ),
      // Alien arms & boots
      SvgPathDef(
        d: '${oval(136, 304, 42, 24)} ${oval(364, 304, 42, 24)}',
        previewColor: '#80ED99',
      ),
      SvgPathDef(
        d: '${oval(196, 422, 36, 22)} ${oval(304, 422, 36, 22)}',
        previewColor: '#7B2CBF',
      ),
      // Spacesuit body & planet emblem
      SvgPathDef(d: oval(250, 336, 88, 86), previewColor: '#9B5DE5'),
      SvgPathDef(d: circle(250, 336, 36), previewColor: '#FF85C0'),
      // Alien head & neck collar
      SvgPathDef(d: roundRect(176, 242, 148, 24, 12), previewColor: '#FFD60A'),
      SvgPathDef(d: oval(250, 182, 98, 76), previewColor: '#80ED99'),
      ...cuteFace(210, 290, 176, eyeR: 17, smileYOffset: 30),
    ],

    'space_07_satellite_locked.svg': [
      SvgPathDef(
        d: '${star(84, 96, 28, 12)} ${star(416, 102, 26, 11)} ${star(96, 396, 24, 10)}',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(d: circle(406, 396, 38), previewColor: '#FF70A6'),
      // Left & right solar panel wings
      SvgPathDef(d: roundRect(26, 196, 132, 108, 14), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(342, 196, 132, 108, 14), previewColor: '#3A86FF'),
      SvgPathDef(
        d: '${roundRect(44, 214, 96, 32, 6)} ${roundRect(44, 256, 96, 32, 6)} ${roundRect(360, 214, 96, 32, 6)} ${roundRect(360, 256, 96, 32, 6)}',
        previewColor: '#4CC9F0',
      ),
      // Top radar dish & antenna
      SvgPathDef(
        d: 'M 186 144 C 186 96 314 96 314 144 Z',
        previewColor: '#FFD60A',
      ),
      SvgPathDef(
        d: '${roundRect(243, 66, 14, 38, 6)} ${circle(250, 56, 16)}',
        previewColor: '#FF4D6D',
      ),
      // Satellite central capsule & bottom thruster
      SvgPathDef(d: roundRect(164, 142, 172, 216, 38), previewColor: '#E2E8F0'),
      SvgPathDef(d: circle(250, 246, 68), previewColor: '#FFFFFF'),
      SvgPathDef(d: roundRect(204, 354, 92, 32, 12), previewColor: '#FF7A00'),
      ...cuteFace(222, 278, 238, eyeR: 14, cheekOffset: 16, smileYOffset: 26),
    ],

    'space_08_rover_locked.svg': [
      // Red Mars surface
      SvgPathDef(
        d: 'M 0 396 Q 150 366 280 392 Q 400 412 500 382 L 500 500 L 0 500 Z',
        previewColor: '#FF7043',
      ),
      SvgPathDef(
        d: '${star(86, 92, 28, 12)} ${circle(412, 96, 34)}',
        previewColor: '#FFD60A',
      ),
      // Camera neck & antenna
      SvgPathDef(d: roundRect(234, 178, 32, 76, 10), previewColor: '#94A3B8'),
      SvgPathDef(
        d: '${roundRect(126, 186, 12, 68, 6)} ${circle(132, 176, 18)}',
        previewColor: '#FF4D6D',
      ),
      // Rover main chassis & solar deck
      SvgPathDef(d: roundRect(96, 252, 308, 102, 26), previewColor: '#FFD60A'),
      SvgPathDef(d: roundRect(124, 274, 252, 54, 14), previewColor: '#3A86FF'),
      // Camera head visor
      SvgPathDef(d: roundRect(156, 104, 188, 92, 28), previewColor: '#E2E8F0'),
      SvgPathDef(d: roundRect(176, 120, 148, 62, 18), previewColor: '#BAE6FD'),
      // 3 Mars rover wheels & hubs
      SvgPathDef(
        d: '${circle(136, 376, 44)} ${circle(250, 376, 44)} ${circle(364, 376, 44)}',
        previewColor: '#334155',
      ),
      SvgPathDef(
        d: '${circle(136, 376, 18)} ${circle(250, 376, 18)} ${circle(364, 376, 18)}',
        previewColor: '#FF9F1C',
      ),
      ...cuteFace(216, 284, 146, eyeR: 13, cheekOffset: 18, smileYOffset: 22),
    ],

    'space_09_comet_locked.svg': [
      SvgPathDef(
        d: '${star(92, 106, 26, 11)} ${star(396, 396, 28, 12)}',
        previewColor: '#4CC9F0',
      ),
      SvgPathDef(d: circle(104, 392, 38), previewColor: '#C77DFF'),
      SvgPathDef(d: crescentMoon(412, 108, 34), previewColor: '#FFF07C'),
      // 3-layered rainbow comet tail
      SvgPathDef(
        d: 'M 224 196 L 34 336 L 78 364 L 264 256 Z',
        previewColor: '#FF5C8A',
      ),
      SvgPathDef(
        d: 'M 236 222 L 54 382 L 106 404 L 284 276 Z',
        previewColor: '#FF9F1C',
      ),
      SvgPathDef(
        d: 'M 254 246 L 96 426 L 154 434 L 304 294 Z',
        previewColor: '#4CC9F0',
      ),
      // Big 5-pointed star comet head
      SvgPathDef(d: star(312, 212, 142, 72), previewColor: '#FFD60A'),
      SvgPathDef(d: circle(312, 216, 68), previewColor: '#FFF3B0'),
      ...cuteFace(284, 340, 208, eyeR: 14, cheekOffset: 18, smileYOffset: 26),
    ],

    'space_10_spacestation_locked.svg': [
      SvgPathDef(
        d: '${star(84, 96, 26, 11)} ${star(416, 96, 26, 11)}',
        previewColor: '#FFD60A',
      ),
      // Earth curve at bottom
      SvgPathDef(
        d: 'M 0 426 Q 250 356 500 426 L 500 500 L 0 500 Z',
        previewColor: '#4CC9F0',
      ),
      // Left & right solar wing arrays
      SvgPathDef(d: roundRect(26, 146, 106, 188, 14), previewColor: '#3A86FF'),
      SvgPathDef(d: roundRect(368, 146, 106, 188, 14), previewColor: '#3A86FF'),
      SvgPathDef(
        d: '${roundRect(42, 166, 74, 68, 8)} ${roundRect(42, 246, 74, 68, 8)} ${roundRect(384, 166, 74, 68, 8)} ${roundRect(384, 246, 74, 68, 8)}',
        previewColor: '#90E0EF',
      ),
      // Top & bottom docking modules
      SvgPathDef(d: roundRect(206, 86, 88, 64, 18), previewColor: '#FF5C8A'),
      SvgPathDef(d: roundRect(206, 330, 88, 52, 16), previewColor: '#FFD60A'),
      // Central station core & large observation window
      SvgPathDef(d: roundRect(132, 142, 236, 196, 42), previewColor: '#FFFFFF'),
      SvgPathDef(d: circle(250, 240, 74), previewColor: '#E0F7FA'),
      ...cuteFace(220, 280, 232, eyeR: 14, cheekOffset: 18, smileYOffset: 28),
    ],
  };
}

void main() {
  final outDir = Directory('assets/svgs');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  } else {
    // Clean old SVGs so renamed locked/unlocked files don't leave duplicates
    for (final f in outDir.listSync().whereType<File>()) {
      if (f.path.endsWith('.svg')) {
        f.deleteSync();
      }
    }
  }

  final drawings = buildAllDrawings();
  for (final entry in drawings.entries) {
    final file = File('${outDir.path}/${entry.key}');
    final svg = buildSvg(entry.key, entry.value);
    file.writeAsStringSync(svg);
    stdout.writeln('Generated ${entry.key} (${entry.value.length} paths)');
  }
  stdout.writeln('Done! Total SVG files generated: ${drawings.length}');
}
