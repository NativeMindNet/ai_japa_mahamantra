import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'encrypted_log_service.dart';

/// Сервис для работы с 108 обработками через модели Braindler от Ollama
/// Реализует Правило № 1: обработка махамантры через 108 циклов
/// 
/// Использует 7 реальных моделей braindler с https://ollama.com/nativemind/braindler
/// и обрабатывает мантру 108 раз с разными параметрами
class Braindler108Service {
  static Braindler108Service? _instance;
  
  bool _isInitialized = false;
  int _currentCycleIndex = 0;
  int _totalCyclesProcessed = 0;
  
  // Статистика
  final List<CycleProcessingResult> _processingResults = [];
  
  // Константы
  static const int _totalCycles = 108;
  static const String _ollamaBaseUrl = 'http://localhost:11434';
  
  // 7 реальных моделей braindler от Ollama
  // https://ollama.com/nativemind/braindler
  static const List<String> _braindlerModels = [
    'braindler:latest',    // 94MB - базовая модель
    'braindler:q2_k',      // 72MB - минимальное квантование
    'braindler:q3_k_s',    // 77MB - легкое квантование
    'braindler:q4_k_s',    // 88MB - среднее квантование
    'braindler:q5_k_m',    // 103MB - хорошее качество
    'braindler:q8_0',      // 140MB - высокое качество
    'braindler:f16',       // 256MB - максимальное качество
  ];
  
  // Вариации параметров для достижения 108 уникальных обработок
  static const List<double> _temperatureVariations = [
    0.7, 0.8, 0.9, 1.0, 1.1, 1.2, // 6 вариаций
  ];
  
  static const List<double> _topPVariations = [
    0.85, 0.90, 0.95, // 3 вариации
  ];
  
  // 7 моделей × 6 температур × 3 top_p = 126 комбинаций (используем первые 108)
  
  Braindler108Service._();
  
  /// Получить singleton экземпляр
  static Braindler108Service get instance {
    _instance ??= Braindler108Service._();
    return _instance!;
  }
  
  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Проверяем доступность Ollama сервера
      final isAvailable = await _checkOllamaAvailability();
      
      if (!isAvailable) {
        debugPrint('Ollama сервер недоступен (проверьте http://localhost:11434)');
        return false;
      }
      
      // Проверяем наличие хотя бы одной модели braindler
      final hasModels = await _checkBraindlerModels();
      
      if (!hasModels) {
        debugPrint('Модели braindler не установлены. Установите: ollama pull braindler');
        return false;
      }
      
      _isInitialized = true;
      debugPrint('Braindler108Service инициализирован');
      
      // Инициализируем сервис логирования
      await EncryptedLogService.instance.initialize();
      
