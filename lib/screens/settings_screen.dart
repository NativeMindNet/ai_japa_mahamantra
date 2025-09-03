import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/japa_provider.dart';
import '../services/background_service.dart';
import '../constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<JapaProvider>(
        builder: (context, japaProvider, child) {
          return Container(
            color: Color(AppConstants.backgroundColor),
            child: SettingsList(
              sections: [
                // Основные настройки джапы
                SettingsSection(
                  title: 'Основные настройки',
                  tiles: [
                    SettingsTile(
                      title: 'Целевые круги',
                      subtitle: '${japaProvider.targetRounds} кругов',
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
                      title: 'Время на круг',
                      subtitle: '${AppConstants.minutesPerRound} минут',
                      leading: const Icon(Icons.timer),
                      trailing: const Text('Примерно'),
                    ),
                    SettingsTile(
                      title: 'Максимум кругов в день',
                      subtitle: '${AppConstants.maxRoundsPerDay} кругов',
                      leading: const Icon(Icons.warning),
                      trailing: const Text('Не рекомендуется превышать'),
                    ),
                  ],
                ),

                // Уведомления и напоминания
                SettingsSection(
                  title: 'Уведомления и напоминания',
                  tiles: [
                    SettingsTile.switchTile(
                      title: 'Уведомления',
                      subtitle: 'Уведомления о прогрессе джапы',
                      leading: const Icon(Icons.notifications),
                      switchValue: japaProvider.notificationsEnabled,
                      onToggle: (value) {
                        japaProvider.setNotificationsEnabled(value);
                      },
                    ),
                    SettingsTile.switchTile(
                      title: 'Автозапуск',
                      subtitle: 'Напоминания о времени джапы',
                      leading: const Icon(Icons.schedule),
                      switchValue: japaProvider.autoStartEnabled,
                      onToggle: (value) {
                        japaProvider.setAutoStartEnabled(value);
                      },
                    ),
                    SettingsTile(
                      title: 'Ежедневное напоминание',
                      subtitle: 'Установить время для джапы',
                      leading: const Icon(Icons.access_time),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showDailyReminderDialog();
                      },
                    ),
                    SettingsTile(
                      title: 'Расписание джапы',
                      subtitle: 'Настроить несколько времен',
                      leading: const Icon(Icons.calendar_today),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showScheduleDialog();
                      },
                    ),
                  ],
                ),

                // Звук и вибрация
                SettingsSection(
                  title: 'Звук и вибрация',
                  tiles: [
                    SettingsTile.switchTile(
                      title: 'Вибрация',
                      subtitle: 'Вибрация при нажатии на бусины',
                      leading: const Icon(Icons.vibration),
                      switchValue: japaProvider.vibrationEnabled,
                      onToggle: (value) {
                        japaProvider.setVibrationEnabled(value);
                      },
                    ),
                    SettingsTile.switchTile(
                      title: 'Звук',
                      subtitle: 'Звуковые эффекты',
                      leading: const Icon(Icons.volume_up),
                      switchValue: japaProvider.soundEnabled,
                      onToggle: (value) {
                        japaProvider.setSoundEnabled(value);
                      },
                    ),
                    SettingsTile(
                      title: 'Звуки джапы',
                      subtitle: 'Настроить звуки для разных событий',
                      leading: const Icon(Icons.music_note),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showSoundSettingsDialog();
                      },
                    ),
                  ],
                ),

                // AI помощник
                SettingsSection(
                  title: 'AI Помощник',
                  tiles: [
                    SettingsTile(
                      title: 'Статус AI',
                      subtitle: 'Проверить доступность mozgach:latest',
                      leading: const Icon(Icons.smart_toy),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _checkAIStatus();
                      },
                    ),
                    SettingsTile(
                      title: 'Настройки AI',
                      subtitle: 'Параметры AI помощника',
                      leading: const Icon(Icons.settings),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showAISettingsDialog();
                      },
                    ),
                    SettingsTile(
                      title: 'Статистика AI',
                      subtitle: 'Использование AI помощника',
                      leading: const Icon(Icons.analytics),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showAIStatsDialog();
                      },
                    ),
                  ],
                ),

                // Статистика и данные
                SettingsSection(
                  title: 'Статистика и данные',
                  tiles: [
                    SettingsTile(
                      title: 'Общая статистика',
                      subtitle: 'Просмотр всех достижений',
                      leading: const Icon(Icons.bar_chart),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showOverallStatsDialog();
                      },
                    ),
                    SettingsTile(
                      title: 'Экспорт данных',
                      subtitle: 'Сохранить данные на устройство',
                      leading: const Icon(Icons.download),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _exportData();
                      },
                    ),
                    SettingsTile(
                      title: 'Очистить данные',
                      subtitle: 'Удалить все сохраненные данные',
                      leading: const Icon(Icons.delete_forever),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showClearDataDialog();
                      },
                    ),
                  ],
                ),

                // О приложении
                SettingsSection(
                  title: 'О приложении',
                  tiles: [
                    SettingsTile(
                      title: 'Версия',
                      subtitle: '1.0.0',
                      leading: const Icon(Icons.info),
                    ),
                    SettingsTile(
                      title: 'Лицензия',
                      subtitle: 'Открытый исходный код',
                      leading: const Icon(Icons.description),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showLicenseDialog();
                      },
                    ),
                    SettingsTile(
                      title: 'Разработчики',
                      subtitle: 'Команда AI Джапа Махамантра',
                      leading: const Icon(Icons.people),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        _showDevelopersDialog();
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

  /// Показывает диалог ежедневного напоминания
  void _showDailyReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ежедневное напоминание'),
          content: const Text('Выберите время для ежедневного напоминания о джапе'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать выбор времени
              },
              child: const Text('Установить'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог расписания
  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Расписание джапы'),
          content: const Text('Настройте несколько времен для напоминаний о джапе'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройку расписания
              },
              child: const Text('Настроить'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог настроек звука
  void _showSoundSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Настройки звука'),
          content: const Text('Настройте звуки для разных событий в джапе'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройки звука
              },
              child: const Text('Настроить'),
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
  void _showAISettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Настройки AI'),
          content: const Text('Настройте параметры AI помощника'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Показать настройки AI
              },
              child: const Text('Настроить'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог статистики AI
  void _showAIStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Статистика AI'),
          content: const Text('Статистика использования AI помощника'),
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

  /// Показывает диалог общей статистики
  void _showOverallStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Общая статистика'),
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

  /// Экспортирует данные
  void _exportData() {
    // TODO: Реализовать экспорт данных
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Экспорт данных будет доступен в следующей версии'),
      ),
    );
  }

  /// Показывает диалог очистки данных
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Очистить данные'),
          content: const Text('Вы уверены, что хотите удалить все сохраненные данные? Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Реализовать очистку данных
              },
              child: const Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог лицензии
  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Лицензия'),
          content: const Text('Это приложение распространяется под лицензией MIT. Исходный код доступен на GitHub.'),
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

  /// Показывает диалог разработчиков
  void _showDevelopersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Разработчики'),
          content: const Text('AI Джапа Махамантра разработана командой энтузиастов для духовного развития.'),
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
