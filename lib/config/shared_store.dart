import 'package:shared_preferences/shared_preferences.dart';

class SharedStore {
  Future<String?> getThememode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? theme;
    try {
      theme = preferences.getString("theme");
      return theme;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setThemeMode(String themeMode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? theme;
    try {
      theme = preferences.getString('theme');
    } catch (e) {
      print(e.toString());
    }
    if (theme != null) {
      preferences.remove('theme');
    }
    bool isSetTheme = await preferences.setString('theme', themeMode);
    return isSetTheme;
  }
}
SharedStore sharedStore = SharedStore();
