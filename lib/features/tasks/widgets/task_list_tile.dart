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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorForEventColorId(task.colorId),
        radius: 12,
      ),
      title: Text(task.title),
      subtitle: Text(
        '${_formatMinutes(context, task.startMinutes)} – ${_formatMinutes(context, task.endMinutes)}'
        '${task.isRecurring ? ' · recurring' : ''}',
      ),
    );
  }
}
