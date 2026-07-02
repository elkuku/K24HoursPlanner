import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/time_utils.dart';

/// Paints a 24-hour dial: hour/quarter-hour ticks, hour numbers 1-24
/// (clockwise from the top), and a single hand sweeping once per day.
class ClockFacePainter extends CustomPainter {
  ClockFacePainter({
    required this.now,
    required this.faceRadius,
    required this.colorScheme,
  });

  final DateTime now;
  final double faceRadius;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (faceRadius <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      center,
      faceRadius,
      Paint()..color = colorScheme.surfaceContainerHighest,
    );

    final minorTickPaint = Paint()
      ..color = colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    final hourTickPaint = Paint()
      ..color = colorScheme.onSurface
      ..strokeWidth = 2.5;

    for (int m = 0; m < 1440; m += 15) {
      final isHour = m % 60 == 0;
      final angle = minutesToAngle(m);
      final outer = Offset(
        center.dx + faceRadius * cos(angle),
        center.dy + faceRadius * sin(angle),
      );
      final innerRadius = faceRadius * (isHour ? 0.88 : 0.95);
      final inner = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      canvas.drawLine(inner, outer, isHour ? hourTickPaint : minorTickPaint);
    }

    for (int h = 0; h < 24; h++) {
      final angle = minutesToAngle(h * 60);
      final labelRadius = faceRadius * 0.76;
      final offset = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );
      final textSpan = TextSpan(
        text: h == 0 ? '24' : '$h',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: faceRadius * 0.09,
          fontWeight: FontWeight.w600,
        ),
      );
      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
    }

    final minutesNow = now.hour * 60 + now.minute;
    final handAngle = minutesToAngle(minutesNow);
    final handPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final handEnd = Offset(
      center.dx + faceRadius * 0.62 * cos(handAngle),
      center.dy + faceRadius * 0.62 * sin(handAngle),
    );
    canvas.drawLine(center, handEnd, handPaint);
    canvas.drawCircle(center, 5, Paint()..color = colorScheme.primary);
  }

  @override
  bool shouldRepaint(covariant ClockFacePainter oldDelegate) {
    return oldDelegate.now != now || oldDelegate.faceRadius != faceRadius;
  }
}
