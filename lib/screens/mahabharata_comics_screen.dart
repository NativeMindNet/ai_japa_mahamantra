import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mahabharata_comic.dart';
import '../services/mahabharata_service.dart';

/// Экран просмотра комиксов Махабхараты
class MahabharataComicsScreen extends StatefulWidget {
  const MahabharataComicsScreen({super.key});

  @override
  State<MahabharataComicsScreen> createState() => _MahabharataComicsScreenState();
}

class _MahabharataComicsScreenState extends State<MahabharataComicsScreen> {
  final MahabharataService _service = MahabharataService.instance;
  List<MahabharataComic> _comics = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, favorites, recent

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    setState(() => _isLoading = true);
    
    try {
      await _service.initialize();
      setState(() {
        _comics = _service.getComicsSortedByEpisode();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки комиксов: $e')),
        );
      }
    }
  }

  List<MahabharataComic> _getFilteredComics() {
    switch (_filter) {
      case 'favorites':
        return _service.getFavoriteComics();
      case 'recent':
        final comics = List<MahabharataComic>.from(_comics);
        comics.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return comics.take(10).toList();
      default:
        return _comics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Махабхарата'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Все комиксы'),
              ),
              const PopupMenuItem(
                value: 'favorites',
                child: Text('Избранное'),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: Text('Недавние'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildComicsList(),
    );
  }

  Widget _buildComicsList() {
    final filteredComics = _getFilteredComics();
    
    if (filteredComics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Комиксы не найдены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте .comics файлы в папку Documents/comics',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredComics.length,
      itemBuilder: (context, index) {
        final comic = filteredComics[index];
        return _buildComicCard(comic);
      },
    );
  }

  Widget _buildComicCard(MahabharataComic comic) {
    final progress = _service.getReadProgress(comic.id);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () => _openComicReader(comic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Превью первой панели
                  if (comic.panels.isNotEmpty)
                    _buildComicCover(comic.panels.first.imagePath)
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 64),
                    ),
                  
                  // Индикатор прогресса
                  if (progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black26,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  
                  // Иконка избранного
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        comic.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: comic.isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        await _service.toggleFavorite(comic.id);
                        setState(() {});
                      },
                    ),
                  ),
                  
                  // Номер эпизода
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${comic.episodeNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.pages, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${comic.panels.length} панелей',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComicCover(String imagePath) {
    // Проверяем, это assets или внешний файл
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 64),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 64),
          );
        },
      );
    }
  }

  void _openComicReader(MahabharataComic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReaderScreen(comic: comic),
      ),
    ).then((_) => setState(() {})); // Обновляем после возврата
  }
}

/// Экран чтения комикса
class ComicReaderScreen extends StatefulWidget {
  final MahabharataComic comic;

  const ComicReaderScreen({super.key, required this.comic});

  @override
  State<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final MahabharataService _service = MahabharataService.instance;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    
    // Обновляем прогресс чтения
    final progress = (page + 1) / widget.comic.panels.length;
    _service.updateReadProgress(widget.comic.id, progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          widget.comic.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              widget.comic.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.comic.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              await _service.toggleFavorite(widget.comic.id);
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Просмотр панелей
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.comic.panels.length,
            itemBuilder: (context, index) {
              final panel = widget.comic.panels[index];
              return _buildPanelView(panel);
            },
          ),
          
          // Индикатор страницы
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / ${widget.comic.panels.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelView(ComicPanel panel) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Stack(
          children: [
            // Изображение панели
            if (panel.imagePath.startsWith('assets/'))
              Image.asset(
                panel.imagePath,
                fit: BoxFit.contain,
              )
            else
              Image.file(
                File(panel.imagePath),
                fit: BoxFit.contain,
              ),
            
            // Текстовые баблы
            ...panel.texts.map((text) => _buildTextBubble(text)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(PanelText text) {
    return Positioned(
      left: text.position.x * MediaQuery.of(context).size.width,
      top: text.position.y * MediaQuery.of(context).size.height,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBubbleColor(text.type),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text.character != null)
              Text(
                text.character!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            Text(
              text.text,
              style: TextStyle(
                fontSize: 14,
                fontStyle: text.type == TextType.thought
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBubbleColor(TextType type) {
    switch (type) {
      case TextType.speech:
        return Colors.white;
      case TextType.thought:
        return Colors.blue[50]!;
      case TextType.narration:
        return Colors.yellow[50]!;
      case TextType.sound:
        return Colors.orange[50]!;
    }
  }
}

import 'dart:io';

