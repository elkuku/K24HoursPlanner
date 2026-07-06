import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import '../../features/tasks/models/planner_task.dart';
import '../../shared/time_utils.dart';
import '../auth/google_auth_service.dart';

const String _kPrimaryCalendarId = 'primary';

/// Reads tasks as events on the signed-in user's primary Google Calendar.
/// Recurrence is Calendar-native (RRULE): "today's tasks" is answered by
/// asking the Calendar API to expand occurrences for today
/// (`singleEvents: true`) rather than any client-side weekday matching.
///
/// [createTask]/[updateTask]/[deleteTask] below are dormant (see "Read-only
/// UI" in CLAUDE.md) and will fail with the read-only
/// [calendarEventsReadonlyScope] this class currently authorizes with — they
/// need the write-capable `calendar.events` scope, which isn't requested
/// while there's no UI that calls them.
class CalendarService {
  CalendarService(this._account);

  final GoogleSignInAccount _account;
  calendar.CalendarApi? _api;

  Future<calendar.CalendarApi> _apiClient() async {
    final cached = _api;
    if (cached != null) return cached;
    final authorization = await _account.authorizationClient.authorizeScopes(
      const [calendarEventsReadonlyScope],
    );
    final client = authorization.authClient(
      scopes: const [calendarEventsReadonlyScope],
    );
    final api = calendar.CalendarApi(client);
    _api = api;
    return api;
  }

  /// Recurring tasks scheduled on [date], plus one-off tasks whose date is
  /// [date] — expanded server-side by the Calendar API.
  Future<List<PlannerTask>> fetchForDate(DateTime date) async {
    final api = await _apiClient();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final events = await api.events.list(
      _kPrimaryCalendarId,
      timeMin: startOfDay,
      timeMax: endOfDay,
      singleEvents: true,
      orderBy: 'startTime',
    );
    return [
      for (final event in events.items ?? const <calendar.Event>[])
        ?PlannerTask.fromEvent(event),
    ];
  }

  /// Fetches the RRULE strings of a recurring series' master event, for
  /// prefilling the edit form's weekday chips. Returns null if the event
  /// isn't recurring or has no explicit recurrence rules.
  Future<List<String>?> fetchRecurrenceRules(String masterEventId) async {
    final api = await _apiClient();
    final event = await api.events.get(_kPrimaryCalendarId, masterEventId);
    return event.recurrence;
  }

  Future<void> createTask({
    required String title,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required String? colorId,
    required List<String>? recurrenceRules,
  }) async {
    final api = await _apiClient();
    await api.events.insert(
      _buildEvent(
        title: title,
        date: date,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        colorId: colorId,
        recurrenceRules: recurrenceRules,
      ),
      _kPrimaryCalendarId,
    );
  }

  /// Updates the whole event (or, for a recurring task, the whole series —
  /// [eventId] should be [PlannerTask.editTargetId]).
  Future<void> updateTask({
    required String eventId,
    required String title,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required String? colorId,
    required List<String>? recurrenceRules,
  }) async {
    final api = await _apiClient();
    await api.events.update(
      _buildEvent(
        title: title,
        date: date,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        colorId: colorId,
        recurrenceRules: recurrenceRules,
      ),
      _kPrimaryCalendarId,
      eventId,
    );
  }

  Future<void> deleteTask(String eventId) async {
    final api = await _apiClient();
    await api.events.delete(_kPrimaryCalendarId, eventId);
  }

  calendar.Event _buildEvent({
    required String title,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required String? colorId,
    required List<String>? recurrenceRules,
  }) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startMinutes ~/ 60,
      startMinutes % 60,
    );
    final end = start.add(
      Duration(minutes: sweepMinutes(startMinutes, endMinutes)),
    );
    return calendar.Event(
      summary: title,
      start: calendar.EventDateTime(dateTime: start),
      end: calendar.EventDateTime(dateTime: end),
      colorId: colorId,
      recurrence: recurrenceRules,
    );
  }
}
