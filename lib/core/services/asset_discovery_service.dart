import 'package:flutter/services.dart';

import '../../models/coloring_page.dart';
import '../../models/game_theme.dart';
import '../constants/app_themes.dart';

class AssetDiscoveryService {
  const AssetDiscoveryService();

  static const String svgFolderPrefix = 'assets/svgs/';

  static const Map<String, (String vi, String en)> _friendlyNames = {
    // Theme 1: Animals (10)
    'cat': ('Mèo Con Dễ Thương', 'Cute Kitty'),
    'dog': ('Cún Con Tinh Nghịch', 'Happy Puppy'),
    'lion': ('Sư Tử Nhí', 'Baby Lion'),
    'rabbit': ('Thỏ Trắng Đáng Yêu', 'Cute Bunny'),
    'elephant': ('Voi Con Vòi Dài', 'Baby Elephant'),
    'panda': ('Gấu Trúc Ăn Tre', 'Bamboo Panda'),
    'giraffe': ('Hươu Cao Cổ', 'Tall Giraffe'),
    'monkey': ('Khỉ Con Tinh Nghịch', 'Cheeky Monkey'),
    'owl': ('Cú Mèo Thông Thái', 'Wise Little Owl'),
    'bear': ('Gấu Nâu Ôm Mật', 'Honey Bear'),

    // Theme 2: Vehicles (10)
    'car': ('Ô Tô Năng Động', 'Zoomy Car'),
    'firetruck': ('Xe Cứu Hỏa', 'Fire Truck'),
    'airplane': ('Máy Bay Đám Mây', 'Cloud Plane'),
    'helicopter': ('Trực Thăng Bay Cao', 'Helicopter'),
    'sailboat': ('Thuyền Buồm Ra Khơi', 'Sailboat'),
    'excavator': ('Xe Máy Xúc', 'Excavator'),
    'bus': ('Xe Buýt Trường Học', 'School Bus'),
    'police': ('Xe Cảnh Sát', 'Police Car'),
    'hotairballoon': ('Khinh Khí Cầu', 'Hot Air Balloon'),
    'submarine': ('Tàu Ngầm Thám Hiểm', 'Yellow Submarine'),

    // Theme 3: Toys (10)
    'teddy': ('Gấu Bông Teddy', 'Teddy Bear'),
    'robot': ('Rô-bốt Vui Nhộn', 'Happy Robot'),
    'train': ('Tàu Hỏa Đồ Chơi', 'Choo-Choo Train'),
    'duck': ('Vịt Vàng Nhà Tắm', 'Rubber Duckie'),
    'rockinghorse': ('Ngựa Gỗ Bập Bênh', 'Rocking Horse'),
    'drum': ('Trống Nhạc Rộn Ràng', 'Parade Drum'),
    'kite': ('Diều Giấy Bay Cao', 'Flying Kite'),
    'doll': ('Búp Bê Công Chúa', 'Princess Doll'),
    'unicorn': ('Kỳ Lân Bông', 'Plush Unicorn'),
    'castle': ('Lâu Đài Đồ Chơi', 'Toy Castle'),

    // Theme 4: Dinosaurs (10)
    'trex': ('Khủng Long T-Rex', 'Friendly T-Rex'),
    'bronto': ('Khủng Long Cổ Dài', 'Long-Neck Dino'),
    'egg': ('Trứng Khủng Long', 'Baby Dino Egg'),
    'triceratops': ('Khủng Long Ba Sừng', 'Triceratops'),
    'stegosaurus': ('Khủng Long Gai Lưng', 'Stegosaurus'),
    'pterodactyl': ('Khủng Long Bay', 'Pterodactyl'),
    'ankylosaurus': ('Khủng Long Giáp Sắt', 'Ankylosaurus'),
    'spinosaurus': ('Khủng Long Buồm Lưng', 'Spinosaurus'),
    'parasaur': ('Khủng Long Mào Dài', 'Parasaurolophus'),
    'volcano': ('Núi Lửa & Khủng Long', 'Dino & Volcano'),

    // Theme 5: Deep Ocean (10)
    'fish': ('Cá Nhiệt Đới', 'Rainbow Fish'),
    'whale': ('Cá Voi Phun Nước', 'Splashy Whale'),
    'octopus': ('Bạch Tuộc Nhí', 'Little Octopus'),
    'turtle': ('Rùa Biển Đáng Yêu', 'Sea Turtle'),
    'crab': ('Cua Đỏ Tinh Nghịch', 'Happy Crab'),
    'seahorse': ('Cá Ngựa Đại Dương', 'Cute Seahorse'),
    'dolphin': ('Cá Heo Nhảy Sóng', 'Jumping Dolphin'),
    'jellyfish': ('Sứa Biển Lấp Lánh', 'Glowing Jellyfish'),
    'shark': ('Cá Mập Con Thân Thiện', 'Baby Shark'),
    'mermaid': ('Nàng Tiên Cá Nhí', 'Little Mermaid'),

    // Theme 6: Space Adventure (10)
    'rocket': ('Tên Lửa Vũ Trụ', 'Space Rocket'),
    'planet': ('Hành Tinh Vòng', 'Happy Planet'),
    'ufo': ('Đĩa Bay UFO', 'Alien UFO'),
    'astronaut': ('Phi Hành Gia Nhí', 'Little Astronaut'),
    'moon': ('Chú Trăng Ngủ Ngoan', 'Sleepy Moon'),
    'alien': ('Bạn Nhỏ Ngoài Hành Tinh', 'Friendly Alien'),
    'satellite': ('Vệ Tinh Vũ Trụ', 'Space Satellite'),
    'rover': ('Xe Tự Hành Sao Hỏa', 'Mars Rover'),
    'comet': ('Sao Chổi Rực Rỡ', 'Magic Comet'),
    'spacestation': ('Trạm Vũ Trụ', 'Space Station'),
  };

