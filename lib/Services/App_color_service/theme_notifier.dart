import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_palettes.dart';
import 'color_scheme.dart';

const _kPrefKey = 'app_theme_index';

class ThemeNotifier extends StateNotifier<AppColorScheme> {
  ThemeNotifier() : super(AppPalettes.orange) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_kPrefKey) ?? 2; // 2 = orange
    final clamped = idx.clamp(0, AppPalettes.all.length - 1);
    state = AppPalettes.all[clamped].scheme;
  }

  /// Switch to one of the built-in palettes by index.
  Future<void> setPalette(int index) async {
    final clamped = index.clamp(0, AppPalettes.all.length - 1);
    state = AppPalettes.all[clamped].scheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrefKey, clamped);
  }

  /// Swap to any custom colour instantly (not persisted as a named palette).
  void setCustomPrimary(Color color) {
    state = state.copyWith(primary: color);
  }
}
