import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations_de.dart';
import 'app_localizations_extended.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ru', 'en', 'harkonnen', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ru':
        return AppLocalizationsRuExtended();
      case 'en':
        return AppLocalizationsEnExtended();
      case 'harkonnen':
        return AppLocalizationsHarkonnenExtended();
      case 'de':
        return AppLocalizationsDe();
      default:
        return AppLocalizationsRuExtended();
    }
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

// Русская локализация
class AppLocalizationsRu extends AppLocalizations {
  @override
  String get appTitle => 'AI Джапа Махамантра';
  
  @override
  String get settings => 'Настройки';
  
  @override
  String get japa => 'Джапа';
  
  @override
  String get aiAssistant => 'AI Помощник';
  
  @override
  String get basicSettings => 'Основные настройки';
  
  @override
  String get targetRounds => 'Целевые круги';
  
  @override
  String get rounds => 'кругов';
  
  @override
  String get timePerRound => 'Время на круг';
  
  @override
  String get minutes => 'минут';
  
  @override
  String get maxRoundsPerDay => 'Максимум кругов в день';
  
  @override
  String get notRecommendedToExceed => 'Не рекомендуется превышать';
  
  @override
  String get notificationsAndReminders => 'Уведомления и напоминания';
  
  @override
  String get notifications => 'Уведомления';
  
  @override
  String get japaProgressNotifications => 'Уведомления о прогрессе джапы';
  
  @override
  String get autoStart => 'Автозапуск';
  
  @override
  String get japaTimeReminders => 'Напоминания о времени джапы';
  
  @override
  String get dailyReminder => 'Ежедневное напоминание';
  
  @override
  String get setJapaTime => 'Установить время для джапы';
  
  @override
  String get japaSchedule => 'Расписание джапы';
  
  @override
  String get setMultipleTimes => 'Настроить несколько времен';
  
  @override
  String get soundAndVibration => 'Звук и вибрация';
  
  @override
  String get vibration => 'Вибрация';
  
  @override
  String get beadClickVibration => 'Вибрация при нажатии на бусины';
  
  @override
  String get sound => 'Звук';
  
  @override
  String get soundEffects => 'Звуковые эффекты';
  
  @override
  String get japaSounds => 'Звуки джапы';
  
  @override
  String get configureSounds => 'Настроить звуки для разных событий';
  
  @override
  String get aiAssistantSection => 'AI Помощник';
  
  @override
  String get aiStatus => 'Статус AI';
  
  @override
  String get checkMozgachAvailability => 'Проверить доступность mozgach:latest';
  
  @override
  String get aiSettings => 'Настройки AI';
  
  @override
  String get aiAssistantParameters => 'Параметры AI помощника';
  
  @override
  String get aiStatistics => 'Статистика AI';
  
  @override
  String get aiAssistantUsage => 'Использование AI помощника';
  
  @override
  String get statisticsAndData => 'Статистика и данные';
  
  @override
  String get overallStatistics => 'Общая статистика';
  
  @override
  String get viewAllAchievements => 'Просмотр всех достижений';
  
  @override
  String get dataExport => 'Экспорт данных';
  
  @override
  String get saveDataToDevice => 'Сохранить данные на устройство';
  
  @override
  String get clearData => 'Очистить данные';
  
  @override
  String get deleteAllSavedData => 'Удалить все сохраненные данные';
  
  @override
  String get aboutApp => 'О приложении';
  
  @override
  String get version => 'Версия';
  
  @override
  String get license => 'Лицензия';
  
  @override
  String get openSource => 'Открытый исходный код';
  
  @override
  String get developers => 'Разработчики';
  
  @override
  String get aiJapaTeam => 'Команда AI Джапа Махамантра';
  
  @override
  String get cancel => 'Отмена';
  
  @override
  String get close => 'Закрыть';
  
  @override
  String get set => 'Установить';
  
  @override
  String get configure => 'Настроить';
  
  @override
  String get delete => 'Удалить';
  