      return true;
    } catch (e) {
      debugPrint('Ошибка инициализации Braindler108Service: $e');
      return false;
    }
  }
  
  /// Проверяет доступность Ollama сервера
  Future<bool> _checkOllamaAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('$_ollamaBaseUrl/api/tags'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Ollama недоступна: $e');
      return false;
    }
  }
  
  /// Проверяет наличие моделей braindler
  Future<bool> _checkBraindlerModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_ollamaBaseUrl/api/tags'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode != 200) return false;
      
      final data = json.decode(response.body);
      final models = data['models'] as List;
      
      // Проверяем наличие хотя бы одной модели braindler
      final hasBraindler = models.any((model) => 
        model['name'].toString().startsWith('braindler')
      );
      
      if (hasBraindler) {
        debugPrint('Найдены модели braindler: ${models.where((m) => m['name'].toString().startsWith('braindler')).map((m) => m['name']).toList()}');
      }
      
      return hasBraindler;
    } catch (e) {
      debugPrint('Ошибка проверки моделей: $e');
      return false;
    }
  }
  
  /// Получить конфигурацию для цикла
  Map<String, dynamic> _getCycleConfiguration(int cycleNumber) {
    // Цикл от 0 до 107 (всего 108)
    final index = cycleNumber % 108;
    
    // Вычисляем индексы для моделей и параметров
    final modelIndex = index % _braindlerModels.length;
    final tempIndex = (index ~/ _braindlerModels.length) % _temperatureVariations.length;
    final topPIndex = (index ~/ (_braindlerModels.length * _temperatureVariations.length)) % _topPVariations.length;
    
    return {
      'model': _braindlerModels[modelIndex],
      'temperature': _temperatureVariations[tempIndex],
      'top_p': _topPVariations[topPIndex],
      'cycle_number': cycleNumber + 1, // 1-108
    };
  }
  
  /// Обработать мантру через один цикл
  Future<CycleProcessingResult> _processThroughCycle({
    required String mantra,
    required int cycleNumber,
    required int beadNumber,
    required int roundNumber,
  }) async {
    final startTime = DateTime.now();
    final config = _getCycleConfiguration(cycleNumber);
    
    try {
      // Формируем промпт для braindler
      final prompt = '''Ты духовный помощник Braindler. Обработай следующую махамантру:

"$mantra"

Бусина: $beadNumber/108
Круг: $roundNumber
Цикл обработки: ${config['cycle_number']}/108

Ответь одним словом благословения или короткой духовной мудростью (не более 10 слов).''';
      
      // Отправляем запрос в Ollama
      final response = await http.post(
        Uri.parse('$_ollamaBaseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': config['model'],
          'prompt': prompt,
          'temperature': config['temperature'],
          'top_p': config['top_p'],
          'stream': false,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['response'] as String;
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        final result = CycleProcessingResult(
          cycleNumber: config['cycle_number'],
          modelName: config['model'],
          temperature: config['temperature'],
          topP: config['top_p'],
          mantra: mantra,
          response: aiResponse.trim(),
          duration: duration,
          timestamp: endTime,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
        );
        
        _processingResults.add(result);
        _totalCyclesProcessed++;
        
        return result;
      } else {
        throw Exception('Ошибка Ollama API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка обработки цикла $cycleNumber: $e');
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return CycleProcessingResult(
        cycleNumber: config['cycle_number'],
        modelName: config['model'],
        temperature: config['temperature'],
        topP: config['top_p'],
        mantra: mantra,
        response: 'Ошибка: $e',
        duration: duration,
        timestamp: endTime,
        beadNumber: beadNumber,
        roundNumber: roundNumber,
        hasError: true,
      );
    }
  }
  
  /// Обработать мантру через все 108 циклов
  Future<List<CycleProcessingResult>> processMantraThroughAll108Cycles({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
    Function(int current, int total)? onProgress,
  }) async {
    if (!_isInitialized) {
      throw Exception('Сервис не инициализирован. Вызовите initialize() сначала.');
    }
    
    final results = <CycleProcessingResult>[];
    
    debugPrint('Начало обработки через 108 циклов braindler...');
    
    for (int i = 0; i < _totalCycles; i++) {
      onProgress?.call(i + 1, _totalCycles);
      
      final result = await _processThroughCycle(
        mantra: mantra,
        cycleNumber: i,
        beadNumber: beadNumber,
        roundNumber: roundNumber,
      );
      
      results.add(result);
      
      // Логируем в зашифрованный лог
      await _logCycleResult(result);
      
      // Небольшая пауза между запросами
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    debugPrint('Обработка через 108 циклов завершена');
    
    return results;
  }
  
  /// Логирование результата цикла
  Future<void> _logCycleResult(CycleProcessingResult result) async {
    try {
      final metadata = {
        'cycle_number': result.cycleNumber,
        'model_name': result.modelName,
        'temperature': result.temperature,
        'top_p': result.topP,
        'bead_number': result.beadNumber,
        'round_number': result.roundNumber,
        'duration_ms': result.duration.inMilliseconds,
        'has_error': result.hasError,
      };
      
      await EncryptedLogService.instance.addLogEntry(
        logType: 'braindler108_cycle',
        message: 'Цикл ${result.cycleNumber}/108: ${result.modelName}\n'
                'Мантра: ${result.mantra}\n'
                'Ответ: ${result.response}',
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Ошибка логирования цикла: $e');
    }
  }
  
  /// Получить статистику обработки
  Future<Map<String, dynamic>> getStatistics() async {
    final successfulCycles = _processingResults.where((r) => !r.hasError).length;
    final failedCycles = _processingResults.where((r) => r.hasError).length;
    
    final totalDuration = _processingResults.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.duration,
    );
    
    final avgDuration = _processingResults.isNotEmpty
        ? totalDuration.inMilliseconds / _processingResults.length
        : 0;
    
    return {
      'is_initialized': _isInitialized,
      'total_cycles': _totalCycles,
      'cycles_processed': _totalCyclesProcessed,
      'successful_cycles': successfulCycles,
      'failed_cycles': failedCycles,
      'avg_duration_ms': avgDuration.round(),
      'total_duration_ms': totalDuration.inMilliseconds,
    };
  }
  
  /// Проверить доступность сервиса
  bool get isAvailable => _isInitialized;
  
  /// Получить количество обработанных циклов
  int get totalCyclesProcessed => _totalCyclesProcessed;
  
  /// Очистить результаты
  void clearResults() {
    _processingResults.clear();
    _currentCycleIndex = 0;
    _totalCyclesProcessed = 0;
  }
}

/// Результат обработки одного цикла
class CycleProcessingResult {
  final int cycleNumber;        // 1-108
  final String modelName;        // Название модели braindler
  final double temperature;      // Параметр температуры
  final double topP;             // Параметр top_p
  final String mantra;           // Исходная мантра
  final String response;         // Ответ AI
  final Duration duration;       // Время обработки
  final DateTime timestamp;      // Время обработки
  final int beadNumber;          // Номер бусины (1-108)
  final int roundNumber;         // Номер круга
  final bool hasError;           // Были ли ошибки
  
  CycleProcessingResult({
    required this.cycleNumber,
    required this.modelName,
    required this.temperature,
    required this.topP,
    required this.mantra,
    required this.response,
    required this.duration,
    required this.timestamp,
    required this.beadNumber,
    required this.roundNumber,
    this.hasError = false,
  });
  
  Map<String, dynamic> toJson() => {
    'cycle_number': cycleNumber,
    'model_name': modelName,
    'temperature': temperature,
    'top_p': topP,
    'mantra': mantra,
    'response': response,
    'duration_ms': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    'bead_number': beadNumber,
    'round_number': roundNumber,
    'has_error': hasError,
  };
}

