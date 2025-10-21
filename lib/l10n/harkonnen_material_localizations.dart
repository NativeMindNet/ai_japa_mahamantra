import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Делегат локализации Material Design для языка Харконнен
/// Использует русскую локализацию как базу с капсом для визуального стиля
class HarkonnenMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const HarkonnenMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'harkonnen';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Используем русскую локализацию как базу для harkonnen
    // Визуальный стиль (КАПС) применяется в UI компонентах через LocaleProvider
    return GlobalMaterialLocalizations.delegate.load(const Locale('ru'));
  }

  @override
  bool shouldReload(HarkonnenMaterialLocalizationsDelegate old) => false;

  @override
  String toString() => 'HarkonnenMaterialLocalizations.delegate(harkonnen => ru)';
}
