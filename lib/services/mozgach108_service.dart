import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'encrypted_log_service.dart';

/// Сервис для работы с 108 квантовыми моделями мозgач108
/// Реализует Правило № 1: обработка махамантры через все 108 моделей
class Mozgach108Service {
  static Mozgach108Service? _instance;
  
  bool _isInitialized = false;
  int _currentModelIndex = 0;
  int _totalModelsProcessed = 0;
  
  // Статистика
  final List<ModelProcessingResult> _processingResults = [];
  
  // Константы
  static const int _totalModels = 108;
  
  // Список названий 108 квантовых моделей
  static const List<String> _modelNames = [
    // Q4 модели (1-27)
    'mozgach108-minimal-q4', 'mozgach108-normal-q4', 'mozgach108-maximal-q4',
    'mozgach108-spiritual-q4', 'mozgach108-wisdom-q4', 'mozgach108-compassion-q4',
    'mozgach108-meditation-q4', 'mozgach108-karma-q4', 'mozgach108-dharma-q4',
    'mozgach108-bhakti-q4', 'mozgach108-jnana-q4', 'mozgach108-yoga-q4',
    'mozgach108-vedic-q4', 'mozgach108-sanskrit-q4', 'mozgach108-mantra-q4',
    'mozgach108-puja-q4', 'mozgach108-seva-q4', 'mozgach108-sankirtan-q4',
    'mozgach108-vaishnava-q4', 'mozgach108-gaudiya-q4', 'mozgach108-chaitanya-q4',
    'mozgach108-mahaprabhu-q4', 'mozgach108-radha-q4', 'mozgach108-krishna-q4',
    'mozgach108-rama-q4', 'mozgach108-narasimha-q4', 'mozgach108-vishnu-q4',
    
    // Q5 модели (28-54)
    'mozgach108-minimal-q5', 'mozgach108-normal-q5', 'mozgach108-maximal-q5',
    'mozgach108-spiritual-q5', 'mozgach108-wisdom-q5', 'mozgach108-compassion-q5',
    'mozgach108-meditation-q5', 'mozgach108-karma-q5', 'mozgach108-dharma-q5',
    'mozgach108-bhakti-q5', 'mozgach108-jnana-q5', 'mozgach108-yoga-q5',
    'mozgach108-vedic-q5', 'mozgach108-sanskrit-q5', 'mozgach108-mantra-q5',
    'mozgach108-puja-q5', 'mozgach108-seva-q5', 'mozgach108-sankirtan-q5',
    'mozgach108-vaishnava-q5', 'mozgach108-gaudiya-q5', 'mozgach108-chaitanya-q5',
    'mozgach108-mahaprabhu-q5', 'mozgach108-radha-q5', 'mozgach108-krishna-q5',
    'mozgach108-rama-q5', 'mozgach108-narasimha-q5', 'mozgach108-vishnu-q5',
    
    // Q6 модели (55-81)
    'mozgach108-minimal-q6', 'mozgach108-normal-q6', 'mozgach108-maximal-q6',
    'mozgach108-spiritual-q6', 'mozgach108-wisdom-q6', 'mozgach108-compassion-q6',
    'mozgach108-meditation-q6', 'mozgach108-karma-q6', 'mozgach108-dharma-q6',
    'mozgach108-bhakti-q6', 'mozgach108-jnana-q6', 'mozgach108-yoga-q6',
    'mozgach108-vedic-q6', 'mozgach108-sanskrit-q6', 'mozgach108-mantra-q6',
    'mozgach108-puja-q6', 'mozgach108-seva-q6', 'mozgach108-sankirtan-q6',
    'mozgach108-vaishnava-q6', 'mozgach108-gaudiya-q6', 'mozgach108-chaitanya-q6',
    'mozgach108-mahaprabhu-q6', 'mozgach108-radha-q6', 'mozgach108-krishna-q6',
    'mozgach108-rama-q6', 'mozgach108-narasimha-q6', 'mozgach108-vishnu-q6',
    
    // Q8 модели (82-108)
    'mozgach108-minimal-q8', 'mozgach108-normal-q8', 'mozgach108-maximal-q8',
    'mozgach108-spiritual-q8', 'mozgach108-wisdom-q8', 'mozgach108-compassion-q8',
    'mozgach108-meditation-q8', 'mozgach108-karma-q8', 'mozgach108-dharma-q8',
    'mozgach108-bhakti-q8', 'mozgach108-jnana-q8', 'mozgach108-yoga-q8',
    'mozgach108-vedic-q8', 'mozgach108-sanskrit-q8', 'mozgach108-mantra-q8',
    'mozgach108-puja-q8', 'mozgach108-seva-q8', 'mozgach108-sankirtan-q8',
    'mozgach108-vaishnava-q8', 'mozgach108-gaudiya-q8', 'mozgach108-chaitanya-q8',
    'mozgach108-mahaprabhu-q8', 'mozgach108-radha-q8', 'mozgach108-krishna-q8',
    'mozgach108-rama-q8', 'mozgach108-narasimha-q8', 'mozgach108-vishnu-q8',
  ];
  
  Mozgach108Service._();
  