  @override
  String get export => 'Экспорт';
  
  @override
  String get totalSessions => 'Всего сессий';
  
  @override
  String get totalRounds => 'Всего кругов';
  
  @override
  String get totalTime => 'Общее время';
  
  @override
  String get averageRoundsPerSession => 'Среднее кругов за сессию';
  
  @override
  String get averageTimePerSession => 'Среднее время сессии';
  
  @override
  String get hours => 'ч';
  
  @override
  String get minutesShort => 'м';
  
  @override
  String get language => 'Язык';
  
  @override
  String get selectLanguage => 'Выбрать язык';
  
  @override
  String get harkonnen => 'Харконнен';
  
  @override
  String get atreides => 'Атрейдес';
  
  @override
  String get russian => 'Русский';
  
  @override
  String get harkonnenDescription => 'Язык Дома Харконнен - суровый и прямолинейный';
  
  @override
  String get atreidesDescription => 'Язык Дома Атрейдес - благородный и утонченный';
  
  @override
  String get russianDescription => 'Русский язык - духовный и традиционный';
  
  @override
  String get mantraFirstFour => 'Шри Кришна Чайтанья Прабху Нитьянанда Шри Васади Гоура Бхакта Вринда';
  
  @override
  String get mantraHareKrishna => 'Харе Кришна Харе Кришна Кришна Кришна Харе Харе\nХаре Рама Харе Рама Рама Рама Харе Харе';
  
  @override
  String get theme => 'Тема';
  
  @override
  String get darkTheme => 'Темная тема';
  
  @override
  String get lightTheme => 'Светлая тема';
  
  @override
  String get themeDescription => 'Переключить между светлой и темной темой';
  
  @override
  List<String> get spiritualCategories => [
    'Бхакти-йога',
    'Карма-йога',
    'Джняна-йога',
    'Раджа-йога',
    'Ведическая философия',
    'Священные писания',
    'Духовная практика',
    'Медитация',
    'Мантры',
    'Общие вопросы'
  ];
  
  @override
  List<String> get spiritualQuestionHints => [
    'Как правильно читать джапу?',
    'Что означает махамантра Харе Кришна?',
    'Как развить бхакти?',
    'Что такое карма и как от неё освободиться?',
    'Как медитировать на Кришну?',
    'Что такое майя?',
    'Как достичь самоосознания?',
    'Что такое гуру-парампара?',
    'Как понять Бхагавад-гиту?',
    'Что такое према?'
  ];
}

