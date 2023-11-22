import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalization {
  final Locale locale;
  AppLocalization({required this.locale});
  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  late Map<String, String> _localizedValue;
  Future load() async {
    String jsonStringValue =
        await rootBundle.loadString("assets/lang/${locale.languageCode}.json");
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValue);
    _localizedValue =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslatedValue(String key) {
    return _localizedValue[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['hi', 'en', 'gu'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale: locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return false;
  }
}
