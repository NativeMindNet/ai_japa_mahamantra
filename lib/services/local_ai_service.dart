import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_llama/flutter_llama.dart';

/// Сервис для работы с локальной AI моделью на устройстве
/// Использует flutter_llama для запуска GGUF моделей
class LocalAIService {
  static LocalAIService? _instance;

  final FlutterLlama _llama = FlutterLlama.instance;

  bool _isInitialized = false;
  bool _isModelLoaded = false;
  String? _modelPath;

  // Статистика отправленных мантр
  int _mantrasSent = 0;
  int _mantrasProcessed = 0;

  // Настройки для максимальной нагрузки и качества
  static const int _nThreads = 8; // Максимум потоков
  static const int _nGpuLayers = -1; // Все слои на GPU
  static const int _contextSize = 4096; // Большой контекст
  static const double _temperature = 0.8; // Креативность
  static const double _topP = 0.95; // Разнообразие
  static const int _topK = 60; // Выбор токенов
  static const int _maxTokens = 512; // Длина ответа

  LocalAIService._();

  /// Получить singleton экземпляр
  static LocalAIService get instance {
    _instance ??= LocalAIService._();
    return _instance!;
  }

  /// Инициализирует локальный AI сервис
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kDebugMode) {
        debugPrint('ℹ️ LocalAI: Инициализация с flutter_llama');
      }

      // Проверяем наличие модели в assets или документах
      final modelPath = await _findOrExtractModel();

      if (modelPath == null) {
        debugPrint('Модель не найдена. Требуется загрузка модели GGUF.');
        return false;
      }

      _modelPath = modelPath;

      // Инициализируем llama через flutter_llama
      if (kDebugMode) {
        debugPrint('Инициализация Llama с моделью: $modelPath');
      }

      final config = LlamaConfig(
        modelPath: modelPath,
        nThreads: _nThreads,
        nGpuLayers: _nGpuLayers,
        contextSize: _contextSize,
        batchSize: 512,
        useGpu: true,
        verbose: kDebugMode,
      );

      final success = await _llama.loadModel(config);

      _isInitialized = success;
      _isModelLoaded = success;

      if (success && kDebugMode) {
        debugPrint('✅ LocalAIService инициализирован успешно с flutter_llama');
        final info = await _llama.getModelInfo();
        if (info != null) {
          debugPrint('📊 Model Info: $info');
        }
      }

      return success;
    } catch (e) {
      debugPrint('Ошибка инициализации LocalAIService: $e');
      _isInitialized = false;
      _isModelLoaded = false;
      return false;
    }
  }

  /// Ищет или извлекает модель из assets
  Future<String?> _findOrExtractModel() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${documentsDir.path}/models/braindler-q2_k.gguf');

      // Если модель уже существует, используем её
      if (await modelFile.exists()) {
        debugPrint('Модель braindler найдена: ${modelFile.path}');
        return modelFile.path;
      }

      // Пытаемся извлечь из assets
      try {
        final modelsDir = Directory('${documentsDir.path}/models');
        if (!await modelsDir.exists()) {
          await modelsDir.create(recursive: true);
        }

        // Копируем модель braindler из assets
        debugPrint('Извлекаем модель braindler из assets...');
        final byteData = await rootBundle.load(
          'assets/models/braindler-q2_k.gguf',
        );
        final buffer = byteData.buffer;
        await modelFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );

        debugPrint('Модель braindler извлечена из assets: ${modelFile.path}');
        return modelFile.path;
      } catch (e) {
        debugPrint('Модель braindler не найдена в assets: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Ошибка поиска модели braindler: $e');
      return null;
    }
  }

  /// Отправляет мантру к AI для обработки
  /// Возвращает true если успешно отправлено
  Future<bool> sendMantraToAI({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
    String? sessionContext,
  }) async {
    if (!_isInitialized || !_isModelLoaded) {
      debugPrint('AI сервис не инициализирован');
      return false;
    }

    try {
      _mantrasSent++;

      // Формируем промпт для AI с контекстом
      final prompt = _buildMantraPrompt(
        mantra: mantra,
        beadNumber: beadNumber,
        roundNumber: roundNumber,
        sessionContext: sessionContext,
      );

      // Отправляем в фоновом режиме для максимальной нагрузки
      _processMantraInBackground(prompt);

      // Сохраняем статистику
      await _updateStatistics();

      return true;
    } catch (e) {
      debugPrint('Ошибка отправки мантры к AI: $e');
      return false;
    }
  }

  /// Обрабатывает мантру в фоновом режиме
  Future<void> _processMantraInBackground(String prompt) async {
    try {
      final params = GenerationParams(
        prompt: prompt,
        temperature: _temperature,
        topP: _topP,
        topK: _topK,
        maxTokens: _maxTokens,
      );

      // Запускаем генерацию
      final response = await _llama.generate(params);

      if (response.text.isNotEmpty) {
        _mantrasProcessed++;
        final preview = response.text.length > 50
            ? '${response.text.substring(0, 50)}...'
            : response.text;
        debugPrint('Мантра обработана AI: $preview');
        debugPrint('Скорость: ${response.tokensPerSecond.toStringAsFixed(2)} tok/s');
      }
    } catch (e) {
      debugPrint('Ошибка обработки мантры: $e');
    }
  }

  /// Формирует промпт для отправки мантры
  String _buildMantraPrompt({
    required String mantra,
    required int beadNumber,
    required int roundNumber,
    String? sessionContext,
  }) {
    final context = sessionContext ?? 'Практика джапа-медитации';

    return '''
Я практикую джапа-медитацию. Контекст сессии: $context

Круг: $roundNumber
Бусина: $beadNumber из 108

Мантра на этой бусине:
$mantra

Пожалуйста, благослови эту мантру и дай духовное наставление для углубления медитации.
Ответь кратко (1-2 предложения), возвышающе и вдохновляюще.
''';
  }

  /// Задает вопрос AI ассистенту
  Future<String?> askQuestion(
    String question, {
    String category = 'spiritual',
  }) async {
    if (!_isInitialized || !_isModelLoaded) {
      return _getOfflineAnswer(question);
    }

    try {
      final prompt = _buildQuestionPrompt(question, category);

      final params = GenerationParams(
        prompt: prompt,
        temperature: _temperature,
        topP: _topP,
        topK: _topK,
        maxTokens: _maxTokens,
      );

      final response = await _llama.generate(params);

      return response.text.isNotEmpty ? response.text : null;
    } catch (e) {
      debugPrint('Ошибка запроса к AI: $e');
      return _getOfflineAnswer(question);
    }
  }

  /// Формирует промпт для вопроса
  String _buildQuestionPrompt(String question, String category) {
    return '''
Ты - духовный наставник в традиции вайшнавизма, последователь Шри Чайтаньи Махапрабху.
Отвечай на вопросы с позиции ведической мудрости.

Категория: $category
Вопрос: $question

Дай мудрый и духовно возвышающий ответ, основанный на:
- Бхагавад-гите
- Шримад-Бхагаватам
- Учении Шри Чайтаньи Махапрабху
- Традиции вайшнавизма

Ответ должен быть понятным, практичным и вдохновляющим.

Ответ:''';
  }

  /// Возвращает офлайн ответ если AI недоступен
  String _getOfflineAnswer(String question) {
    return '''
AI модель временно недоступна.

Рекомендации:
1. Продолжайте практику джапы
2. Изучайте священные писания
3. Общайтесь с преданными
4. Обратитесь к духовному учителю

Харе Кришна! 🕉️
''';
  }

  /// Обновляет статистику
  Future<void> _updateStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('local_ai_mantras_sent', _mantrasSent);
      await prefs.setInt('local_ai_mantras_processed', _mantrasProcessed);
    } catch (e) {
      // silent
    }
  }

  /// Получает статистику
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final info = await _llama.getModelInfo();
      return {
        'mantrasSent': prefs.getInt('local_ai_mantras_sent') ?? 0,
        'mantrasProcessed': prefs.getInt('local_ai_mantras_processed') ?? 0,
        'isInitialized': _isInitialized,
        'isModelLoaded': _isModelLoaded,
        'modelPath': _modelPath,
        'modelInfo': info,
      };
    } catch (e) {
      return {};
    }
  }

  /// Проверяет доступность AI
  bool get isAvailable => _isInitialized && _isModelLoaded;

  /// Получает путь к модели
  String? get modelPath => _modelPath;

  /// Освобождает ресурсы
  Future<void> dispose() async {
    try {
      await _llama.unloadModel();
      _isInitialized = false;
      _isModelLoaded = false;
      debugPrint('LocalAIService ресурсы освобождены');
    } catch (e) {
      debugPrint('Ошибка освобождения ресурсов: $e');
    }
  }
}
