import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/japa_session.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../services/calendar_service.dart';
import '../services/audio_service.dart';
import '../services/achievement_service.dart';
import '../services/magento_service.dart';
import '../services/connectivity_service.dart';
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

  // Облачные сервисы
  final MagentoService _magentoService = MagentoService();
  final ConnectivityService _connectivityService = ConnectivityService();

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
    _initializeCloudServices();
  }

  /// Инициализирует аудио сервис
  Future<void> _initializeAudioService() async {
    try {
      await AudioService().initialize();
    } catch (e) {
      // silent
    }
  }

  /// Инициализирует облачные сервисы
  Future<void> _initializeCloudServices() async {
    try {
      await _connectivityService.initialize();

      // Загружаем настройки Magento и инициализируем, если включены облачные функции
      final prefs = await SharedPreferences.getInstance();
      final cloudEnabled = prefs.getBool('cloud_features_enabled') ?? false;

      if (cloudEnabled) {
        final baseUrl = prefs.getString('magento_base_url') ?? '';
        final consumerKey = prefs.getString('magento_consumer_key') ?? '';
        final consumerSecret = prefs.getString('magento_consumer_secret') ?? '';
        final accessToken = prefs.getString('magento_access_token') ?? '';
        final accessTokenSecret =
            prefs.getString('magento_access_token_secret') ?? '';

        if (baseUrl.isNotEmpty) {
          await _magentoService.initialize(
            baseUrl: baseUrl,
            consumerKey: consumerKey.isEmpty ? null : consumerKey,
            consumerSecret: consumerSecret.isEmpty ? null : consumerSecret,
            accessToken: accessToken.isEmpty ? null : accessToken,
            accessTokenSecret: accessTokenSecret.isEmpty
                ? null
                : accessTokenSecret,
          );
        }
      }
    } catch (e) {
      // silent
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
      // silent
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
      // silent
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
      // silent
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
      // silent
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
              body:
                  'Прошло 24 часа с последней сессии. Начните новую практику.',
              payload: 'auto_start_reminder',
            );
          }
        }
      }
    } catch (e) {
      // silent
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
  Future<void> startSession() async {
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
  Future<void> pauseSession() async {
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
  Future<void> moveToBead(int beadIndex) async {
    if (!_isSessionActive || beadIndex < 0 || beadIndex > 108) return;

    _currentBead = beadIndex;

    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }

    // Проверяем, завершен ли круг
    if (_currentBead == 108) {
      await _completeRound();
    }

    notifyListeners();
  }

  /// Переходит к следующей бусине
  Future<void> nextBead() async {
    if (!_isSessionActive) return;

    if (_currentBead < 108) {
      _currentBead++;
    } else {
      await _completeRound();
    }

    // Вибрация
    if (_vibrationEnabled) {
      Vibration.vibrate(duration: AppConstants.shortVibration);
    }

    // Звук нажатия на бусину
    if (_soundEnabled) {
      await AudioService().playEventSound('bead_click');
    }

    notifyListeners();
  }

  /// Завершает текущий круг
  Future<void> completeRound() async {
    if (!_isSessionActive) return;

    await _completeRound();
    notifyListeners();
  }

  /// Внутренний метод завершения круга
  Future<void> _completeRound() async {
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
      await endSession();
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
  Future<void> endSession() async {
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

    // Синхронизируем с облаком
    await _syncWithCloud();

    notifyListeners();
  }

  /// Сохраняет дату последней сессии
  Future<void> _saveLastSessionDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_session_date',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // silent
    }
  }

  /// Проверяет достижения после завершения сессии
  Future<void> _checkAchievements() async {
    if (_currentSession == null) return;

    try {
      final achievementService = AchievementService();
      final newlyUnlocked = await achievementService.updateProgressFromSession(
        _currentSession!,
      );

      // Показываем уведомления о новых достижениях
      for (final achievement in newlyUnlocked) {
        if (_notificationsEnabled) {
          NotificationService.showAchievementUnlocked(achievement);
        }
      }
    } catch (e) {
      // silent
    }
  }

  /// Запускает таймер сессии
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSessionActive && !_isPaused) {
        _sessionDuration =
            DateTime.now().difference(_sessionStartTime!) - _totalPauseTime;
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
      'averageRoundsPerSession': _totalSessions > 0
          ? (_totalRounds / _totalSessions).round()
          : 0,
      'averageTimePerSession': _totalSessions > 0
          ? _totalTime.inMinutes ~/ _totalSessions
          : 0,
    };
  }

  /// Получает статистику за день
  Future<Map<String, dynamic>> getDailyStats(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = date.toIso8601String().split('T')[0];
      final dailyStatsJson = prefs.getString('daily_stats_$dateKey');

      if (dailyStatsJson != null) {
        return jsonDecode(dailyStatsJson) as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  /// Получает статистику за неделю
  Future<Map<String, dynamic>> getWeeklyStats(DateTime weekStart) async {
    try {
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
          // silent
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
      // silent
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
      // silent
    }
  }

  /// Синхронизирует данные с облаком
  Future<void> _syncWithCloud() async {
    try {
      if (!_magentoService.isCloudAvailable) {
        return; // Облачные функции недоступны
      }

      // Получаем ID пользователя (создаем если нет)
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('user_id', userId);
      }

      // Создаем объект данных для синхронизации
      final cloudData = JapaCloudData(
        userId: userId,
        totalCount: _totalRounds,
        todayCount: await _getTodayRounds(),
        lastUpdate: DateTime.now(),
        achievements: await _getAchievementsData(),
        statistics: _getStatisticsData(),
      );

      // Автоматическая синхронизация (не чаще раз в 5 минут)
      await _magentoService.autoSync(cloudData);
    } catch (e) {
      // Молча игнорируем ошибки синхронизации
      debugPrint('Ошибка синхронизации с облаком: $e');
    }
  }

  /// Получает количество кругов за сегодня
  Future<int> _getTodayRounds() async {
    try {
      final today = DateTime.now();
      final dailyStats = await getDailyStats(today);
      return dailyStats['totalRounds'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Получает данные достижений для синхронизации
  Future<Map<String, dynamic>> _getAchievementsData() async {
    try {
      final achievementService = AchievementService();
      final achievements = await achievementService.getAllAchievements();

      final achievementsData = <String, dynamic>{};
      for (final achievement in achievements) {
        achievementsData[achievement['id']] = {
          'unlocked': achievement['unlocked'],
          'progress': achievement['progress'],
          'unlockedAt': achievement['unlockedAt'],
        };
      }

      return achievementsData;
    } catch (e) {
      return {};
    }
  }

  /// Получает статистические данные для синхронизации
  Map<String, dynamic> _getStatisticsData() {
    return {
      'totalSessions': _totalSessions,
      'totalRounds': _totalRounds,
      'totalTimeMinutes': _totalTime.inMinutes,
      'averageRoundsPerSession': _totalSessions > 0
          ? (_totalRounds / _totalSessions).round()
          : 0,
      'averageTimePerSession': _totalSessions > 0
          ? _totalTime.inMinutes ~/ _totalSessions
          : 0,
      'lastSessionDate': DateTime.now().toIso8601String(),
    };
  }

  /// Принудительная синхронизация с облаком
  Future<bool> forceSyncWithCloud() async {
    try {
      if (!_magentoService.isCloudAvailable) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('user_id', userId);
      }

      final cloudData = JapaCloudData(
        userId: userId,
        totalCount: _totalRounds,
        todayCount: await _getTodayRounds(),
        lastUpdate: DateTime.now(),
        achievements: await _getAchievementsData(),
        statistics: _getStatisticsData(),
      );

      final success = await _magentoService.syncJapaData(cloudData);

      if (success) {
        // Отправляем уведомление о достижениях в облако
        if (_currentSession != null && _currentSession!.completedRounds > 0) {
          await _magentoService.reportAchievement(userId, 'session_completed', {
            'rounds': _currentSession!.completedRounds,
            'duration': _sessionDuration.inMinutes,
            'date': DateTime.now().toIso8601String(),
          });
        }
      }

      return success;
    } catch (e) {
      debugPrint('Ошибка принудительной синхронизации: $e');
      return false;
    }
  }

  /// Загружает данные из облака
  Future<bool> loadFromCloud() async {
    try {
      if (!_magentoService.isCloudAvailable) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        return false;
      }

      final cloudData = await _magentoService.loadJapaData(userId);

      if (cloudData != null) {
        // Обновляем локальные данные из облака (только если они новее)
        final lastLocalUpdate = prefs.getString('last_cloud_sync_date');
        final localUpdateTime = lastLocalUpdate != null
            ? DateTime.tryParse(lastLocalUpdate)
            : DateTime(2000);

        if (localUpdateTime == null ||
            cloudData.lastUpdate.isAfter(localUpdateTime)) {
          // Обновляем статистику
          _totalRounds = cloudData.totalCount;
          _totalSessions =
              cloudData.statistics['totalSessions'] ?? _totalSessions;
          _totalTime = Duration(
            minutes: cloudData.statistics['totalTimeMinutes'] ?? 0,
          );

          // Сохраняем обновленные данные
          await _saveStatistics();
          await prefs.setString(
            'last_cloud_sync_date',
            cloudData.lastUpdate.toIso8601String(),
          );

          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Ошибка загрузки из облака: $e');
      return false;
    }
  }

  /// Получает персональные рекомендации из облака
  Future<List<Map<String, dynamic>>> getCloudRecommendations() async {
    try {
      if (!_magentoService.isCloudAvailable) {
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        return [];
      }

      final recommendations = await _magentoService
          .getPersonalizedRecommendations(userId);
      return recommendations ?? [];
    } catch (e) {
      debugPrint('Ошибка получения рекомендаций: $e');
      return [];
    }
  }

  /// Проверяет доступность облачных функций
  bool get isCloudAvailable => _magentoService.isCloudAvailable;

  /// Проверяет подключение к интернету
  bool get isOnline => _connectivityService.isOnline;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}
