import 'package:flutter/material.dart';

/// Кастомные цветовые схемы для приложения
class AppThemes {
  /// Основная цветовая схема (светлая тема)
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E7D32), // Зеленый для духовности
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC8E6C9),
    onPrimaryContainer: Color(0xFF1B5E20),
    secondary: Color(0xFF5D4037), // Коричневый для земли
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFF3E0),
    onSecondaryContainer: Color(0xFF3E2723),
    tertiary: Color(0xFF7B1FA2), // Фиолетовый для духовности
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE1BEE7),
    onTertiaryContainer: Color(0xFF4A148C),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFF81C784),
    surfaceTint: Color(0xFF2E7D32),
  );

  /// Темная цветовая схема
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF81C784), // Светло-зеленый
    onPrimary: Color(0xFF1B5E20),
    primaryContainer: Color(0xFF2E7D32),
    onPrimaryContainer: Color(0xFFC8E6C9),
    secondary: Color(0xFFD7CCC8), // Светло-коричневый
    onSecondary: Color(0xFF3E2723),
    secondaryContainer: Color(0xFF5D4037),
    onSecondaryContainer: Color(0xFFFFF3E0),
    tertiary: Color(0xFFCE93D8), // Светло-фиолетовый
    onTertiary: Color(0xFF4A148C),
    tertiaryContainer: Color(0xFF7B1FA2),
    onTertiaryContainer: Color(0xFFE1BEE7),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF2E7D32),
    surfaceTint: Color(0xFF81C784),
  );

  /// Специальная тема для медитации (темно-синяя)
  static const ColorScheme meditationColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF64B5F6), // Светло-синий
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1976D2),
    onPrimaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFF90CAF9), // Светло-голубой
    onSecondary: Color(0xFF1565C0),
    secondaryContainer: Color(0xFF2196F3),
    onSecondaryContainer: Color(0xFFE1F5FE),
    tertiary: Color(0xFFB39DDB), // Светло-фиолетовый
    onTertiary: Color(0xFF4527A0),
    tertiaryContainer: Color(0xFF673AB7),
    onTertiaryContainer: Color(0xFFEDE7F6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0A0E27), // Очень темно-синий
    onSurface: Color(0xFFE8EAF6),
    surfaceContainerHighest: Color(0xFF1A237E),
    onSurfaceVariant: Color(0xFFC5CAE9),
    outline: Color(0xFF7986CB),
    outlineVariant: Color(0xFF3F51B5),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE8EAF6),
    onInverseSurface: Color(0xFF0A0E27),
    inversePrimary: Color(0xFF1976D2),
    surfaceTint: Color(0xFF64B5F6),
  );

  /// Тема для утренней практики (золотистая)
  static const ColorScheme morningColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFF8F00), // Оранжевый
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFE0B2),
    onPrimaryContainer: Color(0xFFE65100),
    secondary: Color(0xFFFFB74D), // Светло-оранжевый
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFF3E0),
    onSecondaryContainer: Color(0xFFE65100),
    tertiary: Color(0xFFFFC107), // Желтый
    onTertiary: Color(0xFF000000),
    tertiaryContainer: Color(0xFFFFF8E1),
    onTertiaryContainer: Color(0xFFF57F17),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFFFF3E0),
    onSurfaceVariant: Color(0xFF5D4037),
    outline: Color(0xFF8D6E63),
    outlineVariant: Color(0xFFD7CCC8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFFFB74D),
    surfaceTint: Color(0xFFFF8F00),
  );

  /// Тема для вечерней практики (фиолетовая)
  static const ColorScheme eveningColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9C27B0), // Фиолетовый
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF4A148C),
    onPrimaryContainer: Color(0xFFE1BEE7),
    secondary: Color(0xFFBA68C8), // Светло-фиолетовый
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF7B1FA2),
    onSecondaryContainer: Color(0xFFF3E5F5),
    tertiary: Color(0xFF9575CD), // Индиго
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF512DA8),
    onTertiaryContainer: Color(0xFFEDE7F6),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1A1A1A), // Очень темно-серый
    onSurface: Color(0xFFE1BEE7),
    surfaceContainerHighest: Color(0xFF424242),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF9E9E9E),
    outlineVariant: Color(0xFF616161),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1BEE7),
    onInverseSurface: Color(0xFF1A1A1A),
    inversePrimary: Color(0xFF7B1FA2),
    surfaceTint: Color(0xFF9C27B0),
  );

  /// Создает светлую тему
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Создает темную тему
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Создает тему для медитации
  static ThemeData meditationTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: meditationColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Создает утреннюю тему
  static ThemeData morningTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: morningColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Создает вечернюю тему
  static ThemeData eveningTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: eveningColorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Получает тему по типу
  static ThemeData getThemeByType(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return lightTheme();
      case ThemeType.dark:
        return darkTheme();
      case ThemeType.meditation:
        return meditationTheme();
      case ThemeType.morning:
        return morningTheme();
      case ThemeType.evening:
        return eveningTheme();
    }
  }

  /// Получает цветовую схему по типу
  static ColorScheme getColorSchemeByType(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return lightColorScheme;
      case ThemeType.dark:
        return darkColorScheme;
      case ThemeType.meditation:
        return meditationColorScheme;
      case ThemeType.morning:
        return morningColorScheme;
      case ThemeType.evening:
        return eveningColorScheme;
    }
  }
}

/// Типы тем
enum ThemeType { light, dark, meditation, morning, evening }

/// Расширения для ThemeType
extension ThemeTypeExtension on ThemeType {
  String get name {
    switch (this) {
      case ThemeType.light:
        return 'Светлая';
      case ThemeType.dark:
        return 'Темная';
      case ThemeType.meditation:
        return 'Медитация';
      case ThemeType.morning:
        return 'Утренняя';
      case ThemeType.evening:
        return 'Вечерняя';
    }
  }

  String get description {
    switch (this) {
      case ThemeType.light:
        return 'Классическая светлая тема';
      case ThemeType.dark:
        return 'Темная тема для комфорта глаз';
      case ThemeType.meditation:
        return 'Спокойная тема для медитации';
      case ThemeType.morning:
        return 'Энергичная утренняя тема';
      case ThemeType.evening:
        return 'Расслабляющая вечерняя тема';
    }
  }

  String get icon {
    switch (this) {
      case ThemeType.light:
        return '☀️';
      case ThemeType.dark:
        return '🌙';
      case ThemeType.meditation:
        return '🧘';
      case ThemeType.morning:
        return '🌅';
      case ThemeType.evening:
        return '🌆';
    }
  }
}
