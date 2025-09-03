import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/japa_provider.dart';
import '../services/ai_service.dart';
import '../constants/app_constants.dart';
import '../models/ai_assistant.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<AIConversation> _conversations = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String? _aiStatus;
  bool _isMozgachAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAIStatus();
    _loadConversations();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  /// Проверяет статус AI сервера
  Future<void> _checkAIStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isAvailable = await AIService.isServerAvailable();
      final isMozgach = await AIService.isMozgachAvailable();
      
      setState(() {
        _aiStatus = isAvailable 
            ? (isMozgach ? 'mozgach:latest доступен' : 'AI доступен, но mozgach:latest не найден')
            : 'AI сервер недоступен';
        _isMozgachAvailable = isMozgach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiStatus = 'Ошибка проверки AI';
        _isLoading = false;
      });
    }
  }

  /// Загружает историю разговоров
  Future<void> _loadConversations() async {
    // Здесь можно загрузить сохраненные разговоры из локального хранилища
    // Пока оставляем пустым
  }

  /// Отправляет вопрос к AI
  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final answer = await AIService.askQuestion(
        question,
        category: _selectedCategory ?? 'spiritual',
      );

      if (answer != null) {
        final conversation = AIConversation(
          question: question,
          answer: answer,
          timestamp: DateTime.now(),
          category: _selectedCategory ?? 'spiritual',
        );

        setState(() {
          _conversations.insert(0, conversation);
          _questionController.clear();
          _selectedCategory = null;
        });

        // Сохраняем разговор
        await _saveConversation(conversation);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при получении ответа: $e'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Сохраняет разговор в локальное хранилище
  Future<void> _saveConversation(AIConversation conversation) async {
    // Здесь можно добавить сохранение в локальную базу данных
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text(
          'AI Духовный Помощник',
          style: TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAIStatus,
            tooltip: 'Проверить статус AI',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Открыть настройки AI
            },
            tooltip: 'Настройки AI',
          ),
        ],
      ),
      body: Column(
        children: [
          // Статус AI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            color: _isMozgachAvailable 
                ? Color(AppConstants.successColor).withOpacity(0.1)
                : Color(AppConstants.errorColor).withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _isMozgachAvailable ? Icons.check_circle : Icons.error,
                  color: _isMozgachAvailable 
                      ? Color(AppConstants.successColor)
                      : Color(AppConstants.errorColor),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    _aiStatus ?? 'Проверка статуса...',
                    style: TextStyle(
                      color: _isMozgachAvailable 
                          ? Color(AppConstants.successColor)
                          : Color(AppConstants.errorColor),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Форма вопроса
          Container(
            margin: const EdgeInsets.all(AppConstants.defaultPadding),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Color(AppConstants.surfaceColor),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Задайте духовный вопрос:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Выбор категории
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория вопроса',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.spiritualCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Поле вопроса
                TextField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ваш вопрос',
                    hintText: 'Например: Как правильно читать джапу?',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Кнопка отправки
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _askQuestion,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Задать вопрос AI',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Подсказки
          if (_conversations.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Color(AppConstants.surfaceColor),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Color(AppConstants.primaryColor).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Попробуйте задать один из этих вопросов:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.primaryColor),
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  ...AppConstants.spiritualQuestionHints.take(5).map((hint) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hint,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // История разговоров
          Expanded(
            child: _conversations.isEmpty
                ? const Center(
                    child: Text(
                      'Начните разговор с AI, задав духовный вопрос',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      return _buildConversationCard(conversation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Строит карточку разговора
  Widget _buildConversationCard(AIConversation conversation) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(AppConstants.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    conversation.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.primaryColor),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(conversation.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // Вопрос
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: Color(AppConstants.backgroundColor),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(AppConstants.primaryColor).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❓ Вопрос:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.question,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // Ответ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: Color(AppConstants.successColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(AppConstants.successColor).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: Color(AppConstants.successColor),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Ответ:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.successColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.answer,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Форматирует временную метку
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }
}