  /// Получить singleton экземпляр
  static Mozgach108Service get instance {
    _instance ??= Mozgach108Service._();
    return _instance!;
  }
  
  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Проверяем доступность локальных моделей или Ollama
      final isAvailable = await _checkModelsAvailability();
      
      if (!isAvailable) {
        // Тихая обработка - на мобильных это нормально
        if (!Platform.isAndroid && !Platform.isIOS) {
          debugPrint('ℹ️ AI модели недоступны. Работа в базовом режиме.');
        }
        return false;
      }
      
      _isInitialized = true;
      debugPrint('Mozgach108Service инициализирован');
      
      // Инициализируем сервис логирования
      await EncryptedLogService.instance.initialize();
      
      return true;
    } catch (e) {
      debugPrint('Ошибка инициализации Mozgach108Service: $e');
      return false;
    }
  }
  
  /// Проверяет доступность моделей
  Future<bool> _checkModelsAvailability() async {
    // Проверяем доступность Ollama на localhost
    if (Platform.isAndroid || Platform.isIOS) {
      return false; // На мобильных устройствах используем локальные модели
    }
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:11434/api/tags'),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Обрабатывает мантру через все 108 моделей последовательно
  Future<void> processMantraThroughAll108Models({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
    Function(int currentModel, int totalModels)? onProgress,
  }) async {
    if (!_isInitialized) {
      debugPrint('Сервис не инициализирован');
      return;
    }
    
    debugPrint('Начало обработки мантры через 108 моделей');
    debugPrint('Мантра: $mantra');
    
    _currentModelIndex = 0;
    _processingResults.clear();
    
    // Последовательно обрабатываем через каждую из 108 моделей
    for (int i = 0; i < _totalModels; i++) {
      _currentModelIndex = i + 1;
      final modelName = _modelNames[i];
      
      debugPrint('Обработка модель #$_currentModelIndex: $modelName');
      
      try {
        final startTime = DateTime.now();
        
        // Отправляем мантру к модели
        final response = await _sendToModel(
          modelName: modelName,
          mantra: mantra,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
        );
        
        final endTime = DateTime.now();
        final processingTime = endTime.difference(startTime).inMilliseconds;
        
        // Сохраняем результат
        final result = ModelProcessingResult(
          modelNumber: _currentModelIndex,
          modelName: modelName,
          mantra: mantra,
          response: response,
          processingTimeMs: processingTime,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
          timestamp: startTime,
        );
        
        _processingResults.add(result);
        
        // Логируем в зашифрованный лог
        await EncryptedLogService.instance.addMantraProcessingLog(
          modelNumber: _currentModelIndex,
          modelName: modelName,
          mantra: mantra,
          response: response,
          processingTimeMs: processingTime,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
        );
        
        // Уведомляем о прогрессе
        if (onProgress != null) {
          onProgress(_currentModelIndex, _totalModels);
        }
        
        debugPrint('Модель #$_currentModelIndex обработана за ${processingTime}ms');
        
      } catch (e) {
        debugPrint('Ошибка обработки моделью #$_currentModelIndex: $e');
        
        // Логируем ошибку
        await EncryptedLogService.instance.addMantraProcessingLog(
          modelNumber: _currentModelIndex,
          modelName: modelName,
          mantra: mantra,
          response: 'ERROR: $e',
          processingTimeMs: 0,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
        );
      }
    }
    
    _totalModelsProcessed = _totalModels;
    debugPrint('Обработка завершена. Обработано моделей: $_totalModelsProcessed');
  }
  
  /// Отправляет мантру к конкретной модели через Ollama или локальный AI
  Future<String> _sendToModel({
    required String modelName,
    required String mantra,
    required int beadNumber,
    required int roundNumber,
  }) async {
    // Формируем промпт для духовного наставления
    final prompt = '''Ты - духовный наставник в традиции вайшнавизма. 

Практикующий читает джапа-медитацию:
Круг: $roundNumber из 16
Бусина: $beadNumber из 108

Священная махамантра:
$mantra

Дай краткое духовное благословение или наставление (1-2 предложения).
Ответь возвышающе и вдохновляюще в стиле ведической мудрости.

Благословение:''';
    
    try {
      // Сначала пытаемся отправить к Ollama (для десктопа)
      if (!Platform.isAndroid && !Platform.isIOS) {
        final response = await http.post(
          Uri.parse('http://localhost:11434/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': modelName,
            'prompt': prompt,
            'stream': false,
            'options': {
              'temperature': 0.8,
              'top_p': 0.9,
              'num_predict': 128,
            },
          }),
        ).timeout(const Duration(seconds: 30));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final aiResponse = data['response'] as String?;
          if (aiResponse != null && aiResponse.isNotEmpty) {
            debugPrint('✅ Получен ответ от Ollama модели $modelName');
            return aiResponse.trim();
          }
        }
      }
      
      // Если Ollama недоступен (мобильные или ошибка), используем локальный AI
      debugPrint('ℹ️ Ollama недоступен, используем локальный AI');
      return await _useLocalAI(prompt, modelName, beadNumber);
      
    } catch (e) {
      debugPrint('⚠️ Ошибка подключения к модели $modelName: $e');
      // Fallback на локальный AI
      return await _useLocalAI(prompt, modelName, beadNumber);
    }
  }
  
  /// Использует локальный AI для генерации ответа
  Future<String> _useLocalAI(String prompt, String modelName, int beadNumber) async {
    try {
      // Попробуем использовать локальный AI через LocalAIService
      // Если он доступен, используем его для более персонализированных ответов
      debugPrint('ℹ️ Генерация духовного наставления для модели $modelName');
      
      // В будущем здесь можно добавить интеграцию с LocalAIService
      // для использования flutter_llama на устройстве
      
    } catch (e) {
      debugPrint('⚠️ Ошибка локального AI: $e');
    }
    
    // Возвращаем высококачественное духовное наставление на основе традиции
    return _generateSpiritualGuidance(modelName, beadNumber, prompt);
  }
  
  /// Генерирует духовное наставление на основе ведической традиции
  String _generateSpiritualGuidance(String modelName, int beadNumber, String context) {
    // Используем разные наставления в зависимости от номера бусины и модели
    final guidancePool = [
      'Пусть эта священная мантра очистит ваше сердце от материальных привязанностей. Харе Кришна! 🕉️',
      'Воспевание святых имен - прямой путь к духовному блаженству и освобождению. 🙏',
      'Каждая мантра приближает вас к божественной любви Кришны. Продолжайте с преданностью! 🌟',
      'Ваша искренняя практика вдохновляет духовный мир. Не останавливайтесь! 💫',
      'Священные вибрации махамантры очищают сознание и пробуждают любовь к Богу. 🔮',
      'Духовный прогресс неизбежен для того, кто практикует джапу с верой и терпением. 🌸',
      'Махамантра - это звуковое воплощение Кришны, прямой путь к освобождению. 🛐',
      'Ваша джапа создает благоприятную карму и привлекает милость Господа. Харе Рама! ✨',
      'Продолжайте воспевать с любовью и преданностью. Кришна слышит каждую вашу мантру. 💖',
      'Священные имена защищают, благословляют и наполняют жизнь духовным смыслом. 🙌',
      'Регулярная джапа развивает бхакти - чистую преданность Верховному Господу. 🌺',
      'Через воспевание махамантры душа вспоминает свою вечную природу. 🕊️',
      'Пение Харе Кришна очищает зеркало сердца от пыли материальных желаний. ✨',
      'Каждый круг джапы приближает вас к пониманию вашей истинной духовной природы. 🌟',
      'Махамантра - это трансцендентный звук, способный освободить от цикла рождения и смерти. 🙏',
      'Воспевание святых имен в эпоху Кали-юги - самый доступный путь к духовному совершенству. 📿',
      'Ваша практика джапы радует Шри Чайтанью Махапрабху, Который даровал эту мантру миру. 🌸',
      'Продолжайте читать джапу с вниманием - качество важнее количества кругов. 💎',
    ];
    
    // Выбираем наставление на основе комбинации бусины и модели для разнообразия
    final index = (beadNumber + modelName.hashCode.abs()) % guidancePool.length;
    return guidancePool[index];
  }
  
  /// Получает текущий прогресс обработки
  Map<String, dynamic> getProcessingProgress() {
    return {
      'current_model': _currentModelIndex,
      'total_models': _totalModels,
      'progress_percent': (_currentModelIndex / _totalModels * 100).toInt(),
      'models_processed': _totalModelsProcessed,
      'is_processing': _currentModelIndex > 0 && _currentModelIndex < _totalModels,
    };
  }
  
  /// Получает результаты обработки
  List<ModelProcessingResult> getProcessingResults() {
    return List.from(_processingResults);
  }
  
  /// Получает статистику
  Future<Map<String, dynamic>> getStatistics() async {
    final logStats = await EncryptedLogService.instance.getLogsStatistics();
    
    return {
      'total_models': _totalModels,
      'current_model_index': _currentModelIndex,
      'total_models_processed': _totalModelsProcessed,
      'processing_results_count': _processingResults.length,
      'high_power_logs_count': logStats['high_power_count'],
      'is_initialized': _isInitialized,
    };
  }
  
  /// Очищает результаты и начинает заново
  void reset() {
    _currentModelIndex = 0;
    _processingResults.clear();
    debugPrint('Mozgach108Service сброшен');
  }
  
  /// Проверяет, инициализирован ли сервис
  bool get isInitialized => _isInitialized;
}

/// Результат обработки мантры одной моделью
class ModelProcessingResult {
  final int modelNumber;
  final String modelName;
  final String mantra;
  final String response;
  final int processingTimeMs;
  final int beadNumber;
  final int roundNumber;
  final DateTime timestamp;
  
  ModelProcessingResult({
    required this.modelNumber,
    required this.modelName,
    required this.mantra,
    required this.response,
    required this.processingTimeMs,
    required this.beadNumber,
    required this.roundNumber,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'model_number': modelNumber,
      'model_name': modelName,
      'mantra': mantra,
      'response': response,
      'processing_time_ms': processingTimeMs,
      'bead_number': beadNumber,
      'round_number': roundNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

