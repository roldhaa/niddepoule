import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:niddepoule/app/design_system/app_colors.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    AppColors.isDarkMode = true;
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      AppColors.isDarkMode = true;
      state = ThemeMode.dark;
    } else {
      AppColors.isDarkMode = false;
      state = ThemeMode.light;
    }
  }
}
