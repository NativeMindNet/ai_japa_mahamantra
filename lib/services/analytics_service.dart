import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/japa_session.dart';

/// Модель данных для аналитики
class AnalyticsData {
  final DateTime date;
  final int sessions;
  final int rounds;
  final int totalTime; // в секундах
  final double averageSessionTime;
  final int longestStreak;
  final Map<String, int> timeDistribution; // распределение по времени дня
  final Map<String, int> dayDistribution; // распределение по дням недели

  const AnalyticsData({
    required this.date,
    required this.sessions,
    required this.rounds,
    required this.totalTime,
    required this.averageSessionTime,
    required this.longestStreak,
    required this.timeDistribution,
    required this.dayDistribution,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      date: DateTime.parse(json['date']),
      sessions: json['sessions'],
      rounds: json['rounds'],
      totalTime: json['totalTime'],
      averageSessionTime: json['averageSessionTime'].toDouble(),
      longestStreak: json['longestStreak'],
      timeDistribution: Map<String, int>.from(json['timeDistribution']),
      dayDistribution: Map<String, int>.from(json['dayDistribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'sessions': sessions,
      'rounds': rounds,
      'totalTime': totalTime,
      'averageSessionTime': averageSessionTime,
      'longestStreak': longestStreak,
      'timeDistribution': timeDistribution,
      'dayDistribution': dayDistribution,
    };
  }
}

/// Модель статистики за период
class PeriodStats {
  final DateTime startDate;
  final DateTime endDate;
  final int totalSessions;
  final int totalRounds;
  final int totalTime; // в секундах
  final double averageSessionTime;
  final double averageRoundsPerSession;
  final int longestStreak;
  final int currentStreak;
  final List<AnalyticsData> dailyData;
  final Map<String, int> weeklyDistribution;
  final Map<String, int> monthlyDistribution;
  final List<String> insights;

  const PeriodStats({
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.totalRounds,
    required this.totalTime,
    required this.averageSessionTime,
    required this.averageRoundsPerSession,
    required this.longestStreak,
    required this.currentStreak,
    required this.dailyData,
    required this.weeklyDistribution,
    required this.monthlyDistribution,
    required this.insights,
  });

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalSessions: json['totalSessions'],
      totalRounds: json['totalRounds'],
      totalTime: json['totalTime'],
      averageSessionTime: json['averageSessionTime'].toDouble(),
      averageRoundsPerSession: json['averageRoundsPerSession'].toDouble(),
      longestStreak: json['longestStreak'],
      currentStreak: json['currentStreak'],
      dailyData: (json['dailyData'] as List)
          .map((data) => AnalyticsData.fromJson(data))
          .toList(),
      weeklyDistribution: Map<String, int>.from(json['weeklyDistribution']),
      monthlyDistribution: Map<String, int>.from(json['monthlyDistribution']),
      insights: List<String>.from(json['insights']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalSessions': totalSessions,
      'totalRounds': totalRounds,
      'totalTime': totalTime,
      'averageSessionTime': averageSessionTime,
      'averageRoundsPerSession': averageRoundsPerSession,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'dailyData': dailyData.map((data) => data.toJson()).toList(),
      'weeklyDistribution': weeklyDistribution,
      'monthlyDistribution': monthlyDistribution,
      'insights': insights,
    };
  }
}

/// Сервис для аналитики и статистики
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _sessionsKey = 'japa_sessions_history';
  static const String _analyticsKey = 'analytics_data';

  List<JapaSession> _sessions = [];
  List<AnalyticsData> _analyticsData = [];

  /// Инициализирует сервис аналитики
  Future<void> initialize() async {
    await _loadSessions();
    await _loadAnalyticsData();
    await _updateAnalytics();
  }

