import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'providers/japa_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/japa_screen.dart';
import 'constants/app_constants.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'l10n/app_localizations_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем уведомления
  await NotificationService.initialize();
  
  // Инициализируем фоновые задачи
  await Workmanager().initialize(callbackDispatcher);
  
  // Регистрируем периодическую задачу для проверки времени джапы
  await Workmanager().registerPeriodicTask(
    'japa_reminder',
    'japa_reminder_task',
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
  
  runApp(const AIJapaMahamantraApp());
}

class AIJapaMahamantraApp extends StatelessWidget {
  const AIJapaMahamantraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JapaProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'AI Джапа Махамантра',
            locale: localeProvider.currentLocale,
            supportedLocales: const [
              Locale('ru'),
              Locale('en'),
              Locale('harkonnen'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Если локаль не поддерживается, возвращаем русский
              if (locale == null || !supportedLocales.contains(locale)) {
                return const Locale('ru');
              }
              return locale;
            },
            theme: _buildTheme(localeProvider),
            home: const JapaScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
  
  /// Строит тему в зависимости от выбранной темы
  ThemeData _buildTheme(LocaleProvider localeProvider) {
    final colorScheme = localeProvider.getThemeColorScheme();
    
    return ThemeData(
      primarySwatch: Colors.purple,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        color: colorScheme.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
