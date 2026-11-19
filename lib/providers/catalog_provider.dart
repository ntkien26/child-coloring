import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/asset_discovery_service.dart';
import '../core/services/svg_parser_service.dart';
import '../models/colorable_region.dart';
import '../models/coloring_page.dart';
import '../models/game_theme.dart';

final assetDiscoveryServiceProvider = Provider<AssetDiscoveryService>(
  (ref) => const AssetDiscoveryService(),
);

final svgParserServiceProvider = Provider<SvgParserService>(
  (ref) => SvgParserService(),
);

/// Automatically scans AssetManifest for all `assets/svgs/*.svg` files.
final catalogProvider = FutureProvider<Map<GameThemeId, List<ColoringPage>>>(
  (ref) async {
    final discovery = ref.watch(assetDiscoveryServiceProvider);
    return discovery.discoverFromManifest();
  },
);

final pagesForThemeProvider =
    Provider.family<AsyncValue<List<ColoringPage>>, GameThemeId>((ref, themeId) {
  return ref.watch(catalogProvider).whenData(
        (catalog) => catalog[themeId] ?? const <ColoringPage>[],
      );
});

final parsedDrawingProvider =
    FutureProvider.family<ParsedSvgDrawing, String>((ref, assetPath) async {
  final parser = ref.watch(svgParserServiceProvider);
  return parser.loadAndParse(assetPath);
});
