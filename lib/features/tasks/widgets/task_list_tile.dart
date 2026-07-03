import 'package:flutter/material.dart';

import '../../../shared/colors.dart';
import '../models/planner_task.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({super.key, required this.task});

  final PlannerTask task;

  String _formatMinutes(BuildContext context, int minutes) {
    final timeOfDay = TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);
    return timeOfDay.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForEventColorId(task.colorId);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      clipBehavior: Clip.antiAlias,
      color: color.withValues(alpha: 0.12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 8, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 18,
                      child: const Icon(Icons.event, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${_formatMinutes(context, task.startMinutes)} – ${_formatMinutes(context, task.endMinutes)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
