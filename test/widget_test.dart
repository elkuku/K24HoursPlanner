import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:k24_planner/app.dart';
import 'package:k24_planner/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('renders the K24 Planner app bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayTasksProvider.overrideWithValue(const [])],
        child: const K24PlannerApp(),
      ),
    );

    expect(find.text('K24 Planner'), findsWidgets);

    // Unmount so DayClock's periodic timer is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
