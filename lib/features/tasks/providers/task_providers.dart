import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../shared/time_utils.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.tasks).watch();
});

/// Recurring tasks scheduled on today's weekday, plus one-off tasks whose
/// specific date is today.
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider).value ?? const [];
  final today = DateTime.now();
  return tasks.where((task) {
    if (task.isRecurring) {
      return weekdayMaskIncludes(task.weekdaysMask, today);
    }
    final specific = task.specificDate;
    return specific != null && isSameDate(specific, today);
  }).toList();
});
