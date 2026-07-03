# K24 Planner

A Flutter/Dart Android app for daily task planning centered on a 24-hour analog
clock — a single hand sweeping the dial once per day, numbered 1–24, modeled after
physical 24-hour wall-planner clocks. Today's tasks are shown as colored arc
segments on a ring around the outside of the dial, positioned by time of day.

Tasks aren't stored locally — they're the signed-in user's Google Calendar events
for today, fetched live via the Calendar API. The app is currently read-only: it
displays today's schedule but has no in-app way to add, edit, or delete events
(manage those from Google Calendar itself).

See [`CLAUDE.md`](CLAUDE.md) for architecture, conventions, one-time Google Cloud
OAuth setup, and development commands.

## Quick start

```bash
flutter pub get
flutter run -d emulator-5554   # or a connected device id
flutter analyze
flutter test
```
