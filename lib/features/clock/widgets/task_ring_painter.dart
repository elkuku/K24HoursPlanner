import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/time_utils.dart';

/// A single arc segment to render on the outer ring.
class TaskArc {
  const TaskArc({
    required this.startMinutes,
    required this.endMinutes,
    required this.color,
  });

  final int startMinutes;
  final int endMinutes;
  final Color color;
}

/// Paints task arcs on a ring between [innerRadius] and [outerRadius],
/// positioned by time of day using the same angle convention as the dial.
class TaskRingPainter extends CustomPainter {
  TaskRingPainter({
    required this.arcs,
    required this.innerRadius,
    required this.outerRadius,
    required this.trackColor,
  });

  final List<TaskArc> arcs;
  final double innerRadius;
  final double outerRadius;
  final Color trackColor;

  static const double _gapRadians = 0.02;

  @override
  void paint(Canvas canvas, Size size) {
    if (innerRadius <= 0 || outerRadius <= innerRadius) return;
    final center = Offset(size.width / 2, size.height / 2);
    final ringWidth = outerRadius - innerRadius;
    final radius = (innerRadius + outerRadius) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);

    for (final arc in arcs) {
      final sweepMin = sweepMinutes(arc.startMinutes, arc.endMinutes);
      if (sweepMin <= 0) continue;
      final startAngle = minutesToAngle(arc.startMinutes);
      final sweepAngle = (sweepMin / 1440) * 2 * pi;
      final segmentPaint = Paint()
        ..color = arc.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.butt;
      final adjustedSweep = max(sweepAngle - _gapRadians, 0.001);
      canvas.drawArc(
        rect,
        startAngle + _gapRadians / 2,
        adjustedSweep,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TaskRingPainter oldDelegate) {
    return oldDelegate.arcs != arcs ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.trackColor != trackColor;
  }
}
