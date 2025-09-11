import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants/app_constants.dart';
import '../screens/japa_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/settings_screen.dart';

/// Кастомные переходы между страницами
class CustomPageTransitions {
  
  /// Переход для Android (Material Design)
  static Widget androidTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход для iOS (Cupertino)
  static Widget iosTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    );
  }
  
  /// Переход снизу вверх (для модальных окон)
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход с масштабированием
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход с поворотом
  static Widget rotationTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        )),
        child: child,
      ),
    );
  }
  
  /// Переход для джапа-экрана
  static Widget japaTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        )),
        child: child,
      ),
    );
  }
  
  /// Переход для AI помощника
  static Widget aiTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход для настроек
  static Widget settingsTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход для диалогов
  static Widget dialogTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  /// Переход для уведомлений
  static Widget notificationTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Кастомный PageRouteBuilder для переходов
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String transitionType;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.transitionType = 'default',
    this.duration = AppConstants.mediumAnimation,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (transitionType) {
              case 'slideUp':
                return CustomPageTransitions.slideUpTransition(
                  context, animation, secondaryAnimation, child);
              case 'scale':
                return CustomPageTransitions.scaleTransition(
                  context, animation, secondaryAnimation, child);
              case 'rotation':
                return CustomPageTransitions.rotationTransition(
                  context, animation, secondaryAnimation, child);
              case 'japa':
                return CustomPageTransitions.japaTransition(
                  context, animation, secondaryAnimation, child);
              case 'ai':
                return CustomPageTransitions.aiTransition(
                  context, animation, secondaryAnimation, child);
              case 'settings':
                return CustomPageTransitions.settingsTransition(
                  context, animation, secondaryAnimation, child);
              case 'dialog':
                return CustomPageTransitions.dialogTransition(
                  context, animation, secondaryAnimation, child);
              case 'notification':
                return CustomPageTransitions.notificationTransition(
                  context, animation, secondaryAnimation, child);
              default:
                return CustomPageTransitions.androidTransition(
                  context, animation, secondaryAnimation, child);
            }
          },
        );
}

/// Утилиты для навигации с анимациями
class AnimatedNavigation {
  
  /// Переход к экрану джапы
  static Future<T?> toJapaScreen<T extends Object?>(
    BuildContext context, {
    Object? arguments,
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        child: const JapaScreen(),
        transitionType: 'japa',
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }
  
  /// Переход к AI помощнику
  static Future<T?> toAIAssistant<T extends Object?>(
    BuildContext context, {
    Object? arguments,
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        child: const AIAssistantScreen(),
        transitionType: 'ai',
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }
  
  /// Переход к настройкам
  static Future<T?> toSettings<T extends Object?>(
    BuildContext context, {
    Object? arguments,
  }) {
    return Navigator.push<T>(
      context,
      CustomPageRoute<T>(
        child: const SettingsScreen(),
        transitionType: 'settings',
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }
  
  /// Показ диалога с анимацией
  static Future<T?> showAnimatedDialog<T extends Object?>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
    Object? arguments,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: AppConstants.mediumAnimation,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return CustomPageTransitions.dialogTransition(
          context, animation, secondaryAnimation, child);
      },
    );
  }
  
  /// Показ уведомления с анимацией
  static void showAnimatedSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: kAlwaysCompleteAnimation,
              curve: Curves.elasticOut,
            )),
            child: FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: kAlwaysCompleteAnimation,
                curve: Curves.easeIn,
              )),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}
