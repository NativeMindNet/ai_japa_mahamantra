import 'package:flutter/material.dart';

/// Анимации переходов между страницами
class PageTransitions {
  
  /// Плавный переход снизу вверх
  static Widget slideFromBottom(Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
  
  /// Плавный переход сверху вниз
  static Widget slideFromTop(Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
  
  /// Плавный переход слева направо
  static Widget slideFromLeft(Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
  
  /// Плавный переход справа налево
  static Widget slideFromRight(Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
  
  /// Плавное появление с увеличением
  static Widget scaleIn(Widget child) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }
  
  /// Плавное появление с поворотом
  static Widget rotateIn(Widget child) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
  
  /// Плавное появление с прозрачностью
  static Widget fadeIn(Widget child) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeIn,
      )),
      child: child,
    );
  }
  
  /// Комбинированная анимация: появление + увеличение
  static Widget fadeScaleIn(Widget child) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeIn,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: kAlwaysCompleteAnimation,
          curve: Curves.elasticOut,
        )),
        child: child,
      ),
    );
  }
  
  /// Анимация для джапа-малы
  static Widget malaAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: Transform.rotate(
            angle: Tween<double>(
              begin: -0.1,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )).value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для бусин
  static Widget beadAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 1.0,
            end: 1.2,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: Transform.translate(
            offset: Offset(
              Tween<double>(
                begin: 0.0,
                end: 2.0,
              ).animate(CurvedAnimation(
                parent: controller,
                curve: Curves.easeOutCubic,
              )).value,
              0.0,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для мантры
  static Widget mantraAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeIn,
          )),
          child: Transform.translate(
            offset: Offset(
              0.0,
              Tween<double>(
                begin: 20.0,
                end: 0.0,
              ).animate(CurvedAnimation(
                parent: controller,
                curve: Curves.easeOutCubic,
              )).value,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для статистики
  static Widget statsAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            Tween<double>(
              begin: -50.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )).value,
            0.0,
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для кнопок
  static Widget buttonAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Анимация для уведомлений
  static Widget notificationAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            Tween<double>(
              begin: -100.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            )).value,
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для прогресс-бара
  static Widget progressAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          )).value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Анимация для карточек
  static Widget cardAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            Tween<double>(
              begin: 30.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )).value,
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для списков
  static Widget listAnimation(Widget child, AnimationController controller, int index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            Tween<double>(
              begin: 50.0 + (index * 20.0),
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )).value,
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для диалогов
  static Widget dialogAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для иконок
  static Widget iconAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: Tween<double>(
            begin: 0.0,
            end: 0.1,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          )).value,
          child: Transform.scale(
            scale: Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            )).value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для текста
  static Widget textAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            Tween<double>(
              begin: 10.0,
              end: 0.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeOutCubic,
            )).value,
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Анимация для фона
  static Widget backgroundAnimation(Widget child, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(
            begin: 1.1,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          )).value,
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeIn,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
