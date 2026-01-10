import 'dart:math';
import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  GaugePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const tickCount = 40;
    const tickLength = 6.0;

    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * pi / tickCount) * i;
      final x1 = center.dx + (radius - strokeWidth / 2) * cos(angle);
      final y1 = center.dy + (radius - strokeWidth / 2) * sin(angle);
      final x2 =
          center.dx + (radius - strokeWidth / 2 - tickLength) * cos(angle);
      final y2 =
          center.dy + (radius - strokeWidth / 2 - tickLength) * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // Start at top (12 o'clock position)
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
