import 'package:flutter/material.dart';
import '../models/mahabharata_comic.dart';
import '../services/mahabharata_service.dart';
import '../screens/mahabharata_comics_screen.dart';

/// Виджет для показа комиксов-наград после джапы
/// Интегрирует комиксы Махабхараты с практикой джапы
class JapaComicRewardWidget extends StatefulWidget {
  /// Количество завершенных кругов
  final int completedRounds;
  
  /// Номер текущей бусины (опционально)
  final int? currentBead;
  
  /// Callback после закрытия награды
  final VoidCallback? onDismiss;

  const JapaComicRewardWidget({
    super.key,
    required this.completedRounds,
    this.currentBead,
    this.onDismiss,
  });

  @override
  State<JapaComicRewardWidget> createState() => _JapaComicRewardWidgetState();
}

class _JapaComicRewardWidgetState extends State<JapaComicRewardWidget>
    with SingleTickerProviderStateMixin {
  final MahabharataService _service = MahabharataService.instance;
  List<MahabharataComic> _availableComics = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadRewardComics();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    _animationController.forward();
  }

  Future<void> _loadRewardComics() async {
    setState(() => _isLoading = true);
    
    try {
      await _service.initialize();
      
      // Получаем комиксы-награды
      final rewardComics = _service.getRewardComics(widget.completedRounds);
      
      // Если указана бусина, также проверяем комиксы для этой бусины
      if (widget.currentBead != null) {
        final beadComics = _service.getComicsByJapaConnection(
          beadNumber: widget.currentBead,
        );
        rewardComics.addAll(beadComics);
      }
      
      // Убираем дубликаты
      final uniqueComics = <String, MahabharataComic>{};
      for (var comic in rewardComics) {
        uniqueComics[comic.id] = comic;
      }
      
      setState(() {
        _availableComics = uniqueComics.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки комиксов-наград: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_availableComics.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[700]!, Colors.orange[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🎉 Награда за практику!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Вы завершили ${widget.completedRounds} ${_getRoundWord(widget.completedRounds)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Список доступных комиксов
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _availableComics.length,
                  itemBuilder: (context, index) {
                    final comic = _availableComics[index];
                    return _buildComicRewardCard(comic);
                  },
                ),
              ),
              
              // Кнопки действий
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDismiss?.call();
                        },
                        child: const Text('Позже'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openComicsLibrary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Смотреть все'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComicRewardCard(MahabharataComic comic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openComicReader(comic),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Миниатюра
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: comic.panels.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildThumbnail(comic.panels.first.imagePath),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🆕 Новый',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Эпизод ${comic.episodeNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comic.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comic.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Иконка
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    }
  }

  void _openComicReader(MahabharataComic comic) {
    Navigator.pop(context); // Закрываем диалог награды
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReaderScreen(comic: comic),
      ),
    );
    
    widget.onDismiss?.call();
  }

  void _openComicsLibrary() {
    Navigator.pop(context); // Закрываем диалог награды
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MahabharataComicsScreen(),
      ),
    );
    
    widget.onDismiss?.call();
  }

  String _getRoundWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'круг';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'круга';
    } else {
      return 'кругов';
    }
  }
}

import 'dart:io';

/// Функция-хелпер для показа комиксов-наград
Future<void> showJapaComicReward({
  required BuildContext context,
  required int completedRounds,
  int? currentBead,
  VoidCallback? onDismiss,
}) async {
  // Проверяем, есть ли доступные комиксы
  final service = MahabharataService.instance;
  await service.initialize();
  
  final rewardComics = service.getRewardComics(completedRounds);
  final beadComics = currentBead != null
      ? service.getComicsByJapaConnection(beadNumber: currentBead)
      : <MahabharataComic>[];
  
  final totalComics = {...rewardComics, ...beadComics}.length;
  
  if (totalComics == 0) {
    // Нет доступных комиксов
    return;
  }
  
  // Показываем диалог с наградами
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => JapaComicRewardWidget(
      completedRounds: completedRounds,
      currentBead: currentBead,
      onDismiss: onDismiss,
    ),
  );
}

