import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/colors.dart';
import '../../../shared/time_utils.dart';
import '../models/planner_task.dart';
import '../providers/task_providers.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

Future<void> showTaskFormSheet(BuildContext context, {PlannerTask? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TaskFormSheet(existing: existing),
  );
}

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({super.key, this.existing});

  final PlannerTask? existing;

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  late final TextEditingController _titleController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isRecurring;
  late int _weekdaysMask;
  late DateTime _specificDate;
  late String _colorId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.existing;
    _titleController = TextEditingController(text: task?.title ?? '');
    _startTime = task == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: task.startMinutes ~/ 60, minute: task.startMinutes % 60);
    _endTime = task == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay(hour: task.endMinutes ~/ 60, minute: task.endMinutes % 60);
    _isRecurring = task?.isRecurring ?? true;
    _weekdaysMask = kAllWeekdaysMask;
    _specificDate = task?.specificDate ?? DateTime.now();
    _colorId = task?.colorId ?? googleEventColors.keys.first;
    if (task != null && task.isRecurring) {
      _loadRecurrence(task.editTargetId);
    }
  }

  Future<void> _loadRecurrence(String masterEventId) async {
    final calendarService = ref.read(calendarServiceProvider);
    final rules = await calendarService?.fetchRecurrenceRules(masterEventId);
    if (!mounted) return;
    setState(() => _weekdaysMask = weekdaysMaskFromRecurrence(rules));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int get _startMinutes => _startTime.hour * 60 + _startTime.minute;
  int get _endMinutes => _endTime.hour * 60 + _endTime.minute;

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _specificDate = picked);
  }

  void _toggleWeekday(int weekday) {
    setState(() => _weekdaysMask ^= weekdayBit(weekday));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final calendarService = ref.read(calendarServiceProvider);
    if (calendarService == null) return;
    setState(() => _saving = true);
    final date = _isRecurring ? DateTime.now() : _specificDate;
    final anchorDate = DateTime(date.year, date.month, date.day);
    final recurrenceRules = _isRecurring
        ? [rruleForWeekdaysMask(_weekdaysMask)]
        : null;
    final existing = widget.existing;
    try {
      if (existing == null) {
        await calendarService.createTask(
          title: title,
          date: anchorDate,
          startMinutes: _startMinutes,
          endMinutes: _endMinutes,
          colorId: _colorId,
          recurrenceRules: recurrenceRules,
        );
      } else {
        await calendarService.updateTask(
          eventId: existing.editTargetId,
          title: title,
          date: anchorDate,
          startMinutes: _startMinutes,
          endMinutes: _endMinutes,
          colorId: _colorId,
          recurrenceRules: recurrenceRules,
        );
      }
      ref.invalidate(todayTasksProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final calendarService = ref.read(calendarServiceProvider);
    setState(() => _saving = true);
    try {
      await calendarService?.deleteTask(existing.editTargetId);
      ref.invalidate(todayTasksProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add task' : 'Edit task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: widget.existing == null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartTime,
                    child: Text('Start ${_startTime.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndTime,
                    child: Text('End ${_endTime.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Recurring')),
                ButtonSegment(value: false, label: Text('One-off')),
              ],
              selected: {_isRecurring},
              onSelectionChanged: (selection) =>
                  setState(() => _isRecurring = selection.first),
            ),
            const SizedBox(height: 16),
            if (_isRecurring)
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final weekday = i + 1;
                  final selected = (_weekdaysMask & weekdayBit(weekday)) != 0;
                  return FilterChip(
                    label: Text(_weekdayLabels[i]),
                    selected: selected,
                    onSelected: (_) => _toggleWeekday(weekday),
                  );
                }),
              )
            else
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  'Date: ${_specificDate.year}-${_specificDate.month.toString().padLeft(2, '0')}-${_specificDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: googleEventColors.entries.map((entry) {
                final selected = entry.key == _colorId;
                return GestureDetector(
                  onTap: () => setState(() => _colorId = entry.key),
                  child: CircleAvatar(
                    backgroundColor: entry.value,
                    radius: selected ? 18 : 14,
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (widget.existing != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                if (widget.existing != null) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
