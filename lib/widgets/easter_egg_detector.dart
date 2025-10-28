import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../widgets/modern_ui_components.dart';

/// Детектор Easter Egg для активации скрытых функций
/// Отслеживает специальные последовательности действий пользователя
class EasterEggDetector extends StatefulWidget {
  final Widget child;
  final Function(String eggType)? onEasterEggTriggered;
  final bool enableVibration;
  final bool enableSound;

  const EasterEggDetector({
    super.key,
    required this.child,
    this.onEasterEggTriggered,
    this.enableVibration = true,
    this.enableSound = true,
  });

  @override
  State<EasterEggDetector> createState() => _EasterEggDetectorState();
}

class _EasterEggDetectorState extends State<EasterEggDetector> {
  // Счетчики для различных Easter Egg
  int _tripleTapCount = 0;
  int _longPressCount = 0;
  int _swipeCount = 0;
  int _shakeCount = 0;
  
  // Временные метки для сброса счетчиков
  DateTime? _lastTripleTap;
  DateTime? _lastLongPress;
  DateTime? _lastSwipe;
  DateTime? _lastShake;
  
  // Пороги для активации Easter Egg
  static const int _tripleTapThreshold = 3;
  static const int _longPressThreshold = 5;
  static const int _swipeThreshold = 10;
  static const int _shakeThreshold = 7;
  
  // Время сброса счетчиков (в секундах)
  static const int _resetTimeSeconds = 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onPanUpdate: _handleSwipe,
      child: widget.child,
    );
  }

  void _handleTap() {
    final now = DateTime.now();
    
    // Сбрасываем счетчик если прошло больше времени сброса
    if (_lastTripleTap != null &&
        now.difference(_lastTripleTap!).inSeconds > _resetTimeSeconds) {
      _tripleTapCount = 0;
    }
    
    _tripleTapCount++;
    _lastTripleTap = now;
    
    // Проверяем активацию Easter Egg
    if (_tripleTapCount >= _tripleTapThreshold) {
      _triggerEasterEgg('triple_tap');
      _tripleTapCount = 0;
    }
    
    _provideFeedback();
  }

  void _handleLongPress() {
    final now = DateTime.now();
    
    // Сбрасываем счетчик если прошло больше времени сброса
    if (_lastLongPress != null &&
        now.difference(_lastLongPress!).inSeconds > _resetTimeSeconds) {
      _longPressCount = 0;
    }
    
    _longPressCount++;
    _lastLongPress = now;
    
    // Проверяем активацию Easter Egg
    if (_longPressCount >= _longPressThreshold) {
      _triggerEasterEgg('long_press');
      _longPressCount = 0;
    }
    
    _provideFeedback();
  }

  void _handleSwipe(DragUpdateDetails details) {
    final now = DateTime.now();
    
    // Сбрасываем счетчик если прошло больше времени сброса
    if (_lastSwipe != null &&
        now.difference(_lastSwipe!).inSeconds > _resetTimeSeconds) {
      _swipeCount = 0;
    }
    
    // Проверяем, что это действительно свайп (достаточное расстояние)
    final distance = details.delta.distance;
    if (distance > 10) {
      _swipeCount++;
      _lastSwipe = now;
      
      // Проверяем активацию Easter Egg
      if (_swipeCount >= _swipeThreshold) {
        _triggerEasterEgg('swipe');
        _swipeCount = 0;
      }
      
      _provideFeedback();
    }
  }


  void _triggerEasterEgg(String eggType) {
    // Вызываем callback
    widget.onEasterEggTriggered?.call(eggType);
    
    // Показываем уведомление
    _showEasterEggNotification(eggType);
    
    // Специальная вибрация для Easter Egg
    if (widget.enableVibration) {
      HapticFeedback.heavyImpact();
    }
    
    // Звук Easter Egg
    if (widget.enableSound) {
      HapticFeedback.mediumImpact();
    }
  }

  void _showEasterEggNotification(String eggType) {
    final message = _getEasterEggMessage(eggType);
    
    ModernUIComponents.showSnackBar(
      context: context,
      message: message,
      backgroundColor: const Color(AppConstants.accentColor),
      textColor: Colors.white,
      icon: Icons.celebration,
      duration: const Duration(seconds: 4),
    );
  }

  String _getEasterEggMessage(String eggType) {
    switch (eggType) {
      case 'triple_tap':
        return '🐣 Easter Egg активирован! Тройной тап обнаружен!';
      case 'long_press':
        return '🐣 Easter Egg активирован! Долгое нажатие обнаружено!';
      case 'swipe':
        return '🐣 Easter Egg активирован! Свайпы обнаружены!';
      case 'shake':
        return '🐣 Easter Egg активирован! Встряхивание обнаружено!';
      default:
        return '🐣 Easter Egg активирован!';
    }
  }

  void _provideFeedback() {
    // Легкая вибрация для обратной связи
    if (widget.enableVibration) {
      HapticFeedback.lightImpact();
    }
    
    // Звук обратной связи
    if (widget.enableSound) {
      HapticFeedback.selectionClick();
    }
  }

  /// Получает статистику детектора
  Map<String, dynamic> getStatistics() {
    return {
      'triple_tap_count': _tripleTapCount,
      'long_press_count': _longPressCount,
      'swipe_count': _swipeCount,
      'shake_count': _shakeCount,
      'last_triple_tap': _lastTripleTap?.toIso8601String(),
      'last_long_press': _lastLongPress?.toIso8601String(),
      'last_swipe': _lastSwipe?.toIso8601String(),
      'last_shake': _lastShake?.toIso8601String(),
    };
  }

  /// Сбрасывает все счетчики
  void resetCounters() {
    setState(() {
      _tripleTapCount = 0;
      _longPressCount = 0;
      _swipeCount = 0;
      _shakeCount = 0;
      _lastTripleTap = null;
      _lastLongPress = null;
      _lastSwipe = null;
      _lastShake = null;
    });
  }
}

