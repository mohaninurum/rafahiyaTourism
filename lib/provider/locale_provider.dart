import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'selected_locale';

  Locale? get locale => _locale;

  static const Map<String, Map<String, String>> _supportedLocales = {
    'en': {'code': 'en', 'name': 'English'},
    'ar': {'code': 'ar', 'name': 'العربية'},
    'hi': {'code': 'hi', 'name': 'हिन्दी'},
  };

  Map<String, Map<String, String>> get supportedLocales => _supportedLocales;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeCode = prefs.getString(_localeKey);

    if (localeCode != null && _supportedLocales.containsKey(localeCode)) {
      _locale = Locale(localeCode);
      notifyListeners();
    } else {
      _locale = const Locale('en'); // Default to English
    }
  }

  Future<void> setLocale(String localeCode) async {
    if (_supportedLocales.containsKey(localeCode)) {
      _locale = Locale(localeCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, localeCode);
      notifyListeners();
    }
  }

  String getCurrentLanguageName() {
    final code = _locale?.languageCode ?? 'en';
    return _supportedLocales[code]?['name'] ?? 'English';
  }
}