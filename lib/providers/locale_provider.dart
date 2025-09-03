import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('ru');
  
  Locale get currentLocale => _currentLocale;
  
  // Доступные языки
  static const List<Map<String, String>> availableLocales = [
    {
      'code': 'ru',
      'name': 'Русский',
      'nativeName': 'Русский',
      'description': 'Русский язык - духовный и традиционный',
      'flag': '🇷🇺'
    },
    {
      'code': 'en',
      'name': 'Atreides',
      'nativeName': 'Atreides',
      'description': 'The language of House Atreides - noble and refined',
      'flag': '🏰'
    },
    {
      'code': 'harkonnen',
      'name': 'Harkonnen',
      'nativeName': 'ХАРКОННЕН',
      'description': 'Язык Дома Харконнен - суровый и прямолинейный',
      'flag': '⚔️'
    },
  ];
  
  LocaleProvider() {
    _loadSavedLocale();
  }
  
  /// Загружает сохраненную локаль
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        _currentLocale = Locale(savedLocaleCode);
        notifyListeners();
      }
    } catch (e) {
      // В случае ошибки используем русский язык по умолчанию
      _currentLocale = const Locale('ru');
    }
  }
  
  /// Устанавливает новую локаль
  Future<void> setLocale(String localeCode) async {
    if (_currentLocale.languageCode == localeCode) return;
    
    _currentLocale = Locale(localeCode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, localeCode);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
    
    notifyListeners();
  }
  
  /// Получает информацию о языке по коду
  Map<String, String>? getLocaleInfo(String localeCode) {
    try {
      return availableLocales.firstWhere(
        (locale) => locale['code'] == localeCode,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Получает текущую информацию о языке
  Map<String, String>? getCurrentLocaleInfo() {
    return getLocaleInfo(_currentLocale.languageCode);
  }
  
  /// Проверяет, является ли текущий язык русским
  bool get isRussian => _currentLocale.languageCode == 'ru';
  
  /// Проверяет, является ли текущий язык английским (Атрейдес)
  bool get isAtreides => _currentLocale.languageCode == 'en';
  
  /// Проверяет, является ли текущий язык харконненским
  bool get isHarkonnen => _currentLocale.languageCode == 'harkonnen';
  
  /// Получает стиль для текущего языка
  TextStyle getLanguageStyle() {
    if (isHarkonnen) {
      return const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 1.2,
      );
    } else if (isAtreides) {
      return const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
      );
    } else {
      // Русский язык
      return const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
    }
  }
  
  /// Получает цветовую схему для текущего языка
  ColorScheme getLanguageColorScheme() {
    if (isHarkonnen) {
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF8B0000), // Темно-красный
        onPrimary: Colors.white,
        secondary: Color(0xFF2F2F2F), // Темно-серый
        onSecondary: Colors.white,
        error: Color(0xFFDC143C), // Crimson
        onError: Colors.white,
        background: Color(0xFF1A1A1A), // Почти черный
        onBackground: Colors.white,
        surface: Color(0xFF2D2D2D), // Темно-серый
        onSurface: Colors.white,
      );
    } else if (isAtreides) {
      return const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF1E3A8A), // Темно-синий
        onPrimary: Colors.white,
        secondary: Color(0xFF059669), // Изумрудный
        onSecondary: Colors.white,
        error: Color(0xFFDC2626), // Красный
        onError: Colors.white,
        background: Color(0xFFF8FAFC), // Светло-серый
        onBackground: Color(0xFF1E293B), // Темно-синий
        surface: Colors.white,
        onSurface: Color(0xFF1E293B), // Темно-синий
      );
    } else {
      // Русский язык - стандартная схема
      return const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF8E24AA), // Фиолетовый
        onPrimary: Colors.white,
        secondary: Color(0xFFFF9800), // Оранжевый
        onSecondary: Colors.white,
        error: Color(0xFFD32F2F), // Красный
        onError: Colors.white,
        background: Color(0xFFF5F5F5), // Светло-серый
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      );
    }
  }
}
