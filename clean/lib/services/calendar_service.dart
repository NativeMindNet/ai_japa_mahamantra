import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Сервис для интеграции с календарем
class CalendarService {
  static const String _calendarEventsKey = 'calendar_events';
  static const String _japaScheduleKey = 'japa_schedule';
  
  /// Событие календаря
  static Map<String, dynamic> createJapaEvent({
    required DateTime date,
    required int rounds,
    required Duration duration,
    String? notes,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Джапа - $rounds кругов',
      'description': 'Духовная практика джапы\nВремя: ${duration.inMinutes} минут\n${notes ?? ''}',
      'startTime': date.toIso8601String(),
      'endTime': date.add(duration).toIso8601String(),
      'rounds': rounds,
      'duration': duration.inMinutes,
      'notes': notes ?? '',
      'type': 'japa_session',
      'color': 0xFF8E24AA, // Фиолетовый цвет
      'isAllDay': false,
      'reminder': true,
      'reminderMinutes': 15, // Напоминание за 15 минут
    };
  }
  
  /// Сохраняет событие джапы в календарь
  static Future<void> saveJapaEvent(Map<String, dynamic> event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_calendarEventsKey) ?? [];
      
      eventsJson.add(jsonEncode(event));
      
      // Ограничиваем количество событий (последние 100)
      if (eventsJson.length > 100) {
        eventsJson.removeRange(0, eventsJson.length - 100);
      }
      