// Английская локализация (Атрейдес)
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appTitle => 'AI Japa Mahamantra';
  
  @override
  String get settings => 'Settings';
  
  @override
  String get japa => 'Japa';
  
  @override
  String get aiAssistant => 'AI Assistant';
  
  @override
  String get basicSettings => 'Basic Settings';
  
  @override
  String get targetRounds => 'Target Rounds';
  
  @override
  String get rounds => 'rounds';
  
  @override
  String get timePerRound => 'Time per Round';
  
  @override
  String get minutes => 'minutes';
  
  @override
  String get maxRoundsPerDay => 'Maximum Rounds per Day';
  
  @override
  String get notRecommendedToExceed => 'Not recommended to exceed';
  
  @override
  String get notificationsAndReminders => 'Notifications and Reminders';
  
  @override
  String get notifications => 'Notifications';
  
  @override
  String get japaProgressNotifications => 'Japa progress notifications';
  
  @override
  String get autoStart => 'Auto Start';
  
  @override
  String get japaTimeReminders => 'Japa time reminders';
  
  @override
  String get dailyReminder => 'Daily Reminder';
  
  @override
  String get setJapaTime => 'Set time for japa';
  
  @override
  String get japaSchedule => 'Japa Schedule';
  
  @override
  String get setMultipleTimes => 'Set multiple times';
  
  @override
  String get soundAndVibration => 'Sound and Vibration';
  
  @override
  String get vibration => 'Vibration';
  
  @override
  String get beadClickVibration => 'Vibration when clicking beads';
  
  @override
  String get sound => 'Sound';
  
  @override
  String get soundEffects => 'Sound effects';
  
  @override
  String get japaSounds => 'Japa Sounds';
  
  @override
  String get configureSounds => 'Configure sounds for different events';
  
  @override
  String get aiAssistantSection => 'AI Assistant';
  
  @override
  String get aiStatus => 'AI Status';
  
  @override
  String get checkMozgachAvailability => 'Check mozgach:latest availability';
  
  @override
  String get aiSettings => 'AI Settings';
  
  @override
  String get aiAssistantParameters => 'AI assistant parameters';
  
  @override
  String get aiStatistics => 'AI Statistics';
  
  @override
  String get aiAssistantUsage => 'AI assistant usage';
  
  @override
  String get statisticsAndData => 'Statistics and Data';
  
  @override
  String get overallStatistics => 'Overall Statistics';
  
  @override
  String get viewAllAchievements => 'View all achievements';
  
  @override
  String get dataExport => 'Data Export';
  
  @override
  String get saveDataToDevice => 'Save data to device';
  
  @override
  String get clearData => 'Clear Data';
  
  @override
  String get deleteAllSavedData => 'Delete all saved data';
  
  @override
  String get aboutApp => 'About App';
  
  @override
  String get version => 'Version';
  
  @override
  String get license => 'License';
  
  @override
  String get openSource => 'Open source';
  
  @override
  String get developers => 'Developers';
  
  @override
  String get aiJapaTeam => 'AI Japa Mahamantra Team';
  
  @override
  String get cancel => 'Cancel';
  
  @override
  String get close => 'Close';
  
  @override
  String get set => 'Set';
  
  @override
  String get configure => 'Configure';
  
  @override
  String get delete => 'Delete';
  
  @override
  String get export => 'Export';
  
  @override
  String get totalSessions => 'Total Sessions';
  
  @override
  String get totalRounds => 'Total Rounds';
  
  @override
  String get totalTime => 'Total Time';
  
  @override
  String get averageRoundsPerSession => 'Average rounds per session';
  
  @override
  String get averageTimePerSession => 'Average time per session';
  
  @override
  String get hours => 'h';
  
  @override
  String get minutesShort => 'm';
  
  @override
  String get language => 'Language';
  
  @override
  String get selectLanguage => 'Select Language';
  
  @override
  String get harkonnen => 'Harkonnen';
  
  @override
  String get atreides => 'Atreides';
  
  @override
  String get russian => 'Russian';
  
  @override
  String get harkonnenDescription => 'The language of House Harkonnen - harsh and direct';
  
  @override
  String get atreidesDescription => 'The language of House Atreides - noble and refined';
  
  @override
  String get russianDescription => 'Russian language - spiritual and traditional';
  
  @override
  String get mantraFirstFour => 'SRI KRISHNA CHAITANYA PRABHU NITYANANDA SRI VASADI GOURA BHAKTA VRINDA';
  
  @override
  String get mantraHareKrishna => 'Hare Krishna Hare Krishna Krishna Krishna Hare Hare\nHare Rama Hare Rama Rama Rama Hare Hare';
  
  @override
  String get theme => 'Theme';
  
  @override
  String get darkTheme => 'Dark Theme';
  
  @override
  String get lightTheme => 'Light Theme';
  
  @override
  String get themeDescription => 'Switch between light and dark theme';
  
  @override
  List<String> get spiritualCategories => [
    'Bhakti Yoga',
    'Karma Yoga',
    'Jnana Yoga',
    'Raja Yoga',
    'Vedic Philosophy',
    'Sacred Scriptures',
    'Spiritual Practice',
    'Meditation',
    'Mantras',
    'General Questions'
  ];
  
  @override
  List<String> get spiritualQuestionHints => [
    'How to properly read japa?',
    'What does the Hare Krishna mahamantra mean?',
    'How to develop bhakti?',
    'What is karma and how to be free from it?',
    'How to meditate on Krishna?',
    'What is maya?',
    'How to achieve self-realization?',
    'What is guru-parampara?',
    'How to understand Bhagavad-gita?',
    'What is prema?'
  ];
}

