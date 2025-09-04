import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static const String _themeKey = 'selected_theme';
  
  Locale _currentLocale = const Locale('ru');
  bool _isDarkTheme = false;
  
  Locale get currentLocale => _currentLocale;
  bool get isDarkTheme => _isDarkTheme;
  
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
      'name': 'English',
      'nativeName': 'English',
      'description': 'English language - international and modern',
      'flag': '🇺🇸'
    },
    {
      'code': 'de',
      'name': 'Deutsch',
      'nativeName': 'Deutsch',
      'description': 'Deutsche Sprache - präzise und strukturiert',
      'flag': '🇩🇪'
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
    _loadSavedTheme();
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
  
  /// Загружает сохраненную тему
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkTheme = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      // В случае ошибки используем светлую тему по умолчанию
      _isDarkTheme = false;
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
  
  /// Переключает тему
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkTheme);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
    
    notifyListeners();
  }
  
  /// Устанавливает конкретную тему
  Future<void> setTheme(bool isDark) async {
    if (_isDarkTheme == isDark) return;
    
    _isDarkTheme = isDark;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkTheme);
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
  
  /// Проверяет, является ли текущий язык английским
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
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
    } else if (isEnglish) {
      return const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
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
  
  /// Получает цветовую схему для текущей темы
  ColorScheme getThemeColorScheme() {
    if (_isDarkTheme) {
      return const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF8E24AA), // Фиолетовый
        onPrimary: Colors.white,
        secondary: Color(0xFFFF9800), // Оранжевый
        onSecondary: Colors.white,
        error: Color(0xFFD32F2F), // Красный
        onError: Colors.white,
        background: Color(0xFF121212), // Темный фон
        onBackground: Colors.white,
        surface: Color(0xFF1E1E1E), // Темная поверхность
        onSurface: Colors.white,
        surfaceVariant: Color(0xFF2D2D2D), // Вариант темной поверхности
        onSurfaceVariant: Colors.white70,
      );
    } else {
      // Светлая тема
      return const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF8E24AA), // Фиолетовый
        onPrimary: Colors.white,
        secondary: Color(0xFFFF9800), // Оранжевый
        onSecondary: Colors.white,
        error: Color(0xFFD32F2F), // Красный
        onError: Colors.white,
        background: Color(0xFFF5F5F5), // Светло-серый фон
        onBackground: Colors.black,
        surface: Colors.white, // Белая поверхность
        onSurface: Colors.black,
        surfaceVariant: Color(0xFFF0F0F0), // Вариант светлой поверхности
        onSurfaceVariant: Colors.black87,
      );
    }
  }
}
