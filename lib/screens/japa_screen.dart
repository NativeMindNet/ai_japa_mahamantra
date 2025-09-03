import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/japa_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/japa_mala_widget.dart';
import '../widgets/japa_controls_widget.dart';
import '../widgets/japa_stats_widget.dart';

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
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Открыть историю сессий
            },
            tooltip: 'История сессий',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Открыть настройки
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
                // TODO: Переход к AI помощнику
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
}