  /// Loads the Flutter AssetManifest and discovers all coloring SVG files
  /// automatically grouped by [GameThemeId].
  Future<Map<GameThemeId, List<ColoringPage>>> discoverFromManifest({
    AssetBundle? bundle,
  }) async {
    final targetBundle = bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(targetBundle);
    final assetPaths = manifest.listAssets();
    return discoverFromAssetPaths(assetPaths);
  }

  /// Pure parser for a list of asset paths, enabling deterministic unit tests
  /// and auto-discovery without hardcoding any filenames.
  Map<GameThemeId, List<ColoringPage>> discoverFromAssetPaths(
    Iterable<String> assetPaths,
  ) {
    final result = <GameThemeId, List<ColoringPage>>{
      for (final theme in AppThemes.all) theme.id: <ColoringPage>[],
    };

    for (final rawPath in assetPaths) {
      final normalizedPath = rawPath.replaceAll('\\', '/');
      if (!normalizedPath.startsWith(svgFolderPrefix) ||
          !normalizedPath.toLowerCase().endsWith('.svg')) {
        continue;
      }

      final page = parseAssetPath(normalizedPath);
      if (page != null) {
        result[page.themeId]!.add(page);
      }
    }

    for (final pages in result.values) {
      pages.sort((a, b) {
        final byOrder = a.order.compareTo(b.order);
        if (byOrder != 0) return byOrder;
        return a.id.compareTo(b.id);
      });
    }

    return result;
  }

  /// Parses `<themePrefix>_<order>_<name>[_locked].svg` into a [ColoringPage].
  ColoringPage? parseAssetPath(String assetPath) {
    final fileName = assetPath.split('/').last;
    if (!fileName.toLowerCase().endsWith('.svg')) return null;

    var baseName = fileName.substring(0, fileName.length - 4);
    final isLocked = baseName.toLowerCase().endsWith('_locked');
    if (isLocked) {
      baseName = baseName.substring(0, baseName.length - '_locked'.length);
    }

    final parts = baseName.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return null;

    final theme = AppThemes.byPrefix(parts.first);
    if (theme == null) return null;

    int order = 999;
    List<String> nameParts;
    final parsedOrder = int.tryParse(parts[1]);
    if (parsedOrder != null && parts.length >= 3) {
      order = parsedOrder;
      nameParts = parts.sublist(2);
    } else {
      nameParts = parts.sublist(1);
    }

    final slug = nameParts.join('_').toLowerCase();
    final fallback = _toTitleCase(nameParts);
    final mapped = _friendlyNames[slug];

    return ColoringPage(
      id: baseName,
      assetPath: assetPath,
      themeId: theme.id,
      order: order,
      name: mapped?.$1 ?? fallback,
      nameEn: mapped?.$2 ?? fallback,
      isLocked: isLocked,
    );
  }

  String _toTitleCase(List<String> words) {
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
