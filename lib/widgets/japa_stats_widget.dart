import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class JapaStatsWidget extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final int currentBead;
  final int totalBeads;
  final Duration sessionDuration;

  const JapaStatsWidget({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.currentBead,
    required this.totalBeads,
    required this.sessionDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Color(AppConstants.surfaceColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок
          Text(
            'Прогресс сессии',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.primaryColor),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Основная статистика
          Row(
            children: [
              // Прогресс кругов
              Expanded(
                child: _buildProgressCard(
                  title: 'Круги',
                  current: currentRound,
                  total: totalRounds,
                  icon: Icons.refresh,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
              
              const SizedBox(width: AppConstants.smallPadding),
              
              // Прогресс бусин
              Expanded(
                child: _buildProgressCard(
                  title: 'Бусины',
                  current: currentBead,
                  total: totalBeads,
                  icon: Icons.beads,
                  color: Color(AppConstants.accentColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Время сессии
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: Color(AppConstants.backgroundColor),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: Color(AppConstants.primaryColor),
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Время сессии: ${_formatDuration(sessionDuration)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Прогресс-бар общего прогресса
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Общий прогресс',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _calculateOverallProgress(),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(AppConstants.primaryColor),
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(
                '${_calculateOverallProgressPercentage()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required int current,
    required int total,
    required IconData icon,
    required Color color,
  }) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$current / $total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  /// Форматирует длительность в читаемый вид
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Вычисляет общий прогресс сессии
  double _calculateOverallProgress() {
    if (totalRounds == 0) return 0.0;
    
    final roundProgress = currentRound / totalRounds;
    final beadProgress = currentBead / totalBeads;
    
    // Общий прогресс учитывает и круги, и бусины
    return (roundProgress + beadProgress) / 2;
  }

  /// Вычисляет процент общего прогресса
  int _calculateOverallProgressPercentage() {
    return (_calculateOverallProgress() * 100).round();
  }
}