  /// Загружает сессии из локального хранилища
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);

      if (sessionsJson != null) {
        final List<dynamic> sessionsList = json.decode(sessionsJson);
        _sessions = sessionsList
            .map((json) => JapaSession.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Ошибка загрузки сессий: $e');
    }
  }

  /// Загружает данные аналитики
  Future<void> _loadAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString(_analyticsKey);

      if (analyticsJson != null) {
        final List<dynamic> analyticsList = json.decode(analyticsJson);
        _analyticsData = analyticsList
            .map((json) => AnalyticsData.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Ошибка загрузки данных аналитики: $e');
    }
  }

  /// Сохраняет сессии в локальное хранилище
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = json.encode(
        _sessions.map((session) => session.toJson()).toList(),
      );
      await prefs.setString(_sessionsKey, sessionsJson);
    } catch (e) {
      print('Ошибка сохранения сессий: $e');
    }
  }

  /// Сохраняет данные аналитики
  Future<void> _saveAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = json.encode(
        _analyticsData.map((data) => data.toJson()).toList(),
      );
      await prefs.setString(_analyticsKey, analyticsJson);
    } catch (e) {
      print('Ошибка сохранения данных аналитики: $e');
    }
  }

  /// Добавляет новую сессию
  Future<void> addSession(JapaSession session) async {
    _sessions.add(session);
    await _saveSessions();
    await _updateAnalytics();
  }

  /// Обновляет аналитику на основе всех сессий
  Future<void> _updateAnalytics() async {
    if (_sessions.isEmpty) return;

    // Группируем сессии по дням
    final Map<String, List<JapaSession>> sessionsByDay = {};

    for (final session in _sessions) {
      final dayKey = _getDayKey(session.startTime);
      sessionsByDay.putIfAbsent(dayKey, () => []).add(session);
    }

    // Создаем данные аналитики для каждого дня
    _analyticsData.clear();

    for (final entry in sessionsByDay.entries) {
      final daySessions = entry.value;
      final date = DateTime.parse(entry.key);

      final totalRounds = daySessions.fold(
        0,
        (sum, session) => sum + session.completedRounds,
      );
      final totalTime = daySessions.fold(
        0,
        (sum, session) => sum + session.duration.inSeconds,
      );
      final averageSessionTime = daySessions.isNotEmpty
          ? totalTime / daySessions.length
          : 0.0;

      // Распределение по времени дня
      final timeDistribution = <String, int>{};
      for (final session in daySessions) {
        final hour = session.startTime.hour;
        final timeSlot = _getTimeSlot(hour);
        timeDistribution[timeSlot] = (timeDistribution[timeSlot] ?? 0) + 1;
      }

      // Распределение по дням недели
      final dayDistribution = <String, int>{};
      final dayName = _getDayName(date.weekday);
      dayDistribution[dayName] = daySessions.length;

      final analyticsData = AnalyticsData(
        date: date,
        sessions: daySessions.length,
        rounds: totalRounds,
        totalTime: totalTime,
        averageSessionTime: averageSessionTime,
        longestStreak: _calculateLongestStreak(),
        timeDistribution: timeDistribution,
        dayDistribution: dayDistribution,
      );

      _analyticsData.add(analyticsData);
    }

    // Сортируем по дате
    _analyticsData.sort((a, b) => a.date.compareTo(b.date));

    await _saveAnalyticsData();
  }

  /// Получает ключ дня для группировки
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Получает временной слот
  String _getTimeSlot(int hour) {
    if (hour >= 5 && hour < 9) return 'Утро (5-9)';
    if (hour >= 9 && hour < 12) return 'День (9-12)';
    if (hour >= 12 && hour < 17) return 'После полудня (12-17)';
    if (hour >= 17 && hour < 21) return 'Вечер (17-21)';
    return 'Ночь (21-5)';
  }

  /// Получает название дня недели
  String _getDayName(int weekday) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[weekday - 1];
  }

  /// Вычисляет самую длинную серию
  int _calculateLongestStreak() {
    if (_sessions.isEmpty) return 0;

    final sortedSessions = List<JapaSession>.from(_sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDifference = sessionDate.difference(lastDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
        } else if (daysDifference > 1) {
          longestStreak = longestStreak > currentStreak
              ? longestStreak
              : currentStreak;
          currentStreak = 1;
        }
      }

      lastDate = sessionDate;
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  /// Получает статистику за период
  Future<PeriodStats> getPeriodStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filteredSessions = _sessions.where((session) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return sessionDate.isAtSameMomentAs(start) ||
          sessionDate.isAtSameMomentAs(end) ||
          (sessionDate.isAfter(start) && sessionDate.isBefore(end));
    }).toList();

    final totalSessions = filteredSessions.length;
    final totalRounds = filteredSessions.fold(
      0,
      (sum, session) => sum + session.completedRounds,
    );
    final totalTime = filteredSessions.fold(
      0,
      (sum, session) => sum + session.duration.inSeconds,
    );
    final averageSessionTime = totalSessions > 0
        ? totalTime / totalSessions
        : 0.0;
    final averageRoundsPerSession = totalSessions > 0
        ? totalRounds / totalSessions
        : 0.0;

    final longestStreak = _calculateLongestStreak();
    final currentStreak = _calculateCurrentStreak();

    // Данные по дням
    final dailyData = _analyticsData.where((data) {
      return data.date.isAtSameMomentAs(startDate) ||
          data.date.isAtSameMomentAs(endDate) ||
          (data.date.isAfter(startDate) && data.date.isBefore(endDate));
    }).toList();

    // Распределение по неделям
    final weeklyDistribution = <String, int>{};
    for (final session in filteredSessions) {
      final weekKey = 'Неделя ${_getWeekNumber(session.startTime)}';
      weeklyDistribution[weekKey] = (weeklyDistribution[weekKey] ?? 0) + 1;
    }

    // Распределение по месяцам
    final monthlyDistribution = <String, int>{};
    for (final session in filteredSessions) {
      final monthKey = '${session.startTime.month}/${session.startTime.year}';
      monthlyDistribution[monthKey] = (monthlyDistribution[monthKey] ?? 0) + 1;
    }

    // Генерируем инсайты
    final insights = _generateInsights(
      filteredSessions,
      totalSessions,
      totalRounds,
      totalTime,
    );

    return PeriodStats(
      startDate: startDate,
      endDate: endDate,
      totalSessions: totalSessions,
      totalRounds: totalRounds,
      totalTime: totalTime,
      averageSessionTime: averageSessionTime,
      averageRoundsPerSession: averageRoundsPerSession,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      dailyData: dailyData,
      weeklyDistribution: weeklyDistribution,
      monthlyDistribution: monthlyDistribution,
      insights: insights,
    );
  }

  /// Вычисляет текущую серию
  int _calculateCurrentStreak() {
    if (_sessions.isEmpty) return 0;

    final sortedSessions = List<JapaSession>.from(_sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    int currentStreak = 0;
    DateTime? lastDate;
    final today = DateTime.now();

    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        final daysDifference = today.difference(sessionDate).inDays;
        if (daysDifference <= 1) {
          currentStreak = 1;
          lastDate = sessionDate;
        } else {
          break;
        }
      } else {
        final daysDifference = lastDate.difference(sessionDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }

    return currentStreak;
  }

  /// Получает номер недели
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  /// Генерирует инсайты на основе данных
  List<String> _generateInsights(
    List<JapaSession> sessions,
    int totalSessions,
    int totalRounds,
    int totalTime,
  ) {
    final insights = <String>[];

    if (totalSessions == 0) {
      insights.add('Начните практику джапы для получения статистики');
      return insights;
    }

    // Анализ времени практики
    final morningSessions = sessions
        .where((s) => s.startTime.hour >= 5 && s.startTime.hour < 12)
        .length;
    final eveningSessions = sessions
        .where((s) => s.startTime.hour >= 17 && s.startTime.hour < 22)
        .length;

    if (morningSessions > eveningSessions) {
      insights.add('Вы предпочитаете практиковать утром - отличная привычка!');
    } else if (eveningSessions > morningSessions) {
      insights.add(
        'Вы предпочитаете практиковать вечером - хороший способ завершить день',
      );
    }

    // Анализ продолжительности сессий
    final averageDuration = totalTime / totalSessions;
    if (averageDuration > 1800) {
      // больше 30 минут
      insights.add(
        'Ваши сессии довольно продолжительные - это показывает глубокую преданность',
      );
    } else if (averageDuration < 600) {
      // меньше 10 минут
      insights.add(
        'Попробуйте увеличить продолжительность сессий для лучших результатов',
      );
    }

    // Анализ серий
    final currentStreak = _calculateCurrentStreak();
    if (currentStreak >= 7) {
      insights.add(
        'Отличная серия! Вы практикуете уже $currentStreak дней подряд',
      );
    } else if (currentStreak >= 3) {
      insights.add('Хорошая серия! Продолжайте в том же духе');
    }

    // Анализ прогресса
    if (sessions.length >= 10) {
      final recentSessions = sessions.take(5).toList();
      final olderSessions = sessions.skip(sessions.length - 5).take(5).toList();

      final recentAvg =
          recentSessions.fold(0, (sum, s) => sum + s.completedRounds) /
          recentSessions.length;
      final olderAvg =
          olderSessions.fold(0, (sum, s) => sum + s.completedRounds) /
          olderSessions.length;

      if (recentAvg > olderAvg) {
        insights.add(
          'Вы показываете отличный прогресс! Количество кругов увеличивается',
        );
      }
    }

    return insights;
  }

  /// Получает все сессии
  List<JapaSession> get sessions => List.unmodifiable(_sessions);

  /// Получает данные аналитики
  List<AnalyticsData> get analyticsData => List.unmodifiable(_analyticsData);

  /// Получает статистику за последние 7 дней
  Future<PeriodStats> getLastWeekStats() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    return getPeriodStats(startDate, endDate);
  }

  /// Получает статистику за последний месяц
  Future<PeriodStats> getLastMonthStats() async {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
    return getPeriodStats(startDate, endDate);
  }

  /// Получает статистику за последний год
  Future<PeriodStats> getLastYearStats() async {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    return getPeriodStats(startDate, endDate);
  }

  /// Сбрасывает все данные (для тестирования)
  Future<void> resetData() async {
    _sessions.clear();
    _analyticsData.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    await prefs.remove(_analyticsKey);
  }
}
