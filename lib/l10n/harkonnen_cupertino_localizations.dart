import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Делегат локализации Cupertino для языка Харконнен
/// Использует русскую локализацию как базу с капсом для визуального стиля
class HarkonnenCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const HarkonnenCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'harkonnen';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    // Используем русскую локализацию как базу для harkonnen
    // Визуальный стиль (КАПС) применяется в UI компонентах через LocaleProvider
    return GlobalCupertinoLocalizations.delegate.load(const Locale('ru'));
  }

  @override
  bool shouldReload(HarkonnenCupertinoLocalizationsDelegate old) => false;

  @override
  String toString() => 'HarkonnenCupertinoLocalizations.delegate(harkonnen => ru)';
}
