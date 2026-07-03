import 'package:flutter/material.dart';

import '../../../shared/colors.dart';
import '../models/planner_task.dart';
import 'task_form_sheet.dart';

class TaskListTile extends StatelessWidget {
  const TaskListTile({super.key, required this.task, required this.onDelete});

  final PlannerTask task;
  final VoidCallback onDelete;

  String _formatMinutes(BuildContext context, int minutes) {
    final timeOfDay = TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);
    return timeOfDay.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorForEventColorId(task.colorId),
          radius: 12,
        ),
        title: Text(task.title),
        subtitle: Text(
          '${_formatMinutes(context, task.startMinutes)} – ${_formatMinutes(context, task.endMinutes)}'
          '${task.isRecurring ? ' · recurring' : ''}',
        ),
        onTap: () => showTaskFormSheet(context, existing: task),
      ),
    );
  }
}
