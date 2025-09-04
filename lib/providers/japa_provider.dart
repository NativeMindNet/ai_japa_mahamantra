import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/japa_session.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../services/calendar_service.dart';
import '../services/audio_service.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../constants/app_constants.dart';

class JapaProvider with ChangeNotifier {
  // Текущая сессия
  JapaSession? _currentSession;
  
  // Состояние сессии
  bool _isSessionActive = false;
  bool _isPaused = false;
  
  // Прогресс
  int _currentRound = 0;
  int _targetRounds = 16;
  int _currentBead = 0;
  int _completedRounds = 0;
  
  // Время
  DateTime? _sessionStartTime;
  DateTime? _sessionPauseTime;
  Duration _totalPauseTime = Duration.zero;
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;
  
  // Настройки
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _autoStartEnabled = false;
  
  // Статистика
  int _totalSessions = 0;
  int _totalRounds = 0;
  Duration _totalTime = Duration.zero;
  
  // Геттеры
  JapaSession? get currentSession => _currentSession;
  bool get isSessionActive => _isSessionActive;
  bool get isPaused => _isPaused;
  int get currentRound => _currentRound;
  int get targetRounds => _targetRounds;
  int get currentBead => _currentBead;
  int get completedRounds => _completedRounds;
  Duration get sessionDuration => _sessionDuration;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoStartEnabled => _autoStartEnabled;
  int get totalSessions => _totalSessions;
  int get totalRounds => _totalRounds;
  Duration get totalTime => _totalTime;
  
  JapaProvider() {
    _loadSettings();
    _loadStatistics();
    _checkAutoStart();
    _initializeAudioService();
  }
  
  /// Инициализирует аудио сервис
  Future<void> _initializeAudioService() async {
    try {
      await AudioService().initialize();
    } catch (e) {
      print('Ошибка инициализации AudioService: $e');
    }
  }
  
