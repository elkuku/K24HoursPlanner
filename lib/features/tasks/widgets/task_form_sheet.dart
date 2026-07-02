import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../shared/colors.dart';
import '../../../shared/time_utils.dart';
import '../providers/task_providers.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

Future<void> showTaskFormSheet(BuildContext context, {Task? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TaskFormSheet(existing: existing),
  );
}

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({super.key, this.existing});

  final Task? existing;

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
  late Color _color;

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
    _weekdaysMask = task?.weekdaysMask ?? kAllWeekdaysMask;
    _specificDate = task?.specificDate ?? DateTime.now();
    _color = Color(task?.colorValue ?? taskColorPalette.first.toARGB32());
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
    final db = ref.read(databaseProvider);
    final companion = TasksCompanion(
      title: Value(title),
      startMinutes: Value(_startMinutes),
      endMinutes: Value(_endMinutes),
      colorValue: Value(_color.toARGB32()),
      isRecurring: Value(_isRecurring),
      weekdaysMask: Value(_isRecurring ? _weekdaysMask : kAllWeekdaysMask),
      specificDate: Value(
        _isRecurring
            ? null
            : DateTime(_specificDate.year, _specificDate.month, _specificDate.day),
      ),
    );
    final existing = widget.existing;
    if (existing == null) {
      await db.into(db.tasks).insert(companion);
    } else {
      await (db.update(db.tasks)..where((t) => t.id.equals(existing.id))).write(companion);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final db = ref.read(databaseProvider);
    await (db.delete(db.tasks)..where((t) => t.id.equals(existing.id))).go();
    if (!mounted) return;
    Navigator.of(context).pop();
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
              children: taskColorPalette.map((color) {
                final selected = color.toARGB32() == _color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: CircleAvatar(
                    backgroundColor: color,
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
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                if (widget.existing != null) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: _save, child: const Text('Save')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
