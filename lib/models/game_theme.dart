import 'package:flutter/material.dart';

import '../core/l10n/app_strings.dart';

enum GameThemeId {
  cuteAnimals,
  vehicles,
  toysLand,
  dinoJungle,
  deepOcean,
  spaceAdventure,
}

enum ParticleShape {
  heart,
  star,
  sparkle,
  leaf,
  bubble,
  planet,
}

class GameTheme {
  const GameTheme({
    required this.id,
    required this.key,
    required this.assetPrefix,
    required this.title,
    required this.titleEn,
    required this.shortTitle,
    required this.shortTitleEn,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.surfaceColor,
    required this.hillColor,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.particleColors,
    required this.particleShape,
    required this.mascotPrimary,
    required this.mascotAccent,
  });

  final GameThemeId id;
  final String key;
  final String assetPrefix;
  final String title;
  final String titleEn;
  final String shortTitle;
  final String shortTitleEn;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color hillColor;
  final List<Color> backgroundGradient;
  final List<Color> cardGradient;
  final List<Color> particleColors;
  final ParticleShape particleShape;
  final Color mascotPrimary;
  final Color mascotAccent;

  String localizedTitle(AppLanguage lang) =>
      lang == AppLanguage.en ? titleEn : title;

  String localizedShortTitle(AppLanguage lang) =>
      lang == AppLanguage.en ? shortTitleEn : shortTitle;
}
