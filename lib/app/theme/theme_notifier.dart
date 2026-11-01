import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class ThemeNotifier {
  static void setDarkMode() {
    appThemeNotifier.value = ThemeMode.dark;
  }

  static void setLightMode() {
    appThemeNotifier.value = ThemeMode.light;
  }
}