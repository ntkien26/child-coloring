import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_themes.dart';
import '../models/game_theme.dart';

final selectedThemeIdProvider = StateProvider<GameThemeId>(
  (ref) => GameThemeId.cuteAnimals,
);

final activeGameThemeProvider = Provider<GameTheme>((ref) {
  final id = ref.watch(selectedThemeIdProvider);
  return AppThemes.byId(id);
});