      await prefs.setStringList(_calendarEventsKey, eventsJson);
    } catch (e) {
      print('Ошибка при сохранении события в календарь: $e');
    }
  }
  
  /// Получает все события джапы
  static Future<List<Map<String, dynamic>>> getJapaEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_calendarEventsKey) ?? [];
      
      final events = <Map<String, dynamic>>[];
      
      for (final jsonString in eventsJson) {
        try {
          final event = Map<String, dynamic>.from(jsonDecode(jsonString));
          events.add(event);
        } catch (e) {
          print('Ошибка при загрузке события: $e');
        }
      }
      
      // Сортируем по дате (новые сверху)
      events.sort((a, b) {
        final dateA = DateTime.tryParse(a['startTime'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['startTime'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
      
      return events;
    } catch (e) {
      print('Ошибка при получении событий календаря: $e');
      return [];
    }
  }
  
  /// Получает события за определенный период
  static Future<List<Map<String, dynamic>>> getEventsForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allEvents = await getJapaEvents();
      
      return allEvents.where((event) {
        final eventDate = DateTime.tryParse(event['startTime'] ?? '');
        if (eventDate == null) return false;
        
        return eventDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               eventDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Ошибка при получении событий за период: $e');
      return [];
    }
  }
  
  /// Получает события за день
  static Future<List<Map<String, dynamic>>> getEventsForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getEventsForPeriod(startOfDay, endOfDay);
  }
  
  /// Получает события за неделю
  static Future<List<Map<String, dynamic>>> getEventsForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getEventsForPeriod(weekStart, weekEnd);
  }
  
  /// Получает события за месяц
  static Future<List<Map<String, dynamic>>> getEventsForMonth(DateTime monthStart) async {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
    return getEventsForPeriod(monthStart, monthEnd);
  }
  
  /// Удаляет событие
  static Future<void> deleteEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_calendarEventsKey) ?? [];
      
      eventsJson.removeWhere((jsonString) {
        try {
          final event = jsonDecode(jsonString);
          return event['id'] == eventId;
        } catch (e) {
          return false;
        }
      });
      
      await prefs.setStringList(_calendarEventsKey, eventsJson);
    } catch (e) {
      print('Ошибка при удалении события: $e');
    }
  }
  
  /// Обновляет событие
  static Future<void> updateEvent(String eventId, Map<String, dynamic> updatedEvent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_calendarEventsKey) ?? [];
      
      for (int i = 0; i < eventsJson.length; i++) {
        try {
          final event = jsonDecode(eventsJson[i]);
          if (event['id'] == eventId) {
            eventsJson[i] = jsonEncode(updatedEvent);
            break;
          }
        } catch (e) {
          continue;
        }
      }
      
      await prefs.setStringList(_calendarEventsKey, eventsJson);
    } catch (e) {
      print('Ошибка при обновлении события: $e');
    }
  }
  
  /// Получает статистику по событиям
  static Future<Map<String, dynamic>> getEventsStatistics() async {
    try {
      final events = await getJapaEvents();
      
      if (events.isEmpty) {
        return {
          'totalEvents': 0,
          'totalRounds': 0,
          'totalDuration': 0,
          'averageRounds': 0,
          'averageDuration': 0,
          'eventsThisWeek': 0,
          'eventsThisMonth': 0,
        };
      }
      
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);
      
      final eventsThisWeek = events.where((event) {
        final eventDate = DateTime.tryParse(event['startTime'] ?? '');
        return eventDate != null && eventDate.isAfter(weekStart);
      }).length;
      
      final eventsThisMonth = events.where((event) {
        final eventDate = DateTime.tryParse(event['startTime'] ?? '');
        return eventDate != null && eventDate.isAfter(monthStart);
      }).length;
      
      final totalRounds = events.fold<int>(0, (sum, event) => sum + (event['rounds'] ?? 0));
      final totalDuration = events.fold<int>(0, (sum, event) => sum + (event['duration'] ?? 0));
      
      return {
        'totalEvents': events.length,
        'totalRounds': totalRounds,
        'totalDuration': totalDuration,
        'averageRounds': events.isNotEmpty ? (totalRounds / events.length).round() : 0,
        'averageDuration': events.isNotEmpty ? (totalDuration / events.length).round() : 0,
        'eventsThisWeek': eventsThisWeek,
        'eventsThisMonth': eventsThisMonth,
      };
    } catch (e) {
      print('Ошибка при получении статистики событий: $e');
      return {};
    }
  }
  
  /// Экспортирует события в формат календаря
  static Future<String> exportToCalendarFormat() async {
    try {
      final events = await getJapaEvents();
      
      // Формат iCalendar (ICS)
      final icsContent = StringBuffer();
      icsContent.writeln('BEGIN:VCALENDAR');
      icsContent.writeln('VERSION:2.0');
      icsContent.writeln('PRODID:-//AI Japa Mahamantra//EN');
      icsContent.writeln('CALSCALE:GREGORIAN');
      icsContent.writeln('METHOD:PUBLISH');
      
      for (final event in events) {
        final startTime = DateTime.tryParse(event['startTime'] ?? '');
        final endTime = DateTime.tryParse(event['endTime'] ?? '');
        
        if (startTime != null && endTime != null) {
          icsContent.writeln('BEGIN:VEVENT');
          icsContent.writeln('UID:${event['id']}@ai-japa-mahamantra.app');
          icsContent.writeln('DTSTART:${_formatDateTimeForICS(startTime)}');
          icsContent.writeln('DTEND:${_formatDateTimeForICS(endTime)}');
          icsContent.writeln('SUMMARY:${event['title']}');
          icsContent.writeln('DESCRIPTION:${event['description']}');
          icsContent.writeln('STATUS:CONFIRMED');
          icsContent.writeln('END:VEVENT');
        }
      }
      
      icsContent.writeln('END:VCALENDAR');
      
      return icsContent.toString();
    } catch (e) {
      print('Ошибка при экспорте в формат календаря: $e');
      return '';
    }
  }
  
  /// Форматирует дату для формата ICS
  static String _formatDateTimeForICS(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }
  
  /// Создает напоминание о джапе
  static Future<void> createJapaReminder({
    required DateTime date,
    required String title,
    required String description,
    int reminderMinutes = 15,
  }) async {
    try {
      final reminder = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'reminderMinutes': reminderMinutes,
        'type': 'japa_reminder',
        'isActive': true,
      };
      
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('japa_reminders') ?? [];
      remindersJson.add(jsonEncode(reminder));
      
      await prefs.setStringList('japa_reminders', remindersJson);
    } catch (e) {
      print('Ошибка при создании напоминания: $e');
    }
  }
  
  /// Получает все напоминания
  static Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('japa_reminders') ?? [];
      
      final reminders = <Map<String, dynamic>>[];
      
      for (final jsonString in remindersJson) {
        try {
          final reminder = Map<String, dynamic>.from(jsonDecode(jsonString));
          reminders.add(reminder);
        } catch (e) {
          print('Ошибка при загрузке напоминания: $e');
        }
      }
      
      // Сортируем по дате
      reminders.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateA.compareTo(dateB);
      });
      
      return reminders;
    } catch (e) {
      print('Ошибка при получении напоминаний: $e');
      return [];
    }
  }
  
  /// Удаляет напоминание
  static Future<void> deleteReminder(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getStringList('japa_reminders') ?? [];
      
      remindersJson.removeWhere((jsonString) {
        try {
          final reminder = jsonDecode(jsonString);
          return reminder['id'] == reminderId;
        } catch (e) {
          return false;
        }
      });
      
      await prefs.setStringList('japa_reminders', remindersJson);
    } catch (e) {
      print('Ошибка при удалении напоминания: $e');
    }
  }
  
  /// Очищает все события и напоминания
  static Future<void> clearAllCalendarData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_calendarEventsKey);
      await prefs.remove('japa_reminders');
    } catch (e) {
      print('Ошибка при очистке данных календаря: $e');
    }
  }
}
