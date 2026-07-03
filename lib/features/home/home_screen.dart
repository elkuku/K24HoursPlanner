import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/colors.dart';
import '../clock/widgets/day_clock.dart';
import '../clock/widgets/task_ring_painter.dart';
import '../tasks/models/planner_task.dart';
import '../tasks/providers/task_providers.dart';
import '../tasks/widgets/task_form_sheet.dart';
import '../tasks/widgets/task_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('K24 Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(todayTasksProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(googleAuthServiceProvider).signOut(),
          ),
        ],
      ),
      body: switch (todayTasksAsync) {
        AsyncError(:final error) => Center(
          child: Text('Failed to load tasks: $error'),
        ),
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () => ref.refresh(todayTasksProvider.future),
          child: _TaskListBody(tasks: value),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListBody extends ConsumerWidget {
  const _TaskListBody({required this.tasks});

  final List<PlannerTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = [...tasks]
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final arcs = [
      for (final task in todayTasks)
        TaskArc(
          startMinutes: task.startMinutes,
          endMinutes: task.endMinutes,
          color: colorForEventColorId(task.colorId),
        ),
    ];

    return CustomScrollView(
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
                  final calendarService = ref.read(calendarServiceProvider);
                  await calendarService?.deleteTask(task.editTargetId);
                  ref.invalidate(todayTasksProvider);
                },
              );
            },
          ),
      ],
    );
  }
}
