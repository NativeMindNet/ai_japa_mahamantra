import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/japa_provider.dart';
import '../providers/locale_provider.dart';
import '../services/background_service.dart';
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
                      onPressed: () {
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
                      onPressed: () {
                        _checkAIStatus();
                      },
                    ),
                    SettingsTile(
                      title: l10n.aiSettings,
                      subtitle: l10n.aiAssistantParameters,
                      leading: const Icon(Icons.settings),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showAISettingsDialog(l10n);
                      },
                    ),
                    SettingsTile(
                      title: l10n.aiStatistics,
                      subtitle: l10n.aiAssistantUsage,
                      leading: const Icon(Icons.analytics),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
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
                      onPressed: () {
                        _showOverallStatsDialog(l10n);
                      },
                    ),
                    SettingsTile(
                      title: l10n.dataExport,
                      subtitle: l10n.saveDataToDevice,
                      leading: const Icon(Icons.download),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _exportData(l10n);
                      },
                    ),
                    SettingsTile(
                      title: l10n.clearData,
                      subtitle: l10n.deleteAllSavedData,
                      leading: const Icon(Icons.delete_forever),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
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
                      onPressed: () {
                        _showLicenseDialog(l10n);
                      },
                    ),
                    SettingsTile(
                      title: l10n.developers,
                      subtitle: l10n.aiJapaTeam,
                      leading: const Icon(Icons.people),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.dailyReminder),
          content: Text(l10n.setJapaTime),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать выбор времени
              },
              child: Text(l10n.set),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог расписания
  void _showScheduleDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.japaSchedule),
          content: Text(l10n.setMultipleTimes),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройку расписания
              },
              child: Text(l10n.configure),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог настроек звука
  void _showSoundSettingsDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.japaSounds),
          content: Text(l10n.configureSounds),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройки звука
              },
              child: Text(l10n.configure),
            ),
          ],
        );
      },
    );
  }

  /// Проверяет статус AI
  void _checkAIStatus() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Реализовать проверку статуса AI

    setState(() {
      _isLoading = false;
    });
  }

  /// Показывает диалог настроек AI
  void _showAISettingsDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.aiSettings),
          content: Text(l10n.aiAssistantParameters),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройки AI
              },
              child: Text(l10n.configure),
            ),
          ],
        );
      },
    );
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
  void _exportData(AppLocalizations l10n) {
    // TODO: Реализовать экспорт данных
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Экспорт данных будет доступен в следующей версии'),
      ),
    );
  }

  /// Показывает диалог очистки данных
  void _showClearDataDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.clearData),
          content: Text('Вы уверены, что хотите удалить все сохраненные данные? Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Реализовать очистку данных
              },
              child: Text(
                l10n.delete,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
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
