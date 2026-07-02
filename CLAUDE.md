# K24 Planner

A Flutter/Dart Android app for daily task planning centered on a **24-hour analog
clock** (a single hand sweeping the dial once per 24h, numbered 1–24, modeled after
physical 24-hour wall-planner clocks — not a standard 12-hour clock). Recurring and
one-off tasks are shown as colored arc segments on a ring around the outside of the
dial, positioned by time of day.

## Tech stack

- Flutter (Android target only; project was scaffolded with `--platforms=android`).
- State management: **Riverpod** (`flutter_riverpod`), plain providers — no codegen.
- Persistence: **Drift** (SQLite) via `drift_flutter`'s `driftDatabase()` helper for
  app runtime, `NativeDatabase.memory()` for tests.
- No color-picker or intl dependency: task colors use a small hardcoded Material
  palette (`lib/shared/colors.dart`); time formatting uses Flutter's built-in
  `TimeOfDay.format(context)`.

## Architecture

```
lib/
  main.dart                                  # ProviderScope + runApp
  app.dart                                   # MaterialApp, Material3 theme
  data/database/database.dart                # Drift `Tasks` table + AppDatabase
  features/
    clock/widgets/
      clock_face_painter.dart                # CustomPainter: 24h dial, ticks, hand
      task_ring_painter.dart                  # CustomPainter: task arcs on outer ring
      day_clock.dart                          # Combines face + ring, live Timer
    tasks/
      providers/task_providers.dart           # databaseProvider, allTasksProvider, todayTasksProvider
      widgets/task_form_sheet.dart            # Add/edit bottom sheet
      widgets/task_list_tile.dart             # List row: tap=edit, swipe=delete
    home/home_screen.dart                     # DayClock + today's task list + FAB
  shared/
    time_utils.dart                           # Pure, unit-tested time/angle/weekday helpers
    colors.dart                               # Preset task color palette
test/
  time_utils_test.dart                        # Unit tests for time_utils.dart
  db_smoke_test.dart                          # Plain `test()` DB round-trip via in-memory Drift
  widget_test.dart                            # Widget smoke test (overrides todayTasksProvider)
```

## Key conventions

- **Time storage**: tasks store `startMinutes`/`endMinutes` as minutes-since-midnight
  (0–1439), not `DateTime`, to avoid timezone/date complexity and to make angle math
  trivial.
- **Overnight wrap**: a task's sweep is
  `((endMinutes - startMinutes) % 1440 + 1440) % 1440` (`sweepMinutes` in
  `time_utils.dart`). This means `endMinutes < startMinutes` (e.g. Sleep 23:00→07:00)
  renders correctly as a single continuous arc across midnight with no special-casing.
- **Dial angle**: `minutesToAngle(minutes) = -pi/2 + (minutes/1440) * 2*pi` — puts
  midnight (0/24) at the top of the dial, increasing clockwise.
- **Recurrence**: `weekdaysMask` is a bitmask, bit 0 = Monday .. bit 6 = Sunday
  (`weekdayBit(DateTime.weekday)` / `weekdayMaskIncludes` in `time_utils.dart`).
  `kAllWeekdaysMask = 127` is the default (every day). One-off tasks instead set
  `specificDate` and ignore the mask.
- **"Today's tasks"** (what renders on the ring/list) = recurring tasks whose
  `weekdaysMask` includes today's weekday, plus one-off tasks whose `specificDate` is
  today — computed client-side in `todayTasksProvider`, not in SQL.
- Overlapping tasks at the same time simply paint over each other on the ring (later
  entry wins visually) — no collision/stacking layout, by design for v1.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate database.g.dart after editing database.dart
flutter run -d emulator-5554                                # Pixel_6a_API_35 AVD
flutter analyze
flutter test
```

To launch the emulator if it isn't running: `flutter emulators --launch Pixel_6a_API_35`.
adb lives at `/home/elkuku/Android/Sdk/platform-tools/adb` (not on PATH by default).

## Gotchas

- **Widget-testing Riverpod + Drift**: do not instantiate a real Drift database
  (even `NativeDatabase.memory()`) inside a `testWidgets` block — the FFI calls
  interact badly with `flutter_test`'s `FakeAsync` zone and can hang the test runner
  indefinitely. Instead override the relevant provider directly with static data
  (e.g. `todayTasksProvider.overrideWithValue([...])`). Real DB round-trip tests
  belong in a plain `test()` (see `test/db_smoke_test.dart`), which runs outside the
  widget-test zone and works fine.
- **Stale `flutter run` processes**: `pkill -f "flutter run -d ..."` can silently
  fail to match, because the actual process is `dartvm ... run -d ...` — "flutter"
  only appears in the binary's path, not the process's own argv in a way that forms
  the literal substring `"flutter run"`. A leftover process holds the incremental
  compile lock and will hang subsequent `flutter run`/`flutter test` invocations. If
  a run or test hangs unexpectedly, check `ps aux | grep dart` and kill stale PIDs
  directly.
- Flutter's warm-up frame can call `CustomPainter.paint` with 0×0 constraints before
  real layout happens; `ClockFacePainter` and `DayClock` both guard against
  non-positive radii to avoid a negative-fontSize assertion crash.
