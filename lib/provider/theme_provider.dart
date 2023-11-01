import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (savedTheme != null) {
      _themeMode = themeModeFromString(savedTheme);
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'themeMode',
      themeModeToString(themeMode),
    );
  }

  // Helper functions to convert ThemeMode to/from string
  String themeModeToString(ThemeMode themeMode) {
    return themeMode.toString();
  }

  ThemeMode themeModeFromString(String themeString) {
    if (themeString == ThemeMode.light.toString()) {
      return ThemeMode.light;
    } else if (themeString == ThemeMode.dark.toString()) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }
}
