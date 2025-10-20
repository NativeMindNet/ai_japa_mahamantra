import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/japa_provider.dart';
import '../providers/locale_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/japa_mala_widget.dart';
import '../widgets/japa_controls_widget.dart';
import '../widgets/japa_stats_widget.dart';
// import '../l10n/app_localizations_delegate.dart';
import '../animations/custom_page_transitions.dart';
import '../widgets/chudny_video_widget.dart';
import 'easter_egg_log_screen.dart';

class JapaScreen extends StatefulWidget {
  const JapaScreen({super.key});

  @override
  State<JapaScreen> createState() => _JapaScreenState();
}

class _JapaScreenState extends State<JapaScreen> with TickerProviderStateMixin {
  late AnimationController _malaAnimationController;
  late AnimationController _mantraAnimationController;
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

    _mantraFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mantraAnimationController,
        curve: Curves.easeInOut,
      ),
    );

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
    // final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'AI Japa Mahamantra',
          style: const TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              localeProvider.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              localeProvider.toggleTheme();
            },
            tooltip: localeProvider.isDarkTheme
                ? 'Светлая тема'
                : 'Темная тема',
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              AnimatedNavigation.toAIAssistant(context);
            },
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              _showChudnyVideo();
            },
            tooltip: 'Мотивация от Чудного',
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
              AnimatedNavigation.toSettings(context);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<JapaProvider>(
        builder: (context, japaProvider, child) {
          // Проверяем активацию Easter Egg
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (japaProvider.checkAndResetEasterEggTrigger()) {
              _openEasterEggScreen();
            }
          });

          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Мантра
                Expanded(flex: 2, child: _buildMantraSection(localeProvider)),

                // Мала
                Expanded(
                  flex: 3,
                  child: JapaMalaWidget(
                    currentBead: japaProvider.currentBead,
                    totalBeads: AppConstants.totalBeads,
                    onBeadTap: (int beadIndex) {
                      japaProvider.nextBead();
                    },
                  ),
                ),

                // Управление
                Expanded(
                  flex: 2,
                  child: JapaControlsWidget(
                    isSessionActive: japaProvider.isSessionActive,
                    onStartSession: () {
                      japaProvider.startSession();
                      _malaAnimationController.forward();
                    },
                    onPauseSession: japaProvider.pauseSession,
                    onResumeSession: japaProvider.resumeSession,
                    onCompleteRound: japaProvider.completeRound,
                    onEndSession: () {
                      japaProvider.endSession();
                      _showSessionCompleteDialog();
                    },
                  ),
                ),

                // Статистика
                Expanded(
                  flex: 1,
                  child: JapaStatsWidget(
                    currentRound: japaProvider.currentRound,
                    totalRounds: japaProvider.targetRounds,
                    currentBead: japaProvider.currentBead,
                    totalBeads: AppConstants.totalBeads,
                    sessionDuration: japaProvider.sessionDuration,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Строит секцию с мантрой
  Widget _buildMantraSection(LocaleProvider localeProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Первые 4 бусины
          if (Provider.of<JapaProvider>(context).currentBead <= 4)
            FadeTransition(
              opacity: _mantraFadeAnimation,
              child: Text(
                'Hare Krishna Hare Krishna',
                style: _getMantraStyle(localeProvider),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: AppConstants.smallPadding),

          // Основная мантра
          FadeTransition(
            opacity: _mantraFadeAnimation,
            child: Text(
              'Krishna Krishna Hare Hare',
              style: _getMantraStyle(localeProvider),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Получает стиль для мантры в зависимости от языка
  TextStyle _getMantraStyle(LocaleProvider localeProvider) {
    final baseStyle = localeProvider.getLanguageStyle();

    if (localeProvider.isHarkonnen) {
      return baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.white,
      );
    } else if (localeProvider.isEnglish) {
      return baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.8,
        color: Colors.white,
      );
    } else {
      // Русский язык
      return baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      );
    }
  }

  /// Открывает экран Easter Egg с логами AI
  void _openEasterEggScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EasterEggLogScreen()));
  }

  /// Показывает диалог истории сессий
  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final japaProvider = Provider.of<JapaProvider>(context, listen: false);
        return AlertDialog(
          title: const Text('История сессий'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: japaProvider.getCombinedSessionHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Ошибка загрузки истории');
              }

              final sessions = snapshot.data ?? [];

              if (sessions.isEmpty) {
                return const Text('История сессий пуста');
              }

              return SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isFromMagento = session['source'] == 'magento';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          isFromMagento ? Icons.cloud : Icons.phone_android,
                          color: isFromMagento ? Colors.blue : Colors.green,
                        ),
                        title: Text('Сессия ${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${session['completedRounds']} кругов, ${session['duration']} минут',
                            ),
                            if (isFromMagento) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Мантра: ${session['mantra'] ?? 'Hare Krishna'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              session['date'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (isFromMagento)
                              const Text(
                                'Облако',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                // Синхронизация с Magento
                final japaProvider = Provider.of<JapaProvider>(
                  context,
                  listen: false,
                );
                await japaProvider.loadFromCloud();
                Navigator.of(context).pop();
                _showHistoryDialog(); // Обновляем диалог
              },
              child: const Text('Синхронизировать'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает видео с Чудным
  void _showChudnyVideo() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: ChudnyMotivationWidget(
              onStartJapa: () {
                Navigator.of(context).pop();
                // Автоматически начинаем джапу после мотивации
                Provider.of<JapaProvider>(
                  context,
                  listen: false,
                ).startSession();
                _malaAnimationController.forward();
              },
              onSkip: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
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
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                AnimatedNavigation.toAIAssistant(context);
              },
              child: const Text(
                'Задать вопрос AI',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
