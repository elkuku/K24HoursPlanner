import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:k24_planner/features/home/home_screen.dart';
import 'package:k24_planner/features/tasks/models/planner_task.dart';
import 'package:k24_planner/features/tasks/providers/task_providers.dart';

/// Seeds a handful of sample events (spanning an overnight task and several
/// Google Calendar colors), for use as the README preview image.
///
/// Run as an on-device test:
///
/// ```bash
/// flutter test integration_test/screenshot_test.dart -d emulator-5554
/// ```
///
/// Or run it as a live app and grab a real screenshot with adb:
///
/// ```bash
/// flutter run -d emulator-5554 -t integration_test/screenshot_test.dart
/// adb exec-out screencap -p > screenshots/home_screen.png
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures a screenshot with sample events', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sampleTasks = [
      PlannerTask(
        id: 'demo-sleep',
        recurringEventId: 'demo-sleep-series',
        title: 'Sleep',
        startMinutes: 23 * 60,
        endMinutes: 7 * 60,
        colorId: '9',
        specificDate: today,
      ),
      PlannerTask(
        id: 'demo-breakfast',
        recurringEventId: null,
        title: 'Breakfast',
        startMinutes: 7 * 60,
        endMinutes: 7 * 60 + 30,
        colorId: '5',
        specificDate: today,
      ),
      PlannerTask(
        id: 'demo-school',
        recurringEventId: 'demo-school-series',
        title: 'School',
        startMinutes: 9 * 60,
        endMinutes: 15 * 60,
        colorId: '7',
        specificDate: today,
      ),
      PlannerTask(
        id: 'demo-soccer',
        recurringEventId: null,
        title: 'Soccer practice',
        startMinutes: 17 * 60,
        endMinutes: 18 * 60 + 30,
        colorId: '10',
        specificDate: today,
      ),
      PlannerTask(
        id: 'demo-dinner',
        recurringEventId: null,
        title: 'Dinner',
        startMinutes: 19 * 60,
        endMinutes: 19 * 60 + 45,
        colorId: '6',
        specificDate: today,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayTasksProvider.overrideWith((ref) async => sampleTasks)],
        child: MaterialApp(
          home: const HomeScreen(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('home_screen');

    // Unmount so DayClock's periodic timer is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
