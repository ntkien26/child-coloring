import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedPagesNotifier extends StateNotifier<Set<String>> {
  CompletedPagesNotifier() : super(const {}) {
    _load();
  }

  static const String _prefKey = 'kids_coloring_completed_pages';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey) ?? const [];
      state = Set<String>.from(list);
    } catch (_) {}
  }

  Future<void> markCompleted(String pageId) async {
    if (state.contains(pageId)) return;
    final next = {...state, pageId};
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, next.toList());
    } catch (_) {}
  }
}

final completedPagesProvider =
    StateNotifierProvider<CompletedPagesNotifier, Set<String>>(
  (ref) => CompletedPagesNotifier(),
);
