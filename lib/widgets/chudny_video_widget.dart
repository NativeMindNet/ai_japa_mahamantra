import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_constants.dart';

/// Виджет для воспроизведения видео с Чудным
/// Креативная интеграция в контексте джапы
class ChudnyVideoWidget extends StatefulWidget {
  final VoidCallback? onVideoEnd;
  final bool autoPlay;
  final bool showControls;
  final double? height;
  final double? width;
  final bool loop;
  final String? title;
  final String? subtitle;

  const ChudnyVideoWidget({
    super.key,
    this.onVideoEnd,
    this.autoPlay = false,
    this.showControls = true,
    this.height,
    this.width,
    this.loop = false,
    this.title,
    this.subtitle,
  });

  @override
  State<ChudnyVideoWidget> createState() => _ChudnyVideoWidgetState();
}

class _ChudnyVideoWidgetState extends State<ChudnyVideoWidget>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showOverlay = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeAnimations();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(
      'assets/animations/_nnado_a_chyotki_nnada_ochki_nado_yapfiles.ru.mp4',
    );

    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });

            if (widget.autoPlay) {
              _playVideo();
            }
          }
        })
        .catchError((Object error) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        if (!widget.loop) {
          _onVideoEnd();
        }
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  void _playVideo() {
    setState(() {
      _isPlaying = true;
      _showOverlay = false;
    });
    _controller.play();
  }

  void _pauseVideo() {
    setState(() {
      _isPlaying = false;
    });
    _controller.pause();
  }

  void _onVideoEnd() {
    setState(() {
      _isPlaying = false;
      _showOverlay = true;
    });
    widget.onVideoEnd?.call();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _hideOverlay() {
    if (_isPlaying) {
      setState(() {
        _showOverlay = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height ?? 300,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Stack(
              children: [
                // Видео
                GestureDetector(
                  onTap: _hideOverlay,
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),

                // Оверлей с контролами
                if (_showOverlay || widget.showControls) _buildVideoOverlay(),

                // Заголовок и подзаголовок
                if (widget.title != null || widget.subtitle != null)
                  _buildTitleOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка воспроизведения
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Прогресс бар
            if (widget.showControls)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    bufferedColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height ?? 300,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Загрузка видео с Чудным...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: widget.height ?? 300,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки видео',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Проверьте наличие файла в ассетах',
              style: TextStyle(fontSize: 12, color: Colors.red[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Специальный виджет для мотивационного видео перед джапой
class ChudnyMotivationWidget extends StatelessWidget {
  final VoidCallback? onStartJapa;
  final VoidCallback? onSkip;

  const ChudnyMotivationWidget({super.key, this.onStartJapa, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Заголовок
          Text(
            'Мотивация от Чудного',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Видео
          ChudnyVideoWidget(
            height: 250,
            title: 'Очки нннада???',
            subtitle: 'А четки??? Четки нннада???',
            onVideoEnd: () {
              // Показываем кнопки после окончания видео
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Кнопки действий
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStartJapa,
                  icon: const Icon(Icons.play_circle_filled),
                  label: const Text('Начать джапу'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Пропустить'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Виджет для показа видео в полноэкранном режиме
class ChudnyFullscreenWidget extends StatefulWidget {
  const ChudnyFullscreenWidget({super.key});

  @override
  State<ChudnyFullscreenWidget> createState() => _ChudnyFullscreenWidgetState();
}

class _ChudnyFullscreenWidgetState extends State<ChudnyFullscreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Чудный о четках',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ChudnyVideoWidget(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width,
          autoPlay: true,
          loop: true,
          title: 'Очки нннада???',
          subtitle: 'А четки??? Четки нннада???',
        ),
      ),
    );
  }
}
