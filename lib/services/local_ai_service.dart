import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с локальной AI моделью на устройстве
/// Использует llama.cpp для запуска GGUF моделей
class LocalAIService {
  static LocalAIService? _instance;
  static const MethodChannel _channel = MethodChannel(
    'ai_japa_mahamantra/local_ai',
  );

  bool _isInitialized = false;
  bool _isModelLoaded = false;
  String? _modelPath;

  // Статистика отправленных мантр
  int _mantrasSent = 0;
  int _mantrasProcessed = 0;

  // Настройки для максимальной нагрузки и качества
  static const int _nThreads = 8; // Максимум потоков
  static const int _nGpuLayers = 99; // Максимум GPU слоев
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
      // Проверяем наличие модели в assets или документах
      final modelPath = await _findOrExtractModel();

      if (modelPath == null) {
        debugPrint('Модель не найдена. Требуется загрузка модели GGUF.');
        return false;
      }

      _modelPath = modelPath;

      // Инициализируем нативный код
      final result = await _channel.invokeMethod('initialize', {
        'modelPath': modelPath,
        'nThreads': _nThreads,
        'nGpuLayers': _nGpuLayers,
        'contextSize': _contextSize,
      });

      if (result == true) {
        _isInitialized = true;
        _isModelLoaded = true;
        debugPrint('LocalAIService инициализирован успешно');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Ошибка инициализации LocalAIService: $e');
      return false;
    }
  }

  /// Ищет или извлекает модель из assets
  Future<String?> _findOrExtractModel() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelFile = File(
        '${documentsDir.path}/models/braindler-q2_k.gguf',
      );

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
      // Запускаем генерацию с максимальными параметрами
      final response = await _channel.invokeMethod('generate', {
        'prompt': prompt,
        'temperature': _temperature,
        'topP': _topP,
        'topK': _topK,
        'maxTokens': _maxTokens,
        'nThreads': _nThreads,
        'nGpuLayers': _nGpuLayers,
      });

      if (response != null) {
        _mantrasProcessed++;
        debugPrint(
          'Мантра обработана AI: ${response.toString().substring(0, 50)}...',
        );
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

      final response = await _channel.invokeMethod('generate', {
        'prompt': prompt,
        'temperature': _temperature,
        'topP': _topP,
        'topK': _topK,
        'maxTokens': _maxTokens,
        'nThreads': _nThreads,
        'nGpuLayers': _nGpuLayers,
      });

      return response?.toString();
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
      return {
        'mantrasSent': prefs.getInt('local_ai_mantras_sent') ?? 0,
        'mantrasProcessed': prefs.getInt('local_ai_mantras_processed') ?? 0,
        'isInitialized': _isInitialized,
        'isModelLoaded': _isModelLoaded,
        'modelPath': _modelPath,
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
      await _channel.invokeMethod('dispose');
      _isInitialized = false;
      _isModelLoaded = false;
    } catch (e) {
      debugPrint('Ошибка освобождения ресурсов: $e');
    }
  }
}
