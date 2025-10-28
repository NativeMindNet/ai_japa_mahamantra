import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/encrypted_log_service.dart';
import '../services/braindler108_service.dart';
import '../services/mozgach108_service.dart';
import '../services/local_ai_service.dart';
import '../constants/app_constants.dart';
import '../widgets/modern_ui_components.dart';

/// Экран для просмотра всех зашифрованных логов AI систем
/// Доступен только через Easter Egg активацию
class EasterEggLogsScreen extends StatefulWidget {
  const EasterEggLogsScreen({super.key});

  @override
  State<EasterEggLogsScreen> createState() => _EasterEggLogsScreenState();
}

class _EasterEggLogsScreenState extends State<EasterEggLogsScreen>
    with SingleTickerProviderStateMixin {
  final _encryptedLogService = EncryptedLogService.instance;
  final _braindlerService = Braindler108Service.instance;
  final _mozgachService = Mozgach108Service.instance;
  final _localAIService = LocalAIService.instance;

  late TabController _tabController;
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _allLogs = {};
  Map<String, int> _logStatistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLogs() async {
    setState(() => _isLoading = true);

    try {
      // Загружаем все типы логов
      final allLogs = await _encryptedLogService.getAllLogs();
      final logStats = await _encryptedLogService.getLogsStatistics();

      setState(() {
        _allLogs = allLogs;
        _logStatistics = logStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ModernUIComponents.showSnackBar(
          context: context,
          message: 'Ошибка загрузки логов: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _clearLogs(String logType) async {
    final confirm = await ModernUIComponents.showConfirmDialog(
      context: context,
      title: 'Очистить логи?',
      message: 'Это действие удалит все логи типа "$logType". Продолжить?',
      confirmText: 'Очистить',
      cancelText: 'Отмена',
    );

    if (confirm == true) {
      await _encryptedLogService.clearLogs(logType);
      await _loadAllLogs();
      if (mounted) {
        ModernUIComponents.showSnackBar(
          context: context,
          message: 'Логи очищены',
          backgroundColor: Colors.green,
        );
      }
    }
  }

  Future<void> _clearAllLogs() async {
    final confirm = await ModernUIComponents.showConfirmDialog(
      context: context,
      title: 'Очистить ВСЕ логи?',
      message: 'Это действие удалит все зашифрованные логи. Продолжить?',
      confirmText: 'Очистить все',
      cancelText: 'Отмена',
      confirmColor: Colors.red,
    );

    if (confirm == true) {
      await _encryptedLogService.clearAllLogs();
      await _loadAllLogs();
      if (mounted) {
        ModernUIComponents.showSnackBar(
          context: context,
          message: 'Все логи очищены',
          backgroundColor: Colors.green,
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ModernUIComponents.showSnackBar(
      context: context,
      message: 'Скопировано в буфер обмена',
      backgroundColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 AI Системы - Зашифрованные Логи'),
        backgroundColor: const Color(AppConstants.primaryColor),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '📊 Статистика'),
            Tab(text: '🧠 Braindler108'),
            Tab(text: '⚡ Mozgach108'),
            Tab(text: '📱 LocalAI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllLogs,
            tooltip: 'Обновить',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Очистить все логи'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? ModernUIComponents.loadingIndicator(message: 'Загрузка логов...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildBraindlerLogsTab(),
                _buildMozgachLogsTab(),
                _buildLocalAILogsTab(),
              ],
            ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModernUIComponents.sectionHeader(
            title: 'Общая статистика логов',
            subtitle: 'Зашифрованные данные AI систем',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Статистика по типам логов
          ModernUIComponents.gradientCard(
            context: context,
            gradientColors: [
              Colors.blue.withValues(alpha: 0.1),
              Colors.purple.withValues(alpha: 0.1),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Статистика по типам логов',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ..._logStatistics.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getLogTypeDisplayName(entry.key)),
                        Text(
                          '${entry.value} записей',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Статистика сервисов
          ModernUIComponents.gradientCard(
            context: context,
            gradientColors: [
              Colors.green.withValues(alpha: 0.1),
              Colors.teal.withValues(alpha: 0.1),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔧 Статус AI сервисов',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildServiceStatus('Braindler108', _braindlerService.isAvailable),
                _buildServiceStatus('Mozgach108', _mozgachService.isInitialized),
                _buildServiceStatus('LocalAI', _localAIService.isAvailable),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Размеры логов
          FutureBuilder<Map<String, int>>(
            future: _encryptedLogService.getLogsSizeInBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final sizes = snapshot.data!;
                return ModernUIComponents.gradientCard(
                  context: context,
                  gradientColors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.1),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💾 Размеры логов',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ...sizes.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getLogTypeDisplayName(entry.key)),
                              Text(
                                _formatBytes(entry.value),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus(String serviceName, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(serviceName),
          Row(
            children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.error,
                color: isAvailable ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? 'Активен' : 'Неактивен',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBraindlerLogsTab() {
    final logs = _allLogs['high_power'] ?? [];
    
    if (logs.isEmpty) {
      return ModernUIComponents.emptyState(
        icon: Icons.psychology,
        title: 'Логи Braindler108 пусты',
        subtitle: 'Завершите хотя бы один цикл обработки через 108 моделей Braindler',
        action: ModernUIComponents.animatedButton(
          text: 'Обновить',
          onPressed: _loadAllLogs,
          icon: Icons.refresh,
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          color: const Color(AppConstants.primaryColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Braindler108 Логи (${logs.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () => _copyToClipboard(
                      logs.map((log) => log.toString()).join('\n'),
                    ),
                    tooltip: 'Копировать',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _clearLogs('high_power_108'),
                    tooltip: 'Очистить',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.blue),
                          const SizedBox(width: AppConstants.smallPadding),
                          Expanded(
                            child: Text(
                              log['message'] ?? 'Нет сообщения',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            _formatTimestamp(log['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (log['metadata'] != null) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Метаданные: ${log['metadata']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMozgachLogsTab() {
    final logs = _allLogs['high_power'] ?? [];
    
    if (logs.isEmpty) {
      return ModernUIComponents.emptyState(
        icon: Icons.flash_on,
        title: 'Логи Mozgach108 пусты',
        subtitle: 'Завершите хотя бы один цикл обработки через 108 моделей Mozgach',
        action: ModernUIComponents.animatedButton(
          text: 'Обновить',
          onPressed: _loadAllLogs,
          icon: Icons.refresh,
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          color: const Color(AppConstants.accentColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mozgach108 Логи (${logs.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () => _copyToClipboard(
                      logs.map((log) => log.toString()).join('\n'),
                    ),
                    tooltip: 'Копировать',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _clearLogs('high_power_108'),
                    tooltip: 'Очистить',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.orange),
                          const SizedBox(width: AppConstants.smallPadding),
                          Expanded(
                            child: Text(
                              log['message'] ?? 'Нет сообщения',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            _formatTimestamp(log['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (log['metadata'] != null) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Метаданные: ${log['metadata']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocalAILogsTab() {
    final logs = _allLogs['general'] ?? [];
    
    if (logs.isEmpty) {
      return ModernUIComponents.emptyState(
        icon: Icons.phone_android,
        title: 'Логи LocalAI пусты',
        subtitle: 'Используйте локальный AI для обработки мантр',
        action: ModernUIComponents.animatedButton(
          text: 'Обновить',
          onPressed: _loadAllLogs,
          icon: Icons.refresh,
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          color: Colors.green,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LocalAI Логи (${logs.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () => _copyToClipboard(
                      logs.map((log) => log.toString()).join('\n'),
                    ),
                    tooltip: 'Копировать',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _clearLogs('general'),
                    tooltip: 'Очистить',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone_android, color: Colors.green),
                          const SizedBox(width: AppConstants.smallPadding),
                          Expanded(
                            child: Text(
                              log['message'] ?? 'Нет сообщения',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            _formatTimestamp(log['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (log['metadata'] != null) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Метаданные: ${log['metadata']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getLogTypeDisplayName(String logType) {
    switch (logType) {
      case 'high_power_count':
        return '🧠 Braindler108';
      case 'low_power_count':
        return '⚡ Low Power';
      case 'general_count':
        return '📱 LocalAI';
      case 'total_count':
        return '📊 Всего';
      default:
        return logType;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Неизвестно';
    try {
      final dateTime = DateTime.parse(timestamp.toString());
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Неверный формат';
    }
  }
}