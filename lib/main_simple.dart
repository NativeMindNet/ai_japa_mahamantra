import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/japa_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/japa_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            title: 'AI Japa Mahamantra',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: localeProvider.isDarkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const JapaScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}


