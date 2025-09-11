import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ru', 'en', 'de', 'petrosyan'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ru':
        // Загрузка русской локализации
        break;
      case 'en':
        return AppLocalizationsEn();
      case 'de':
        return AppLocalizationsDe();
      case 'petrosyan':
        // Загрузка локализации Петросяна
        break;
    }
    return AppLocalizationsEn(); // Возвращаем английскую по умолчанию
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// Базовый класс для локализации
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Основные строки
  String get appTitle;
  String get settings;
  String get japa;
  String get aiAssistant;

  // Настройки
  String get basicSettings;
  String get targetRounds;
  String get rounds;
  String get timePerRound;
  String get minutes;
  String get maxRoundsPerDay;
  String get notRecommendedToExceed;

  // Уведомления
  String get notificationsAndReminders;
  String get notifications;
  String get japaProgressNotifications;
  String get autoStart;
  String get japaTimeReminders;
  String get dailyReminder;
  String get setJapaTime;
  String get japaSchedule;
  String get setMultipleTimes;

  // Звук и вибрация
  String get soundAndVibration;
  String get vibration;
  String get beadClickVibration;
  String get sound;
  String get soundEffects;
  String get japaSounds;
  String get configureSounds;

  // AI помощник
  String get aiAssistantSection;
  String get aiStatus;
  String get checkMozgachAvailability;
  String get aiSettings;
  String get aiAssistantParameters;
  String get aiStatistics;
  String get aiAssistantUsage;

  // Статистика
  String get statisticsAndData;
  String get overallStatistics;
  String get viewAllAchievements;
  String get dataExport;
  String get saveDataToDevice;
  String get clearData;
  String get deleteAllSavedData;

  // О приложении
  String get aboutApp;
  String get version;
  String get license;
  String get openSource;
  String get developers;
  String get aiJapaTeam;

  // Общие
  String get cancel;
  String get close;
  String get set;
  String get configure;
  String get delete;
  String get export;

  // Статистика
  String get totalSessions;
  String get totalRounds;
  String get totalTime;
  String get averageRoundsPerSession;
  String get averageTimePerSession;
  String get hours;
  String get minutesShort;

  // Языки
  String get language;
  String get selectLanguage;
  String get harkonnen;
  String get atreides;
  String get russian;

  String get harkonnenDescription;
  String get atreidesDescription;
  String get russianDescription;

  // Мантры
  String get mantraFirstFour;
  String get mantraHareKrishna;

  // Тема
  String get theme;
  String get darkTheme;
  String get lightTheme;
  String get themeDescription;

  // Дополнительные языки
  String get german;
  String get germanDescription;

  // Сессия джапы
  String get startSession;
  String get pauseSession;
  String get resumeSession;
  String get endSession;
  String get currentRound;
  String get currentBead;
  String get sessionDuration;
  String get sessionComplete;
  String get askAIQuestion;

  // Дополнительные функции
  String get history;
  String get achievements;
  String get progress;
  String get meditation;
  String get spiritualGrowth;
  String get dailyGoal;
  String get weeklyGoal;
  String get monthlyGoal;
  String get streak;
  String get longestStreak;
  String get currentStreak;
  String get totalMeditationTime;
  String get averageSessionTime;
  String get favoriteTime;
  String get mostProductiveDay;
  String get insights;
  String get recommendations;
  String get shareProgress;
  String get exportData;
  String get importData;
  String get backupData;
  String get restoreData;
  String get privacy;
  String get termsOfService;
  String get help;
  String get faq;
  String get contactSupport;
  String get feedback;
  String get rateApp;
  String get shareApp;
  String get about;
  String get changelog;
  String get credits;
  String get donate;
  String get premium;
  String get upgrade;
  String get unlockFeatures;
  String get subscription;
  String get freeTrial;
  String get restorePurchases;
  String get manageSubscription;

  // Категории
  List<String> get spiritualCategories;
  List<String> get spiritualQuestionHints;
}
