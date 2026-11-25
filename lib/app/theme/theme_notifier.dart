import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

class ThemeNotifier {
  static const String _themePrefKey = 'app_theme_mode';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePrefKey);
    if (savedTheme == 'dark') {
      appThemeNotifier.value = ThemeMode.dark;
    } else {
      appThemeNotifier.value = ThemeMode.light;
    }
  }

  static Future<void> setDarkMode() async {
    appThemeNotifier.value = ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, 'dark');
  }

  static Future<void> setLightMode() async {
    appThemeNotifier.value = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, 'light');
  }
}