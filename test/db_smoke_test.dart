import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:k24_planner/data/database/database.dart';

void main() {
  test('in-memory database opens and inserts', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await db.into(db.tasks).insert(
      TasksCompanion.insert(title: 'Test', startMinutes: 0, endMinutes: 60, colorValue: 0xFF000000),
    );
    expect(id, isNonZero);
    await db.close();
  }, timeout: const Timeout(Duration(seconds: 15)));
}
