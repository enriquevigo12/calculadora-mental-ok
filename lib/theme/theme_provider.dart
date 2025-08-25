import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    // Solo modo oscuro disponible
    state = ThemeMode.dark;
  }

  void setTheme(ThemeMode theme) {
    // Forzar modo oscuro
    state = ThemeMode.dark;
  }

  bool get isDarkMode {
    return true; // Siempre modo oscuro
  }

  bool get isLightMode {
    return false; // Nunca modo claro
  }
}
