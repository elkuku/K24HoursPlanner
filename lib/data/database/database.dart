import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get startMinutes => integer()(); // minutes since midnight, 0-1439
  IntColumn get endMinutes => integer()(); // may be < start (wraps past midnight)
  IntColumn get colorValue => integer()(); // ARGB
  BoolColumn get isRecurring => boolean().withDefault(const Constant(true))();
  IntColumn get weekdaysMask =>
      integer().withDefault(const Constant(127))(); // bit0=Mon..bit6=Sun
  DateTimeColumn get specificDate =>
      dateTime().nullable()(); // set only when !isRecurring
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'k24_planner');
  }
}
