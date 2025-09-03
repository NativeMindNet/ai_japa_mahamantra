import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/japa_session.dart';
import '../services/ai_service.dart';

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
  
  // Геттеры
  JapaSession? get currentSession => _currentSession;
  bool get isSessionActive => _isSessionActive;
  bool get isPaused => _isPaused;
  int get currentRound => _currentRound;
  int get targetRounds => _targetRounds;
  int get currentBead => _currentBead;
  int get completedRounds => _completedRounds;
  Duration get sessionDuration => _sessionDuration;
  
  /// Устанавливает целевое количество кругов
  void setTargetRounds(int rounds) {
    if (rounds > 0 && rounds <= 64) {
      _targetRounds = rounds;
      notifyListeners();
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
    
    notifyListeners();
  }
  
  /// Приостанавливает сессию
  void pauseSession() {
    if (!_isSessionActive || _isPaused) return;
    
    _isPaused = true;
    _sessionPauseTime = DateTime.now();
    _sessionTimer?.cancel();
    
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
    
    notifyListeners();
  }
  
  /// Перемещает к определенной бусине
  void moveToBead(int beadIndex) {
    if (!_isSessionActive || beadIndex < 0 || beadIndex > 108) return;
    
    _currentBead = beadIndex;
    
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
    
    // Проверяем, завершена ли сессия
    if (_completedRounds >= _targetRounds) {
      _endSession();
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
    
    notifyListeners();
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
  
  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
