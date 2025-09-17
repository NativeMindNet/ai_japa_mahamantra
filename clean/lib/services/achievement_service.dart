import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/japa_session.dart';

/// Сервис для управления достижениями
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  static const String _achievementsKey = 'achievements';
  static const String _progressKey = 'achievement_progress';
  static const String _statsKey = 'achievement_stats';

  List<Achievement> _achievements = [];
  Map<String, AchievementProgress> _progress = {};
  AchievementStats? _stats;

  /// Инициализирует сервис достижений
  Future<void> initialize() async {
    await _loadAchievements();
    await _loadProgress();
    await _loadStats();
    
    // Создаем базовые достижения, если их нет
    if (_achievements.isEmpty) {
      await _createDefaultAchievements();
    }
  }

  /// Загружает достижения из локального хранилища
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      
      if (achievementsJson != null) {
        final List<dynamic> achievementsList = json.decode(achievementsJson);
        _achievements = achievementsList
            .map((json) => Achievement.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Ошибка загрузки достижений: $e');
    }
  }

  /// Загружает прогресс достижений
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      
      if (progressJson != null) {
        final Map<String, dynamic> progressMap = json.decode(progressJson);
        _progress = progressMap.map(
          (key, value) => MapEntry(key, AchievementProgress.fromJson(value)),
        );
      }
    } catch (e) {
      print('Ошибка загрузки прогресса достижений: $e');
    }
  }

  /// Загружает статистику достижений
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      
      if (statsJson != null) {
        _stats = AchievementStats.fromJson(json.decode(statsJson));
      }
    } catch (e) {
      print('Ошибка загрузки статистики достижений: $e');
    }
  }

  /// Сохраняет достижения в локальное хранилище
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = json.encode(
        _achievements.map((achievement) => achievement.toJson()).toList(),
      );
      await prefs.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Ошибка сохранения достижений: $e');
    }
  }

  /// Сохраняет прогресс достижений
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(
        _progress.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_progressKey, progressJson);
    } catch (e) {
      print('Ошибка сохранения прогресса достижений: $e');
    }
  }

  /// Сохраняет статистику достижений
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_stats != null) {
        final statsJson = json.encode(_stats!.toJson());
        await prefs.setString(_statsKey, statsJson);
      }
    } catch (e) {
      print('Ошибка сохранения статистики достижений: $e');
    }
  }

  /// Создает базовые достижения
  Future<void> _createDefaultAchievements() async {
    _achievements = [
      // Достижения по количеству сессий
      Achievement(
        id: 'first_session',
        title: 'Первые шаги',
        description: 'Завершите свою первую сессию джапы',
        type: AchievementType.sessionCount,
        rarity: AchievementRarity.common,
        icon: '🎯',
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_first_session'],
        metadata: {'category': 'beginner'},
      ),
      
      Achievement(
        id: 'dedicated_practitioner',
        title: 'Преданный практик',
        description: 'Завершите 10 сессий джапы',
        type: AchievementType.sessionCount,
        rarity: AchievementRarity.rare,
        icon: '🕉️',
        targetValue: 10,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_dedicated', 'title_practitioner'],
        metadata: {'category': 'dedication'},
      ),
      
      Achievement(
        id: 'japa_master',
        title: 'Мастер джапы',
        description: 'Завершите 100 сессий джапы',
        type: AchievementType.sessionCount,
        rarity: AchievementRarity.epic,
        icon: '👑',
        targetValue: 100,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_master', 'title_master', 'unlock_special_sounds'],
        metadata: {'category': 'mastery'},
      ),
      
      // Достижения по количеству кругов
      Achievement(
        id: 'first_round',
        title: 'Первый круг',
        description: 'Завершите свой первый круг джапы',
        type: AchievementType.roundCount,
        rarity: AchievementRarity.common,
        icon: '🔄',
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_first_round'],
        metadata: {'category': 'beginner'},
      ),
      
      Achievement(
        id: 'hundred_rounds',
        title: 'Сотня кругов',
        description: 'Завершите 100 кругов джапы',
        type: AchievementType.roundCount,
        rarity: AchievementRarity.rare,
        icon: '💯',
        targetValue: 100,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_hundred', 'title_centurion'],
        metadata: {'category': 'milestone'},
      ),
      
      Achievement(
        id: 'thousand_rounds',
        title: 'Тысяча кругов',
        description: 'Завершите 1000 кругов джапы',
        type: AchievementType.roundCount,
        rarity: AchievementRarity.legendary,
        icon: '🌟',
        targetValue: 1000,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_thousand', 'title_legend', 'unlock_golden_theme'],
        metadata: {'category': 'legendary'},
      ),
      
      // Достижения по времени
      Achievement(
        id: 'one_hour',
        title: 'Час медитации',
        description: 'Проведите в общей сложности 1 час в джапе',
        type: AchievementType.timeSpent,
        rarity: AchievementRarity.common,
        icon: '⏰',
        targetValue: 3600, // 1 час в секундах
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_one_hour'],
        metadata: {'category': 'time'},
      ),
      
      Achievement(
        id: 'ten_hours',
        title: 'Десять часов',
        description: 'Проведите в общей сложности 10 часов в джапе',
        type: AchievementType.timeSpent,
        rarity: AchievementRarity.rare,
        icon: '🕐',
        targetValue: 36000, // 10 часов в секундах
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_ten_hours', 'title_time_keeper'],
        metadata: {'category': 'time'},
      ),
      
      Achievement(
        id: 'hundred_hours',
        title: 'Сто часов',
        description: 'Проведите в общей сложности 100 часов в джапе',
        type: AchievementType.timeSpent,
        rarity: AchievementRarity.epic,
        icon: '⏳',
        targetValue: 360000, // 100 часов в секундах
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_hundred_hours', 'title_time_master', 'unlock_meditation_timer'],
        metadata: {'category': 'time'},
      ),
      
      // Достижения по сериям
      Achievement(
        id: 'three_day_streak',
        title: 'Трехдневная серия',
        description: 'Практикуйте джапу 3 дня подряд',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        icon: '🔥',
        targetValue: 3,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_three_day'],
        metadata: {'category': 'streak'},
      ),
      
      Achievement(
        id: 'week_streak',
        title: 'Недельная серия',
        description: 'Практикуйте джапу 7 дней подряд',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        icon: '📅',
        targetValue: 7,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_week', 'title_consistent'],
        metadata: {'category': 'streak'},
      ),
      
      Achievement(
        id: 'month_streak',
        title: 'Месячная серия',
        description: 'Практикуйте джапу 30 дней подряд',
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        icon: '🗓️',
        targetValue: 30,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_month', 'title_unstoppable', 'unlock_daily_reminder'],
        metadata: {'category': 'streak'},
      ),
      
      // Специальные достижения
      Achievement(
        id: 'early_bird',
        title: 'Ранняя пташка',
        description: 'Практикуйте джапу до 6 утра',
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        icon: '🌅',
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_early_bird', 'title_morning_practitioner'],
        metadata: {'category': 'special', 'time_requirement': 'before_6am'},
      ),
      
      Achievement(
        id: 'night_owl',
        title: 'Ночная сова',
        description: 'Практикуйте джапу после 10 вечера',
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        icon: '🌙',
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_night_owl', 'title_evening_practitioner'],
        metadata: {'category': 'special', 'time_requirement': 'after_10pm'},
      ),
      
      Achievement(
        id: 'perfect_session',
        title: 'Идеальная сессия',
        description: 'Завершите сессию без пауз',
        type: AchievementType.special,
        rarity: AchievementRarity.epic,
        icon: '✨',
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        rewards: ['badge_perfect', 'title_flawless'],
        metadata: {'category': 'special', 'requirement': 'no_pauses'},
      ),
    ];
    
    await _saveAchievements();
  }

  /// Обновляет прогресс достижений на основе сессии джапы
  Future<List<Achievement>> updateProgressFromSession(JapaSession session) async {
    final List<Achievement> newlyUnlocked = [];
    
    for (final achievement in _achievements) {
      if (achievement.isUnlocked) continue;
      
      int newValue = achievement.currentValue;
      bool shouldUnlock = false;
      
      switch (achievement.type) {
        case AchievementType.sessionCount:
          newValue++;
          break;
        case AchievementType.roundCount:
          newValue += session.completedRounds;
          break;
        case AchievementType.timeSpent:
          newValue += session.duration.inSeconds;
          break;
        case AchievementType.streak:
          // Логика для серий будет реализована отдельно
          break;
        case AchievementType.special:
          // Специальная логика для каждого достижения
          if (achievement.id == 'early_bird' && _isEarlyMorning(session.startTime)) {
            newValue = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'night_owl' && _isLateEvening(session.startTime)) {
            newValue = 1;
            shouldUnlock = true;
          } else if (achievement.id == 'perfect_session' && !session.wasPaused) {
            newValue = 1;
            shouldUnlock = true;
          }
          break;
      }
      
      // Проверяем, достигнуто ли достижение
      if (newValue >= achievement.targetValue || shouldUnlock) {
        final updatedAchievement = achievement.copyWith(
          currentValue: newValue,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        
        _achievements[_achievements.indexWhere((a) => a.id == achievement.id)] = updatedAchievement;
        newlyUnlocked.add(updatedAchievement);
        
        // Обновляем прогресс
        _progress[achievement.id] = AchievementProgress(
          achievementId: achievement.id,
          currentValue: newValue,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
      } else {
        // Обновляем только прогресс
        _achievements[_achievements.indexWhere((a) => a.id == achievement.id)] = 
            achievement.copyWith(currentValue: newValue);
        
        _progress[achievement.id] = AchievementProgress(
          achievementId: achievement.id,
          currentValue: newValue,
          isUnlocked: false,
          lastUpdated: DateTime.now(),
        );
      }
    }
    
    await _saveAchievements();
    await _saveProgress();
    await _updateStats();
    
    return newlyUnlocked;
  }

  /// Проверяет, является ли время ранним утром
  bool _isEarlyMorning(DateTime time) {
    return time.hour < 6;
  }

  /// Проверяет, является ли время поздним вечером
  bool _isLateEvening(DateTime time) {
    return time.hour >= 22;
  }

  /// Обновляет статистику достижений
  Future<void> _updateStats() async {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    
    _stats = AchievementStats(
      totalAchievements: _achievements.length,
      unlockedAchievements: unlockedAchievements.length,
      commonCount: unlockedAchievements.where((a) => a.rarity == AchievementRarity.common).length,
      rareCount: unlockedAchievements.where((a) => a.rarity == AchievementRarity.rare).length,
      epicCount: unlockedAchievements.where((a) => a.rarity == AchievementRarity.epic).length,
      legendaryCount: unlockedAchievements.where((a) => a.rarity == AchievementRarity.legendary).length,
      completionPercentage: _achievements.isNotEmpty 
          ? (unlockedAchievements.length / _achievements.length) * 100 
          : 0.0,
      recentUnlocks: unlockedAchievements
          .where((a) => a.unlockedAt != null)
          .toList()
          ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!))
          .take(5)
          .map((a) => a.id)
          .toList(),
      typeCounts: {
        for (final type in AchievementType.values)
          type: unlockedAchievements.where((a) => a.type == type).length,
      },
    );
    
    await _saveStats();
  }

  /// Получает все достижения
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  /// Получает разблокированные достижения
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();

  /// Получает заблокированные достижения
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();

  /// Получает достижения по типу
  List<Achievement> getAchievementsByType(AchievementType type) =>
      _achievements.where((a) => a.type == type).toList();

  /// Получает достижения по редкости
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) =>
      _achievements.where((a) => a.rarity == rarity).toList();

  /// Получает достижение по ID
  Achievement? getAchievementById(String id) =>
      _achievements.firstWhere((a) => a.id == id, orElse: () => throw StateError('Achievement not found'));

  /// Получает статистику достижений
  AchievementStats? get stats => _stats;

  /// Получает прогресс достижения
  AchievementProgress? getProgress(String achievementId) => _progress[achievementId];

  /// Сбрасывает все достижения (для тестирования)
  Future<void> resetAchievements() async {
    _achievements.clear();
    _progress.clear();
    _stats = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_statsKey);
    
    await _createDefaultAchievements();
  }
}
