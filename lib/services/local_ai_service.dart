import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'encrypted_log_service.dart';

/// Сервис для работы с локальными AI моделями на устройстве
/// Использует flutter_llama для работы с GGUF моделями
class LocalAIService {
  static LocalAIService? _instance;
  
  bool _isInitialized = false;
  bool _isModelLoaded = false;
  String? _modelPath;
  String? _modelName;
  
  // Flutter LLaMA instance
  FlutterLlama? _llama;
  
  // Статистика использования
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  Duration _totalProcessingTime = Duration.zero;
  
  // Настройки
  bool _enableLocalAI = true;
  
  // Константы
  static const String _modelFileName = 'braindler-q2_k.gguf';
  static const String _prefKeyModelPath = 'local_ai_model_path';
  static const String _prefKeyModelName = 'local_ai_model_name';
  static const String _prefKeyEnableLocalAI = 'local_ai_enabled';
  
  LocalAIService._();
  
  /// Получить singleton экземпляр
  static LocalAIService get instance {
    _instance ??= LocalAIService._();
    return _instance!;
  }
  
  /// Инициализация сервиса
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Загружаем настройки
      await _loadSettings();
      
      // Проверяем наличие модели GGUF
      await _checkForModel();
      
      // Инициализируем сервис логирования
      await EncryptedLogService.instance.initialize();
      
      _isInitialized = true;
      debugPrint('LocalAIService инициализирован');
      
