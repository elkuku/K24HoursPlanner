import 'package:googleapis/calendar/v3.dart' as calendar;

/// App-level task derived from a Google Calendar event. Time-of-day fields
/// use the same minutes-since-midnight convention as the rest of the app
/// (see `time_utils.dart`), so the clock/ring painters need no changes.
class PlannerTask {
  const PlannerTask({
    required this.id,
    required this.recurringEventId,
    required this.title,
    required this.startMinutes,
    required this.endMinutes,
    required this.colorId,
    required this.specificDate,
  });

  /// The calendar event id. For a recurring task this is one occurrence's
  /// instance id (`events.list(singleEvents: true)` expands the series into
  /// per-day instances); mutations that should affect the whole series use
  /// [recurringEventId] via [editTargetId] instead.
  final String id;

  /// Non-null when this task is an occurrence of a recurring series; holds
  /// the id of the series' master event.
  final String? recurringEventId;

  final String title;
  final int startMinutes;
  final int endMinutes;
  final String? colorId;

  /// The local calendar date (midnight) this occurrence falls on.
  final DateTime specificDate;

  bool get isRecurring => recurringEventId != null;

  /// The event id that update/delete calls should target: the series
  /// master when recurring (edits/deletes the whole series), otherwise this
  /// occurrence's own id.
  String get editTargetId => recurringEventId ?? id;

  /// Builds a [PlannerTask] from a Calendar API [event], or returns null for
  /// all-day events (`start.date` set, no `start.dateTime`) which have no
  /// meaningful time-of-day to plot on the ring — a v1 limitation.
  static PlannerTask? fromEvent(calendar.Event event) {
    final id = event.id;
    final startDateTime = event.start?.dateTime?.toLocal();
    final endDateTime = event.end?.dateTime?.toLocal();
    if (id == null || startDateTime == null || endDateTime == null) {
      return null;
    }
    return PlannerTask(
      id: id,
      recurringEventId: event.recurringEventId,
      title: event.summary ?? '(untitled)',
      startMinutes: startDateTime.hour * 60 + startDateTime.minute,
      endMinutes: endDateTime.hour * 60 + endDateTime.minute,
      colorId: event.colorId,
      specificDate: DateTime(
        startDateTime.year,
        startDateTime.month,
        startDateTime.day,
      ),
    );
  }
}
