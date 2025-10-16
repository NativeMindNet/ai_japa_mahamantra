import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import 'modern_ui_components.dart';

class JapaMalaWidget extends StatefulWidget {
  final int currentBead;
  final int totalBeads;
  final Function(int) onBeadTap;

  const JapaMalaWidget({
    super.key,
    required this.currentBead,
    required this.totalBeads,
    required this.onBeadTap,
  });

  @override
  State<JapaMalaWidget> createState() => _JapaMalaWidgetState();
}

class _JapaMalaWidgetState extends State<JapaMalaWidget>
    with TickerProviderStateMixin {
  late AnimationController _beadAnimationController;

  @override
  void initState() {
    super.initState();
    _beadAnimationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _beadAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernUIComponents.gradientCard(
      context: context,
      gradientColors: [
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      ],
      child: Container(
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        child: CustomPaint(
          painter: JapaMalaPainter(
            currentBead: widget.currentBead,
            totalBeads: widget.totalBeads,
          ),
          child: GestureDetector(
            onTapUp: (details) {
              _handleBeadTap(details.localPosition);
            },
          ),
        ),
      ),
    );
  }

  void _handleBeadTap(Offset localPosition) {
    final size = context.size;
    if (size == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Вычисляем расстояние от центра
    final distance = (localPosition - center).distance;

    if (distance <= radius * 0.8 && distance >= radius * 0.3) {
      // Вычисляем угол
      final angle = (localPosition - center).direction;

      // Определяем номер бусины
      final beadIndex = _getBeadIndexFromAngle(angle);

      if (beadIndex >= 0 && beadIndex <= widget.totalBeads) {
        widget.onBeadTap(beadIndex);
        _beadAnimationController.forward().then((_) {
          _beadAnimationController.reverse();
        });
      }
    }
  }

  int _getBeadIndexFromAngle(double angle) {
    // Используем тот же расчет, что и в _drawMala
    const startAngle = -3.14159 / 2; // Начинаем снизу
    final angleStep = 2 * 3.14159 / widget.totalBeads; // Шаг между бусинами
    const offsetAngle = 3.14159 / 18; // Небольшое смещение (10 градусов)

    // Нормализуем угол к диапазону [0, 2π]
    double normalizedAngle = angle;
    if (normalizedAngle < 0) normalizedAngle += 2 * 3.14159;

    // Вычисляем номер бусины с учетом смещения
    double adjustedAngle = normalizedAngle - offsetAngle;
    if (adjustedAngle < 0) adjustedAngle += 2 * 3.14159;

    final beadIndex = ((adjustedAngle - startAngle) / angleStep).round() + 1;

    // Проверяем границы
    if (beadIndex < 1) return 1;
    if (beadIndex > widget.totalBeads) return widget.totalBeads;

    return beadIndex;
  }
}

class JapaMalaPainter extends CustomPainter {
  final int currentBead;
  final int totalBeads;

  JapaMalaPainter({required this.currentBead, required this.totalBeads});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Рисуем основную малу
    _drawMala(canvas, center, radius);

    // Рисуем нулевую бусину (большую)
    _drawZeroBead(canvas, center, radius);

    // Рисуем текущую бусину с подсветкой
    if (currentBead > 0) {
      _drawCurrentBead(canvas, center, radius);
    }
  }

  void _drawMala(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(AppConstants.primaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Рисуем круг малы
    canvas.drawCircle(center, radius * 0.6, paint);

    // Рисуем бусины
    for (int i = 1; i <= totalBeads; i++) {
      // Начинаем с угла -π/2 (внизу) и идем против часовой стрелки
      // Смещаем на небольшой угол, чтобы избежать перекрытия с нулевой бусиной
      const startAngle = -3.14159 / 2; // Начинаем снизу
      final angleStep = 2 * 3.14159 / totalBeads; // Шаг между бусинами
      const offsetAngle = 3.14159 / 18; // Небольшое смещение (10 градусов)
      final angle = startAngle + (i - 1) * angleStep + offsetAngle;

      final beadCenter = Offset(
        center.dx + (radius * 0.6) * cos(angle),
        center.dy + (radius * 0.6) * sin(angle),
      );

      final beadPaint = Paint()
        ..color = i == currentBead
            ? const Color(AppConstants.accentColor)
            : const Color(AppConstants.primaryColor)
        ..style = PaintingStyle.fill;

      // Размер бусины зависит от позиции
      double beadSize = 8.0;
      if (i <= 4) {
        beadSize = 12.0; // Первые 4 бусины больше
      } else if (i == 27 || i == 54 || i == 81) {
        beadSize = 10.0; // Разделительные бусины
      }

      canvas.drawCircle(beadCenter, beadSize, beadPaint);

      // Рисуем обводку для текущей бусины
      if (i == currentBead) {
        final borderPaint = Paint()
          ..color = const Color(AppConstants.accentColor)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawCircle(beadCenter, beadSize + 2, borderPaint);
      }
    }
  }

  void _drawZeroBead(Canvas canvas, Offset center, double radius) {
    // Нулевая бусина (большая) зафиксирована внизу по центру
    final zeroBeadCenter = Offset(center.dx, center.dy + radius * 0.6);

    // Добавляем тень для лучшей видимости
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(
      Offset(zeroBeadCenter.dx + 2, zeroBeadCenter.dy + 2),
      22.0,
      shadowPaint,
    );

    final zeroBeadPaint = Paint()
      ..color = const Color(AppConstants.successColor)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(zeroBeadCenter, 20.0, zeroBeadPaint);

    // Обводка нулевой бусины
    final zeroBeadBorderPaint = Paint()
      ..color = const Color(AppConstants.primaryColor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(zeroBeadCenter, 20.0, zeroBeadBorderPaint);

    // Текст "0" в нулевой бусине
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        zeroBeadCenter.dx - textPainter.width / 2,
        zeroBeadCenter.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawCurrentBead(Canvas canvas, Offset center, double radius) {
    if (currentBead <= 0 || currentBead > totalBeads) return;

    // Используем тот же расчет углов, что и в _drawMala
    const startAngle = -3.14159 / 2; // Начинаем снизу
    final angleStep = 2 * 3.14159 / totalBeads; // Шаг между бусинами
    const offsetAngle = 3.14159 / 18; // Небольшое смещение (10 градусов)
    final angle = startAngle + (currentBead - 1) * angleStep + offsetAngle;

    final beadCenter = Offset(
      center.dx + (radius * 0.6) * cos(angle),
      center.dy + (radius * 0.6) * sin(angle),
    );

    // Подсветка текущей бусины
    final highlightPaint = Paint()
      ..color = const Color(AppConstants.accentColor).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(beadCenter, 15.0, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is JapaMalaPainter &&
        oldDelegate.currentBead != currentBead;
  }
}
