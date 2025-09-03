import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/japa_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/japa_mala_widget.dart';
import '../widgets/japa_controls_widget.dart';
import '../widgets/japa_stats_widget.dart';
import 'ai_assistant_screen.dart';

class JapaScreen extends StatefulWidget {
  const JapaScreen({super.key});

  @override
  State<JapaScreen> createState() => _JapaScreenState();
}

class _JapaScreenState extends State<JapaScreen> with TickerProviderStateMixin {
  late AnimationController _malaAnimationController;
  late AnimationController _mantraAnimationController;
  late Animation<double> _malaScaleAnimation;
  late Animation<double> _mantraFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _malaAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _mantraAnimationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _malaScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _malaAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _mantraFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mantraAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Запускаем анимации
    _malaAnimationController.forward();
    _mantraAnimationController.forward();
  }

  @override
  void dispose() {
    _malaAnimationController.dispose();
    _mantraAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text(
          'AI Джапа Махамантра',
          style: TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIAssistantScreen(),
                ),
              );
            },
            tooltip: 'AI Помощник',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showHistoryDialog();
            },
            tooltip: 'История сессий',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Consumer<JapaProvider>(
        builder: (context, japaProvider, child) {
          return Column(
            children: [
              // Статистика текущей сессии
              Expanded(
                flex: 2,
                child: JapaStatsWidget(
                  currentRound: japaProvider.currentRound,
                  totalRounds: japaProvider.targetRounds,
                  currentBead: japaProvider.currentBead,
                  totalBeads: AppConstants.totalBeads,
                  sessionDuration: japaProvider.sessionDuration,
                ),
              ),
              
              // Визуализация малы
              Expanded(
                flex: 4,
                child: ScaleTransition(
                  scale: _malaScaleAnimation,
                  child: JapaMalaWidget(
                    currentBead: japaProvider.currentBead,
                    totalBeads: AppConstants.totalBeads,
                    onBeadTap: (beadIndex) {
                      japaProvider.moveToBead(beadIndex);
                    },
                  ),
                ),
              ),
              
              // Отображение мантры
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _mantraFadeAnimation,
                  child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Текущая мантра:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.primaryColor),
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          _getCurrentMantra(japaProvider.currentBead),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Sanskrit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Элементы управления
              Expanded(
                flex: 2,
                child: JapaControlsWidget(
                  isSessionActive: japaProvider.isSessionActive,
                  onStartSession: () {
                    japaProvider.startSession();
                    _malaAnimationController.forward();
                  },
                  onPauseSession: () {
                    japaProvider.pauseSession();
                  },
                  onResumeSession: () {
                    japaProvider.resumeSession();
                  },
                  onCompleteRound: () {
                    japaProvider.completeRound();
                    _malaAnimationController.forward();
                  },
                  onEndSession: () {
                    japaProvider.endSession();
                    _showSessionCompleteDialog();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Возвращает мантру для текущей бусины
  String _getCurrentMantra(int currentBead) {
    if (currentBead <= 4 && currentBead > 0) {
      return AppConstants.firstFourBeadsMantra;
    } else {
      return AppConstants.hareKrishnaMantra;
    }
  }

  /// Показывает диалог завершения сессии
  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Сессия завершена! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(AppConstants.successColor),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Consumer<JapaProvider>(
            builder: (context, japaProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Поздравляем! Вы завершили ${japaProvider.completedRounds} кругов джапы.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Время сессии: ${japaProvider.sessionDuration.inMinutes} минут',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    'Теперь вы можете задать духовные вопросы AI помощнику.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIAssistantScreen(),
                  ),
                );
              },
              child: const Text(
                'Задать вопрос AI',
                style: TextStyle(
                  color: Color(AppConstants.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог истории
  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('История сессий'),
          content: Consumer<JapaProvider>(
            builder: (context, japaProvider, child) {
              final stats = japaProvider.getOverallStats();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Всего сессий: ${stats['totalSessions']}'),
                  Text('Всего кругов: ${stats['totalRounds']}'),
                  Text('Общее время: ${stats['totalTime'].inHours}ч ${stats['totalTime'].inMinutes % 60}м'),
                  Text('Среднее кругов за сессию: ${stats['averageRoundsPerSession']}'),
                  Text('Среднее время сессии: ${stats['averageTimePerSession']} минут'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог настроек
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Настройки'),
          content: Consumer<JapaProvider>(
            builder: (context, japaProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Целевое количество кругов
                  ListTile(
                    title: const Text('Целевые круги'),
                    subtitle: Text('${japaProvider.targetRounds}'),
                    trailing: DropdownButton<int>(
                      value: japaProvider.targetRounds,
                      items: AppConstants.recommendedRounds.map((rounds) {
                        return DropdownMenuItem(
                          value: rounds,
                          child: Text('$rounds'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          japaProvider.setTargetRounds(value);
                        }
                      },
                    ),
                  ),
                  
                  // Вибрация
                  SwitchListTile(
                    title: const Text('Вибрация'),
                    subtitle: const Text('Вибрация при нажатии на бусины'),
                    value: japaProvider.vibrationEnabled,
                    onChanged: (value) {
                      japaProvider.setVibrationEnabled(value);
                    },
                  ),
                  
                  // Звук
                  SwitchListTile(
                    title: const Text('Звук'),
                    subtitle: const Text('Звуковые эффекты'),
                    value: japaProvider.soundEnabled,
                    onChanged: (value) {
                      japaProvider.setSoundEnabled(value);
                    },
                  ),
                  
                  // Уведомления
                  SwitchListTile(
                    title: const Text('Уведомления'),
                    subtitle: const Text('Уведомления о прогрессе'),
                    value: japaProvider.notificationsEnabled,
                    onChanged: (value) {
                      japaProvider.setNotificationsEnabled(value);
                    },
                  ),
                  
                  // Автозапуск
                  SwitchListTile(
                    title: const Text('Автозапуск'),
                    subtitle: const Text('Напоминания о джапе'),
                    value: japaProvider.autoStartEnabled,
                    onChanged: (value) {
                      japaProvider.setAutoStartEnabled(value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}
