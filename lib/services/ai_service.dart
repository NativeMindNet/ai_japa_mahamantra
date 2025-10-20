import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'package:dio/dio.dart';

class AIService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'braindler:q2_k';

  // Счетчик отправленных мантр для статистики
  static int _mantraSentCount = 0;

  // Кэш для ответов
  static final Map<String, String> _responseCache = {};

  // Локальные ответы для офлайн режима
  static final Map<String, String> _localResponses = {
    'japa_how_to': '''
Правильная техника джапы:

1. **Поза**: Сядьте в удобную позу, спина прямая
2. **Мала**: Держите малу в правой руке
3. **Техника**: Большим пальцем двигайте бусины от большой к малой
4. **Мантра**: Читайте мантру четко и осознанно
5. **Концентрация**: Фокусируйтесь на звуке мантры
6. **Нулевая бусина**: Не касайтесь её при развороте

Помните: качество важнее количества. Лучше прочитать 1 круг с концентрацией, чем 16 без внимания.
''',

    'mantra_meaning': '''
Махамантра "Харе Кришна Харе Рама":

**Харе** - обращение к энергии преданного служения
**Кришна** - Верховная Личность Бога, привлекающий всех
**Рама** - Верховное наслаждение, источник счастья

Эта мантра очищает сердце от материальных желаний и пробуждает любовь к Богу. Она является звуковым воплощением трансцендентного звука и способна даровать освобождение.
''',

    'bhakti_development': '''
Развитие бхакти (преданности):

1. **Слушание** - читайте священные писания
2. **Повторение** - регулярная джапа
3. **Памятование** - медитация на Кришну
4. **Поклонение** - служение в храме
5. **Молитва** - искренние обращения к Богу
6. **Служение** - помощь другим преданным

Бхакти развивается постепенно, через регулярную практику и милость духовного учителя.
''',

    'karma_liberation': '''
Карма и освобождение:

**Карма** - закон действия и реакции, который связывает душу материальным миром.

**Пути освобождения:**
- Карма-йога - бескорыстное действие
- Джняна-йога - путь знания
- Бхакти-йога - путь преданности (самый эффективный)

Через бхакти можно выйти за пределы кармы и достичь духовного мира, где нет страданий и смерти.
''',

    'krishna_meditation': '''
Медитация на Кришну:

1. **Образ**: Представляйте Кришну как прекрасного пастушка
2. **Атрибуты**: Флейта, корона с павлиньим пером, желтые одежды
3. **Место**: Вриндаван, вечная обитель любви
4. **Чувства**: Любовь, благодарность, преданность
5. **Мантра**: Повторяйте Харе Кришна махамантру

Медитация должна быть регулярной и искренней. Кришна находится в сердце каждого живого существа.
''',

    'maya_understanding': '''
Майя - иллюзорная энергия:

**Что такое майя:**
- Иллюзорная энергия, скрывающая истинную природу души
- Заставляет забыть о вечной связи с Богом
- Создает ложное отождествление с телом

**Как преодолеть:**
- Регулярная джапа и медитация
- Изучение священных писаний
- Общение с преданными
- Милость духовного учителя

Майя сильна, но преданность к Кришне сильнее.
''',

    'self_realization': '''
Самоосознание (атма-джняна):

**Что это:**
- Понимание своей истинной природы как духовной души
- Осознание вечности, знания и блаженства
- Понимание отношений с Верховным Господом

**Путь к самоосознанию:**
1. Слушание о Кришне
2. Повторение мантр
3. Памятование о Боге
4. Поклонение Божеству
5. Молитва
6. Служение

Самоосознание приходит через бхакти, а не через материальные усилия.
''',

    'guru_parampara': '''
Гуру-парампара - цепь духовных учителей:

**Что это:**
- Непрерывная цепь передачи духовного знания
- Начинается от Кришны и идет через великих ачарьев
- Обеспечивает чистоту учения

**Важность:**
- Без гуру невозможно постичь духовную науку
- Гуру является представителем Кришны
- Через гуру приходит милость

**Как найти гуру:**
- Искренне молиться Кришне
- Изучать священные писания
- Общаться с преданными
- Следовать принципам бхакти
''',

    'bhagavad_gita': '''
Бхагавад-гита - песнь Бога:

**Основные темы:**
- Природа души и тела
- Карма и освобождение
- Пути духовного развития
- Преданное служение
- Любовь к Богу

**Ключевые уроки:**
- "Выполняй свой долг, но не привязывайся к результатам"
- "Я есть источник всех духовных и материальных миров"
- "Предайся Мне, и Я освобожу тебя от всех грехов"

Изучайте Гиту с преданным настроением, и Кришна откроет вам её тайны.
''',

    'prema_love': '''
Према - чистая любовь к Богу:

**Что такое према:**
- Высшая форма любви, свободная от материальных желаний
- Естественное состояние души
- Цель всех духовных практик

**Признаки премы:**
- Постоянное памятование о Кришне
- Отсутствие материальных желаний
- Желание служить Богу
- Любовь ко всем живым существам

**Как развить:**
- Регулярная джапа
- Слушание о Кришне
- Общение с преданными
- Милость духовного учителя

Према - это дар Кришны, который нельзя заслужить, но можно получить через преданное служение.
''',
  };

  /// Отправляет вопрос к AI модели
  static Future<String?> askQuestion(
    String question, {
    String category = 'spiritual',
  }) async {
    final dio = Dio();
    try {
      // Проверяем кэш
      if (_responseCache.containsKey(question)) {
        return _responseCache[question];
      }

      // Сначала пытаемся использовать локальные ответы
      final localAnswer = _getLocalAnswer(question, category);
      if (localAnswer != null) {
        _responseCache[question] = localAnswer;
        return localAnswer;
      }

      // Проверяем доступность AI сервера
      if (await isServerAvailable()) {
        final response = await dio.post(
          '$_baseUrl/api/generate',
          data: {
            'model': _model,
            'prompt': _buildPrompt(question, category),
            'stream': false,
            'options': {'temperature': 0.7, 'top_p': 0.9, 'max_tokens': 500},
          },
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final answer = data['response'] as String?;

          if (answer != null && answer.isNotEmpty) {
            // Кэшируем ответ
            _responseCache[question] = answer;
            await _saveToLocalStorage(question, answer);
            return answer;
          }
        }
      }

      // Если AI недоступен, используем локальные ответы
      return _getFallbackAnswer(question, category);
    } catch (e) {
      return _getFallbackAnswer(question, category);
    }
  }

  /// Получает локальный ответ на вопрос
  static String? _getLocalAnswer(String question, String category) {
    final lowerQuestion = question.toLowerCase();

    // Ищем ключевые слова в вопросе
    if (lowerQuestion.contains('как') &&
        lowerQuestion.contains('читать') &&
        lowerQuestion.contains('джапу')) {
      return _localResponses['japa_how_to'];
    }
    if (lowerQuestion.contains('что') &&
        lowerQuestion.contains('означает') &&
        lowerQuestion.contains('мантра')) {
      return _localResponses['mantra_meaning'];
    }
    if (lowerQuestion.contains('как') &&
        lowerQuestion.contains('развить') &&
        lowerQuestion.contains('бхакти')) {
      return _localResponses['bhakti_development'];
    }
    if (lowerQuestion.contains('карма') &&
        lowerQuestion.contains('освобождение')) {
      return _localResponses['karma_liberation'];
    }
    if (lowerQuestion.contains('медитировать') &&
        lowerQuestion.contains('кришна')) {
      return _localResponses['krishna_meditation'];
    }
    if (lowerQuestion.contains('майя')) {
      return _localResponses['maya_understanding'];
    }
    if (lowerQuestion.contains('самоосознание')) {
      return _localResponses['self_realization'];
    }
    if (lowerQuestion.contains('гуру') || lowerQuestion.contains('парампара')) {
      return _localResponses['guru_parampara'];
    }
    if (lowerQuestion.contains('бхагавад') && lowerQuestion.contains('гита')) {
      return _localResponses['bhagavad_gita'];
    }
    if (lowerQuestion.contains('према') || lowerQuestion.contains('любовь')) {
      return _localResponses['prema_love'];
    }

    return null;
  }

  /// Получает запасной ответ
  static String _getFallbackAnswer(String question, String category) {
    return '''
Спасибо за ваш духовный вопрос! 

К сожалению, AI сервер временно недоступен. Вот несколько рекомендаций:

1. **Продолжайте практику джапы** - это лучший способ получить ответы
2. **Изучайте священные писания** - Бхагавад-гита, Шримад-Бхагаватам
3. **Общайтесь с преданными** - они могут поделиться опытом
4. **Обратитесь к духовному учителю** - он даст точные ответы

Помните: истинное знание приходит через преданное служение и милость Кришны.

Харе Кришна! 🕉️
''';
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

  /// Сохраняет ответ в локальное хранилище
  static Future<void> _saveToLocalStorage(
    String question,
    String answer,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'ai_response_${question.hashCode}';
      await prefs.setString(key, answer);

      // Ограничиваем количество сохраненных ответов
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('ai_response_'))
          .toList();
      if (keys.length > 100) {
        // Удаляем старые ответы
        for (int i = 0; i < keys.length - 100; i++) {
          await prefs.remove(keys[i]);
        }
      }
    } catch (e) {
      // silent
    }
  }

  /// Получает подсказки для духовных вопросов
  static List<String> getSpiritualQuestionHints() {
    return AppConstants.spiritualQuestionHints;
  }

  /// Проверяет доступность AI сервера
  static Future<bool> isServerAvailable() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        '$_baseUrl/api/tags',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Получает информацию о доступных моделях
  static Future<List<String>> getAvailableModels() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        '$_baseUrl/api/tags',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
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

  /// Проверяет, доступна ли модель braindler
  static Future<bool> isBraindlerAvailable() async {
    try {
      final models = await getAvailableModels();
      return models.contains(_model) || 
             models.any((m) => m.startsWith('braindler'));
    } catch (e) {
      return false;
    }
  }

  /// Получает информацию о модели
  static Future<Map<String, dynamic>?> getModelInfo() async {
    final dio = Dio();
    try {
      final response = await dio.post(
        '$_baseUrl/api/show',
        data: {'name': _model},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
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

  /// Получает статистику использования AI
  static Future<Map<String, dynamic>> getUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalQuestions = prefs.getInt('ai_total_questions') ?? 0;
      final successfulResponses = prefs.getInt('ai_successful_responses') ?? 0;
      final localResponses = prefs.getInt('ai_local_responses') ?? 0;

      return {
        'total_questions': totalQuestions,
        'successful_responses': successfulResponses,
        'local_responses': localResponses,
        'success_rate': totalQuestions > 0
            ? (successfulResponses / totalQuestions * 100).round()
            : 0,
        'cache_size': _responseCache.length,
      };
    } catch (e) {
      return {};
    }
  }

  /// Обновляет статистику использования
  static Future<void> updateUsageStats({
    required bool isSuccessful,
    required bool isLocal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final totalQuestions = (prefs.getInt('ai_total_questions') ?? 0) + 1;
      await prefs.setInt('ai_total_questions', totalQuestions);

      if (isSuccessful) {
        final successfulResponses =
            (prefs.getInt('ai_successful_responses') ?? 0) + 1;
        await prefs.setInt('ai_successful_responses', successfulResponses);
      }

      if (isLocal) {
        final localResponses = (prefs.getInt('ai_local_responses') ?? 0) + 1;
        await prefs.setInt('ai_local_responses', localResponses);
      }
    } catch (e) {
      // silent
    }
  }
}
