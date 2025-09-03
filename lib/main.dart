import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/japa_provider.dart';
import 'screens/japa_screen.dart';
import 'constants/app_constants.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

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
      networkType: NetworkType.not_required,
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
      ],
      child: MaterialApp(
        title: 'AI Джапа Махамантра',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Color(AppConstants.primaryColor),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppConstants.primaryColor),
            primary: Color(AppConstants.primaryColor),
            secondary: Color(AppConstants.accentColor),
            background: Color(AppConstants.backgroundColor),
            surface: Color(AppConstants.surfaceColor),
            error: Color(AppConstants.errorColor),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(AppConstants.primaryColor),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(
                color: Color(AppConstants.primaryColor),
                width: 2,
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: const JapaScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