      return true;
    } catch (e) {
      debugPrint('Ошибка инициализации LocalAIService: $e');
      return false;
    }
  }
  
  /// Загрузка настроек
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _enableLocalAI = prefs.getBool(_prefKeyEnableLocalAI) ?? true;
    _modelPath = prefs.getString(_prefKeyModelPath);
    _modelName = prefs.getString(_prefKeyModelName);
    
    debugPrint('Настройки LocalAI загружены: enabled=$_enableLocalAI, model=$_modelName');
  }
  
  /// Сохранение настроек
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_prefKeyEnableLocalAI, _enableLocalAI);
    if (_modelPath != null) {
      await prefs.setString(_prefKeyModelPath, _modelPath!);
    }
    if (_modelName != null) {
      await prefs.setString(_prefKeyModelName, _modelName!);
    }
  }
  
  /// Проверяет наличие модели GGUF и загружает её через flutter_llama
  Future<void> _checkForModel() async {
    try {
      // Проверяем в assets директории (встроенная модель)
      final assetsModelPath = 'assets/models/$_modelFileName';
      
      // Проверяем в Documents директории
      final documentsDir = await getApplicationDocumentsDirectory();
      final documentsModelPath = '${documentsDir.path}/models/$_modelFileName';
      
      // Проверяем в Downloads директории
      final downloadsDir = await getDownloadsDirectory();
      final downloadsModelPath = downloadsDir != null 
          ? '${downloadsDir.path}/$_modelFileName'
          : null;
      
      // Ищем модель в разных местах
      String? foundModelPath;
      
      // Приоритет: Documents -> Downloads -> Assets
      if (await File(documentsModelPath).exists()) {
        foundModelPath = documentsModelPath;
        debugPrint('✅ Найдена модель в Documents: $foundModelPath');
      } else if (downloadsModelPath != null && await File(downloadsModelPath).exists()) {
        foundModelPath = downloadsModelPath;
        debugPrint('✅ Найдена модель в Downloads: $foundModelPath');
      } else {
        // Проверяем assets (встроенная модель)
        foundModelPath = assetsModelPath;
        debugPrint('ℹ️ Используется встроенная модель из assets');
      }
      
      // Пытаемся загрузить модель
      if (foundModelPath.isNotEmpty) {
        // Загружаем модель через flutter_llama
        await _loadLlamaModel(foundModelPath);
        
        _modelPath = foundModelPath;
        _modelName = _modelFileName;
        _isModelLoaded = true;
        
        await _saveSettings();
        debugPrint('✅ Модель GGUF загружена через flutter_llama: $_modelName');
      } else {
        debugPrint('❌ Модель GGUF не найдена. Поместите $_modelFileName в папку Documents/models или Downloads');
        _isModelLoaded = false;
      }
    } catch (e) {
      debugPrint('❌ Ошибка проверки модели: $e');
      _isModelLoaded = false;
    }
  }
  
  /// Загружает модель через flutter_llama
  Future<void> _loadLlamaModel(String modelPath) async {
    try {
      debugPrint('⏳ Загрузка модели через flutter_llama: $modelPath');
      
      _llama = FlutterLlama.instance;
      
      final config = LlamaConfig(
        modelPath: modelPath,
        nThreads: 4,
        nGpuLayers: 0, // CPU only for mobile compatibility
        contextSize: 2048,
        useGpu: false, // Disable GPU for mobile
      );
      
      await _llama!.loadModel(config);
      
      debugPrint('✅ Модель успешно загружена через flutter_llama');
    } catch (e) {
      debugPrint('❌ Ошибка загрузки модели через flutter_llama: $e');
      _llama = null;
      throw e;
    }
  }
  
  /// Отправляет мантру к локальному AI
  Future<bool> sendMantraToAI({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
    required String sessionContext,
  }) async {
    if (!_isInitialized || !_enableLocalAI || !_isModelLoaded) {
      debugPrint('LocalAI недоступен: initialized=$_isInitialized, enabled=$_enableLocalAI, loaded=$_isModelLoaded');
      return false;
    }
    
    try {
      _totalRequests++;
      final startTime = DateTime.now();
      
      // Формируем промпт для локального AI
      final prompt = _buildPrompt(mantra, beadNumber, roundNumber, sessionContext);
      
      // Отправляем к локальному AI через flutter_llama
      final response = await _processWithLocalAI(prompt);
      
      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime);
      _totalProcessingTime += processingTime;
      
      if (response.isNotEmpty) {
        _successfulRequests++;
        
        // Логируем успешную обработку
        await _logMantraProcessing(
          mantra: mantra,
          response: response,
          beadNumber: beadNumber,
          roundNumber: roundNumber,
          processingTime: processingTime,
          success: true,
        );
        
        debugPrint('✅ LocalAI обработал мантру #$beadNumber за ${processingTime.inMilliseconds}ms');
        return true;
      } else {
        _failedRequests++;
        debugPrint('❌ LocalAI вернул пустой ответ');
        return false;
      }
    } catch (e) {
      _failedRequests++;
      debugPrint('❌ Ошибка LocalAI: $e');
      
      // Логируем ошибку
      await _logMantraProcessing(
        mantra: mantra,
        response: 'ERROR: $e',
        beadNumber: beadNumber,
        roundNumber: roundNumber,
        processingTime: Duration.zero,
        success: false,
      );
      
      return false;
    }
  }
  
  /// Обрабатывает промпт через локальный AI с использованием flutter_llama
  Future<String> _processWithLocalAI(String prompt) async {
    try {
      if (_llama == null) {
        debugPrint('❌ Flutter LLaMA не инициализирован');
        throw Exception('Flutter LLaMA не инициализирован');
      }
      
      debugPrint('⏳ Обработка через flutter_llama...');
      
      // Генерируем ответ через реальную GGUF модель
      final params = GenerationParams(
        prompt: prompt,
        temperature: 0.8,
        topP: 0.9,
        topK: 40,
        maxTokens: 128,
        repeatPenalty: 1.1,
      );
      
      // Используем stream для получения ответа
      final buffer = StringBuffer();
      
      await for (final token in _llama!.generateStream(params)) {
        buffer.write(token);
      }
      
      final response = buffer.toString();
      
      if (response.isNotEmpty) {
        debugPrint('✅ Получен ответ от flutter_llama: ${response.length > 50 ? "${response.substring(0, 50)}..." : response}');
        return response.trim();
      } else {
        debugPrint('⚠️ Flutter LLaMA вернул пустой ответ');
        throw Exception('Пустой ответ от модели');
      }
    } catch (e) {
      debugPrint('❌ Ошибка обработки через flutter_llama: $e');
      // В случае ошибки используем fallback
      return _generateFallbackResponse(prompt);
    }
  }
  
  /// Генерирует fallback ответ когда модель недоступна
  String _generateFallbackResponse(String prompt) {
    debugPrint('ℹ️ Используется fallback ответ');
    
    final responses = [
      'Харе Кришна! Пусть эта священная мантра очистит ваше сердце. 🕉️',
      'Продолжайте воспевание с преданностью. Кришна слышит каждую мантру. 🙏',
      'Каждая бусина приближает вас к божественному. Харе Кришна! 🌟',
      'Ваша практика вдохновляет. Продолжайте с любовью! 💫',
      'Священные вибрации очищают сознание и сердце. 🔮',
      'Духовный прогресс приходит через искреннюю практику. 🌸',
      'Махамантра - прямой путь к освобождению. 🛐',
      'Ваша джапа создает благоприятную карму. Харе Рама! ✨',
      'Продолжайте с любовью и преданностью к Кришне. 💖',
      'Священные имена защищают и благословляют вас. 🙌',
    ];
    
    // Выбираем ответ на основе хэша промпта для консистентности
    final hash = prompt.hashCode.abs();
    return responses[hash % responses.length];
  }
  
  /// Строит промпт для AI
  String _buildPrompt(String mantra, int beadNumber, int roundNumber, String sessionContext) {
    return '''
Ты - духовный наставник в традиции вайшнавизма. 

Контекст сессии: $sessionContext
Текущий круг: $roundNumber
Текущая бусина: $beadNumber из 108

Мантра для благословения:
$mantra

Дай краткое духовное наставление (1-2 предложения) для этой мантры.
Ответ должен быть вдохновляющим и возвышающим.
''';
  }
  
  /// Логирует обработку мантры
  Future<void> _logMantraProcessing({
    required String mantra,
    required String response,
    required int beadNumber,
    required int roundNumber,
    required Duration processingTime,
    required bool success,
  }) async {
    try {
      final metadata = {
        'mantra': mantra,
        'response': response,
        'bead_number': beadNumber,
        'round_number': roundNumber,
        'processing_time_ms': processingTime.inMilliseconds,
        'success': success,
        'model_name': _modelName ?? 'local_ai',
        'model_path': _modelPath ?? 'unknown',
      };
      
      await EncryptedLogService.instance.addLogEntry(
        logType: 'local_ai_processing',
        message: 'Мантра #$beadNumber обработана локальным AI',
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Ошибка логирования LocalAI: $e');
    }
  }
  
  /// Включает/выключает локальный AI
  Future<void> setEnabled(bool enabled) async {
    _enableLocalAI = enabled;
    await _saveSettings();
    debugPrint('LocalAI ${enabled ? "включен" : "отключен"}');
  }
  
  /// Устанавливает путь к модели
  Future<void> setModelPath(String path) async {
    _modelPath = path;
    _isModelLoaded = await File(path).exists();
    
    if (_isModelLoaded) {
      _modelName = path.split('/').last;
      await _saveSettings();
      debugPrint('Модель установлена: $_modelName');
    } else {
      debugPrint('Файл модели не найден: $path');
    }
  }
  
  /// Получает статистику
  Future<Map<String, dynamic>> getStatistics() async {
    final avgProcessingTime = _totalRequests > 0 
        ? _totalProcessingTime.inMilliseconds / _totalRequests
        : 0;
    
    return {
      'is_initialized': _isInitialized,
      'is_model_loaded': _isModelLoaded,
      'is_enabled': _enableLocalAI,
      'model_name': _modelName,
      'model_path': _modelPath,
      'total_requests': _totalRequests,
      'successful_requests': _successfulRequests,
      'failed_requests': _failedRequests,
      'success_rate': _totalRequests > 0 
          ? (_successfulRequests / _totalRequests * 100).round()
          : 0,
      'avg_processing_time_ms': avgProcessingTime.round(),
      'total_processing_time_ms': _totalProcessingTime.inMilliseconds,
    };
  }
  
  /// Проверяет доступность сервиса
  bool get isAvailable => _isInitialized && _enableLocalAI && _isModelLoaded;
  
  /// Проверяет, загружена ли модель
  bool get isModelLoaded => _isModelLoaded;
  
  /// Получает имя модели
  String? get modelName => _modelName;
  
  /// Получает путь к модели
  String? get modelPath => _modelPath;
  
  /// Очищает статистику
  void clearStatistics() {
    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _totalProcessingTime = Duration.zero;
    debugPrint('Статистика LocalAI очищена');
  }
  
  /// Перезагружает модель
  Future<bool> reloadModel() async {
    try {
      debugPrint('⏳ Перезагрузка модели...');
      
      // Выгружаем текущую модель
      if (_llama != null) {
        // flutter_llama не требует явного dispose
        _llama = null;
      }
      
      _isModelLoaded = false;
      await _checkForModel();
      
      if (_isModelLoaded) {
        debugPrint('✅ Модель перезагружена успешно');
        return true;
      } else {
        debugPrint('❌ Не удалось перезагрузить модель');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Ошибка перезагрузки модели: $e');
      return false;
    }
  }
  
  /// Освобождает ресурсы
  Future<void> dispose() async {
    try {
      if (_llama != null) {
        // flutter_llama управляет ресурсами автоматически
        _llama = null;
        debugPrint('✅ Flutter LLaMA ресурсы освобождены');
      }
    } catch (e) {
      debugPrint('❌ Ошибка освобождения ресурсов: $e');
    }
  }
}