import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/colors.dart';
import '../clock/widgets/day_clock.dart';
import '../clock/widgets/task_ring_painter.dart';
import '../settings/providers/settings_providers.dart';
import '../settings/settings_screen.dart';
import '../tasks/models/planner_task.dart';
import '../tasks/providers/task_providers.dart';
import '../tasks/widgets/task_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);
    final appTitle = ref.watch(appTitleProvider).value ?? kDefaultAppTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }
}

class _TaskListBody extends StatelessWidget {
  const _TaskListBody({required this.tasks});

  final List<PlannerTask> tasks;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: AspectRatio(aspectRatio: 1, child: DayClock(arcs: arcs)),
          ),
        ),
        if (todayTasks.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 12),
                    Text(
                      'Nothing planned for today!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            sliver: SliverList.builder(
              itemCount: todayTasks.length,
              itemBuilder: (context, index) => TaskListTile(task: todayTasks[index]),
            ),
          ),
      ],
    );
  }
}
