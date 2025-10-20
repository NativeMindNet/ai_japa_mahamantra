import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'encrypted_log_service.dart';
import 'mozgach108_service.dart';
import 'ai_power_mode_service.dart';
import 'notification_service.dart';

/// Сервис для воспевания при спящем режиме и на зарядке
/// Реализует Правило № 4: Постоянное воспевание для утилизации свободных ресурсов
///
/// Особенности:
/// - Автоматическое воспевание при подключении зарядки
/// - Воспевание в фоновом режиме при спящем экране
/// - Сохранение результатов в зашифрованный лог
/// - Использование AI моделей или Low Power режима
class ChargingChantingService {
  static ChargingChantingService? _instance;

  bool _isInitialized = false;
  bool _isChanting = false;
  bool _isCharging = false;
  int _batteryLevel = 100;

  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _chantingTimer;

  // Настройки
  bool _enableOnCharging = true;
  bool _enableInSleepMode = false;
  bool _useAIModels = true;
  int _chantingIntervalSeconds = 30; // Интервал между воспеваниями

  // Статистика
  int _totalChants = 0;
  int _chantsDuringCharging = 0;
  int _chantsDuringSleep = 0;
  DateTime? _lastChantTime;
  DateTime? _chargingStartTime;

  // Константы
  static const String _mahamantra =
      "Харе Кришна Харе Кришна Кришна Кришна Харе Харей Харе Рама Харе Рама Рама Рама Харей Харе";

  ChargingChantingService._();

  /// Получить singleton экземпляр
  static ChargingChantingService get instance {
    _instance ??= ChargingChantingService._();
    return _instance!;
  }

  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Загружаем настройки
      await _loadSettings();

      // Инициализируем необходимые сервисы
      await EncryptedLogService.instance.initialize();
      await AIPowerModeService.instance.initialize();

      // Проверяем текущее состояние батареи
      await _checkBatteryState();

      // Подписываемся на изменения состояния батареи
      _subscribeToBatteryState();

      _isInitialized = true;
      debugPrint('ChargingChantingService инициализирован');

