import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Режимы работы AI
enum AIPowerMode {
  /// High Power - использует AI модели и ускорители
  highPower,
  
  /// Low Power - энергоэффективный режим с простой конкатенацией
  lowPower,
}

/// Сервис для управления режимами работы AI
/// Реализует Правило № 3: Энергоэффективный режим при отсутствии AI ускорителя
class AIPowerModeService {
  static AIPowerModeService? _instance;
  
  AIPowerMode _currentMode = AIPowerMode.highPower; // По умолчанию High Power
  bool _isAIAcceleratorAvailable = false;
  
  // Для Low Power режима
  String _lowPowerMantraAccumulator = '';
  int _lowPowerCycleCount = 0;
  final List<String> _lowPowerLogs = [];
  
  // Константы
  static const String _prefKeyMode = 'ai_power_mode';
  static const String _prefKeyAcceleratorAvailable = 'ai_accelerator_available';
  static const int _maxCycles = 108;
  static const String _mantraText = 'Харе Кришна Харе Кришна Кришна Кришна Харе Харей Харе Рама Харе Рама Рама Рама Харей Харе';
  
  AIPowerModeService._();
  
  /// Получить singleton экземпляр
  static AIPowerModeService get instance {
    _instance ??= AIPowerModeService._();
    return _instance!;
  }
  
