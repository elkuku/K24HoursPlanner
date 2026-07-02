import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clock/widgets/day_clock.dart';
import '../clock/widgets/task_ring_painter.dart';
import '../tasks/providers/task_providers.dart';
import '../tasks/widgets/task_form_sheet.dart';
import '../tasks/widgets/task_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = [...ref.watch(todayTasksProvider)]
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final arcs = [
      for (final task in todayTasks)
        TaskArc(
          startMinutes: task.startMinutes,
          endMinutes: task.endMinutes,
          color: Color(task.colorValue),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('K24 Planner')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AspectRatio(aspectRatio: 1, child: DayClock(arcs: arcs)),
            ),
          ),
          if (todayTasks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No tasks for today yet. Tap + to add one.')),
            )
          else
            SliverList.builder(
              itemCount: todayTasks.length,
              itemBuilder: (context, index) {
                final task = todayTasks[index];
                return TaskListTile(
                  task: task,
                  onDelete: () async {
                    final db = ref.read(databaseProvider);
                    await (db.delete(db.tasks)..where((t) => t.id.equals(task.id))).go();
                  },
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
