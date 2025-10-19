import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// Модель профиля пользователя для интеграции с Magento
@JsonSerializable()
class UserProfile {
  /// Уникальный идентификатор пользователя в Magento
  @JsonKey(name: 'id')
  final String customerId;

  /// Email пользователя
  final String email;

  /// Имя пользователя
  @JsonKey(name: 'firstname')
  final String firstName;

  /// Фамилия пользователя
  @JsonKey(name: 'lastname')
  final String lastName;

  /// Дата регистрации
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Дата последнего обновления
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Токен доступа
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? accessToken;

  /// Настройки джапы
  final JapaPreferences? japaPreferences;

  /// Статистика пользователя
  final UserStatistics? statistics;

  /// Аватар пользователя (URL)
  final String? avatarUrl;

  /// Часовой пояс
  final String? timezone;

  /// Язык интерфейса
  final String? language;

  UserProfile({
    required this.customerId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.createdAt,
    this.updatedAt,
    this.accessToken,
    this.japaPreferences,
    this.statistics,
    this.avatarUrl,
    this.timezone,
    this.language,
  });

  /// Полное имя пользователя
  String get fullName => '$firstName $lastName';

  /// Копирование с изменениями
  UserProfile copyWith({
    String? customerId,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    JapaPreferences? japaPreferences,
    UserStatistics? statistics,
    String? avatarUrl,
    String? timezone,
    String? language,
  }) {
    return UserProfile(
      customerId: customerId ?? this.customerId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      japaPreferences: japaPreferences ?? this.japaPreferences,
      statistics: statistics ?? this.statistics,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

/// Настройки практики джапы
@JsonSerializable()
class JapaPreferences {
  /// Ежедневная цель (количество мантр)
  final int dailyGoal;

  /// Количество кругов мала
  final int malaRounds;

  /// Напоминания включены
  final bool remindersEnabled;

  /// Время напоминания
  final String? reminderTime;

  /// Звук бусин включен
  final bool beadSoundEnabled;

  /// Вибрация включена
  final bool vibrationEnabled;

  /// Автоматическая синхронизация
  final bool autoSync;

  /// Любимая мантра
  final String? favoriteMantra;

  JapaPreferences({
    this.dailyGoal = 108,
    this.malaRounds = 1,
    this.remindersEnabled = true,
    this.reminderTime,
    this.beadSoundEnabled = true,
    this.vibrationEnabled = true,
    this.autoSync = true,
    this.favoriteMantra,
  });

  JapaPreferences copyWith({
    int? dailyGoal,
    int? malaRounds,
    bool? remindersEnabled,
    String? reminderTime,
    bool? beadSoundEnabled,
    bool? vibrationEnabled,
    bool? autoSync,
    String? favoriteMantra,
  }) {
    return JapaPreferences(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      malaRounds: malaRounds ?? this.malaRounds,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      beadSoundEnabled: beadSoundEnabled ?? this.beadSoundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoSync: autoSync ?? this.autoSync,
      favoriteMantra: favoriteMantra ?? this.favoriteMantra,
    );
  }

  factory JapaPreferences.fromJson(Map<String, dynamic> json) =>
      _$JapaPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$JapaPreferencesToJson(this);
}

/// Статистика пользователя
@JsonSerializable()
class UserStatistics {
  /// Общее количество мантр
  final int totalMantras;

  /// Общее количество сессий
  final int totalSessions;

  /// Текущая серия дней
  final int currentStreak;

  /// Лучшая серия дней
  final int bestStreak;

  /// Общее время практики (минуты)
  final int totalMinutes;

  /// Количество достижений
  final int achievementsCount;

  /// Уровень пользователя
  final int level;

  /// Опыт (XP)
  final int experience;

  /// Рейтинг в глобальной таблице лидеров
  final int? globalRank;

  UserStatistics({
    this.totalMantras = 0,
    this.totalSessions = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalMinutes = 0,
    this.achievementsCount = 0,
    this.level = 1,
    this.experience = 0,
    this.globalRank,
  });

  UserStatistics copyWith({
    int? totalMantras,
    int? totalSessions,
    int? currentStreak,
    int? bestStreak,
    int? totalMinutes,
    int? achievementsCount,
    int? level,
    int? experience,
    int? globalRank,
  }) {
    return UserStatistics(
      totalMantras: totalMantras ?? this.totalMantras,
      totalSessions: totalSessions ?? this.totalSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      achievementsCount: achievementsCount ?? this.achievementsCount,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      globalRank: globalRank ?? this.globalRank,
    );
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);
}

