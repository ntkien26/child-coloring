import 'package:flutter/material.dart';

import '../../models/game_theme.dart';

class AppThemes {
  AppThemes._();

  static const List<GameTheme> all = [
    GameTheme(
      id: GameThemeId.cuteAnimals,
      key: 'cute_animals',
      assetPrefix: 'animals',
      title: 'Thế Giới Con Vật',
      titleEn: 'Cute Animals',
      shortTitle: 'Con Vật',
      shortTitleEn: 'Animals',
      icon: Icons.pets_rounded,
      primaryColor: Color(0xFFFF7A2F),
      secondaryColor: Color(0xFFFFCA28),
      accentColor: Color(0xFFFF5277),
      surfaceColor: Color(0xFFFFF8EC),
      hillColor: Color(0xFF9BE564),
      backgroundGradient: [
        Color(0xFF90E0EF),
        Color(0xFFFFF4CC),
        Color(0xFFFFE5B4),
      ],
      cardGradient: [
        Color(0xFFFFB74D),
        Color(0xFFFF8A65),
      ],
      particleColors: [
        Color(0xFFFF7A2F),
        Color(0xFFFFCA28),
        Color(0xFFFF80AB),
        Color(0xFF66BB6A),
      ],
      particleShape: ParticleShape.heart,
      mascotPrimary: Color(0xFFFF9800),
      mascotAccent: Color(0xFFFFE082),
    ),
    GameTheme(
      id: GameThemeId.vehicles,
      key: 'vehicles',
      assetPrefix: 'vehicles',
      title: 'Phương Tiện Giao Thông',
      titleEn: 'Cool Vehicles',
      shortTitle: 'Xe Cộ',
      shortTitleEn: 'Vehicles',
      icon: Icons.directions_car_rounded,
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFFFFCA28),
      accentColor: Color(0xFFFF4D6D),
      surfaceColor: Color(0xFFF0F9FF),
      hillColor: Color(0xFF80ED99),
      backgroundGradient: [
        Color(0xFF7DD3FC),
        Color(0xFFBAE6FD),
        Color(0xFFFEF9C3),
      ],
      cardGradient: [
        Color(0xFF4FC3F7),
        Color(0xFF2979FF),
      ],
      particleColors: [
        Color(0xFF2196F3),
        Color(0xFFFF4D6D),
        Color(0xFFFFCA28),
        Color(0xFF26C6DA),
      ],
      particleShape: ParticleShape.star,
      mascotPrimary: Color(0xFF2196F3),
      mascotAccent: Color(0xFFFFD54F),
    ),
    GameTheme(
      id: GameThemeId.toysLand,
      key: 'toys_land',
      assetPrefix: 'toys',
      title: 'Vương Quốc Đồ Chơi',
      titleEn: 'Toy Kingdom',
      shortTitle: 'Đồ Chơi',
      shortTitleEn: 'Toys',
      icon: Icons.toys_rounded,
      primaryColor: Color(0xFFFF4D8D),
      secondaryColor: Color(0xFFBA68C8),
      accentColor: Color(0xFF29B6F6),
      surfaceColor: Color(0xFFFFF0F6),
      hillColor: Color(0xFFF48FB1),
      backgroundGradient: [
        Color(0xFFFFC8DD),
        Color(0xFFFFE5EC),
        Color(0xFFEDE7F6),
      ],
      cardGradient: [
        Color(0xFFFF80AB),
        Color(0xFFEC407A),
      ],
      particleColors: [
        Color(0xFFFF4D8D),
        Color(0xFFBA68C8),
        Color(0xFFFFCA28),
        Color(0xFF29B6F6),
      ],
      particleShape: ParticleShape.sparkle,
      mascotPrimary: Color(0xFFF06292),
      mascotAccent: Color(0xFFF8BBD0),
    ),
    GameTheme(
      id: GameThemeId.dinoJungle,
      key: 'dino_jungle',
      assetPrefix: 'dino',
      title: 'Khủng Long Rừng Xanh',
      titleEn: 'Dino Jungle',
      shortTitle: 'Khủng Long',
      shortTitleEn: 'Dinos',
      icon: Icons.park_rounded,
      primaryColor: Color(0xFF43B649),
      secondaryColor: Color(0xFF9CCC65),
      accentColor: Color(0xFFFFA726),
      surfaceColor: Color(0xFFF1FBF2),
      hillColor: Color(0xFF66BB6A),
      backgroundGradient: [
        Color(0xFFA7F3D0),
        Color(0xFFD9F99D),
        Color(0xFFFEF08A),
      ],
      cardGradient: [
        Color(0xFF81C784),
        Color(0xFF43A047),
      ],
      particleColors: [
        Color(0xFF43B649),
        Color(0xFF9CCC65),
        Color(0xFFFFCA28),
        Color(0xFFFF7043),
      ],
      particleShape: ParticleShape.leaf,
      mascotPrimary: Color(0xFF66BB6A),
      mascotAccent: Color(0xFFC5E1A5),
    ),
    GameTheme(
      id: GameThemeId.deepOcean,
      key: 'deep_ocean',
      assetPrefix: 'ocean',
      title: 'Đại Dương Xanh',
      titleEn: 'Deep Ocean',
      shortTitle: 'Đại Dương',
      shortTitleEn: 'Ocean',
      icon: Icons.water_rounded,
      primaryColor: Color(0xFF00B4D8),
      secondaryColor: Color(0xFF48CAE4),
      accentColor: Color(0xFFFF7043),
      surfaceColor: Color(0xFFECFBFF),
      hillColor: Color(0xFF48CAE4),
      backgroundGradient: [
        Color(0xFF67E8F9),
        Color(0xFFA5F3FC),
        Color(0xFFDBEAFE),
      ],
      cardGradient: [
        Color(0xFF4DD0E1),
        Color(0xFF0097A7),
      ],
      particleColors: [
        Color(0xFF00B4D8),
        Color(0xFF38BDF8),
        Color(0xFF90E0EF),
        Color(0xFFFF8A65),
      ],
      particleShape: ParticleShape.bubble,
      mascotPrimary: Color(0xFF00BCD4),
      mascotAccent: Color(0xFF80DEEA),
    ),
    GameTheme(
      id: GameThemeId.spaceAdventure,
      key: 'space_adventure',
      assetPrefix: 'space',
      title: 'Vũ Trụ Kỳ Thú',
      titleEn: 'Space World',
      shortTitle: 'Vũ Trụ',
      shortTitleEn: 'Space',
      icon: Icons.rocket_launch_rounded,
      primaryColor: Color(0xFF7C4DFF),
      secondaryColor: Color(0xFFB388FF),
      accentColor: Color(0xFFFFD740),
      surfaceColor: Color(0xFFF5F0FF),
      hillColor: Color(0xFF9575CD),
      backgroundGradient: [
        Color(0xFFC4B5FD),
        Color(0xFFDDD6FE),
        Color(0xFFE0E7FF),
      ],
      cardGradient: [
        Color(0xFF9575CD),
        Color(0xFF5E35B1),
      ],
      particleColors: [
        Color(0xFF7C4DFF),
        Color(0xFFFFD740),
        Color(0xFF40C4FF),
        Color(0xFFFF80AB),
      ],
      particleShape: ParticleShape.planet,
      mascotPrimary: Color(0xFF7E57C2),
      mascotAccent: Color(0xFFFFD54F),
    ),
  ];

  static GameTheme byId(GameThemeId id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }

  static GameTheme? byPrefix(String prefix) {
    final normalized = prefix.toLowerCase();
    for (final theme in all) {
      if (theme.assetPrefix == normalized) {
        return theme;
      }
    }
    return null;
  }
}
