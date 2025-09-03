import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
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
          print('Неизвестная задача: $task');
      }
      return true;
    } catch (e) {
      print('Ошибка в фоновой задаче: $e');
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
    if (hoursSinceLastJapa < 12) return; // Напоминаем не чаще чем раз в 12 часов
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
  final scheduledTime = prefs.getString('japa_scheduled_time');
  
  if (scheduledTime != null) {
    final scheduled = DateTime.parse(scheduledTime);
    final now = DateTime.now();
    
    // Проверяем, пришло ли время для джапы
    if (now.hour == scheduled.hour && now.minute == scheduled.minute) {
      await NotificationService.showJapaReminder(
        title: 'Время для джапы! 🕉️',
        body: 'Пришло запланированное время для духовной практики.',
        payload: 'scheduled_japa',
      );
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
  final dailyStats = prefs.getString('daily_stats_$today');
  
  if (dailyStats != null) {
    final stats = Map<String, dynamic>.from(
      dailyStats as Map<String, dynamic>
    );
    stats['total_rounds'] = totalRounds;
    stats['total_sessions'] = totalSessions;
    stats['total_time_minutes'] = totalTime;
    await prefs.setString('daily_stats_$today', stats.toString());
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
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
  
  /// Регистрирует задачу для проверки расписания
  static Future<void> registerScheduleCheck() async {
    await Workmanager().registerPeriodicTask(
      'japa_schedule',
      'japa_schedule_check',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
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
      final hasRegisteredTasks = prefs.getBool('background_tasks_registered') ?? false;
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
          networkType: NetworkType.not_required,
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
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }).toList();
  }
}
