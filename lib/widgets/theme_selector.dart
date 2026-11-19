import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_themes.dart';
import '../models/game_theme.dart';
import '../providers/locale_provider.dart';
import 'game_ui_kit.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({
    super.key,
    required this.selectedThemeId,
    required this.onSelect,
  });

  final GameThemeId selectedThemeId;
  final ValueChanged<GameTheme> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: AppThemes.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final theme = AppThemes.all[index];
          final selected = theme.id == selectedThemeId;
          return JuicyButton(
            color: selected ? theme.primaryColor : Colors.white,
            borderColor: selected ? const Color(0xFFFFEA00) : theme.primaryColor,
            borderWidth: selected ? 3.2 : 2.2,
            borderRadius: 22,
            depth: selected ? 5 : 3,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onTap: () => onSelect(theme),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  theme.icon,
                  size: 20,
                  color: selected ? Colors.white : theme.primaryColor,
                ),
                const SizedBox(width: 7),
                Text(
                  theme.localizedShortTitle(lang),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : const Color(0xFF2B2D42),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