  /// Загружает настройки
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoStartEnabled = prefs.getBool('auto_start_enabled') ?? false;
      _targetRounds = prefs.getInt('target_rounds') ?? 16;
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки настроек: $e');
    }
  }
  
  /// Сохраняет настройки
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vibration_enabled', _vibrationEnabled);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('auto_start_enabled', _autoStartEnabled);
      await prefs.setInt('target_rounds', _targetRounds);
    } catch (e) {
      print('Ошибка сохранения настроек: $e');
    }
  }
  
  /// Загружает статистику
  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalSessions = prefs.getInt('total_sessions') ?? 0;
      _totalRounds = prefs.getInt('total_rounds') ?? 0;
      final totalMinutes = prefs.getInt('total_time_minutes') ?? 0;
      _totalTime = Duration(minutes: totalMinutes);
      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
    }
  }
  
  /// Сохраняет статистику
  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('total_sessions', _totalSessions);
      await prefs.setInt('total_rounds', _totalRounds);
      await prefs.setInt('total_time_minutes', _totalTime.inMinutes);
    } catch (e) {
      print('Ошибка сохранения статистики: $e');
    }
  }
  
  /// Проверяет автозапуск
  Future<void> _checkAutoStart() async {
    if (!_autoStartEnabled) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSessionDate = prefs.getString('last_session_date');
      
      if (lastSessionDate != null) {
        final lastSession = DateTime.parse(lastSessionDate);
        final now = DateTime.now();
        
        // Если прошло больше 24 часов, предлагаем начать сессию
        if (now.difference(lastSession).inHours >= 24) {
          if (_notificationsEnabled) {
            await NotificationService.showJapaReminder(
              title: 'Время для джапы! 🕉️',
              body: 'Прошло 24 часа с последней сессии. Начните новую практику.',
              payload: 'auto_start_reminder',
            );
          }
        }
      }
    } catch (e) {
      print('Ошибка проверки автозапуска: $e');
    }
  }
  
  /// Устанавливает целевое количество кругов
  void setTargetRounds(int rounds) {
    if (rounds > 0 && rounds <= 64) {
      _targetRounds = rounds;
      _saveSettings();
      notifyListeners();
    }
  }
  
  /// Включает/выключает вибрацию
  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  /// Включает/выключает звук
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    AudioService().setSoundEnabled(enabled);
    _saveSettings();
    notifyListeners();
  }
  
  /// Включает/выключает уведомления
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  /// Включает/выключает автозапуск
  void setAutoStartEnabled(bool enabled) {
    _autoStartEnabled = enabled;
    _saveSettings();
    notifyListeners();
    
    if (enabled) {
      BackgroundService.registerJapaReminder();
    } else {
      BackgroundService.cancelTask('japa_reminder');
    }
  }
  
  /// Начинает новую сессию
  void startSession() {
    if (_isSessionActive) return;
    
    _currentSession = JapaSession(
      id: DateTime.now().millisecondsSinceEpoch,
      startTime: DateTime.now(),
      targetRounds: _targetRounds,
    );
    
    _isSessionActive = true;
    _isPaused = false;
    _currentRound = 1;
    _currentBead = 1;
    _completedRounds = 0;
    _sessionStartTime = DateTime.now();
    _sessionPauseTime = null;
    _totalPauseTime = Duration.zero;
    _sessionDuration = Duration.zero;
    
    // Запускаем таймер
    _startSessionTimer();
    
    // Вибрация и звук
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }
    
    // Звук начала сессии
    if (_soundEnabled) {
      await AudioService().playEventSound('session_start');
    }
    
    // Уведомление о начале сессии
    if (_notificationsEnabled) {
      NotificationService.showJapaReminder(
        title: 'Сессия началась! 🕉️',
        body: 'Начинайте практику джапы. Цель: $_targetRounds кругов.',
        payload: 'session_started',
      );
    }
    
    notifyListeners();
  }
  
  /// Приостанавливает сессию
  void pauseSession() {
    if (!_isSessionActive || _isPaused) return;
    
    _isPaused = true;
    _sessionPauseTime = DateTime.now();
    _sessionTimer?.cancel();
    
    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.mediumVibration);
    }
    
    // Звук завершения круга
    if (_soundEnabled) {
      await AudioService().playEventSound('round_complete');
    }
    
    notifyListeners();
  }
  
  /// Возобновляет сессию
  void resumeSession() {
    if (!_isSessionActive || !_isPaused) return;
    
    _isPaused = false;
    if (_sessionPauseTime != null) {
      _totalPauseTime += DateTime.now().difference(_sessionPauseTime!);
      _sessionPauseTime = null;
    }
    
    // Возобновляем таймер
    _startSessionTimer();
    
    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }
    
    notifyListeners();
  }
  
  /// Перемещает к определенной бусине
  void moveToBead(int beadIndex) {
    if (!_isSessionActive || beadIndex < 0 || beadIndex > 108) return;
    
    _currentBead = beadIndex;
    
    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }
    
    // Проверяем, завершен ли круг
    if (_currentBead == 108) {
      _completeRound();
    }
    
    notifyListeners();
  }
  
  /// Переходит к следующей бусине
  void nextBead() {
    if (!_isSessionActive) return;
    
    if (_currentBead < 108) {
      _currentBead++;
    } else {
      _completeRound();
    }
    
    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }
    
    // Звук нажатия на бусину
    if (_soundEnabled) {
      AudioService().playEventSound('bead_click');
    }
    
    notifyListeners();
  }
  
  /// Завершает текущий круг
  void completeRound() {
    if (!_isSessionActive) return;
    
    _completeRound();
    notifyListeners();
  }
  
  /// Внутренний метод завершения круга
  void _completeRound() {
    _completedRounds++;
    
    // Добавляем круг в сессию
    if (_currentSession != null) {
      final round = JapaRound(
        roundNumber: _currentRound,
        startTime: _sessionStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationSeconds: _sessionDuration.inSeconds,
        isCompleted: true,
      );
      
      final updatedRounds = List<JapaRound>.from(_currentSession!.rounds);
      updatedRounds.add(round);
      
      _currentSession = _currentSession!.copyWith(
        completedRounds: _completedRounds,
        rounds: updatedRounds,
      );
    }
    
    // Вибрация завершения круга
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.mediumVibration);
    }
    
    // Уведомление о завершении круга
    if (_notificationsEnabled) {
      NotificationService.showRoundComplete(
        roundNumber: _currentRound,
        totalRounds: _targetRounds,
      );
    }
    
    // Проверяем, завершена ли сессия
    if (_completedRounds >= _targetRounds) {
      endSession();
      return;
    }
    
    // Начинаем новый круг
    _currentRound++;
    _currentBead = 1;
    
    // Обновляем время начала круга
    _sessionStartTime = DateTime.now();
    _sessionDuration = Duration.zero;
  }
  
  /// Завершает сессию
  void endSession() {
    if (!_isSessionActive) return;
    
    _isSessionActive = false;
    _isPaused = false;
    _sessionTimer?.cancel();
    
    // Завершаем сессию
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        isActive: false,
        completedRounds: _completedRounds,
        currentBead: _currentBead,
      );
    }
    
    // Обновляем статистику
    _totalSessions++;
    _totalRounds += _completedRounds;
    _totalTime += _sessionDuration;
    _saveStatistics();
    
    // Сохраняем дату последней сессии
    _saveLastSessionDate();
    
    // Сохраняем сессию в историю
    if (_currentSession != null) {
      await _saveSessionToHistory(_currentSession!);
      
      // Сохраняем событие в календарь
      await _saveSessionToCalendar(_currentSession!);
    }
    
    // Вибрация завершения сессии
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.longVibration);
    }
    
    // Звук завершения сессии
    if (_soundEnabled) {
      await AudioService().playEventSound('session_complete');
    }
    
    // Уведомление о завершении сессии
    if (_notificationsEnabled) {
      NotificationService.showSessionComplete(
        totalRounds: _completedRounds,
        duration: _sessionDuration,
      );
    }
    
    // Проверяем достижения
    await _checkAchievements();
    
    notifyListeners();
  }
  
  /// Сохраняет дату последней сессии
  Future<void> _saveLastSessionDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_session_date', DateTime.now().toIso8601String());
    } catch (e) {
      print('Ошибка сохранения даты сессии: $e');
    }
  }
  
  /// Проверяет достижения после завершения сессии
  Future<void> _checkAchievements() async {
    if (_currentSession == null) return;
    
    try {
      final achievementService = AchievementService();
      final newlyUnlocked = await achievementService.updateProgressFromSession(_currentSession!);
      
      // Показываем уведомления о новых достижениях
      for (final achievement in newlyUnlocked) {
        if (_notificationsEnabled) {
          NotificationService.showAchievementUnlocked(achievement);
        }
      }
    } catch (e) {
      print('Ошибка проверки достижений: $e');
    }
  }
  
  /// Запускает таймер сессии
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionActive && !_isPaused) {
        _sessionDuration = DateTime.now().difference(_sessionStartTime!) - _totalPauseTime;
        notifyListeners();
      }
    });
  }
  
  /// Сбрасывает сессию
  void resetSession() {
    _sessionTimer?.cancel();
    
    _currentSession = null;
    _isSessionActive = false;
    _isPaused = false;
    _currentRound = 0;
    _currentBead = 0;
    _completedRounds = 0;
    _sessionStartTime = null;
    _sessionPauseTime = null;
    _totalPauseTime = Duration.zero;
    _sessionDuration = Duration.zero;
    
    notifyListeners();
  }
  
  /// Получает статистику сессии
  Map<String, dynamic> getSessionStats() {
    if (_currentSession == null) return {};
    
    return {
      'totalRounds': _targetRounds,
      'completedRounds': _completedRounds,
      'currentRound': _currentRound,
      'currentBead': _currentBead,
      'sessionDuration': _sessionDuration,
      'isActive': _isSessionActive,
      'isPaused': _isPaused,
    };
  }
  
  /// Получает общую статистику
  Map<String, dynamic> getOverallStats() {
    return {
      'totalSessions': _totalSessions,
      'totalRounds': _totalRounds,
      'totalTime': _totalTime,
      'averageRoundsPerSession': _totalSessions > 0 ? (_totalRounds / _totalSessions).round() : 0,
      'averageTimePerSession': _totalSessions > 0 ? _totalTime.inMinutes ~/ _totalSessions : 0,
    };
  }
  
  /// Получает статистику за день
  Future<Map<String, dynamic>> getDailyStats(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = date.toIso8601String().split('T')[0];
      final dailyStats = prefs.getString('daily_stats_$dateKey');
      
      if (dailyStats != null) {
        return Map<String, dynamic>.from(
          dailyStats as Map<String, dynamic>
        );
      }
      
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// Получает статистику за неделю
  Future<Map<String, dynamic>> getWeeklyStats(DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final stats = <String, dynamic>{};
      
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dailyStats = await getDailyStats(date);
        stats[date.toIso8601String().split('T')[0]] = dailyStats;
      }
      
      return stats;
    } catch (e) {
      return {};
    }
  }
  
  /// Получает статистику за месяц
  Future<Map<String, dynamic>> getMonthlyStats(DateTime monthStart) async {
    try {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);
      final daysInMonth = monthEnd.day;
      final stats = <String, dynamic>{};
      
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(monthStart.year, monthStart.month, i);
        final dailyStats = await getDailyStats(date);
        stats[date.toIso8601String().split('T')[0]] = dailyStats;
      }
      
      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Получает историю сессий
  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('japa_sessions_history') ?? [];
      
      final sessions = <Map<String, dynamic>>[];
      
      for (final jsonString in sessionsJson) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          sessions.add(json);
        } catch (e) {
          print('Ошибка при загрузке сессии: $e');
        }
      }
      
      // Сортируем по дате (новые сверху)
      sessions.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
      
      return sessions;
    } catch (e) {
      print('Ошибка при получении истории сессий: $e');
      return [];
    }
  }

  /// Сохраняет сессию в историю
  Future<void> _saveSessionToHistory(JapaSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('japa_sessions_history') ?? [];
      
      final sessionData = {
        'id': session.id,
        'startTime': session.startTime.toIso8601String(),
        'endTime': session.endTime?.toIso8601String(),
        'completedRounds': session.completedRounds,
        'targetRounds': session.targetRounds,
        'duration': session.endTime != null 
            ? session.endTime!.difference(session.startTime).inMinutes 
            : 0,
        'date': session.startTime.toIso8601String().split('T')[0],
        'isActive': session.isActive,
      };
      
      sessionsJson.add(jsonEncode(sessionData));
      
      // Ограничиваем количество сохраненных сессий (последние 50)
      if (sessionsJson.length > 50) {
        sessionsJson.removeRange(0, sessionsJson.length - 50);
      }
      
      await prefs.setStringList('japa_sessions_history', sessionsJson);
      
    } catch (e) {
      print('Ошибка при сохранении сессии в историю: $e');
    }
  }

  /// Сохраняет сессию в календарь
  Future<void> _saveSessionToCalendar(JapaSession session) async {
    try {
      if (session.endTime == null) return;
      
      final duration = session.endTime!.difference(session.startTime);
      
      final calendarEvent = CalendarService.createJapaEvent(
        date: session.startTime,
        rounds: session.completedRounds,
        duration: duration,
        notes: 'Сессия джапы завершена успешно',
      );
      
      await CalendarService.saveJapaEvent(calendarEvent);
    } catch (e) {
      print('Ошибка при сохранении сессии в календарь: $e');
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
