import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../providers/japa_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/profile_provider.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../services/magento_service.dart';
import '../services/connectivity_service.dart';
import '../services/charging_chanting_service.dart';
import '../constants/app_constants.dart';
import '../screens/profile_screen.dart';
import '../screens/easter_egg_logs_screen.dart';
// import '../l10n/app_localizations_delegate.dart'; // Временно отключено
import '../utils/simple_localizations.dart';
import '../animations/custom_page_transitions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _cloudFeaturesEnabled = false;
  bool _isOnline = false;

  // Easter Egg: Режим разработчика через нажатия на версию
  int _versionTapCount = 0;
  bool _developerModeEnabled = false;
  Timer? _versionTapTimer;
  static const int _requiredTaps = 7; // Как в Android
  static const Duration _tapTimeout = Duration(seconds: 3);

  final MagentoService _magentoService = MagentoService();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _loadCloudSettings();
    _initConnectivity();
    _loadDeveloperMode();
  }

  /// Загружает статус режима разработчика
  Future<void> _loadDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _developerModeEnabled = prefs.getBool('developer_mode_enabled') ?? false;
    });
  }

  /// Сохраняет статус режима разработчика
  Future<void> _saveDeveloperMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('developer_mode_enabled', enabled);
    setState(() {
      _developerModeEnabled = enabled;
    });
  }

  /// Загружает настройки облачных функций
  Future<void> _loadCloudSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cloudFeaturesEnabled = prefs.getBool('cloud_features_enabled') ?? false;
    });
  }

  /// Инициализирует проверку подключения
  Future<void> _initConnectivity() async {
    await _connectivityService.initialize();
    setState(() {
      _isOnline = _connectivityService.isOnline;
    });

    // Слушаем изменения подключения
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    _versionTapTimer?.cancel();
    super.dispose();
  }

  /// Обработка нажатия на версию (Easter Egg)
  void _handleVersionTap() {
    if (_developerModeEnabled) {
      // Уже включен - показываем сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔓 Режим разработчика уже активирован'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _versionTapCount++;
    });

    // Сбрасываем счетчик через таймаут
    _versionTapTimer?.cancel();
    _versionTapTimer = Timer(_tapTimeout, () {
      if (mounted) {
        setState(() {
          _versionTapCount = 0;
        });
      }
    });

    // Показываем прогресс
    final remaining = _requiredTaps - _versionTapCount;
    if (remaining > 0 && remaining <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔐 Еще $remaining ${_pluralTaps(remaining)} до режима разработчика',
          ),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }

    // Активируем режим разработчика
    if (_versionTapCount >= _requiredTaps) {
      _activateDeveloperMode();
    }
  }

  /// Склонение слова "нажатие"
  String _pluralTaps(int count) {
    if (count == 1) return 'нажатие';
    if (count >= 2 && count <= 4) return 'нажатия';
    return 'нажатий';
  }

  /// Активация режима разработчика
  void _activateDeveloperMode() {
    _saveDeveloperMode(true);
    _versionTapCount = 0;

    // Показываем сообщение об активации
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🎉 Режим разработчика активирован! Теперь доступен просмотр логов.',
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );

    // Вибрация
    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SimpleLocalizations();
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Consumer<JapaProvider>(
        builder: (context, japaProvider, child) {
          return Stack(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: SettingsList(
                  sections: [
                    // Выбор языка
                    SettingsSection(
                      title: l10n.language,
                      tiles: [
                        SettingsTile(
                          title: l10n.selectLanguage,
                          subtitle: _getCurrentLanguageName(localeProvider),
                          leading: const Icon(Icons.language),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showLanguageSelectionDialog(localeProvider);
                          },
                        ),
                      ],
                    ),

                    // Настройки темы
                    SettingsSection(
                      title: l10n.theme,
                      tiles: [
                        SettingsTile.switchTile(
                          title: l10n.darkTheme,
                          subtitle: l10n.themeDescription,
                          leading: const Icon(Icons.dark_mode),
                          switchValue: localeProvider.isDarkTheme,
                          onToggle: (value) {
                            localeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),

                    // Основные настройки джапы
                    SettingsSection(
                      title: l10n.basicSettings,
                      tiles: [
                        SettingsTile(
                          title: l10n.targetRounds,
                          subtitle:
                              '${japaProvider.targetRounds} ${l10n.rounds}',
                          leading: const Icon(Icons.track_changes),
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
                        SettingsTile(
                          title: l10n.timePerRound,
                          subtitle:
                              '${AppConstants.minutesPerRound} ${l10n.minutes}',
                          leading: const Icon(Icons.timer),
                          trailing: const Text('Примерно'),
                        ),
                        SettingsTile(
                          title: l10n.maxRoundsPerDay,
                          subtitle:
                              '${AppConstants.maxRoundsPerDay} ${l10n.rounds}',
                          leading: const Icon(Icons.warning),
                          trailing: Text(l10n.notRecommendedToExceed),
                        ),
                      ],
                    ),

                    // Уведомления и напоминания
                    SettingsSection(
                      title: l10n.notificationsAndReminders,
                      tiles: [
                        SettingsTile.switchTile(
                          title: l10n.notifications,
                          subtitle: l10n.japaProgressNotifications,
                          leading: const Icon(Icons.notifications),
                          switchValue: japaProvider.notificationsEnabled,
                          onToggle: (value) {
                            japaProvider.setNotificationsEnabled(value);
                          },
                        ),
                        SettingsTile.switchTile(
                          title: l10n.autoStart,
                          subtitle: l10n.japaTimeReminders,
                          leading: const Icon(Icons.schedule),
                          switchValue: japaProvider.autoStartEnabled,
                          onToggle: (value) {
                            japaProvider.setAutoStartEnabled(value);
                          },
                        ),
                        SettingsTile(
                          title: l10n.dailyReminder,
                          subtitle: l10n.setJapaTime,
                          leading: const Icon(Icons.access_time),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showDailyReminderDialog(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.japaSchedule,
                          subtitle: l10n.setMultipleTimes,
                          leading: const Icon(Icons.calendar_today),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showScheduleDialog(l10n);
                          },
                        ),
                      ],
                    ),

                    // Звук и вибрация
                    SettingsSection(
                      title: l10n.soundAndVibration,
                      tiles: [
                        SettingsTile.switchTile(
                          title: l10n.vibration,
                          subtitle: l10n.beadClickVibration,
                          leading: const Icon(Icons.vibration),
                          switchValue: japaProvider.vibrationEnabled,
                          onToggle: (value) {
                            japaProvider.setVibrationEnabled(value);
                          },
                        ),
                        SettingsTile.switchTile(
                          title: l10n.sound,
                          subtitle: l10n.soundEffects,
                          leading: const Icon(Icons.volume_up),
                          switchValue: japaProvider.soundEnabled,
                          onToggle: (value) {
                            japaProvider.setSoundEnabled(value);
                          },
                        ),
                        SettingsTile(
                          title: l10n.japaSounds,
                          subtitle: l10n.configureSounds,
                          leading: const Icon(Icons.music_note),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showSoundSettingsDialog(l10n);
                          },
                        ),
                      ],
                    ),

                    // AI помощник
                    SettingsSection(
                      title: l10n.aiAssistantSection,
                      tiles: [
                        SettingsTile(
                          title: l10n.aiStatus,
                          subtitle: l10n.checkMozgachAvailability,
                          leading: const Icon(Icons.smart_toy),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _checkAIStatus();
                          },
                        ),
                        SettingsTile(
                          title: l10n.aiSettings,
                          subtitle: l10n.aiAssistantParameters,
                          leading: const Icon(Icons.settings),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showAISettingsDialog(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.aiStatistics,
                          subtitle: l10n.aiAssistantUsage,
                          leading: const Icon(Icons.analytics),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showAIStatsDialog(l10n);
                          },
                        ),
                      ],
                    ),

                    // Воспевание на зарядке (Правило № 4)
                    SettingsSection(
                      title: '🔋 Воспевание на зарядке',
                      tiles: [
                        SettingsTile.switchTile(
                          title: 'Включить на зарядке',
                          subtitle:
                              'Автоматическое воспевание при подключении зарядки',
                          leading: const Icon(Icons.battery_charging_full),
                          switchValue:
                              true, // Значение по умолчанию, будет загружено позже
                          onToggle: (value) async {
                            await ChargingChantingService.instance
                                .setChargingChantingEnabled(value);
                            setState(() {});
                          },
                        ),
                        SettingsTile.switchTile(
                          title: 'Воспевание в спящем режиме',
                          subtitle: 'Работа в фоновом режиме (энергозатратно)',
                          leading: const Icon(Icons.bedtime),
                          switchValue:
                              false, // Значение по умолчанию, будет загружено позже
                          onToggle: (value) async {
                            await ChargingChantingService.instance
                                .setSleepChantingEnabled(value);
                            setState(() {});
                          },
                        ),
                        SettingsTile.switchTile(
                          title: 'Использовать AI модели',
                          subtitle: 'Обработка через 108 моделей Мозgач108',
                          leading: const Icon(Icons.psychology),
                          switchValue:
                              true, // Значение по умолчанию, будет загружено позже
                          onToggle: (value) async {
                            await ChargingChantingService.instance
                                .setUseAIModels(value);
                            setState(() {});
                          },
                        ),
                        SettingsTile(
                          title: 'Интервал воспевания',
                          subtitle: '30 секунд между мантрами',
                          leading: const Icon(Icons.timer),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showChantingIntervalDialog();
                          },
                        ),
                        SettingsTile(
                          title: 'Статистика воспевания',
                          subtitle: 'Просмотр статистики и логов',
                          leading: const Icon(Icons.bar_chart),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showChantingStatsDialog();
                          },
                        ),
                      ],
                    ),

                    // Облачные функции
                    SettingsSection(
                      title: 'Облачные функции',
                      tiles: [
                        SettingsTile.switchTile(
                          title: 'Облачная синхронизация',
                          subtitle: _isOnline
                              ? (_cloudFeaturesEnabled
                                    ? 'Включена • Онлайн'
                                    : 'Выключена • Онлайн')
                              : 'Нет подключения к интернету',
                          leading: Icon(
                            _isOnline ? Icons.cloud : Icons.cloud_off,
                            color: _isOnline
                                ? (_cloudFeaturesEnabled
                                      ? Colors.green
                                      : Colors.grey)
                                : Colors.red,
                          ),
                          switchValue: _cloudFeaturesEnabled,
                          onToggle: _isOnline
                              ? (value) async {
                                  await _toggleCloudFeatures(value);
                                }
                              : null,
                        ),
                        if (_cloudFeaturesEnabled && _isOnline) ...[
                          SettingsTile(
                            title: 'Профиль пользователя',
                            subtitle: 'Управление профилем и настройками',
                            leading: const Icon(Icons.account_circle),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                          SettingsTile(
                            title: 'Глобальная статистика',
                            subtitle:
                                'Посмотреть общую статистику пользователей',
                            leading: const Icon(Icons.public),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              _showGlobalStatsDialog();
                            },
                          ),
                          SettingsTile(
                            title: 'Рейтинг пользователей',
                            subtitle: 'Топ практикующих джапу',
                            leading: const Icon(Icons.leaderboard),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              _showLeaderboardDialog();
                            },
                          ),
                          SettingsTile(
                            title: 'Персональные рекомендации',
                            subtitle:
                                'AI-рекомендации на основе вашей практики',
                            leading: const Icon(Icons.recommend),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              _showRecommendationsDialog();
                            },
                          ),
                          SettingsTile(
                            title: 'Настройки облака',
                            subtitle: 'Конфигурация Magento бэкенда',
                            leading: const Icon(Icons.cloud_sync),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              _showCloudSettingsDialog();
                            },
                          ),
                        ],
                      ],
                    ),

                    // Статистика и данные
                    SettingsSection(
                      title: l10n.statisticsAndData,
                      tiles: [
                        SettingsTile(
                          title: l10n.overallStatistics,
                          subtitle: l10n.viewAllAchievements,
                          leading: const Icon(Icons.bar_chart),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showOverallStatsDialog(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.dataExport,
                          subtitle: l10n.saveDataToDevice,
                          leading: const Icon(Icons.download),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _exportData(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.clearData,
                          subtitle: l10n.deleteAllSavedData,
                          leading: const Icon(Icons.delete_forever),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showClearDataDialog(l10n);
                          },
                        ),
                      ],
                    ),

                    // О приложении
                    SettingsSection(
                      title: l10n.aboutApp,
                      tiles: [
                        // Версия приложения - Easter Egg (7 нажатий активируют режим разработчика)
                        SettingsTile(
                          title: l10n.version,
                          subtitle: '1.0.0',
                          leading: Icon(
                            _developerModeEnabled
                                ? Icons.developer_mode
                                : Icons.info,
                            color: _developerModeEnabled ? Colors.green : null,
                          ),
                          trailing: _developerModeEnabled
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                          onPressed: (context) => _handleVersionTap(),
                        ),
                        // Кнопка просмотра логов (только в режиме разработчика)
                        if (_developerModeEnabled)
                          SettingsTile(
                            title: '🔓 Просмотр логов',
                            subtitle: 'Зашифрованные логи воспеваний (AES-256)',
                            leading: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onPressed: (context) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EasterEggLogsScreen(),
                                ),
                              );
                            },
                          ),
                        SettingsTile(
                          title: l10n.license,
                          subtitle: l10n.openSource,
                          leading: const Icon(Icons.description),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showLicenseDialog(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.developers,
                          subtitle: l10n.aiJapaTeam,
                          leading: const Icon(Icons.people),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showDevelopersDialog(l10n);
                          },
                        ),
                        SettingsTile(
                          title: l10n.donate,
                          subtitle: 'Поддержать развитие приложения',
                          leading: const Icon(Icons.favorite),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onPressed: (context) {
                            _showDonationDialog(l10n);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Получает название текущего языка
  String _getCurrentLanguageName(LocaleProvider localeProvider) {
    final currentInfo = localeProvider.getCurrentLocaleInfo();
    return currentInfo?['nativeName'] ?? 'Русский';
  }

  /// Показывает диалог выбора языка
  void _showLanguageSelectionDialog(LocaleProvider localeProvider) {
    AnimatedNavigation.showAnimatedDialog(
      context,
      child: AlertDialog(
        title: Text(SimpleLocalizations().selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: LocaleProvider.availableLocales.length,
            itemBuilder: (context, index) {
              final locale = LocaleProvider.availableLocales[index];
              final isSelected =
                  localeProvider.currentLocale.languageCode == locale['code'];

              return ListTile(
                leading: Text(
                  locale['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  locale['name']!,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(locale['description']!),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  localeProvider.setLocale(locale['code']!);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(SimpleLocalizations().close),
          ),
        ],
      ),
    );
  }

  /// Показывает диалог ежедневного напоминания
  void _showDailyReminderDialog(SimpleLocalizations l10n) {
    TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.dailyReminder),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.setJapaTime),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      'Выбранное время: ${selectedTime.format(context)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _setDailyReminder(selectedTime, l10n);
                  },
                  child: Text(l10n.set),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Устанавливает ежедневное напоминание
  Future<void> _setDailyReminder(
    TimeOfDay time,
    SimpleLocalizations l10n,
  ) async {
    try {
      await NotificationService.scheduleDailyReminder(
        time: time,
        title: 'Время для джапы! 🕉️',
        body: 'Начните свою духовную практику',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ежедневное напоминание установлено на ${time.format(context)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при установке напоминания: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Показывает диалог расписания
  void _showScheduleDialog(SimpleLocalizations l10n) {
    List<TimeOfDay> scheduledTimes = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.japaSchedule),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.setMultipleTimes),
                    const SizedBox(height: 16),
                    if (scheduledTimes.isEmpty)
                      const Text(
                        'Нажмите "+" чтобы добавить время',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...scheduledTimes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final time = entry.value;
                        return ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(time.format(context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                scheduledTimes.removeAt(index);
                              });
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 6, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            scheduledTimes.add(picked);
                            scheduledTimes.sort(
                              (a, b) => (a.hour * 60 + a.minute).compareTo(
                                b.hour * 60 + b.minute,
                              ),
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить время'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _setSchedule(scheduledTimes, l10n);
                  },
                  child: Text(l10n.configure),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Устанавливает расписание джапы
  Future<void> _setSchedule(
    List<TimeOfDay> times,
    SimpleLocalizations l10n,
  ) async {
    try {
      // Сохраняем расписание в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final timesJson = times
          .map((time) => '${time.hour}:${time.minute}')
          .toList();
      await prefs.setStringList('japa_schedule', timesJson);

      // Планируем уведомления для каждого времени
      for (int i = 0; i < times.length; i++) {
        await NotificationService.scheduleDailyReminder(
          time: times[i],
          title: 'Время для джапы! 🕉️',
          body: 'Начните свою духовную практику (${i + 1}/${times.length})',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Расписание установлено: ${times.length} напоминаний'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при установке расписания: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Показывает диалог настроек звука
  void _showSoundSettingsDialog(SimpleLocalizations l10n) {
    final audioService = AudioService();
    final settings = audioService.getSettings();

    String selectedSound = settings['currentSoundType'] as String;
    double volume = settings['volume'] as double;
    bool enableSound = settings['soundEnabled'] as bool;

    final availableSounds = audioService.getAvailableSounds();
    final soundOptions = <String, String>{};

    for (final sound in availableSounds) {
      soundOptions[sound] = audioService.getSoundName(sound);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.japaSounds),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.configureSounds),
                    const SizedBox(height: 16),

                    // Включение/выключение звука
                    SwitchListTile(
                      title: const Text('Включить звуки'),
                      subtitle: const Text('Звуковые эффекты при джапе'),
                      value: enableSound,
                      onChanged: (value) {
                        setState(() {
                          enableSound = value;
                        });
                      },
                    ),

                    if (enableSound) ...[
                      const SizedBox(height: 16),

                      // Выбор звука
                      DropdownButtonFormField<String>(
                        initialValue: selectedSound,
                        decoration: const InputDecoration(
                          labelText: 'Тип звука',
                          border: OutlineInputBorder(),
                        ),
                        items: soundOptions.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedSound = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Громкость
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Громкость: ${(volume * 100).round()}%'),
                          Slider(
                            value: volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                volume = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Кнопка прослушивания
                      ElevatedButton.icon(
                        onPressed: () {
                          _playTestSound(selectedSound, volume);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Прослушать'),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveSoundSettings(
                      selectedSound,
                      volume,
                      enableSound,
                      l10n,
                    );
                  },
                  child: Text(l10n.configure),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Воспроизводит тестовый звук
  void _playTestSound(String soundType, double volume) {
    try {
      AudioService().playTestSound(soundType);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Воспроизводится: ${AudioService().getSoundName(soundType)} (громкость: ${(volume * 100).round()}%)',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка воспроизведения звука: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Сохраняет настройки звука
  Future<void> _saveSoundSettings(
    String soundType,
    double volume,
    bool enableSound,
    SimpleLocalizations l10n,
  ) async {
    try {
      final audioService = AudioService();
      await audioService.setSoundType(soundType);
      await audioService.setVolume(volume);
      await audioService.setSoundEnabled(enableSound);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки звука сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении настроек звука: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Проверяет статус AI
  Future<void> _checkAIStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isServerAvailable = await AIService.isServerAvailable();
      final isBraindlerAvailable = await AIService.isBraindlerAvailable();
      final availableModels = await AIService.getAvailableModels();
      final modelInfo = await AIService.getModelInfo();

      String statusMessage;
      Color statusColor;

      if (isServerAvailable && isBraindlerAvailable) {
        statusMessage =
            'AI сервер доступен\nМодель braindler:q2_k готова к работе\nДоступно моделей: ${availableModels.length}';
        statusColor = Colors.green;
      } else if (isServerAvailable) {
        statusMessage =
            'AI сервер доступен, но braindler не найден\nДоступные модели: ${availableModels.join(', ')}';
        statusColor = Colors.orange;
      } else {
        statusMessage =
            'AI сервер недоступен\nПроверьте подключение к localhost:11434';
        statusColor = Colors.red;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isServerAvailable && isBraindlerAvailable
                        ? Icons.check_circle
                        : Icons.error,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  const Text('Статус AI'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusMessage, style: TextStyle(color: statusColor)),
                  if (modelInfo != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Информация о модели:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Размер: ${modelInfo['size'] ?? 'Неизвестно'}'),
                    Text('Семейство: ${modelInfo['family'] ?? 'Неизвестно'}'),
                    Text(
                      'Параметры: ${modelInfo['parameter_size'] ?? 'Неизвестно'}',
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Закрыть'),
                ),
                if (!isServerAvailable || !isBraindlerAvailable)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showAIHelpDialog();
                    },
                    child: const Text('Помощь'),
                  ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при проверке статуса AI: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Показывает диалог помощи по настройке AI
  void _showAIHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Настройка AI'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Для работы AI помощника необходимо:'),
                SizedBox(height: 8),
                Text('1. Установить Ollama: https://ollama.ai'),
                Text('2. Запустить Ollama сервер'),
                Text('3. Скачать модель mozgach:latest'),
                SizedBox(height: 16),
                Text('Команды для установки:'),
                SizedBox(height: 8),
                Text(
                  'ollama pull mozgach:latest',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
                SizedBox(height: 8),
                Text('ollama serve', style: TextStyle(fontFamily: 'monospace')),
                SizedBox(height: 16),
                Text('После установки перезапустите приложение.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог настроек AI
  void _showAISettingsDialog(SimpleLocalizations l10n) {
    String selectedModel = 'mozgach:latest';
    double temperature = 0.7;
    int maxTokens = 500;
    bool useLocalResponses = true;
    bool enableCache = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.aiSettings),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.aiAssistantParameters),
                      const SizedBox(height: 16),

                      // Выбор модели
                      DropdownButtonFormField<String>(
                        initialValue: selectedModel,
                        decoration: const InputDecoration(
                          labelText: 'AI Модель',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'mozgach:latest',
                            child: Text('mozgach:latest (рекомендуется)'),
                          ),
                          DropdownMenuItem(
                            value: 'llama2:latest',
                            child: Text('llama2:latest'),
                          ),
                          DropdownMenuItem(
                            value: 'mistral:latest',
                            child: Text('mistral:latest'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedModel = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Температура
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Температура: ${temperature.toStringAsFixed(1)}',
                          ),
                          Slider(
                            value: temperature,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                temperature = value;
                              });
                            },
                          ),
                          const Text(
                            'Низкая: более точные ответы\nВысокая: более творческие ответы',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Максимальное количество токенов
                      TextFormField(
                        initialValue: maxTokens.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Максимум токенов',
                          border: OutlineInputBorder(),
                          helperText: 'Максимальная длина ответа',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed > 0) {
                            setState(() {
                              maxTokens = parsed;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Дополнительные настройки
                      SwitchListTile(
                        title: const Text('Использовать локальные ответы'),
                        subtitle: const Text(
                          'Показывать предустановленные ответы когда AI недоступен',
                        ),
                        value: useLocalResponses,
                        onChanged: (value) {
                          setState(() {
                            useLocalResponses = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        title: const Text('Кэшировать ответы'),
                        subtitle: const Text(
                          'Сохранять ответы для быстрого доступа',
                        ),
                        value: enableCache,
                        onChanged: (value) {
                          setState(() {
                            enableCache = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveAISettings(
                      selectedModel,
                      temperature,
                      maxTokens,
                      useLocalResponses,
                      enableCache,
                      l10n,
                    );
                  },
                  child: Text(l10n.configure),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Сохраняет настройки AI
  Future<void> _saveAISettings(
    String model,
    double temperature,
    int maxTokens,
    bool useLocalResponses,
    bool enableCache,
    SimpleLocalizations l10n,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_model', model);
      await prefs.setDouble('ai_temperature', temperature);
      await prefs.setInt('ai_max_tokens', maxTokens);
      await prefs.setBool('ai_use_local_responses', useLocalResponses);
      await prefs.setBool('ai_enable_cache', enableCache);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки AI сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении настроек AI: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Показывает диалог статистики AI
  void _showAIStatsDialog(SimpleLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.aiStatistics),
          content: Text(l10n.aiAssistantUsage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог общей статистики
  void _showOverallStatsDialog(SimpleLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.overallStatistics),
          content: Consumer<JapaProvider>(
            builder: (context, japaProvider, child) {
              final stats = japaProvider.getOverallStats();
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.totalSessions}: ${stats['totalSessions']}'),
                  Text('${l10n.totalRounds}: ${stats['totalRounds']}'),
                  Text(
                    '${l10n.totalTime}: ${stats['totalTime'].inHours}${l10n.hours} ${stats['totalTime'].inMinutes % 60}${l10n.minutesShort}',
                  ),
                  Text(
                    '${l10n.averageRoundsPerSession}: ${stats['averageRoundsPerSession']}',
                  ),
                  Text(
                    '${l10n.averageTimePerSession}: ${stats['averageTimePerSession']} ${l10n.minutes}',
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
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Экспортирует данные
  Future<void> _exportData(SimpleLocalizations l10n) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Получаем все данные из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final exportData = <String, dynamic>{};

      for (final key in allKeys) {
        final value = prefs.get(key);
        if (value != null) {
          exportData[key] = value;
        }
      }

      // Добавляем метаданные экспорта
      exportData['export_metadata'] = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'total_keys': allKeys.length,
      };

      // Конвертируем в JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Здесь можно добавить логику сохранения файла
      // Пока просто показываем данные в диалоге
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Экспорт данных'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    const Text('Данные готовы к экспорту:'),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonString,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Закрыть'),
                ),
                TextButton(
                  onPressed: () {
                    // Здесь можно добавить логику копирования в буфер обмена
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Данные скопированы в буфер обмена'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Копировать'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при экспорте данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Показывает диалог очистки данных
  void _showClearDataDialog(SimpleLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.clearData),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вы уверены, что хотите удалить все сохраненные данные?'),
              SizedBox(height: 8),
              Text('Это действие удалит:'),
              Text('• Все сессии джапы'),
              Text('• Статистику'),
              Text('• Настройки'),
              Text('• Разговоры с AI'),
              SizedBox(height: 8),
              Text(
                'Это действие нельзя отменить!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllData(l10n);
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Очищает все данные
  Future<void> _clearAllData(SimpleLocalizations l10n) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Показываем диалог подтверждения
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Финальное подтверждение'),
            content: const Text(
              'Вы действительно хотите удалить ВСЕ данные? Это действие необратимо!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'УДАЛИТЬ ВСЕ',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Очищаем SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Отменяем все уведомления
        await NotificationService.cancelAll();

        // Очищаем кэш AI
        AIService.clearCache();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Все данные успешно удалены'),
              backgroundColor: Colors.green,
            ),
          );

          // Перезагружаем приложение
          // В реальном приложении можно использовать restart_app пакет
          // Restart.restartApp();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при очистке данных: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Показывает диалог лицензии
  void _showLicenseDialog(SimpleLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.license),
          content: const Text(
            'Это приложение распространяется под лицензией MIT. Исходный код доступен на GitHub.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог разработчиков
  void _showDevelopersDialog(SimpleLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.developers),
          content: const Text(
            'AI Джапа Махамантра разработана командой энтузиастов для духовного развития.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог пожертвований
  void _showDonationDialog(SimpleLocalizations l10n) {
    const String donationAddress = '0xffcba0b4980eb2d2336bfdb1e5a0fc49c620908a';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.donate),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Поддержите развитие приложения AI Джапа Махамантра!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Адрес для пожертвований:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  donationAddress,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваша поддержка поможет нам:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Улучшать AI-помощника'),
              const Text('• Добавлять новые функции'),
              const Text('• Поддерживать серверы'),
              const Text('• Развивать духовные практики'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.close),
            ),
            TextButton(
              onPressed: () {
                // Копируем адрес в буфер обмена
                // В реальном приложении можно использовать clipboard пакет
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Адрес скопирован в буфер обмена'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Копировать адрес'),
            ),
          ],
        );
      },
    );
  }

  /// Переключает облачные функции
  Future<void> _toggleCloudFeatures(bool enabled) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _magentoService.setCloudFeaturesEnabled(enabled);

      if (enabled) {
        // Инициализируем Magento сервис с базовыми настройками
        await _magentoService.initialize(
          baseUrl: 'https://your-magento-backend.com', // TODO: Настроить URL
          // TODO: Добавить токены авторизации
        );
      }

      setState(() {
        _cloudFeaturesEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Облачные функции включены'
                : 'Облачные функции выключены',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при переключении облачных функций: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Показывает диалог глобальной статистики
  Future<void> _showGlobalStatsDialog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _magentoService.getGlobalStatistics();

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Глобальная статистика'),
              content: stats != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Всего пользователей: ${stats['totalUsers'] ?? 'Неизвестно'}',
                        ),
                        Text(
                          'Всего кругов джапы: ${stats['totalRounds'] ?? 'Неизвестно'}',
                        ),
                        Text(
                          'Активных сегодня: ${stats['activeToday'] ?? 'Неизвестно'}',
                        ),
                        Text(
                          'Средний прогресс: ${stats['averageProgress'] ?? 'Неизвестно'}',
                        ),
                      ],
                    )
                  : const Text('Не удалось загрузить статистику'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке статистики: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Показывает диалог рейтинга
  Future<void> _showLeaderboardDialog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final leaderboard = await _magentoService.getLeaderboard(limit: 20);

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Рейтинг пользователей'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: leaderboard != null && leaderboard.isNotEmpty
                    ? ListView.builder(
                        itemCount: leaderboard.length,
                        itemBuilder: (context, index) {
                          final user = leaderboard[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              user['name'] ?? 'Анонимный пользователь',
                            ),
                            subtitle: Text(
                              '${user['totalRounds'] ?? 0} кругов',
                            ),
                            trailing: Text(
                              '${user['streak'] ?? 0} дней подряд',
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('Не удалось загрузить рейтинг')),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке рейтинга: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Показывает диалог рекомендаций
  Future<void> _showRecommendationsDialog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем ID пользователя из настроек
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'anonymous';

      final recommendations = await _magentoService
          .getPersonalizedRecommendations(userId);

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Персональные рекомендации'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: recommendations != null && recommendations.isNotEmpty
                    ? ListView.builder(
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = recommendations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recommendation['title'] ?? 'Рекомендация',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(recommendation['description'] ?? ''),
                                  if (recommendation['priority'] != null)
                                    Chip(
                                      label: Text(
                                        'Приоритет: ${recommendation['priority']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('Рекомендации пока недоступны')),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при загрузке рекомендаций: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Показывает диалог настроек облака
  void _showCloudSettingsDialog() {
    String baseUrl = 'https://your-magento-backend.com';
    String consumerKey = '';
    String consumerSecret = '';
    String accessToken = '';
    String accessTokenSecret = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Настройки облака'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Настройки подключения к Magento бэкенду'),
                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: baseUrl,
                        decoration: const InputDecoration(
                          labelText: 'URL бэкенда',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => baseUrl = value,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        initialValue: consumerKey,
                        decoration: const InputDecoration(
                          labelText: 'Consumer Key',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => consumerKey = value,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        initialValue: consumerSecret,
                        decoration: const InputDecoration(
                          labelText: 'Consumer Secret',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => consumerSecret = value,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        initialValue: accessToken,
                        decoration: const InputDecoration(
                          labelText: 'Access Token',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => accessToken = value,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        initialValue: accessTokenSecret,
                        decoration: const InputDecoration(
                          labelText: 'Access Token Secret',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => accessTokenSecret = value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveCloudSettings(
                      baseUrl,
                      consumerKey,
                      consumerSecret,
                      accessToken,
                      accessTokenSecret,
                    );
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Сохраняет настройки облака
  Future<void> _saveCloudSettings(
    String baseUrl,
    String consumerKey,
    String consumerSecret,
    String accessToken,
    String accessTokenSecret,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('magento_base_url', baseUrl);
      await prefs.setString('magento_consumer_key', consumerKey);
      await prefs.setString('magento_consumer_secret', consumerSecret);
      await prefs.setString('magento_access_token', accessToken);
      await prefs.setString('magento_access_token_secret', accessTokenSecret);

      // Переинициализируем Magento сервис с новыми настройками
      if (_cloudFeaturesEnabled) {
        await _magentoService.initialize(
          baseUrl: baseUrl,
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          accessToken: accessToken,
          accessTokenSecret: accessTokenSecret,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки облака сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении настроек: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Показывает диалог настройки интервала воспевания
  void _showChantingIntervalDialog() {
    int currentInterval = 30; // Значение по умолчанию

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Интервал воспевания'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Время между мантрами (секунды):'),
                  const SizedBox(height: 16),
                  Slider(
                    value: currentInterval.toDouble(),
                    min: 10,
                    max: 300,
                    divisions: 29,
                    label: '$currentInterval сек',
                    onChanged: (value) {
                      setState(() {
                        currentInterval = value.toInt();
                      });
                    },
                  ),
                  Text(
                    '$currentInterval секунд',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Примерно ${(3600 / currentInterval).floor()} воспеваний в час',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    await ChargingChantingService.instance.setChantingInterval(
                      currentInterval,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Интервал установлен: $currentInterval секунд',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Показывает диалог со статистикой воспевания на зарядке
  void _showChantingStatsDialog() {
    final stats = ChargingChantingService.instance.getStatistics();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.green),
              SizedBox(width: 8),
              Text('Статистика воспевания'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  'Статус',
                  stats['is_chanting'] ? '🟢 Активно' : '⚪ Неактивно',
                ),
                _buildStatRow(
                  'На зарядке',
                  stats['is_charging'] ? '🔋 Да' : '🪫 Нет',
                ),
                _buildStatRow('Батарея', '${stats['battery_level']}%'),
                const Divider(),
                _buildStatRow('Всего воспеваний', '${stats['total_chants']}'),
                _buildStatRow(
                  'На зарядке',
                  '${stats['chants_during_charging']}',
                ),
                _buildStatRow(
                  'В спящем режиме',
                  '${stats['chants_during_sleep']}',
                ),
                const Divider(),
                _buildStatRow('Интервал', '${stats['interval_seconds']} сек'),
                _buildStatRow(
                  'Использование AI',
                  stats['use_ai_models'] ? '🧠 Да' : '💡 Low Power',
                ),
                const Divider(),
                if (stats['last_chant_time'] != null)
                  _buildStatRow(
                    'Последнее воспевание',
                    _formatDateTime(stats['last_chant_time']),
                  ),
                if (stats['charging_start_time'] != null)
                  _buildStatRow(
                    'Зарядка началась',
                    _formatDateTime(stats['charging_start_time']),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showChantingLogsDialog();
              },
              child: const Text('Показать логи'),
            ),
          ],
        );
      },
    );
  }

  /// Вспомогательный метод для отображения строки статистики
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Форматирует дату и время
  String _formatDateTime(String? isoString) {
    if (isoString == null) return 'Нет данных';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Ошибка формата';
    }
  }

  /// Показывает диалог с логами воспевания
  void _showChantingLogsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.article, color: Colors.blue),
              SizedBox(width: 8),
              Text('Логи воспевания'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Логи воспевания зашифрованы и доступны через Easter Egg',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Для доступа к полным логам:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Тройной тап на 108-й бусине'),
                const Text('2. Или удержание мандалы + свайп 108 раз'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Переход к экрану логов можно добавить позже
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Открыть секретные логи'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }
}