// Харконненская локализация
class AppLocalizationsHarkonnen extends AppLocalizations {
  @override
  String get appTitle => 'AI ДЖАПА МАХАМАНТРА';
  
  @override
  String get settings => 'НАСТРОЙКИ';
  
  @override
  String get japa => 'ДЖАПА';
  
  @override
  String get aiAssistant => 'AI ПОМОЩНИК';
  
  @override
  String get basicSettings => 'ОСНОВНЫЕ НАСТРОЙКИ';
  
  @override
  String get targetRounds => 'ЦЕЛЕВЫЕ КРУГИ';
  
  @override
  String get rounds => 'кругов';
  
  @override
  String get timePerRound => 'ВРЕМЯ НА КРУГ';
  
  @override
  String get minutes => 'минут';
  
  @override
  String get maxRoundsPerDay => 'МАКСИМУМ КРУГОВ В ДЕНЬ';
  
  @override
  String get notRecommendedToExceed => 'НЕ РЕКОМЕНДУЕТСЯ ПРЕВЫШАТЬ';
  
  @override
  String get notificationsAndReminders => 'УВЕДОМЛЕНИЯ И НАПОМИНАНИЯ';
  
  @override
  String get notifications => 'УВЕДОМЛЕНИЯ';
  
  @override
  String get japaProgressNotifications => 'Уведомления о прогрессе джапы';
  
  @override
  String get autoStart => 'АВТОЗАПУСК';
  
  @override
  String get japaTimeReminders => 'Напоминания о времени джапы';
  
  @override
  String get dailyReminder => 'ЕЖЕДНЕВНОЕ НАПОМИНАНИЕ';
  
  @override
  String get setJapaTime => 'Установить время для джапы';
  
  @override
  String get japaSchedule => 'РАСПИСАНИЕ ДЖАПЫ';
  
  @override
  String get setMultipleTimes => 'Настроить несколько времен';
  
  @override
  String get soundAndVibration => 'ЗВУК И ВИБРАЦИЯ';
  
  @override
  String get vibration => 'ВИБРАЦИЯ';
  
  @override
  String get beadClickVibration => 'Вибрация при нажатии на бусины';
  
  @override
  String get sound => 'ЗВУК';
  
  @override
  String get soundEffects => 'Звуковые эффекты';
  
  @override
  String get japaSounds => 'ЗВУКИ ДЖАПЫ';
  
  @override
  String get configureSounds => 'Настроить звуки для разных событий';
  
  @override
  String get aiAssistantSection => 'AI ПОМОЩНИК';
  
  @override
  String get aiStatus => 'СТАТУС AI';
  
  @override
  String get checkMozgachAvailability => 'Проверить доступность mozgach:latest';
  
  @override
  String get aiSettings => 'НАСТРОЙКИ AI';
  
  @override
  String get aiAssistantParameters => 'Параметры AI помощника';
  
  @override
  String get aiStatistics => 'СТАТИСТИКА AI';
  
  @override
  String get aiAssistantUsage => 'Использование AI помощника';
  
  @override
  String get statisticsAndData => 'СТАТИСТИКА И ДАННЫЕ';
  
  @override
  String get overallStatistics => 'ОБЩАЯ СТАТИСТИКА';
  
  @override
  String get viewAllAchievements => 'Просмотр всех достижений';
  
  @override
  String get dataExport => 'ЭКСПОРТ ДАННЫХ';
  
  @override
  String get saveDataToDevice => 'Сохранить данные на устройство';
  
  @override
  String get clearData => 'ОЧИСТИТЬ ДАННЫЕ';
  
  @override
  String get deleteAllSavedData => 'Удалить все сохраненные данные';
  
