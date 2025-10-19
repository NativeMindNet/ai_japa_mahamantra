import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/encrypted_log_service.dart';
import '../services/ai_power_mode_service.dart';
import '../services/mozgach108_service.dart';

/// Секретный экран для просмотра зашифрованных логов
/// Доступен только через Easter Egg:
/// - Тройной тап на 108-й бусине
/// - Или удержание центральной мандалы + свайп по часовой стрелке 108 раз
class EasterEggLogsScreen extends StatefulWidget {
  const EasterEggLogsScreen({Key? key}) : super(key: key);

  @override
  State<EasterEggLogsScreen> createState() => _EasterEggLogsScreenState();
}

class _EasterEggLogsScreenState extends State<EasterEggLogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Данные логов
  List<Map<String, dynamic>> _highPowerLogs = [];
  List<Map<String, dynamic>> _lowPowerLogs = [];
  Map<String, int> _logsStatistics = {};
  Map<String, dynamic> _aiStats = {};
  Map<String, dynamic> _mozgachStats = {};
  
  bool _isLoading = true;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
    
    // Показываем конфетти при открытии Easter Egg
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showConfetti = true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    try {
      // Загружаем логи
      final highPower = await EncryptedLogService.instance.getHighPowerLogs();
      final lowPower = await EncryptedLogService.instance.getLowPowerLogs();
      final stats = await EncryptedLogService.instance.getLogsStatistics();
      
      // Загружаем статистику AI
      final aiPowerStats = AIPowerModeService.instance.getStatistics();
      final mozgachStats = await Mozgach108Service.instance.getStatistics();
      
      setState(() {
        _highPowerLogs = highPower;
        _lowPowerLogs = lowPower;
        _logsStatistics = stats;
        _aiStats = aiPowerStats;
        _mozgachStats = mozgachStats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            const Icon(Icons.lock, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.amber, Colors.orange, Colors.deepOrange],
              ).createShader(bounds),
              child: const Text(
                '🕉️ ENCRYPTED LOGS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _loadAllData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.amber),
            color: Colors.grey[900],
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportLogs();
                  break;
                case 'clear':
                  _confirmClearLogs();
                  break;
                case 'stats':
                  _showStatistics();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Экспорт логов', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Статистика', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Очистить логи', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'High Power\n(108 Models)', icon: Icon(Icons.rocket_launch, size: 18)),
            Tab(text: 'Low Power\n(Energy Save)', icon: Icon(Icons.battery_saver, size: 18)),
            Tab(text: 'Statistics', icon: Icon(Icons.analytics, size: 18)),
            Tab(text: 'About', icon: Icon(Icons.info, size: 18)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Фон с эффектом матрицы
          _buildMatrixBackground(),
          
          // Контент
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHighPowerTab(),
                    _buildLowPowerTab(),
                    _buildStatisticsTab(),
                    _buildAboutTab(),
                  ],
                ),
          
          // Конфетти эффект
          if (_showConfetti) _buildConfettiEffect(),
        ],
      ),
    );
  }

  Widget _buildMatrixBackground() {
    return Opacity(
      opacity: 0.05,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade900,
              Colors.black,
              Colors.amber.shade900,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighPowerTab() {
    if (_highPowerLogs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.rocket_launch,
        title: 'Нет High Power логов',
        subtitle: 'Обработайте мантру через 108 моделей мозgач108',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _highPowerLogs.length,
      itemBuilder: (context, index) {
        final log = _highPowerLogs[index];
        final metadata = log['metadata'] as Map<String, dynamic>?;
        
        return _buildLogCard(
          index: index + 1,
          title: 'Модель #${metadata?['model_number'] ?? '?'}',
          subtitle: metadata?['model_name'] ?? 'Unknown',
          timestamp: log['timestamp'] ?? '',
          color: Colors.amber,
          icon: Icons.precision_manufacturing,
          children: [
            _buildLogDetail('Бусина', '${metadata?['bead_number'] ?? '?'} / 108'),
            _buildLogDetail('Круг', '#${metadata?['round_number'] ?? '?'}'),
            _buildLogDetail('Время обработки', '${metadata?['processing_time_ms'] ?? 0} ms'),
            const Divider(color: Colors.grey),
            _buildLogDetail('Мантра', metadata?['mantra'] ?? '', isMultiline: true),
            const Divider(color: Colors.grey),
            _buildLogDetail('Ответ AI', metadata?['response'] ?? '', isMultiline: true),
          ],
        );
      },
    );
  }

  Widget _buildLowPowerTab() {
    if (_lowPowerLogs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.battery_saver,
        title: 'Нет Low Power логов',
        subtitle: 'Завершите цикл 108 мантр в энергоэффективном режиме',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lowPowerLogs.length,
      itemBuilder: (context, index) {
        final log = _lowPowerLogs[index];
        final metadata = log['metadata'] as Map<String, dynamic>?;
        
        return _buildLogCard(
          index: index + 1,
          title: 'Цикл #${metadata?['cycle_number'] ?? '?'}',
          subtitle: 'Low Power Mode',
          timestamp: log['timestamp'] ?? '',
          color: Colors.green,
          icon: Icons.eco,
          children: [
            _buildLogDetail('Мантр обработано', '${metadata?['mantras_count'] ?? 0}'),
            _buildLogDetail('Длина текста', '${metadata?['text_length'] ?? 0} символов'),
            const Divider(color: Colors.grey),
            _buildLogDetail(
              'Накопленный текст',
              _truncateText(metadata?['accumulated_text'] ?? '', 500),
              isMultiline: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Логи',
          [
            {'label': 'High Power', 'value': _logsStatistics['high_power_count'] ?? 0},
            {'label': 'Low Power', 'value': _logsStatistics['low_power_count'] ?? 0},
            {'label': 'Всего', 'value': _logsStatistics['total_count'] ?? 0},
          ],
          Colors.amber,
          Icons.file_present,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'AI Power Mode',
          [
            {'label': 'Текущий режим', 'value': _aiStats['currentMode'] ?? 'Unknown'},
            {'label': 'Ускоритель доступен', 'value': _aiStats['isAcceleratorAvailable'] ?? false ? 'Да' : 'Нет'},
            {'label': 'Low Power циклы', 'value': _aiStats['lowPowerCycleCount'] ?? 0},
            {'label': 'Размер аккумулятора', 'value': '${_aiStats['accumulatorLength'] ?? 0} символов'},
          ],
          Colors.blue,
          Icons.power_settings_new,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Мозgач108',
          [
            {'label': 'Всего моделей', 'value': _mozgachStats['total_models'] ?? 108},
            {'label': 'Обработано', 'value': _mozgachStats['total_models_processed'] ?? 0},
            {'label': 'Текущий индекс', 'value': _mozgachStats['current_model_index'] ?? 0},
            {'label': 'Инициализирован', 'value': _mozgachStats['is_initialized'] ?? false ? 'Да' : 'Нет'},
          ],
          Colors.purple,
          Icons.psychology,
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lock, color: Colors.amber, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Encrypted Logs System',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AES-256 Encryption',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'О системе логирования',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Этот экран доступен только через Easter Egg и содержит зашифрованные логи обработки мантр через AI модели.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                _buildAboutItem(
                  '🔒 Шифрование',
                  'AES-256 с уникальным ключом для каждого устройства',
                ),
                _buildAboutItem(
                  '🚀 High Power Mode',
                  'Обработка через 108 квантовых моделей мозgач108',
                ),
                _buildAboutItem(
                  '🔋 Low Power Mode',
                  'Энергоэффективная конкатенация строк',
                ),
                _buildAboutItem(
                  '📊 Метаданные',
                  'Timestamp, номер модели, время обработки, ответы AI',
                ),
                _buildAboutItem(
                  '🔐 Безопасность',
                  'Логи хранятся только на устройстве и никуда не передаются',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogCard({
    required int index,
    required String title,
    required String subtitle,
    required String timestamp,
    required Color color,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(color: color, fontSize: 12),
              ),
              Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogDetail(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    List<Map<String, dynamic>> items,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['label'],
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        item['value'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiEffect() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _showConfetti ? 1.0 : 0.0,
        duration: const Duration(seconds: 2),
        onEnd: () {
          if (mounted) {
            setState(() => _showConfetti = false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.amber.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<void> _exportLogs() async {
    try {
      final highPowerText = await EncryptedLogService.instance
          .exportLogsAsText(EncryptedLogService.logTypeHighPower);
      final lowPowerText = await EncryptedLogService.instance
          .exportLogsAsText(EncryptedLogService.logTypeLowPower);
      
      final fullExport = '$highPowerText\n\n$lowPowerText';
      
      await Clipboard.setData(ClipboardData(text: fullExport));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Логи скопированы в буфер обмена'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmClearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Очистить все логи?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Это действие необратимо. Все зашифрованные логи будут удалены.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await EncryptedLogService.instance.clearAllLogs();
      await _loadAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Все логи очищены'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.amber),
            SizedBox(width: 8),
            Text('Детальная статистика', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('High Power логов', _logsStatistics['high_power_count'] ?? 0),
              _buildStatItem('Low Power логов', _logsStatistics['low_power_count'] ?? 0),
              _buildStatItem('Всего записей', _logsStatistics['total_count'] ?? 0),
              const Divider(color: Colors.grey),
              _buildStatItem('Моделей обработано', _mozgachStats['total_models_processed'] ?? 0),
              _buildStatItem('Текущий прогресс', '${_mozgachStats['current_model_index'] ?? 0}/108'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

