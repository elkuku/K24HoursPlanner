import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/time_utils.dart';

class _DayPart {
  const _DayPart({
    required this.startMinutes,
    required this.sweepMinutes,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  final int startMinutes;
  final int sweepMinutes;
  final Color color;
  final Color textColor;
  final IconData icon;
}

// Boundaries match a physical 24h day-planner wall clock: night 19:30-05:30,
// morning 05:30-09:00, day 09:00-17:00, evening 17:00-19:30.
const _dayParts = [
  _DayPart(
    startMinutes: 19 * 60 + 30,
    sweepMinutes: 10 * 60,
    color: Color(0xFF2C4BA0),
    textColor: Colors.white,
    icon: Icons.nightlight_round,
  ),
  _DayPart(
    startMinutes: 5 * 60 + 30,
    sweepMinutes: 3 * 60 + 30,
    color: Color(0xFF3CB878),
    textColor: Colors.black,
    icon: Icons.local_cafe,
  ),
  _DayPart(
    startMinutes: 9 * 60,
    sweepMinutes: 8 * 60,
    color: Color(0xFFFFCC33),
    textColor: Colors.black,
    icon: Icons.wb_sunny,
  ),
  _DayPart(
    startMinutes: 17 * 60,
    sweepMinutes: 2 * 60 + 30,
    color: Color(0xFFD24A3A),
    textColor: Colors.black,
    icon: Icons.wb_twilight,
  ),
];

/// Paints a colorful 24-hour dial modeled after physical day-planner wall
/// clocks: four color-coded quadrants (night/morning/day/evening, each with
/// an icon), hour/quarter-hour ticks, hour numbers 1-24, and a single hand
/// sweeping once per day.
class ClockFacePainter extends CustomPainter {
  ClockFacePainter({required this.now, required this.faceRadius});

  final DateTime now;
  final double faceRadius;

  _DayPart _partForMinute(int minute) {
    for (final part in _dayParts) {
      final diff = ((minute - part.startMinutes) % 1440 + 1440) % 1440;
      if (diff < part.sweepMinutes) return part;
    }
    return _dayParts.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (faceRadius <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: faceRadius);

    for (final part in _dayParts) {
      canvas.drawArc(
        rect,
        minutesToAngle(part.startMinutes),
        (part.sweepMinutes / 1440) * 2 * pi,
        true,
        Paint()..color = part.color,
      );
    }

    final minorTickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    final hourTickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5;

    for (int m = 0; m < 1440; m += 15) {
      final isHour = m % 60 == 0;
      final angle = minutesToAngle(m);
      final outer = Offset(
        center.dx + faceRadius * 0.98 * cos(angle),
        center.dy + faceRadius * 0.98 * sin(angle),
      );
      final innerRadius = faceRadius * (isHour ? 0.86 : 0.93);
      final inner = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      canvas.drawLine(inner, outer, isHour ? hourTickPaint : minorTickPaint);
    }

    for (int h = 0; h < 24; h++) {
      final part = _partForMinute(h * 60);
      final isMajor = h.isEven;
      final angle = minutesToAngle(h * 60);
      final labelRadius = faceRadius * (isMajor ? 0.76 : 0.735);
      final offset = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );
      final textSpan = TextSpan(
        text: h == 0 ? '24' : '$h',
        style: TextStyle(
          color: part.textColor,
          fontSize: faceRadius * (isMajor ? 0.115 : 0.08),
          fontWeight: FontWeight.w800,
        ),
      );
      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, offset - Offset(painter.width / 2, painter.height / 2));
    }

    for (final part in _dayParts) {
      final midMinute = part.startMinutes + part.sweepMinutes ~/ 2;
      final angle = minutesToAngle(midMinute);
      final iconRadius = faceRadius * 0.47;
      final offset = Offset(
        center.dx + iconRadius * cos(angle),
        center.dy + iconRadius * sin(angle),
      );
      final iconSize = faceRadius * 0.22;
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(part.icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: part.icon.fontFamily,
            package: part.icon.fontPackage,
            color: part.textColor.withValues(alpha: 0.85),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        offset - Offset(iconPainter.width / 2, iconPainter.height / 2),
      );
    }

    final minutesNow = now.hour * 60 + now.minute;
    final handAngle = minutesToAngle(minutesNow);
    final handEnd = Offset(
      center.dx + faceRadius * 0.62 * cos(handAngle),
      center.dy + faceRadius * 0.62 * sin(handAngle),
    );
    final handOutlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = faceRadius * 0.09
      ..strokeCap = StrokeCap.round;
    final handPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = faceRadius * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, handEnd, handOutlinePaint);
    canvas.drawLine(center, handEnd, handPaint);

    canvas.drawCircle(center, faceRadius * 0.07, Paint()..color = Colors.white);
    canvas.drawCircle(center, faceRadius * 0.05, Paint()..color = const Color(0xFF1A1A1A));
  }

  @override
  bool shouldRepaint(covariant ClockFacePainter oldDelegate) {
    return oldDelegate.now != now || oldDelegate.faceRadius != faceRadius;
  }
}
