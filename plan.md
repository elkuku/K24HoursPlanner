# K24 Planner — Flutter 24-hour daily task planner

## Context

The user wants a new Android app, built with Dart/Flutter, whose centerpiece is a **24-hour analog clock face** (single hand sweeping the full dial once per day, numbered 1–24, like the referenced physical wall-planner product) instead of a normal 12-hour clock. Around that clock, an **outer ring** displays the user's tasks for the day as colored arc segments positioned by time of day. Recurring tasks (configurable per weekday) reappear on the ring automatically every matching day; one-off tasks are tied to a specific date. The project started from an empty folder — this is a full greenfield scaffold, not a modification of existing code.

Confirmed decisions from the user:
- Tasks are time ranges (start + end), rendered as arcs on the ring — not single-point markers.
- Recurrence is configurable per weekday (defaults to all 7 days), not just "every day".
- Both recurring and one-off (specific-date) tasks are supported.
- Stack: **Riverpod** (state) + **Drift/SQLite** (persistence).
- App name **"K24 Planner"**, package `com.elkuku.k24planner`.
- Android-only target (`flutter create --platforms=android`).
- Verification cadence: run on the emulator **per milestone**, not after every single edit.

## Tech stack & dependencies

- Flutter 3.44.1 / Dart 3.12.
- State: `flutter_riverpod` (plain providers, no codegen — keeps build_runner usage limited to Drift).
- Persistence: `drift`, `drift_flutter` (simplifies SQLite setup), `sqlite3_flutter_libs`, `path_provider`, `path`. Dev deps: `drift_dev`, `build_runner`.
- No extra color-picker or intl packages: task colors use a small hardcoded Material palette (chip picker), time formatting uses Flutter's built-in `TimeOfDay.format(context)`.
- Emulator: `Pixel_6a_API_35` (device id `emulator-5554`).

## Data model

Single Drift table `Tasks`:
```dart
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get startMinutes => integer()();      // minutes since midnight, 0-1439
  IntColumn get endMinutes => integer()();        // may be < start (task wraps past midnight)
  IntColumn get colorValue => integer()();        // ARGB
  BoolColumn get isRecurring => boolean().withDefault(const Constant(true))();
  IntColumn get weekdaysMask => integer().withDefault(const Constant(127))(); // bit0=Mon..bit6=Sun
  DateTimeColumn get specificDate => dateTime().nullable()(); // set only when !isRecurring
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```
- Arc sweep for rendering/wrap handling: `sweepMinutes = ((endMinutes - startMinutes) % 1440 + 1440) % 1440`, so overnight tasks (e.g. Sleep 23:00→07:00) render correctly without special-casing. Implemented in `lib/shared/time_utils.dart`.
- "Today's tasks" (what appears on the ring) = recurring tasks whose `weekdaysMask` bit for `DateTime.now().weekday` is set, **plus** one-off tasks whose `specificDate` is today. Computed client-side in a Riverpod provider from the full task stream — no need for date logic in SQL.

## Folder structure

```
lib/
  main.dart                       # ProviderScope + runApp
  app.dart                        # MaterialApp, Material3 theme
  data/
    database/database.dart        # Drift AppDatabase, Tasks table (drift codegen -> database.g.dart)
  features/
    clock/
      widgets/clock_face_painter.dart   # CustomPainter: dial, ticks, numbers 1-24, live hand
      widgets/task_ring_painter.dart    # CustomPainter: outer arc segments from task list
      widgets/day_clock.dart            # Stack combining face + ring + live Timer
    tasks/
      providers/task_providers.dart     # databaseProvider, allTasksProvider (Stream), todayTasksProvider
      widgets/task_form_sheet.dart      # add/edit bottom sheet: title, time pickers, recurring/one-off toggle, weekday chips, date picker, color chips
      widgets/task_list_tile.dart       # list row below the clock, tap=edit, swipe=delete
    home/home_screen.dart               # Scaffold: DayClock + today's task list + FAB
  shared/
    time_utils.dart                     # minutesToAngle(), sweepMinutes(), weekday bitmask helpers (unit-testable pure functions)
    colors.dart                         # preset task color palette
test/
  time_utils_test.dart                  # unit tests for angle math + weekday matching
```

## Milestones (build → run on emulator → verify each step)

