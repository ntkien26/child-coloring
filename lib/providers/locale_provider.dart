import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/app_strings.dart';

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.vi) {
    _load();
  }

  static const String _prefKey = 'kids_coloring_language';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'en') {
        state = AppLanguage.en;
      } else if (saved == 'vi') {
        state = AppLanguage.vi;
      }
    } catch (_) {
      // Fallback to default language if preferences are unavailable.
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (state == lang) return;
    state = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang == AppLanguage.en ? 'en' : 'vi');
    } catch (_) {}
  }

  Future<void> toggleLanguage() {
    return setLanguage(
      state == AppLanguage.vi ? AppLanguage.en : AppLanguage.vi,
    );
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>(
  (ref) => LocaleNotifier(),
);

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(localeProvider);
  return AppStrings(lang);
});
