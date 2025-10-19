import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_power_mode_service.dart';
import '../constants/app_constants.dart';

/// Easter Egg экран для просмотра логов Low Power режима
/// Доступен только через специальную последовательность действий
class EasterEggLogScreen extends StatefulWidget {
  const EasterEggLogScreen({super.key});

  @override
  State<EasterEggLogScreen> createState() => _EasterEggLogScreenState();
}

class _EasterEggLogScreenState extends State<EasterEggLogScreen>
    with SingleTickerProviderStateMixin {
  final _aiPowerService = AIPowerModeService.instance;
  String _fullLog = '';
  List<String> _recentLogs = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final fullLog = await _aiPowerService.getFullCycleLog();
      final recentLogs = _aiPowerService.getLogs();

      setState(() {
        _fullLog = fullLog;
        _recentLogs = recentLogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fullLog = 'Ошибка загрузки логов: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить логи?'),
        content: const Text(
          'Это действие удалит все сохраненные логи. Продолжить?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _aiPowerService.clearLogs();
      await _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Логи очищены')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скопировано в буфер обмена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐣 Easter Egg - AI Логи'),
        backgroundColor: const Color(AppConstants.primaryColor),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Статистика'),
            Tab(text: 'Циклы 108'),
            Tab(text: 'Все логи'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Очистить логи',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildCycleLogsTab(),
                _buildAllLogsTab(),
              ],
            ),
    );
  }

  Widget _buildStatisticsTab() {
    final stats = _aiPowerService.getStatistics();
    final lowPowerStatus = _aiPowerService.getLowPowerStatus();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Режим работы AI',
            icon: Icons.power_settings_new,
            children: [
              _buildStatItem('Текущий режим', stats['currentMode'] ?? 'Unknown'),
              _buildStatItem(
                'AI Ускоритель',
                stats['isAcceleratorAvailable'] == true
                    ? '✅ Доступен'
                    : '❌ Недоступен',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Текущий цикл Low Power',
            icon: Icons.loop,
            children: [
              _buildStatItem(
                'Прогресс',
                '${lowPowerStatus['cycleCount']}/${lowPowerStatus['maxCycles']}',
              ),
              LinearProgressIndicator(
                value: lowPowerStatus['progress'] as double,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(AppConstants.primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              _buildStatItem(
                'Размер аккумулятора',
                '${lowPowerStatus['accumulatorLength']} символов',
              ),
              _buildStatItem(
                'Статус',
                lowPowerStatus['isComplete'] == true
                    ? '✅ Завершен'
                    : '⏳ В процессе',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Общая статистика',
            icon: Icons.analytics,
            children: [
              _buildStatItem(
                'Записей в памяти',
                '${stats['logsCount']}',
              ),
              _buildStatItem(
                'Циклов Low Power',
                '${lowPowerStatus['cycleCount']}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLogsTab() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(AppConstants.primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Завершенные циклы 108 мантр',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () => _copyToClipboard(_fullLog),
                  tooltip: 'Копировать',
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _fullLog,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllLogsTab() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(AppConstants.primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Все логи (${_recentLogs.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () =>
                      _copyToClipboard(_recentLogs.join('\n')),
                  tooltip: 'Копировать',
                ),
              ],
            ),
          ),
          Expanded(
            child: _recentLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Логи пусты',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _recentLogs.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final log = _recentLogs[
                          _recentLogs.length - 1 - index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          log,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.greenAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(AppConstants.primaryColor)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