1. **Scaffold** — DONE. `flutter create --platforms=android --org com.elkuku --project-name k24_planner .`, app label set to "K24 Planner", dependencies added, empty scaffold verified on emulator via screenshot.
2. **Clock face** — DONE. `ClockFacePainter` (dial, tick marks, numbers 1–24 clockwise from top, single hand sweeping 360° per 24h, live-updating via `Timer.periodic`) + center digital time text, wired via `DayClock` into `home_screen.dart`. Verified on emulator via screenshot: hand correctly pointed near "15" at 14:56 system time. Fixed a crash where the warm-up frame's 0x0 layout constraints produced a negative `faceRadius`/font size (guarded in both `ClockFacePainter.paint` and `DayClock`'s `LayoutBuilder`).
3. **Task ring** — DONE. `TaskRingPainter` (`lib/features/clock/widgets/task_ring_painter.dart`) renders `TaskArc` segments outside the dial using the sweep formula, with visual gaps between segments. Verified on emulator with hardcoded sample data in `home_screen.dart` (`_sampleArcs`, marked TEMPORARY) — confirmed correct positioning for a normal arc, a small arc, and an overnight-wrapping arc (23:00→07:00) rendering as one continuous band across the midnight mark.
4. **Data layer** — DONE. `Tasks` Drift table in `lib/data/database/database.dart`, codegen via `dart run build_runner build` produced `database.g.dart`. `lib/features/tasks/providers/task_providers.dart` has `databaseProvider`, `allTasksProvider` (Stream via `.watch()`), `todayTasksProvider` (weekday/date matching, computed via pure helpers `weekdayMaskIncludes`/`isSameDate` added to `time_utils.dart`). `test/time_utils_test.dart` covers angle math, sweep wrap, weekday mask, same-date logic (9 tests). `flutter analyze` clean, `flutter test` all passing (11 tests incl. fixed default `widget_test.dart`, which referenced the removed counter-app `MyApp` class). Not yet wired into the UI — `home_screen.dart` still uses the milestone-3 `_sampleArcs`; real wiring happens in milestone 6.
5. **Task form** — DONE. `lib/features/tasks/widgets/task_form_sheet.dart`: title field, start/end `showTimePicker`, `SegmentedButton` toggle between "Recurring" (weekday `FilterChip`s, default all selected) and "One-off" (date picker), color chip palette (`shared/colors.dart`), Save/Delete writing through `databaseProvider` (`db.into(db.tasks).insert(...)` / `db.update(...)`/`db.delete(...)`). FAB in `home_screen.dart` wired to `showTaskFormSheet(context)` for add. Verified end-to-end on emulator: opened form, typed a title, saved, sheet closed with no exceptions; pulled the on-device SQLite file (`adb shell run-as com.elkuku.k24_planner cat app_flutter/k24_planner.sqlite`) and confirmed the row (`Standup`, 540–600 min, recurring, mask 127) was persisted correctly. Tap-to-edit from the ring/list still pending — wired in milestone 6 once the real list exists.
6. **Wire end-to-end** — DONE. `home_screen.dart` is now a `ConsumerWidget` using `todayTasksProvider` (sorted by `startMinutes`) to feed both `DayClock`'s ring and a `CustomScrollView`/`SliverList` of today's tasks via the new `TaskListTile` (`lib/features/tasks/widgets/task_list_tile.dart` — tap opens edit form, swipe-to-dismiss deletes); shows an empty-state message when there are no tasks. Removed the milestone-3 `_sampleArcs`. Verified thoroughly on emulator: added a task through the real form and confirmed it appeared on the ring + list immediately; edited a task and confirmed the form pre-filled correctly; swipe-deleted tasks and confirmed removal from both ring and list; did a **full cold restart** (`adb shell am force-stop` + `am start`, stronger than a hot-restart) and confirmed the SQLite-backed task survived; verified the empty-state message renders when the last task is removed. Skipped re-verifying the overnight-wrap arc through the UI form specifically (ADB text/time-picker automation proved too fiddly) — the wrap math itself was already verified thoroughly in milestone 3 and is unchanged.
   - Along the way, fixed a real bug: a first attempt at testing with a real in-memory Drift database (`NativeDatabase.memory()`) inside `testWidgets` caused the test runner to hang indefinitely (FFI + `FakeAsync` interaction). Fixed by overriding `todayTasksProvider` directly with a static value in the widget test instead of standing up a real database — narrower, faster, and avoids the hang. Added `test/db_smoke_test.dart` (plain `test()`, not `testWidgets()`) to still cover a real DB insert round-trip via `NativeDatabase.memory()`, which works fine outside the `FakeAsync` widget-test zone.
   - Also had to kill a stale `flutter run` process from an earlier milestone that silently survived a `pkill` pattern mismatch (matched on `dartvm ... run -d emulator-5554`, not literally `flutter run`) and was holding the incremental-compile lock, causing `flutter test`/`flutter run` to hang. Worth checking `ps aux | grep dart` if a run/test hangs unexpectedly.
7. **Polish + docs** — NEXT. `flutter analyze` clean and `flutter test` passing (12 tests) already confirmed. Remaining: write `CLAUDE.md` (project overview, architecture, key formulas — minutes-since-midnight, weekday bitmask spec, angle formula — and commands: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter run -d emulator-5554`, `flutter analyze`, `flutter test`), plus the gotchas noted above (stale process detection, widget-testing pattern for Riverpod+Drift).

## Verification approach

At the end of each milestone: ensure the `Pixel_6a_API_35` AVD is running (`flutter emulators --launch Pixel_6a_API_35`, device id `emulator-5554`), then `flutter run -d emulator-5554 --debug`. Capture a screenshot with `adb exec-out screencap -p > screenshot.png` (adb at `/home/elkuku/Android/Sdk/platform-tools/adb`; wake the screen first with `adb shell input keyevent KEYCODE_WAKEUP` if it comes back black) and use the Read tool to visually inspect layout/rendering, rather than just trusting a clean compile. Stop the run before moving to the next milestone's edits. Finish with `flutter analyze` and `flutter test` passing.

## Deliverables

- Full Flutter project under `/home/elkuku/repos/K24HoursPlanner`.
- `CLAUDE.md` at repo root documenting the architecture and conventions above for future sessions.
