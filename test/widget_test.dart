import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:k24_planner/features/home/home_screen.dart';
import 'package:k24_planner/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('renders the K24 Planner app bar', (WidgetTester tester) async {
    // Tests HomeScreen directly (rather than the full K24PlannerApp) to
    // avoid the Google sign-in auth gate: GoogleSignInAccount has no public
    // constructor, so authStateProvider can't be faked with a signed-in
    // value from application code. See CLAUDE.md's testWidgets gotcha.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayTasksProvider.overrideWithValue(const AsyncValue.data([])),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('K24 Planner'), findsWidgets);

    // Unmount so DayClock's periodic timer is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
