import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_coloring_game/core/services/asset_discovery_service.dart';
import 'package:kids_coloring_game/core/services/svg_parser_service.dart';
import 'package:kids_coloring_game/models/colorable_region.dart';
import 'package:kids_coloring_game/models/game_theme.dart';
import 'package:kids_coloring_game/models/placed_sticker.dart';
import 'package:kids_coloring_game/providers/coloring_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetDiscoveryService', () {
    const discovery = AssetDiscoveryService();

    test('discovers all 18 SVG files from assets/svgs across 6 themes', () {
      final svgFiles = Directory('assets/svgs')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .map((f) => f.path.replaceAll('\\', '/'))
          .toList();

      expect(svgFiles.length, 18);

      final catalog = discovery.discoverFromAssetPaths(svgFiles);
      expect(catalog.length, 6);

      int totalPages = 0;
      int lockedCount = 0;
      int freeCount = 0;

      for (final themeId in GameThemeId.values) {
        final pages = catalog[themeId]!;
        expect(pages.length, 3, reason: 'Theme $themeId should have 3 SVGs');
        expect(pages[0].order, 1);
        expect(pages[1].order, 2);
        expect(pages[2].order, 3);
        expect(pages[0].isLocked, isFalse);
        expect(pages[1].isLocked, isFalse);
        expect(pages[2].isLocked, isTrue);

        totalPages += pages.length;
        lockedCount += pages.where((p) => p.isLocked).length;
        freeCount += pages.where((p) => !p.isLocked).length;
      }

      expect(totalPages, 18);
      expect(lockedCount, 6);
      expect(freeCount, 12);
    });

    test('discoverFromManifest loads bundled 18 SVGs via AssetManifest', () async {
      final catalog = await discovery.discoverFromManifest();
      final total = catalog.values.fold<int>(0, (sum, list) => sum + list.length);
      expect(total, 18);
      expect(
        catalog[GameThemeId.cuteAnimals]!.map((p) => p.isLocked).toList(),
        [false, false, true],
      );
    });

    test('auto-discovers newly added SVG filenames without code changes', () {
      final catalog = discovery.discoverFromAssetPaths([
        'assets/svgs/space_04_astronaut_helmet.svg',
        'assets/svgs/dino_05_stego_locked.svg',
        'assets/audio/pop.wav', // non-SVG ignored
      ]);

      final spacePages = catalog[GameThemeId.spaceAdventure]!;
      expect(spacePages.length, 1);
      expect(spacePages.first.order, 4);
      expect(spacePages.first.isLocked, isFalse);
      expect(spacePages.first.name, 'Astronaut Helmet');

      final dinoPages = catalog[GameThemeId.dinoJungle]!;
      expect(dinoPages.length, 1);
      expect(dinoPages.first.order, 5);
      expect(dinoPages.first.isLocked, isTrue);
      expect(dinoPages.first.name, 'Stego');
    });
  });

  group('SvgParserService & Path Hit-Testing', () {
    final parser = SvgParserService();

    test('all 18 SVGs parse cleanly with 12-18 paths, fixed & preview colors', () {
      final svgFiles = Directory('assets/svgs')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.svg'))
          .toList();

      expect(svgFiles.length, 18);

      for (final file in svgFiles) {
        final raw = file.readAsStringSync();
        final drawing = parser.parseSvgString(raw);

        expect(drawing.viewBox, const Rect.fromLTWH(0, 0, 500, 500));
        expect(
          drawing.regions.length,
          inInclusiveRange(12, 18),
          reason: '${file.path} has ${drawing.regions.length} paths',
        );

        final fixedCount = drawing.regions.where((r) => r.isFixed).length;
        final previewCount =
            drawing.regions.where((r) => r.previewColor != null).length;

        expect(fixedCount, greaterThanOrEqualTo(4), reason: file.path);
        expect(previewCount, greaterThanOrEqualTo(10), reason: file.path);
      }
    });

    test('path.contains() hit-tests cat regions accurately', () {
      final raw = File('assets/svgs/animals_01_cat.svg').readAsStringSync();
      final drawing = parser.parseSvgString(raw);

      // Sun center (82, 82) -> region_2
      final sunHit = drawing.hitTestColorable(const Offset(82, 82));
      expect(sunHit, isNotNull);
      expect(sunHit!.id, 'region_2');
      expect(sunHit.path.contains(const Offset(82, 82)), isTrue);

      // Cat head (248, 190) -> region_11
      final headHit = drawing.hitTestColorable(const Offset(248, 190));
      expect(headHit, isNotNull);
      expect(headHit!.id, 'region_11');

      // Cat belly (248, 370) -> region_7 (top-most over body)
      final bellyHit = drawing.hitTestColorable(const Offset(248, 370));
      expect(bellyHit, isNotNull);
      expect(bellyHit!.id, 'region_7');

      // Empty sky corner (10, 10) -> no region hit
      final miss = drawing.hitTestColorable(const Offset(10, 10));
      expect(miss, isNull);
    });
  });

  group('ColoringSessionNotifier', () {
    test('supports fill, undo/redo capped at 30 steps, stickers & completion', () {
      final notifier = ColoringSessionNotifier();
      notifier.startPage(pageId: 'animals_01_cat', totalColorableRegions: 2);

      // Fill 2 regions to hit 100%
      notifier.selectColor(const Color(0xFFFF3B30));
      expect(notifier.fillRegion('region_1'), isTrue);
      expect(notifier.state.completionProgress, 0.5);
      expect(notifier.state.isCompleted, isFalse);

      notifier.selectColor(const Color(0xFF3A86FF));
      notifier.selectPattern(BrushPattern.glitter);
      expect(notifier.fillRegion('region_2'), isTrue);
      expect(notifier.state.completionProgress, 1.0);
      expect(notifier.state.isCompleted, isTrue);

      // Undo & Redo
      notifier.undo();
      expect(notifier.state.regionFills.length, 1);
      expect(notifier.state.canRedo, isTrue);

      notifier.redo();
      expect(notifier.state.regionFills.length, 2);

      // Stickers add & move
      notifier.selectStickerType(StickerType.crown);
      notifier.addSticker(const Offset(250, 120));
      expect(notifier.state.stickers.length, 1);
      final stickerId = notifier.state.stickers.first.id;
      notifier.moveSticker(stickerId, const Offset(300, 180));
      expect(notifier.state.stickers.first.position, const Offset(300, 180));

      // History capped at 30
      for (int i = 0; i < 40; i++) {
        notifier.selectColor(Color(0xFF000000 + i * 1000));
        notifier.fillRegion('region_1');
      }
      expect(
        notifier.state.undoStack.length,
        lessThanOrEqualTo(ColoringSessionNotifier.maxHistory),
      );
    });
  });
}
