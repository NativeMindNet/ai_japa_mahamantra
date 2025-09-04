import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Современные UI компоненты в стиле Material Design 3
class ModernUIComponents {
  
  /// Создает современную карточку с градиентом
  static Widget gradientCard({
    required Widget child,
    List<Color>? gradientColors,
    double? elevation,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
        child: child,
      ),
    );
  }
  
  /// Создает современную кнопку с анимацией
  static Widget animatedButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColor != null 
              ? [backgroundColor, backgroundColor.withOpacity(0.8)]
              : [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor ?? Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
  
  /// Создает современный индикатор прогресса
  static Widget modernProgressIndicator({
    required double value,
    double? height,
    Color? backgroundColor,
    Color? progressColor,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height ?? 8,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Создает современный чип
  static Widget modernChip({
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (textColor ?? Colors.white)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (textColor ?? Colors.white)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Создает современный список
  static Widget modernListTile({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Создает современный переключатель
  static Widget modernSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? label,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
  
  /// Создает современный слайдер
  static Widget modernSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
      ),
    );
  }
  
  /// Создает современный индикатор загрузки
  static Widget modernLoadingIndicator({
    String? message,
    double size = 40,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  /// Создает современный разделитель
  static Widget modernDivider({
    double? height,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      height: height ?? 1,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
  
  /// Создает современный заголовок секции
  static Widget modernSectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
  
  /// Создает современный бейдж
  static Widget modernBadge({
    required String text,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Расширения для контекста
extension BuildContextExtension on BuildContext {
  /// Получает цветовую схему
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Получает текстовую тему
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Получает размеры экрана
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Проверяет, является ли экран маленьким
  bool get isSmallScreen => screenSize.width < 600;
  
  /// Проверяет, является ли экран большим
  bool get isLargeScreen => screenSize.width > 1200;
}
