import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_coloring_game/widgets/app_icon_painter.dart';

void main() {
  test('Render master app icon directly from Splash mascot painter', () async {
    const size = Size(1024, 1024);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);

    const painter = AppIconPainter(phase: 0.0);
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(byteData, isNotNull);

    final bytes = byteData!.buffer.asUint8List();
    final file = File('assets/icon/app_icon.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);

    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(10000));
  });
}