      return true;
    } catch (e) {
      debugPrint('Ошибка инициализации ChargingChantingService: $e');
      return false;
    }
  }

  /// Загрузка настроек из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _enableOnCharging = prefs.getBool('charging_chanting_enabled') ?? true;
    _enableInSleepMode = prefs.getBool('sleep_chanting_enabled') ?? false;
    _useAIModels = prefs.getBool('charging_use_ai') ?? true;
    _chantingIntervalSeconds = prefs.getInt('chanting_interval_seconds') ?? 30;

    _totalChants = prefs.getInt('total_chants') ?? 0;
    _chantsDuringCharging = prefs.getInt('chants_during_charging') ?? 0;
    _chantsDuringSleep = prefs.getInt('chants_during_sleep') ?? 0;

    final lastChantStr = prefs.getString('last_chant_time');
    if (lastChantStr != null) {
      _lastChantTime = DateTime.parse(lastChantStr);
    }
  }

  /// Сохранение настроек в SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('charging_chanting_enabled', _enableOnCharging);
    await prefs.setBool('sleep_chanting_enabled', _enableInSleepMode);
    await prefs.setBool('charging_use_ai', _useAIModels);
    await prefs.setInt('chanting_interval_seconds', _chantingIntervalSeconds);

    await prefs.setInt('total_chants', _totalChants);
    await prefs.setInt('chants_during_charging', _chantsDuringCharging);
    await prefs.setInt('chants_during_sleep', _chantsDuringSleep);

    if (_lastChantTime != null) {
      await prefs.setString(
        'last_chant_time',
        _lastChantTime!.toIso8601String(),
      );
    }
  }

  /// Проверка текущего состояния батареи
  Future<void> _checkBatteryState() async {
    try {
      final batteryState = await _battery.batteryState;
      _batteryLevel = await _battery.batteryLevel;

      _isCharging =
          batteryState == BatteryState.charging ||
          batteryState == BatteryState.full;

      debugPrint(
        'Состояние батареи: ${batteryState.name}, уровень: $_batteryLevel%',
      );

      // Обновляем состояние воспевания
      await _updateChantingState();
    } catch (e) {
      debugPrint('Ошибка проверки состояния батареи: $e');
    }
  }

  /// Подписка на изменения состояния батареи
  void _subscribeToBatteryState() {
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) async {
      debugPrint('Состояние батареи изменилось: ${state.name}');

      final wasCharging = _isCharging;
      _isCharging =
          state == BatteryState.charging || state == BatteryState.full;

      if (_isCharging && !wasCharging) {
        // Зарядка началась
        _chargingStartTime = DateTime.now();

        // Показываем уведомление
        if (_enableOnCharging) {
          await NotificationService.showJapaReminder(
            title: '🔋 Зарядка началась - воспевание активировано',
            body:
                'Устройство на зарядке. Махамантра будет воспеваться автоматически. Харе Кришна!',
            payload: 'charging_chanting_started',
          );
        }
      } else if (!_isCharging && wasCharging) {
        // Зарядка закончилась
        final chargingDuration = _chargingStartTime != null
            ? DateTime.now().difference(_chargingStartTime!)
            : Duration.zero;

        // Показываем уведомление с результатами
        if (_enableOnCharging && _chargingStartTime != null) {
          await NotificationService.showJapaReminder(
            title: '🔋 Зарядка завершена',
            body:
                'Время на зарядке: ${chargingDuration.inMinutes} мин. '
                'Воспевано мантр: $_chantsDuringCharging. Харе Кришна!',
            payload: 'charging_chanting_ended',
          );
        }

        _chargingStartTime = null;
      }

      await _updateChantingState();
    });
  }

  /// Обновление состояния воспевания
  Future<void> _updateChantingState() async {
    final shouldChant =
        (_enableOnCharging && _isCharging) || _enableInSleepMode;

    if (shouldChant && !_isChanting) {
      await _startChanting();
    } else if (!shouldChant && _isChanting) {
      await _stopChanting();
    }
  }

  /// Начать воспевание
  Future<void> _startChanting() async {
    if (_isChanting) return;

    _isChanting = true;

    try {
      // Включаем wakelock для постоянной работы (аналогично "Keep screen on" для разработчиков)
      await WakelockPlus.enable();
      debugPrint('Wakelock активирован - устройство не будет засыпать');

      // Запускаем периодическое воспевание
      _chantingTimer = Timer.periodic(
        Duration(seconds: _chantingIntervalSeconds),
        (_) => _performChant(),
      );

      // Выполняем первое воспевание сразу
      await _performChant();

      debugPrint(
        'Воспевание началось (интервал: $_chantingIntervalSeconds сек)',
      );
    } catch (e) {
      debugPrint('Ошибка запуска воспевания: $e');
      _isChanting = false;
    }
  }

  /// Остановить воспевание
  Future<void> _stopChanting() async {
    if (!_isChanting) return;

    _isChanting = false;

    try {
      // Отключаем wakelock
      await WakelockPlus.disable();
      debugPrint('Wakelock деактивирован');

      // Останавливаем таймер
      _chantingTimer?.cancel();
      _chantingTimer = null;

      debugPrint('Воспевание остановлено');
    } catch (e) {
      debugPrint('Ошибка остановки воспевания: $e');
    }
  }

  /// Выполнить одно воспевание
  Future<void> _performChant() async {
    try {
      final startTime = DateTime.now();
      _lastChantTime = startTime;

      String result;

      if (_useAIModels) {
        // Используем AI модели (High Power Mode)
        final aiService = AIPowerModeService.instance;
        final isHighPowerMode = aiService.isAcceleratorAvailable;

        if (isHighPowerMode) {
          // Обрабатываем через Мозgач108
          final mozgachService = Mozgach108Service.instance;

          try {
            // Обрабатываем через все 108 моделей
            await mozgachService.processMantraThroughAll108Models(
              mantra: _mahamantra,
              beadNumber: _totalChants % 108,
              roundNumber: (_totalChants / 108).floor() + 1,
            );
            result = 'AI обработка через 108 моделей завершена';
          } catch (e) {
            debugPrint('Ошибка AI обработки: $e');
            result = await _simpleLowPowerChant();
          }
        } else {
          // Low Power Mode - простая конкатенация
          result = await _simpleLowPowerChant();
        }
      } else {
        // Всегда используем Low Power Mode
        result = await _simpleLowPowerChant();
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Обновляем статистику
      _totalChants++;
      if (_isCharging) {
        _chantsDuringCharging++;
      }
      if (_enableInSleepMode) {
        _chantsDuringSleep++;
      }

      await _saveSettings();

      // Логируем результат в зашифрованный лог
      await _logChantResult(result, duration, startTime);

      // Легкая вибрация (если доступна)
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 50);
      }

      debugPrint(
        'Воспевание выполнено #$_totalChants (${duration.inMilliseconds}ms)',
      );
    } catch (e) {
      debugPrint('Ошибка выполнения воспевания: $e');
    }
  }

  /// Простое воспевание в Low Power режиме (конкатенация строк)
  Future<String> _simpleLowPowerChant() async {
    final buffer = StringBuffer();
    buffer.writeln('=== Low Power Режим Воспевания ===');
    buffer.writeln('Время: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Режим: ${_isCharging ? "На зарядке" : "Спящий режим"}');
    buffer.writeln('Батарея: $_batteryLevel%');
    buffer.writeln();
    buffer.writeln(_mahamantra);
    buffer.writeln();
    buffer.writeln('Харе Кришна! 🕉️');

    return buffer.toString();
  }

  /// Логирование результата воспевания
  Future<void> _logChantResult(
    String result,
    Duration duration,
    DateTime timestamp,
  ) async {
    try {
      final metadata = {
        'duration_ms': duration.inMilliseconds,
        'is_charging': _isCharging,
        'battery_level': _batteryLevel,
        'total_chants': _totalChants,
        'chants_during_charging': _chantsDuringCharging,
        'mode': _useAIModels ? 'AI' : 'Low Power',
      };

      await EncryptedLogService.instance.addLogEntry(
        logType: 'charging_chanting',
        message: result,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Ошибка логирования воспевания: $e');
    }
  }

  /// Включить/выключить воспевание на зарядке
  Future<void> setChargingChantingEnabled(bool enabled) async {
    _enableOnCharging = enabled;
    await _saveSettings();
    await _updateChantingState();

    debugPrint('Воспевание на зарядке: ${enabled ? "включено" : "отключено"}');
  }

  /// Включить/выключить воспевание в спящем режиме
  Future<void> setSleepChantingEnabled(bool enabled) async {
    _enableInSleepMode = enabled;
    await _saveSettings();
    await _updateChantingState();

    debugPrint(
      'Воспевание в спящем режиме: ${enabled ? "включено" : "отключено"}',
    );
  }

  /// Установить использование AI моделей
  Future<void> setUseAIModels(bool useAI) async {
    _useAIModels = useAI;
    await _saveSettings();

    debugPrint('Использование AI моделей: ${useAI ? "включено" : "отключено"}');
  }

  /// Установить интервал воспевания (в секундах)
  Future<void> setChantingInterval(int seconds) async {
    if (seconds < 10) seconds = 10; // Минимум 10 секунд
    if (seconds > 3600) seconds = 3600; // Максимум 1 час

    _chantingIntervalSeconds = seconds;
    await _saveSettings();

    // Перезапускаем таймер, если воспевание активно
    if (_isChanting) {
      await _stopChanting();
      await _startChanting();
    }

    debugPrint('Интервал воспевания установлен: $seconds секунд');
  }

  /// Получить статистику воспевания
  Map<String, dynamic> getStatistics() {
    return {
      'is_initialized': _isInitialized,
      'is_chanting': _isChanting,
      'is_charging': _isCharging,
      'battery_level': _batteryLevel,
      'enable_on_charging': _enableOnCharging,
      'enable_in_sleep': _enableInSleepMode,
      'use_ai_models': _useAIModels,
      'interval_seconds': _chantingIntervalSeconds,
      'total_chants': _totalChants,
      'chants_during_charging': _chantsDuringCharging,
      'chants_during_sleep': _chantsDuringSleep,
      'last_chant_time': _lastChantTime?.toIso8601String(),
      'charging_start_time': _chargingStartTime?.toIso8601String(),
    };
  }

  /// Получить текущий статус
  String getStatus() {
    if (!_isInitialized) return 'Не инициализирован';
    if (_isChanting && _isCharging) return 'Воспевание на зарядке';
    if (_isChanting) return 'Воспевание в спящем режиме';
    if (_isCharging) return 'На зарядке (воспевание отключено)';
    return 'Ожидание';
  }

  /// Проверить, активно ли воспевание
  bool get isChanting => _isChanting;

  /// Проверить, идет ли зарядка
  bool get isCharging => _isCharging;

  /// Получить уровень батареи
  int get batteryLevel => _batteryLevel;

  /// Получить количество воспеваний
  int get totalChants => _totalChants;

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _stopChanting();
    await _batteryStateSubscription?.cancel();
    _batteryStateSubscription = null;
    _isInitialized = false;

    debugPrint('ChargingChantingService освобожден');
  }
}
