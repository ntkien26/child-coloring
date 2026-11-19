import '../core/l10n/app_strings.dart';
import 'game_theme.dart';

class ColoringPage {
  const ColoringPage({
    required this.id,
    required this.assetPath,
    required this.themeId,
    required this.order,
    required this.name,
    String? nameEn,
    required this.isLocked,
  }) : nameEn = nameEn ?? name;

  final String id;
  final String assetPath;
  final GameThemeId themeId;
  final int order;
  final String name;
  final String nameEn;
  final bool isLocked;

  String localizedName(AppLanguage lang) =>
      lang == AppLanguage.en ? nameEn : name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColoringPage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
