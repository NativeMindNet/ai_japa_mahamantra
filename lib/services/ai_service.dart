import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_assistant.dart';

class AIService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'mozgach:latest';
  
  // Кэш для ответов
  static final Map<String, String> _responseCache = {};
  
  /// Отправляет вопрос к AI модели
  static Future<String?> askQuestion(String question, {String category = 'spiritual'}) async {
    try {
      // Проверяем кэш
      if (_responseCache.containsKey(question)) {
        return _responseCache[question];
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': _buildPrompt(question, category),
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
            'max_tokens': 500,
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['response'] as String?;
        
        if (answer != null && answer.isNotEmpty) {
          // Кэшируем ответ
          _responseCache[question] = answer;
          return answer;
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка при обращении к AI: $e');
      return null;
    }
  }
  
  /// Строит промпт для AI с учетом контекста
  static String _buildPrompt(String question, String category) {
    return '''
Ты - духовный наставник в традиции вайшнавизма, последователь Шри Чайтаньи Махапрабху. 
Отвечай на вопросы с позиции ведической мудрости и учения Шри Чайтаньи Махапрабху.

Категория вопроса: $category
Вопрос: $question

Пожалуйста, дай мудрый и духовно возвышающий ответ, основанный на:
- Бхагавад-гите
- Шримад-Бхагаватам
- Учении Шри Чайтаньи Махапрабху
- Традиции вайшнавизма

Ответ должен быть:
- Понятным и доступным
- Практичным для духовной жизни
- Вдохновляющим и возвышающим
- Соответствующим этикету православного вайшнавизма

Ответ:''';
  }
  
  /// Получает подсказки для духовных вопросов
  static List<String> getSpiritualQuestionHints() {
    return [
      'Как правильно читать джапу?',
      'Что означает махамантра Харе Кришна?',
      'Как развить бхакти?',
      'Что такое карма и как от неё освободиться?',
      'Как медитировать на Кришну?',
      'Что такое майя?',
      'Как достичь самоосознания?',
      'Что такое гуру-парампара?',
      'Как понять Бхагавад-гиту?',
      'Что такое према?',
      'Как преодолеть материальные желания?',
      'Что такое чистое преданное служение?',
      'Как развить любовь к Богу?',
      'Что означает "Кришна-сознание"?',
      'Как практиковать бхакти-йогу в повседневной жизни?',
    ];
  }
  
  /// Проверяет доступность AI сервера
  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Получает информацию о доступных моделях
  static Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;
        
        if (models != null) {
          return models.map((m) => m['name'] as String).toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Очищает кэш ответов
  static void clearCache() {
    _responseCache.clear();
  }
  
  /// Получает размер кэша
  static int getCacheSize() {
    return _responseCache.length;
  }
}
