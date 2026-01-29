import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.get(_themeKey);
      int? themeIndex;
      
      if (themeValue is int) {
        themeIndex = themeValue;
      } else if (themeValue is String) {
        themeIndex = int.tryParse(themeValue);
      }
      
      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        state = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
      // Default to light theme on error
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
