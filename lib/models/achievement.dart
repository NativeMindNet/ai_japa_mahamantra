import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

/// Типы достижений
enum AchievementType {
  @JsonValue('session_count')
  sessionCount,
  @JsonValue('round_count')
  roundCount,
  @JsonValue('time_spent')
  timeSpent,
  @JsonValue('streak')
  streak,
  @JsonValue('special')
  special,
}

/// Редкость достижения
enum AchievementRarity {
  @JsonValue('common')
  common,
  @JsonValue('rare')
  rare,
  @JsonValue('epic')
  epic,
  @JsonValue('legendary')
  legendary,
}

/// Модель достижения
@JsonSerializable()
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementRarity rarity;
  final String icon;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final List<String> rewards;
  final Map<String, dynamic> metadata;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rarity,
    required this.icon,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.rewards,
    required this.metadata,
  });

  /// Создает копию достижения с обновленными значениями
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    AchievementRarity? rarity,
    String? icon,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    List<String>? rewards,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rewards: rewards ?? this.rewards,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Проверяет, достигнуто ли достижение
  bool get isAchieved => currentValue >= targetValue;

  /// Возвращает прогресс в процентах
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  /// Возвращает цвет достижения в зависимости от редкости
  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return '#4CAF50'; // Зеленый
      case AchievementRarity.rare:
        return '#2196F3'; // Синий
      case AchievementRarity.epic:
        return '#9C27B0'; // Фиолетовый
      case AchievementRarity.legendary:
        return '#FF9800'; // Оранжевый
    }
  }

  /// Возвращает название редкости
  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Обычное';
      case AchievementRarity.rare:
        return 'Редкое';
      case AchievementRarity.epic:
        return 'Эпическое';
      case AchievementRarity.legendary:
        return 'Легендарное';
    }
  }

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, type: $type, rarity: $rarity, isUnlocked: $isUnlocked)';
  }
}

/// Модель прогресса достижения
@JsonSerializable()
class AchievementProgress {
  final String achievementId;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final DateTime lastUpdated;

  const AchievementProgress({
    required this.achievementId,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
    required this.lastUpdated,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) => _$AchievementProgressFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementProgressToJson(this);
}

/// Модель награды
@JsonSerializable()
class Reward {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String type; // 'badge', 'title', 'unlock', 'bonus'
  final Map<String, dynamic> data;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.data,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
  Map<String, dynamic> toJson() => _$RewardToJson(this);
}

/// Модель статистики достижений
@JsonSerializable()
class AchievementStats {
  final int totalAchievements;
  final int unlockedAchievements;
  final int commonCount;
  final int rareCount;
  final int epicCount;
  final int legendaryCount;
  final double completionPercentage;
  final List<String> recentUnlocks;
  final Map<AchievementType, int> typeCounts;

  const AchievementStats({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.commonCount,
    required this.rareCount,
    required this.epicCount,
    required this.legendaryCount,
    required this.completionPercentage,
    required this.recentUnlocks,
    required this.typeCounts,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) => _$AchievementStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementStatsToJson(this);
}
