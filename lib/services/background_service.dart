import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Обработчик фоновых задач
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'japa_reminder_task':
          await _handleJapaReminder();
          break;
        case 'japa_schedule_check':
          await _handleScheduleCheck();
          break;
        case 'japa_progress_sync':
          await _handleProgressSync();
          break;
        default:
        // silent
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}

/// Обработчик напоминания о джапе
Future<void> _handleJapaReminder() async {
  final prefs = await SharedPreferences.getInstance();
  final isEnabled = prefs.getBool('japa_reminders_enabled') ?? true;

  if (!isEnabled) return;

  final now = DateTime.now();
  final lastJapaDate = prefs.getString('last_japa_date');
  final lastJapa = lastJapaDate != null ? DateTime.parse(lastJapaDate) : null;

  // Проверяем, прошло ли достаточно времени с последней джапы
  if (lastJapa != null) {
    final hoursSinceLastJapa = now.difference(lastJapa).inHours;
    if (hoursSinceLastJapa < 12)
      return; // Напоминаем не чаще чем раз в 12 часов
  }

  // Проверяем время дня (джапа лучше всего утром и вечером)
  final hour = now.hour;
  if (hour >= 4 && hour <= 8 || hour >= 17 && hour <= 21) {
    await NotificationService.showJapaReminder(
      title: 'Время для джапы! 🕉️',
      body: 'Пришло время для духовной практики. Харе Кришна!',
    );
  }
}

/// Обработчик проверки расписания
Future<void> _handleScheduleCheck() async {
  final prefs = await SharedPreferences.getInstance();
  final isEnabled = prefs.getBool('auto_schedule_enabled') ?? true;

  if (!isEnabled) return;

  final now = DateTime.now();
  final isWeekday = now.weekday >= 1 && now.weekday <= 5; // Пн-Пт

  // Определяем времена для текущего типа дня
  List<Map<String, int>> scheduleTimes;
  if (isWeekday) {
    // Будни: 08:01 и 21:08
    scheduleTimes = [
      {'hour': 8, 'minute': 1},
      {'hour': 21, 'minute': 8},
    ];
  } else {
    // Выходные: 09:00 и 21:00
    scheduleTimes = [
      {'hour': 9, 'minute': 0},
      {'hour': 21, 'minute': 0},
    ];
  }

  // Проверяем, пришло ли время для джапы
  for (final time in scheduleTimes) {
    if (now.hour == time['hour'] && now.minute == time['minute']) {
      final lastNotificationKey =
          'last_schedule_notification_${time['hour']}_${time['minute']}';
      final lastNotification = prefs.getString(lastNotificationKey);

      // Проверяем, не отправляли ли мы уже уведомление сегодня в это время
      if (lastNotification != null) {
        final lastDate = DateTime.parse(lastNotification);
        if (lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day) {
          continue; // Уже отправляли сегодня
        }
      }

      await NotificationService.showJapaReminder(
        title: 'Время для джапы! 🕉️',
        body:
            'Пришло запланированное время для духовной практики. Харе Кришна!',
        payload: 'scheduled_japa',
      );

      // Сохраняем время последнего уведомления
      await prefs.setString(lastNotificationKey, now.toIso8601String());
    }
  }
}

/// Обработчик синхронизации прогресса
Future<void> _handleProgressSync() async {
  final prefs = await SharedPreferences.getInstance();
  final lastSync = prefs.getString('last_progress_sync');

  if (lastSync != null) {
    final lastSyncDate = DateTime.parse(lastSync);
    final now = DateTime.now();

    // Синхронизируем прогресс раз в день
    if (now.difference(lastSyncDate).inDays >= 1) {
      await _syncProgress();
      await prefs.setString('last_progress_sync', now.toIso8601String());
    }
  }
}

/// Синхронизация прогресса
Future<void> _syncProgress() async {
  final prefs = await SharedPreferences.getInstance();

  // Здесь можно добавить логику для синхронизации с облаком
  // или другими устройствами

  // Пока просто обновляем локальную статистику
  final totalRounds = prefs.getInt('total_rounds') ?? 0;
  final totalSessions = prefs.getInt('total_sessions') ?? 0;
  final totalTime = prefs.getInt('total_time_minutes') ?? 0;

  // Сохраняем статистику за день
  final today = DateTime.now().toIso8601String().split('T')[0];
  final dailyStatsJson = prefs.getString('daily_stats_$today');

  if (dailyStatsJson != null) {
    final stats = jsonDecode(dailyStatsJson) as Map<String, dynamic>;
    stats['total_rounds'] = totalRounds;
    stats['total_sessions'] = totalSessions;
    stats['total_time_minutes'] = totalTime;
    await prefs.setString('daily_stats_$today', jsonEncode(stats));
  }
}

