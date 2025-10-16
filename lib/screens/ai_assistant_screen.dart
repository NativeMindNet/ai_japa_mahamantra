import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../constants/app_constants.dart';
import '../models/ai_assistant.dart';
import '../l10n/app_localizations_delegate.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
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

      if (mounted) {
        setState(() {
          _aiStatus = isAvailable
              ? (isMozgach
                    ? 'mozgach:latest доступен'
                    : 'AI доступен, но mozgach:latest не найден')
              : 'AI сервер недоступен';
          _isMozgachAvailable = isMozgach;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiStatus = 'Ошибка проверки AI';
          _isLoading = false;
        });
      }
    }
  }

  /// Загружает историю разговоров
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getStringList('ai_conversations') ?? [];

      final conversations = <AIConversation>[];

      for (final jsonString in conversationsJson) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final conversation = AIConversation.fromJson(json);
          conversations.add(conversation);
        } catch (e) {
          // silent
        }
      }

      // Сортируем по времени (новые сверху)
      conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          _conversations.addAll(conversations);
        });
      }
    } catch (e) {
      // silent
    }
  }

  /// Отправляет вопрос к AI
  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    // Скрываем клавиатуру
    FocusScope.of(context).unfocus();

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

        if (mounted) {
          setState(() {
            _conversations.insert(0, conversation);
            _questionController.clear();
            _selectedCategory = null;
          });
        }

        // Сохраняем разговор
        await _saveConversation(conversation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отправке вопроса: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Сохраняет разговор
  Future<void> _saveConversation(AIConversation conversation) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Получаем существующие разговоры
      final conversationsJson = prefs.getStringList('ai_conversations') ?? [];

      // Добавляем новый разговор
      conversationsJson.add(jsonEncode(conversation.toJson()));

      // Ограничиваем количество сохраненных разговоров (последние 100)
      if (conversationsJson.length > 100) {
        conversationsJson.removeRange(0, conversationsJson.length - 100);
      }

      // Сохраняем обратно
      await prefs.setStringList('ai_conversations', conversationsJson);

      // Обновляем статистику
      await AIService.updateUsageStats(isSuccessful: true, isLocal: false);
    } catch (e) {
      // silent
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.aiAssistant,
          style: const TextStyle(
            fontFamily: 'Sanskrit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // Статус AI
            _buildAIStatusCard(l10n),

            // Форма вопроса
            _buildQuestionForm(l10n),

            // История разговоров
            Expanded(child: _buildConversationsList(l10n)),
          ],
        ),
      ),
    );
  }

  /// Строит карточку статуса AI
  Widget _buildAIStatusCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isMozgachAvailable ? Icons.check_circle : Icons.error,
                  color: _isMozgachAvailable ? Colors.green : Colors.red,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  l10n.aiStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _aiStatus ?? 'Проверка...',
              style: TextStyle(
                color: _isMozgachAvailable ? Colors.green : Colors.red,
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: AppConstants.smallPadding),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  /// Строит форму вопроса
  Widget _buildQuestionForm(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Задайте духовный вопрос:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),

            // Категория
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: l10n.spiritualCategories.asMap().entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key.toString(),
                  child: Text(entry.value),
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _askQuestion(),
              decoration: InputDecoration(
                labelText: 'Ваш вопрос',
                hintText: 'Например: ${l10n.spiritualQuestionHints.first}',
                border: const OutlineInputBorder(),
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
                    : const Text('Задать вопрос'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Строит список разговоров
  Widget _buildConversationsList(AppLocalizations l10n) {
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Начните разговор с AI',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Задайте духовный вопрос выше',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Вопрос
                Row(
                  children: [
                    const Icon(Icons.question_answer, color: Colors.blue),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        conversation.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Ответ
                Row(
                  children: [
                    const Icon(Icons.smart_toy, color: Colors.green),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        conversation.answer,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Время
                Text(
                  _formatTimestamp(conversation.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Форматирует временную метку
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч назад';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }
}
