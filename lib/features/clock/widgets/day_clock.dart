import 'dart:async';

import 'package:flutter/material.dart';

import 'clock_face_painter.dart';
import 'task_ring_painter.dart';

/// Combines the 24-hour dial with a live-updating hand and an outer ring
/// of task arcs (18% of the radius, just outside the dial).
class DayClock extends StatefulWidget {
  const DayClock({super.key, this.arcs = const []});

  final List<TaskArc> arcs;

  @override
  State<DayClock> createState() => _DayClockState();
}

class _DayClockState extends State<DayClock> {
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        if (size <= 0 || size.isInfinite) return const SizedBox.shrink();
        final outerRadius = size / 2;
        final ringWidth = outerRadius * 0.18;
        final faceRadius = outerRadius - ringWidth - 4;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: TaskRingPainter(
                  arcs: widget.arcs,
                  innerRadius: faceRadius + 4,
                  outerRadius: outerRadius,
                  trackColor: colorScheme.surfaceContainerHigh,
                ),
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: ClockFacePainter(now: _now, faceRadius: faceRadius),
              ),
            ),
          ],
        );
      },
    );
  }
}
