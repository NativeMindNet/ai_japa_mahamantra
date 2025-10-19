import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/easter_egg_logs_screen.dart';

/// Детектор Easter Egg для открытия секретного экрана логов
/// Активируется тройным тапом на 108-й бусине
class EasterEggDetector extends StatefulWidget {
  final Widget child;
  final bool isSpecialBead; // true если это 108-я бусина
  
  const EasterEggDetector({
    Key? key,
    required this.child,
    this.isSpecialBead = false,
  }) : super(key: key);

  @override
  State<EasterEggDetector> createState() => _EasterEggDetectorState();
}

class _EasterEggDetectorState extends State<EasterEggDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;
  
  static const int _requiredTaps = 3;
  static const Duration _tapTimeout = Duration(seconds: 2);

  void _handleTap() {
    if (!widget.isSpecialBead) return;
    
    setState(() {
      _tapCount++;
    });

    // Сбрасываем счетчик через таймаут
    _resetTimer?.cancel();
    _resetTimer = Timer(_tapTimeout, () {
      if (mounted) {
        setState(() {
          _tapCount = 0;
        });
      }
    });

    // Проверяем, достигнуто ли нужное количество тапов
    if (_tapCount >= _requiredTaps) {
      _activateEasterEgg();
    }
  }

  void _activateEasterEgg() {
    _tapCount = 0;
    _resetTimer?.cancel();

    // Вибрация при активации
    _triggerHapticFeedback();

    // Открываем секретный экран
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EasterEggLogsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _triggerHapticFeedback() {
    // Создаем серию вибраций для обратной связи
    Future.delayed(Duration.zero, () async {
      for (int i = 0; i < 3; i++) {
        // Здесь можно использовать Vibration.vibrate если пакет подключен
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          widget.child,
          
          // Индикатор прогресса (опционально, для дебага)
          if (widget.isSpecialBead && _tapCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_tapCount/$_requiredTaps',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Альтернативный детектор через удержание центральной мандалы
class MandalaCenterEasterEggDetector extends StatefulWidget {
  final Widget child;
  
  const MandalaCenterEasterEggDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MandalaCenterEasterEggDetector> createState() =>
      _MandalaCenterEasterEggDetectorState();
}

class _MandalaCenterEasterEggDetectorState
    extends State<MandalaCenterEasterEggDetector> {
  int _swipeCount = 0;
  bool _isHolding = false;
  Timer? _holdTimer;
  Offset? _startPosition;
  
  static const int _requiredSwipes = 108;
  static const Duration _holdDuration = Duration(seconds: 2);

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isHolding = true;
      _swipeCount = 0;
      _startPosition = details.localPosition;
    });

    // Запускаем таймер удержания
    _holdTimer = Timer(_holdDuration, () {
      // После 2 секунд удержания начинаем считать свайпы
      debugPrint('Easter Egg: Удержание активировано, ожидаем 108 свайпов');
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isHolding || _startPosition == null) return;

    final currentPosition = details.localPosition;
    final dx = currentPosition.dx - _startPosition!.dx;
    final dy = currentPosition.dy - _startPosition!.dy;
    final distance = (dx * dx + dy * dy);

    // Если движение по кругу (примерная проверка)
    if (distance > 100) {
      setState(() {
        _swipeCount++;
        _startPosition = currentPosition;
      });

      if (_swipeCount >= _requiredSwipes) {
        _activateEasterEgg();
      }
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isHolding = false;
      _swipeCount = 0;
      _startPosition = null;
    });
    _holdTimer?.cancel();
  }

  void _activateEasterEgg() {
    _isHolding = false;
    _swipeCount = 0;
    _holdTimer?.cancel();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EasterEggLogsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          widget.child,
          
          // Индикатор прогресса свайпов
          if (_isHolding && _swipeCount > 0)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🕉️ $_swipeCount / $_requiredSwipes',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
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
}

/// Расширение для всех виджетов для быстрого добавления Easter Egg
extension EasterEggExtension on Widget {
  /// Оборачивает виджет в детектор Easter Egg для 108-й бусины
  Widget withBeadEasterEgg({bool isSpecialBead = false}) {
    return EasterEggDetector(
      isSpecialBead: isSpecialBead,
      child: this,
    );
  }

  /// Оборачивает виджет в детектор для центральной мандалы
  Widget withMandalaEasterEgg() {
    return MandalaCenterEasterEggDetector(
      child: this,
    );
  }
}

