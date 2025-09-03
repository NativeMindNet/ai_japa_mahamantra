class AppConstants {
  // Махамантра для первых 4 бусин
  static const String firstFourBeadsMantra = 
      "ШРИ КРИШНА ЧАЙТАНЬЯ ПРАБХУ НИТЬЯНАНДА ШРИ ВАСАДИ ГОУРА БАХТА ВРИНДА";
  
  // Основная махамантра Харе Кришна
  static const String hareKrishnaMantra = 
      "Харе Кришна Харе Кришна Кришна Кришна Харе Харе\n"
      "Харе Рама Харе Рама Рама Рама Харе Харе";
  
  // Количество бусин в джапа-мале (без нулевой)
  static const int totalBeads = 108;
  
  // Рекомендуемые количества кругов
  static const List<int> recommendedRounds = [2, 4, 16, 64];
  
  // Максимальное количество кругов в день
  static const int maxRoundsPerDay = 64;
  
  // Время на один круг (примерно)
  static const int minutesPerRound = 15;
  
  // Категории духовных вопросов
  static const List<String> spiritualCategories = [
    'Бхакти-йога',
    'Карма-йога',
    'Джняна-йога',
    'Раджа-йога',
    'Ведическая философия',
    'Священные писания',
    'Духовная практика',
    'Медитация',
    'Мантры',
    'Общие вопросы',
  ];
  
  // Подсказки для духовных вопросов
  static const List<String> spiritualQuestionHints = [
    'Как правильно читать джапу?',
    'Что означает махамантра Харе Кришна?',
    'Как развить бхакти?',
    'Что такое карма и как от неё освободиться?',
    'Как медитировать на Кришну?',
    'Что такое майя?',
    'Как достичь самоосознания?',
    'Что такое гуру-парампара?',
    'Как понять Бхагавад-гиту?',
    'Что такое према?',
  ];
  
  // Цвета приложения
  static const int primaryColor = 0xFF8E24AA; // Фиолетовый
  static const int accentColor = 0xFFFF9800;  // Оранжевый
  static const int backgroundColor = 0xFFF5F5F5;
  static const int surfaceColor = 0xFFFFFFFF;
  static const int errorColor = 0xFFD32F2F;
  static const int successColor = 0xFF388E3C;
  
  // Размеры
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  
  // Анимации
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // Звуки
  static const String beadClickSound = 'bead_click.mp3';
  static const String roundCompleteSound = 'round_complete.mp3';
  static const String sessionCompleteSound = 'session_complete.mp3';
  
  // Вибрации
  static const int shortVibration = 50;
  static const int mediumVibration = 100;
  static const int longVibration = 200;
}