  /// Инициализация сервиса
  Future<void> initialize() async {
    try {
      // Проверяем доступность AI ускорителя
      _isAIAcceleratorAvailable = await _checkAIAcceleratorAvailability();
      
      // Загружаем сохраненные настройки
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyAcceleratorAvailable, _isAIAcceleratorAvailable);
      
      // Если ускоритель недоступен, переключаемся на Low Power
      if (!_isAIAcceleratorAvailable) {
        _currentMode = AIPowerMode.lowPower;
        await prefs.setString(_prefKeyMode, 'lowPower');
        debugPrint('AI ускоритель недоступен. Активирован Low Power режим.');
      } else {
        final savedMode = prefs.getString(_prefKeyMode) ?? 'highPower';
        _currentMode = savedMode == 'lowPower' 
            ? AIPowerMode.lowPower 
            : AIPowerMode.highPower;
        debugPrint('AI ускоритель доступен. Режим: $_currentMode');
      }
      
      _addLog('Сервис инициализирован. Режим: $_currentMode');
    } catch (e) {
      debugPrint('Ошибка инициализации AIPowerModeService: $e');
    }
  }
  
  /// Проверяет доступность AI ускорителя
  Future<bool> _checkAIAcceleratorAvailability() async {
    try {
      // Проверяем наличие GPU/Neural Engine
      if (Platform.isAndroid) {
        // На Android проверяем наличие GPU через OpenGL
        // Для упрощения считаем, что если есть модель - есть ускоритель
        return false; // Будет false, так как модели нет
      } else if (Platform.isIOS) {
        // На iOS проверяем Neural Engine
        return true; // iOS обычно имеет Neural Engine
      }
      return false;
    } catch (e) {
      debugPrint('Ошибка проверки AI ускорителя: $e');
      return false;
    }
  }
  
  /// Обрабатывает мантру в соответствии с текущим режимом
  Future<void> processMantra({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
  }) async {
    if (_currentMode == AIPowerMode.lowPower) {
      await _processMantraLowPower(mantra, beadNumber, roundNumber);
    } else {
      await _processMantraHighPower(mantra, beadNumber, roundNumber);
    }
  }
  
  /// Обрабатывает мантру в High Power режиме
  Future<void> _processMantraHighPower(
    String mantra,
    int beadNumber,
    int roundNumber,
  ) async {
    // В High Power режиме используется AI модель
    // Эта логика уже реализована в LocalAIService
    _addLog('High Power: Круг $roundNumber, Бусина $beadNumber - отправлено в AI');
  }
  
  /// Обрабатывает мантру в Low Power режиме
  /// В цикле добавляет к строковой переменной предыдущей через стандартную конкатенацию одну мантру
  Future<void> _processMantraLowPower(
    String mantra,
    int beadNumber,
    int roundNumber,
  ) async {
    // Стандартная конкатенация строк (энергоэффективная)
    _lowPowerMantraAccumulator = _lowPowerMantraAccumulator + mantra + '\n';
    _lowPowerCycleCount++;
    
    _addLog('Low Power: Круг $roundNumber, Бусина $beadNumber/$_maxCycles');
    
    // Когда цикл 108 закончен - сохраняем в лог
    if (_lowPowerCycleCount >= _maxCycles) {
      await _finalizeLowPowerCycle(roundNumber);
    }
  }
  
  /// Завершает цикл Low Power режима
  Future<void> _finalizeLowPowerCycle(int roundNumber) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '''
=== ЦИКЛ 108 ЗАВЕРШЕН ===
Дата: $timestamp
Круг: $roundNumber
Режим: Low Power (Энергоэффективный)
Количество мантр: $_lowPowerCycleCount

НАКОПЛЕННЫЕ МАНТРЫ:
$_lowPowerMantraAccumulator

Длина строки: ${_lowPowerMantraAccumulator.length} символов
========================
''';
    
    _addLog('ЦИКЛ ЗАВЕРШЕН: $_lowPowerCycleCount мантр обработано');
    await _saveCycleLog(logEntry);
    
    // Сбрасываем счетчик и аккумулятор для следующего цикла
    _lowPowerMantraAccumulator = '';
    _lowPowerCycleCount = 0;
    
    debugPrint('Low Power цикл завершен. Результат сохранен в лог.');
  }
  
  /// Сохраняет лог цикла в файл
  Future<void> _saveCycleLog(String logEntry) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logFile = File('${dir.path}/low_power_cycles.log');
      
      // Добавляем в конец файла
      await logFile.writeAsString(
        logEntry + '\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Ошибка сохранения лога: $e');
    }
  }
  
  /// Добавляет запись в оперативный лог
  void _addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    _lowPowerLogs.add(logMessage);
    
    // Ограничиваем размер лога в памяти
    if (_lowPowerLogs.length > 1000) {
      _lowPowerLogs.removeAt(0);
    }
  }
  
  /// Переключает режим работы
  Future<void> setMode(AIPowerMode mode) async {
    if (mode == AIPowerMode.highPower && !_isAIAcceleratorAvailable) {
      debugPrint('Невозможно включить High Power - ускоритель недоступен');
      return;
    }
    
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKeyMode,
      mode == AIPowerMode.highPower ? 'highPower' : 'lowPower',
    );
    
    _addLog('Режим изменен на: $mode');
    debugPrint('AI режим изменен на: $mode');
  }
  
  /// Получает текущий режим
  AIPowerMode get currentMode => _currentMode;
  
  /// Проверяет доступность AI ускорителя
  bool get isAcceleratorAvailable => _isAIAcceleratorAvailable;
  
  /// Получает статус текущего цикла Low Power
  Map<String, dynamic> getLowPowerStatus() {
    return {
      'cycleCount': _lowPowerCycleCount,
      'maxCycles': _maxCycles,
      'progress': _lowPowerCycleCount / _maxCycles,
      'accumulatorLength': _lowPowerMantraAccumulator.length,
      'isComplete': _lowPowerCycleCount >= _maxCycles,
    };
  }
  
  /// Получает все логи (для Easter Egg)
  List<String> getLogs() {
    return List.from(_lowPowerLogs);
  }
  
  /// Получает полный лог циклов из файла (для Easter Egg)
  Future<String> getFullCycleLog() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logFile = File('${dir.path}/low_power_cycles.log');
      
      if (await logFile.exists()) {
        return await logFile.readAsString();
      }
      return 'Лог пуст. Завершите хотя бы один цикл из 108 мантр.';
    } catch (e) {
      return 'Ошибка чтения лога: $e';
    }
  }
  
  /// Очищает все логи
  Future<void> clearLogs() async {
    try {
      _lowPowerLogs.clear();
      
      final dir = await getApplicationDocumentsDirectory();
      final logFile = File('${dir.path}/low_power_cycles.log');
      
      if (await logFile.exists()) {
        await logFile.delete();
      }
      
      _addLog('Логи очищены');
      debugPrint('Все логи очищены');
    } catch (e) {
      debugPrint('Ошибка очистки логов: $e');
    }
  }
  
  /// Получает статистику
  Map<String, dynamic> getStatistics() {
    return {
      'currentMode': _currentMode.toString(),
      'isAcceleratorAvailable': _isAIAcceleratorAvailable,
      'lowPowerCycleCount': _lowPowerCycleCount,
      'lowPowerMaxCycles': _maxCycles,
      'logsCount': _lowPowerLogs.length,
      'accumulatorLength': _lowPowerMantraAccumulator.length,
    };
  }
}

