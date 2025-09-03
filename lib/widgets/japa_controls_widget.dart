import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class JapaControlsWidget extends StatelessWidget {
  final bool isSessionActive;
  final VoidCallback onStartSession;
  final VoidCallback onPauseSession;
  final VoidCallback onResumeSession;
  final VoidCallback onCompleteRound;
  final VoidCallback onEndSession;

  const JapaControlsWidget({
    super.key,
    required this.isSessionActive,
    required this.onStartSession,
    required this.onPauseSession,
    required this.onResumeSession,
    required this.onCompleteRound,
    required this.onEndSession,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Основные кнопки управления
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Кнопка старт/пауза/возобновление
              _buildControlButton(
                icon: isSessionActive ? Icons.pause : Icons.play_arrow,
                label: isSessionActive ? 'Пауза' : 'Старт',
                color: isSessionActive 
                    ? Color(AppConstants.errorColor)
                    : Color(AppConstants.successColor),
                onPressed: isSessionActive ? onPauseSession : onStartSession,
              ),
              
              // Кнопка завершения круга
              _buildControlButton(
                icon: Icons.refresh,
                label: 'Круг',
                color: Color(AppConstants.accentColor),
                onPressed: isSessionActive ? onCompleteRound : null,
              ),
              
              // Кнопка завершения сессии
              _buildControlButton(
                icon: Icons.stop,
                label: 'Стоп',
                color: Color(AppConstants.errorColor),
                onPressed: isSessionActive ? onEndSession : null,
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Кнопка возобновления (если сессия на паузе)
          if (isSessionActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResumeSession,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'Возобновить сессию',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppConstants.successColor),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Информация о сессии
          Container(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: Color(AppConstants.backgroundColor),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  icon: Icons.timer,
                  label: 'Время',
                  value: '00:00',
                ),
                _buildInfoItem(
                  icon: Icons.refresh,
                  label: 'Круги',
                  value: '0/16',
                ),
                _buildInfoItem(
                  icon: Icons.circle,
                  label: 'Бусины',
                  value: '0/108',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onPressed != null 
                ? Color(AppConstants.primaryColor)
                : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(AppConstants.primaryColor),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.primaryColor),
          ),
        ),
      ],
    );
  }
}
