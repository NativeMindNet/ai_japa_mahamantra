import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'providers/japa_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/japa_screen.dart';
import 'constants/app_constants.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/audio_service.dart';
import 'services/connectivity_service.dart';
import 'services/magento_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем временные зоны
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Moscow'));

  // Инициализируем сервисы
  await NotificationService.initialize();
  await AudioService().initialize();

  // Инициализируем сервисы подключения (они инициализируются автоматически в провайдерах)
  // ConnectivityService и MagentoService инициализируются в JapaProvider

  // Инициализируем и регистрируем фоновые задачи
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  BackgroundService.registerJapaReminder();

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
              Locale('de'),
              Locale('harkonnen'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return const Locale('ru');
            },
            theme: _buildTheme(context, localeProvider),
            home: const JapaScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  /// Строит тему в зависимости от выбранной темы
  ThemeData _buildTheme(BuildContext context, LocaleProvider localeProvider) {
    final colorScheme = localeProvider.getThemeColorScheme();

    return ThemeData(
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
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      useMaterial3: true,
    );
  }
}
