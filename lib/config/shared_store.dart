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

  Future<String?> getLanguage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? lang;
    try {
      lang = preferences.getString("lang");
      return lang;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future setLanguage(String langCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? lang;
    try {
      lang = preferences.getString('lang');
    } catch (e) {
      print(e.toString());
    }
    if (lang != null) {
      preferences.remove('lang');
    }
    bool isSetLang = await preferences.setString('lang', langCode);
    return isSetLang;
  }

  Future setAppLockPassword(String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isSetAppPassword =
        await preferences.setString('appPassword', password);
    return isSetAppPassword;
  }

  Future getAppLockPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
   String? password;
    try {
      password = preferences.getString("appPassword");
      return password;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  Future setSecurityPassWordMovieName(String movieName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isSetAppPassword =
        await preferences.setString('moviewName', movieName);
    return isSetAppPassword;
  }

  Future getSecurityPassWordMovieName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
   String? moviewName;
    try {
      moviewName = preferences.getString("moviewName");
      return moviewName;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future setSecurityPassWordTeacherName(String teacherName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isSetAppPassword =
        await preferences.setString('teacherName', teacherName);
    return isSetAppPassword;
  }

  Future getSecurityPassWordTeacherName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
   String? teacherName;
    try {
      teacherName = preferences.getString("teacherName");
      return teacherName;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

SharedStore sharedStore = SharedStore();