/// Специальный Easter Egg для активации через последовательность нажатий на бусины
class BeadEasterEggDetector extends StatefulWidget {
  final Widget child;
  final Function()? onEasterEggTriggered;
  final int targetBeadNumber;
  final int requiredTaps;

  const BeadEasterEggDetector({
    super.key,
    required this.child,
    this.onEasterEggTriggered,
    this.targetBeadNumber = 108,
    this.requiredTaps = 3,
  });

  @override
  State<BeadEasterEggDetector> createState() => _BeadEasterEggDetectorState();
}

class _BeadEasterEggDetectorState extends State<BeadEasterEggDetector> {
  int _tapCount = 0;
  DateTime? _lastTap;
  static const int _resetTimeSeconds = 2;

  void _handleBeadTap(int beadNumber) {
    if (beadNumber != widget.targetBeadNumber) {
      _resetTapCount();
      return;
    }

    final now = DateTime.now();
    
    // Сбрасываем счетчик если прошло больше времени сброса
    if (_lastTap != null &&
        now.difference(_lastTap!).inSeconds > _resetTimeSeconds) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTap = now;
    
    // Проверяем активацию Easter Egg
    if (_tapCount >= widget.requiredTaps) {
      _triggerEasterEgg();
      _resetTapCount();
    }
  }

  void _triggerEasterEgg() {
    // Вызываем callback
    widget.onEasterEggTriggered?.call();
    
    // Специальная вибрация
    HapticFeedback.heavyImpact();
    
    // Показываем уведомление
    if (mounted) {
      ModernUIComponents.showSnackBar(
        context: context,
        message: '🐣 Easter Egg активирован! Тройной тап на бусине ${widget.targetBeadNumber}!',
        backgroundColor: const Color(AppConstants.accentColor),
        textColor: Colors.white,
        icon: Icons.celebration,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _resetTapCount() {
    setState(() {
      _tapCount = 0;
      _lastTap = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBeadTap(widget.targetBeadNumber),
      child: widget.child,
    );
  }
}

/// Детектор для активации через встряхивание устройства
class ShakeDetector extends StatefulWidget {
  final Widget child;
  final Function()? onShakeDetected;
  final double shakeThreshold;
  final Duration debounceTime;

  const ShakeDetector({
    super.key,
    required this.child,
    this.onShakeDetected,
    this.shakeThreshold = 2.0,
    this.debounceTime = const Duration(milliseconds: 500),
  });

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  DateTime? _lastShakeTime;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Комбинированный детектор всех типов Easter Egg
class UniversalEasterEggDetector extends StatefulWidget {
  final Widget child;
  final Function(String eggType)? onEasterEggTriggered;

  const UniversalEasterEggDetector({
    super.key,
    required this.child,
    this.onEasterEggTriggered,
  });

  @override
  State<UniversalEasterEggDetector> createState() => _UniversalEasterEggDetectorState();
}

class _UniversalEasterEggDetectorState extends State<UniversalEasterEggDetector> {
  @override
  Widget build(BuildContext context) {
    return EasterEggDetector(
      onEasterEggTriggered: widget.onEasterEggTriggered,
      child: ShakeDetector(
        onShakeDetected: () {
          widget.onEasterEggTriggered?.call('shake');
        },
        child: widget.child,
      ),
    );
  }
}