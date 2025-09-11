import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../constants/app_constants.dart';
import '../widgets/modern_ui_components.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AchievementService _achievementService = AchievementService();
  
  List<Achievement> _achievements = [];
  AchievementStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _achievementService.initialize();
      _achievements = _achievementService.achievements;
      _stats = _achievementService.stats;
    } catch (e) {
      // silent
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все', icon: Icon(Icons.all_inclusive)),
            Tab(text: 'Разблокированные', icon: Icon(Icons.lock_open)),
            Tab(text: 'Заблокированные', icon: Icon(Icons.lock)),
            Tab(text: 'Статистика', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? ModernUIComponents.modernLoadingIndicator(
              message: 'Загрузка достижений...',
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllAchievementsTab(),
                _buildUnlockedAchievementsTab(),
                _buildLockedAchievementsTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }

  Widget _buildAllAchievementsTab() {
    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final achievement = _achievements[index];
          return _buildAchievementCard(achievement);
        },
      ),
    );
  }

  Widget _buildUnlockedAchievementsTab() {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    
    if (unlockedAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нет разблокированных достижений',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Практикуйте джапу, чтобы разблокировать достижения!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: unlockedAchievements.length,
        itemBuilder: (context, index) {
          final achievement = unlockedAchievements[index];
          return _buildAchievementCard(achievement);
        },
      ),
    );
  }

  Widget _buildLockedAchievementsTab() {
    final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();
    
    if (lockedAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Поздравляем!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Вы разблокировали все достижения!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: lockedAchievements.length,
        itemBuilder: (context, index) {
          final achievement = lockedAchievements[index];
          return _buildAchievementCard(achievement);
        },
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) {
      return Center(
        child: ModernUIComponents.modernLoadingIndicator(
          message: 'Загрузка статистики...',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Общая статистика
          ModernUIComponents.gradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernUIComponents.modernSectionHeader(
                  title: 'Общая статистика',
                  subtitle: 'Ваш прогресс в достижениях',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Всего достижений',
                        '${_stats!.totalAchievements}',
                        Icons.emoji_events,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Разблокировано',
                        '${_stats!.unlockedAchievements}',
                        Icons.lock_open,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ModernUIComponents.modernProgressIndicator(
                  value: _stats!.completionPercentage / 100,
                  label: 'Прогресс: ${_stats!.completionPercentage.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Статистика по редкости
          ModernUIComponents.gradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernUIComponents.modernSectionHeader(
                  title: 'По редкости',
                  subtitle: 'Разблокированные достижения по категориям',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRarityStatCard(
                        'Обычные',
                        '${_stats!.commonCount}',
                        AchievementRarity.common,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRarityStatCard(
                        'Редкие',
                        '${_stats!.rareCount}',
                        AchievementRarity.rare,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRarityStatCard(
                        'Эпические',
                        '${_stats!.epicCount}',
                        AchievementRarity.epic,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRarityStatCard(
                        'Легендарные',
                        '${_stats!.legendaryCount}',
                        AchievementRarity.legendary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Статистика по типам
          ModernUIComponents.gradientCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernUIComponents.modernSectionHeader(
                  title: 'По типам',
                  subtitle: 'Достижения по категориям',
                ),
                const SizedBox(height: 16),
                ...AchievementType.values.map((type) {
                  final count = _stats!.typeCounts[type] ?? 0;
                  return _buildTypeStatCard(type, count);
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Недавние разблокировки
          if (_stats!.recentUnlocks.isNotEmpty)
            ModernUIComponents.gradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernUIComponents.modernSectionHeader(
                    title: 'Недавние разблокировки',
                    subtitle: 'Последние достижения',
                  ),
                  const SizedBox(height: 16),
                  ..._stats!.recentUnlocks.map((achievementId) {
                    final achievement = _achievements.firstWhere(
                      (a) => a.id == achievementId,
                      orElse: () => throw StateError('Achievement not found'),
                    );
                    return _buildRecentAchievementCard(achievement);
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return ModernUIComponents.gradientCard(
      gradientColors: achievement.isUnlocked
          ? [
              Color(int.parse(achievement.rarityColor.replaceFirst('#', '0xFF'))),
              Color(int.parse(achievement.rarityColor.replaceFirst('#', '0xFF'))).withAlpha(204),
            ]
          : [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(204),
            ],
      child: Row(
        children: [
          // Иконка достижения
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? Colors.white.withAlpha(51)
                  : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Информация о достижении
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: achievement.isUnlocked
                        ? Colors.white.withAlpha(230)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ModernUIComponents.modernBadge(
                      text: achievement.rarityName,
                      backgroundColor: achievement.isUnlocked
                          ? Colors.white.withAlpha(51)
                          : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(25),
                      textColor: achievement.isUnlocked
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    if (achievement.isUnlocked && achievement.unlockedAt != null)
                      ModernUIComponents.modernBadge(
                        text: 'Разблокировано',
                        backgroundColor: Colors.green.withAlpha(51),
                        textColor: Colors.green,
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Прогресс
          Column(
            children: [
              Text(
                '${achievement.currentValue}/${achievement.targetValue}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 60,
                child: ModernUIComponents.modernProgressIndicator(
                  value: achievement.progress,
                  height: 4,
                  backgroundColor: achievement.isUnlocked
                      ? Colors.white.withAlpha(76)
                      : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(76),
                  progressColor: achievement.isUnlocked
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRarityStatCard(String title, String value, AchievementRarity rarity) {
    final achievement = Achievement(
      id: '',
      title: '',
      description: '',
      type: AchievementType.sessionCount,
      rarity: rarity,
      icon: '',
      targetValue: 0,
      currentValue: 0,
      isUnlocked: false,
      rewards: [],
      metadata: {},
    );
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(int.parse(achievement.rarityColor.replaceFirst('#', '0xFF'))).withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Color(int.parse(achievement.rarityColor.replaceFirst('#', '0xFF'))).withAlpha(76),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(int.parse(achievement.rarityColor.replaceFirst('#', '0xFF'))),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStatCard(AchievementType type, int count) {
    String typeName;
    IconData icon;
    
    switch (type) {
      case AchievementType.sessionCount:
        typeName = 'Сессии';
        icon = Icons.play_circle;
        break;
      case AchievementType.roundCount:
        typeName = 'Круги';
        icon = Icons.refresh;
        break;
      case AchievementType.timeSpent:
        typeName = 'Время';
        icon = Icons.timer;
        break;
      case AchievementType.streak:
        typeName = 'Серии';
        icon = Icons.local_fire_department;
        break;
      case AchievementType.special:
        typeName = 'Специальные';
        icon = Icons.star;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              typeName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievementCard(Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            achievement.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (achievement.unlockedAt != null)
                  Text(
                    'Разблокировано ${_formatDate(achievement.unlockedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'только что';
    }
  }
}