  @override
  String get aboutApp => 'О ПРИЛОЖЕНИИ';
  
  @override
  String get version => 'ВЕРСИЯ';
  
  @override
  String get license => 'ЛИЦЕНЗИЯ';
  
  @override
  String get openSource => 'Открытый исходный код';
  
  @override
  String get developers => 'РАЗРАБОТЧИКИ';
  
  @override
  String get aiJapaTeam => 'Команда AI Джапа Махамантра';
  
  @override
  String get cancel => 'ОТМЕНА';
  
  @override
  String get close => 'ЗАКРЫТЬ';
  
  @override
  String get set => 'УСТАНОВИТЬ';
  
  @override
  String get configure => 'НАСТРОИТЬ';
  
  @override
  String get delete => 'УДАЛИТЬ';
  
  @override
  String get export => 'ЭКСПОРТ';
  
  @override
  String get totalSessions => 'ВСЕГО СЕССИЙ';
  
  @override
  String get totalRounds => 'ВСЕГО КРУГОВ';
  
  @override
  String get totalTime => 'ОБЩЕЕ ВРЕМЯ';
  
  @override
  String get averageRoundsPerSession => 'Среднее кругов за сессию';
  
  @override
  String get averageTimePerSession => 'Среднее время сессии';
  
  @override
  String get hours => 'ч';
  
  @override
  String get minutesShort => 'м';
  
  @override
  String get language => 'ЯЗЫК';
  
  @override
  String get selectLanguage => 'ВЫБРАТЬ ЯЗЫК';
  
  @override
  String get harkonnen => 'ХАРКОННЕН';
  
  @override
  String get atreides => 'АТРЕЙДЕС';
  
  @override
  String get russian => 'РУССКИЙ';
  
  @override
  String get harkonnenDescription => 'Язык Дома Харконнен - суровый и прямолинейный';
  
  @override
  String get atreidesDescription => 'Язык Дома Атрейдес - благородный и утонченный';
  
  @override
  String get russianDescription => 'Русский язык - духовный и традиционный';
  
  @override
  String get mantraFirstFour => 'ШРИ КРИШНА ЧАЙТАНЬЯ ПРАБХУ НИТЬЯНАНДА ШРИ ВАСАДИ ГОУРА БХАКТА ВРИНДА';
  
  @override
  String get mantraHareKrishna => 'ХАРЕ КРИШНА ХАРЕ КРИШНА КРИШНА КРИШНА ХАРЕ ХАРЕ\nХАРЕ РАМА ХАРЕ РАМА РАМА РАМА ХАРЕ ХАРЕ';
  
  @override
  String get theme => 'ТЕМА';
  
  @override
  String get darkTheme => 'ТЕМНАЯ ТЕМА';
  
  @override
  String get lightTheme => 'СВЕТЛАЯ ТЕМА';
  
  @override
  String get themeDescription => 'Переключить между светлой и темной темой';
  
  @override
  List<String> get spiritualCategories => [
    'БХАКТИ-ЙОГА',
    'КАРМА-ЙОГА',
    'ДЖНЯНА-ЙОГА',
    'РАДЖА-ЙОГА',
    'ВЕДИЧЕСКАЯ ФИЛОСОФИЯ',
    'СВЯЩЕННЫЕ ПИСАНИЯ',
    'ДУХОВНАЯ ПРАКТИКА',
    'МЕДИТАЦИЯ',
    'МАНТРЫ',
    'ОБЩИЕ ВОПРОСЫ'
  ];
  
  @override
  List<String> get spiritualQuestionHints => [
    'Как правильно читать джапу?',
    'Что означает махамантра Харе Кришна?',
    'Как развить бхакти?',
    'Что такое карма и как от неё освободиться?',
    'Как медитировать на Кришну?',
    'Что такое майя?',
    'Как достичь самоосознания?',
    'Что такое гуру-парампара?',
    'Как понять Бхагавад-гиту?',
    'Что такое према?'
  ];
}