/// Класс для управления фоновыми задачами
class BackgroundService {
  /// Регистрирует периодическую задачу для напоминаний
  static Future<void> registerJapaReminder() async {
    await Workmanager().registerPeriodicTask(
      'japa_reminder',
      'japa_reminder_task',
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Регистрирует задачу для проверки расписания (каждые 15 минут)
  static Future<void> registerScheduleCheck() async {
    await Workmanager().registerPeriodicTask(
      'japa_schedule',
      'japa_schedule_check',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Миграция для старых версий - включает автоматическое расписание по умолчанию
  static Future<void> _migrateToDefaultSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    // Проверяем, была ли уже выполнена миграция
    final migrationDone = prefs.getBool('schedule_migration_v1') ?? false;

    if (!migrationDone) {
      // Для всех пользователей (новых и старых) включаем расписание по умолчанию
      // Если пользователь не устанавливал настройку явно, включаем
      final hasExplicitSetting = prefs.containsKey('auto_schedule_enabled');

      if (!hasExplicitSetting) {
        // Включаем расписание по умолчанию для всех
        await prefs.setBool('auto_schedule_enabled', true);
      }

      // Отмечаем миграцию как выполненную
      await prefs.setBool('schedule_migration_v1', true);
    }
  }

  /// Регистрирует автоматическое расписание по умолчанию
  /// Будни: 08:01 и 21:08
  /// Выходные: 09:00 и 21:00
  static Future<void> registerDefaultAutoSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    // Выполняем миграцию для старых версий
    await _migrateToDefaultSchedule();

    // Проверяем, не отключено ли автоматическое расписание
    final isEnabled = prefs.getBool('auto_schedule_enabled') ?? true;
    if (!isEnabled) return;

    // Устанавливаем флаг, что автоматическое расписание зарегистрировано
    await prefs.setBool('auto_schedule_registered', true);

    // Регистрируем проверку расписания
    await registerScheduleCheck();
  }

  /// Включает/выключает автоматическое расписание
  static Future<void> setAutoScheduleEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_schedule_enabled', enabled);

    if (enabled) {
      await registerDefaultAutoSchedule();
    } else {
      await cancelTask('japa_schedule');
    }
  }

  /// Проверяет, включено ли автоматическое расписание
  static Future<bool> isAutoScheduleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_schedule_enabled') ?? true;
  }

  /// Регистрирует задачу для синхронизации прогресса
  static Future<void> registerProgressSync() async {
    await Workmanager().registerPeriodicTask(
      'japa_progress',
      'japa_progress_sync',
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// Отменяет все фоновые задачи
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  /// Отменяет конкретную задачу
  static Future<void> cancelTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
  }

  /// Проверяет статус фоновых задач
  static Future<bool> areBackgroundTasksEnabled() async {
    try {
      // Проверяем, зарегистрированы ли задачи
      final prefs = await SharedPreferences.getInstance();
      final hasRegisteredTasks =
          prefs.getBool('background_tasks_registered') ?? false;
      return hasRegisteredTasks;
    } catch (e) {
      return false;
    }
  }

  /// Устанавливает время для ежедневного напоминания
  static Future<void> setDailyReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_reminder_time', '${time.hour}:${time.minute}');

    // Планируем уведомление
    await NotificationService.scheduleDailyReminder(
      time: time,
      title: 'Время для джапы! 🕉️',
      body: 'Пришло время для духовной практики. Харе Кришна!',
    );
  }

  /// Получает время ежедневного напоминания
  static Future<TimeOfDay?> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('daily_reminder_time');

    if (timeString != null) {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return null;
  }

  /// Включает/выключает напоминания
  static Future<void> setRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('japa_reminders_enabled', enabled);

    if (!enabled) {
      await NotificationService.cancelAll();
    }
  }

  /// Проверяет, включены ли напоминания
  static Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('japa_reminders_enabled') ?? true;
  }

  /// Устанавливает расписание джапы
  static Future<void> setJapaSchedule(List<TimeOfDay> times) async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleStrings = times.map((t) => '${t.hour}:${t.minute}').toList();
    await prefs.setStringList('japa_schedule', scheduleStrings);

    // Регистрируем задачи для каждого времени
    for (int i = 0; i < times.length; i++) {
      await Workmanager().registerOneOffTask(
        'japa_schedule_$i',
        'japa_schedule_check',
        inputData: {'scheduled_time': '${times[i].hour}:${times[i].minute}'},
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    }
  }

  /// Получает расписание джапы
  static Future<List<TimeOfDay>> getJapaSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduleStrings = prefs.getStringList('japa_schedule') ?? [];

    return scheduleStrings.map((s) {
      final parts = s.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }
}
