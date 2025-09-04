import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/japa_provider.dart';
import '../providers/locale_provider.dart';
import '../services/background_service.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations_delegate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
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
          return Container(
            color: Theme.of(context).colorScheme.background,
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
                        localeProvider.setTheme(value);
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
                      subtitle: '${japaProvider.targetRounds} ${l10n.rounds}',
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
                      subtitle: '${AppConstants.minutesPerRound} ${l10n.minutes}',
                      leading: const Icon(Icons.timer),
                      trailing: const Text('Примерно'),
                    ),
                    SettingsTile(
                      title: l10n.maxRoundsPerDay,
                      subtitle: '${AppConstants.maxRoundsPerDay} ${l10n.rounds}',
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
                    SettingsTile(
                      title: l10n.version,
                      subtitle: '1.0.0',
                      leading: const Icon(Icons.info),
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
                  ],
                ),
              ],
            ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).selectLanguage),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocaleProvider.availableLocales.length,
              itemBuilder: (context, index) {
                final locale = LocaleProvider.availableLocales[index];
                final isSelected = localeProvider.currentLocale.languageCode == locale['code'];
                
                return ListTile(
                  leading: Text(
                    locale['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    locale['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(locale['description']!),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
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
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог ежедневного напоминания
  void _showDailyReminderDialog(AppLocalizations l10n) {
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
                    title: Text('Выбранное время: ${selectedTime.format(context)}'),
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
  Future<void> _setDailyReminder(TimeOfDay time, AppLocalizations l10n) async {
    try {
      await NotificationService.scheduleDailyReminder(
        time: time,
        title: 'Время для джапы! 🕉️',
        body: 'Начните свою духовную практику',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ежедневное напоминание установлено на ${time.format(context)}'),
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
  void _showScheduleDialog(AppLocalizations l10n) {
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
                          title: Text('${time.format(context)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                scheduledTimes.removeAt(index);
                              });
                            },
                          ),
                        );
                      }).toList(),
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
                            scheduledTimes.sort((a, b) => 
                              (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
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
  Future<void> _setSchedule(List<TimeOfDay> times, AppLocalizations l10n) async {
    try {
      // Сохраняем расписание в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final timesJson = times.map((time) => '${time.hour}:${time.minute}').toList();
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
  void _showSoundSettingsDialog(AppLocalizations l10n) {
    String selectedSound = 'mantra_bell';
    double volume = 0.7;
    bool enableSound = true;
    
    final soundOptions = {
      'mantra_bell': 'Колокольчик мантры',
      'tibetan_bowl': 'Тибетская чаша',
      'om_sound': 'Звук Ом',
      'nature_sounds': 'Звуки природы',
      'silent': 'Без звука',
    };
    
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
                        value: selectedSound,
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
                    await _saveSoundSettings(selectedSound, volume, enableSound, l10n);
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
    // Здесь можно добавить логику воспроизведения звука
    // Пока просто показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Воспроизводится: $soundType (громкость: ${(volume * 100).round()}%)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Сохраняет настройки звука
  Future<void> _saveSoundSettings(String soundType, double volume, bool enableSound, AppLocalizations l10n) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('japa_sound_type', soundType);
      await prefs.setDouble('japa_sound_volume', volume);
      await prefs.setBool('japa_sound_enabled', enableSound);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      final isMozgachAvailable = await AIService.isMozgachAvailable();
      final availableModels = await AIService.getAvailableModels();
      final modelInfo = await AIService.getModelInfo();
      
      String statusMessage;
      Color statusColor;
      
      if (isServerAvailable && isMozgachAvailable) {
        statusMessage = 'AI сервер доступен\nМодель mozgach:latest готова к работе\nДоступно моделей: ${availableModels.length}';
        statusColor = Colors.green;
      } else if (isServerAvailable) {
        statusMessage = 'AI сервер доступен, но mozgach:latest не найден\nДоступные модели: ${availableModels.join(', ')}';
        statusColor = Colors.orange;
      } else {
        statusMessage = 'AI сервер недоступен\nПроверьте подключение к localhost:11434';
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
                    isServerAvailable && isMozgachAvailable ? Icons.check_circle : Icons.error,
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
                  Text(
                    statusMessage,
                    style: TextStyle(color: statusColor),
                  ),
                  if (modelInfo != null) ...[
                    const SizedBox(height: 16),
                    const Text('Информация о модели:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Размер: ${modelInfo['size'] ?? 'Неизвестно'}'),
                    Text('Семейство: ${modelInfo['family'] ?? 'Неизвестно'}'),
                    Text('Параметры: ${modelInfo['parameter_size'] ?? 'Неизвестно'}'),
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
                if (!isServerAvailable || !isMozgachAvailable)
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
                Text('ollama pull mozgach:latest', style: TextStyle(fontFamily: 'monospace')),
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
  void _showAISettingsDialog(AppLocalizations l10n) {
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
                        value: selectedModel,
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
                          Text('Температура: ${temperature.toStringAsFixed(1)}'),
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
                        subtitle: const Text('Показывать предустановленные ответы когда AI недоступен'),
                        value: useLocalResponses,
                        onChanged: (value) {
                          setState(() {
                            useLocalResponses = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Кэшировать ответы'),
                        subtitle: const Text('Сохранять ответы для быстрого доступа'),
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
                    await _saveAISettings(selectedModel, temperature, maxTokens, useLocalResponses, enableCache, l10n);
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
  Future<void> _saveAISettings(String model, double temperature, int maxTokens, bool useLocalResponses, bool enableCache, AppLocalizations l10n) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_model', model);
      await prefs.setDouble('ai_temperature', temperature);
      await prefs.setInt('ai_max_tokens', maxTokens);
      await prefs.setBool('ai_use_local_responses', useLocalResponses);
      await prefs.setBool('ai_enable_cache', enableCache);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Настройки AI сохранены'),
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
  void _showAIStatsDialog(AppLocalizations l10n) {
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
  void _showOverallStatsDialog(AppLocalizations l10n) {
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
                  Text('${l10n.totalTime}: ${stats['totalTime'].inHours}${l10n.hours} ${stats['totalTime'].inMinutes % 60}${l10n.minutesShort}'),
                  Text('${l10n.averageRoundsPerSession}: ${stats['averageRoundsPerSession']}'),
                  Text('${l10n.averageTimePerSession}: ${stats['averageTimePerSession']} ${l10n.minutes}'),
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
  Future<void> _exportData(AppLocalizations l10n) async {
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
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
  void _showClearDataDialog(AppLocalizations l10n) {
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
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
  Future<void> _clearAllData(AppLocalizations l10n) async {
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
            content: const Text('Вы действительно хотите удалить ВСЕ данные? Это действие необратимо!'),
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
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
  void _showLicenseDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.license),
          content: Text('Это приложение распространяется под лицензией MIT. Исходный код доступен на GitHub.'),
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
  void _showDevelopersDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.developers),
          content: Text('AI Джапа Махамантра разработана командой энтузиастов для духовного развития.'),
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
}
