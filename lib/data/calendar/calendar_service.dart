import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' show AccessDeniedException;

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
  String? _accessToken;

  Future<calendar.CalendarApi> _apiClient() async {
    final cached = _api;
    if (cached != null) return cached;
    final authorization = await _account.authorizationClient.authorizeScopes(
      const [calendarEventsReadonlyScope],
    );
    _accessToken = authorization.accessToken;
    final client = authorization.authClient(
      scopes: const [calendarEventsReadonlyScope],
    );
    final api = calendar.CalendarApi(client);
    _api = api;
    return api;
  }

  /// Runs [action] against the (possibly cached) [CalendarApi], retrying
  /// once with a freshly-authorized client if the server rejects the
  /// cached access token.
  ///
  /// `extension_google_sign_in_as_googleapis_auth`'s `authClient()` bakes in
  /// a fake 365-day expiry (the underlying platform SDK doesn't expose the
  /// token's real expiry) and no refresh token, so the client we cache in
  /// [_api] never proactively refreshes — it just keeps using the same
  /// access token forever. If the app sits backgrounded long enough for
  /// Google's real (much shorter) server-side expiry to pass, every call
  /// starts failing with [AccessDeniedException] until the process is
  /// killed. `google_sign_in`'s own docs describe the fix: clear the stale
  /// token from the platform's local cache, then re-authorize.
  Future<T> _run<T>(
    Future<T> Function(calendar.CalendarApi api) action,
  ) async {
    final api = await _apiClient();
    try {
      return await action(api);
    } on AccessDeniedException {
      _api = null;
      final staleToken = _accessToken;
      if (staleToken != null) {
        await _account.authorizationClient.clearAuthorizationToken(
          accessToken: staleToken,
        );
      }
      return action(await _apiClient());
    }
  }

  /// Recurring tasks scheduled on [date], plus one-off tasks whose date is
  /// [date] — expanded server-side by the Calendar API.
  Future<List<PlannerTask>> fetchForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _run((api) async {
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
    });
  }

  /// Fetches the RRULE strings of a recurring series' master event, for
  /// prefilling the edit form's weekday chips. Returns null if the event
  /// isn't recurring or has no explicit recurrence rules.
  Future<List<String>?> fetchRecurrenceRules(String masterEventId) {
    return _run((api) async {
      final event = await api.events.get(_kPrimaryCalendarId, masterEventId);
      return event.recurrence;
    });
  }

  Future<void> createTask({
    required String title,
    required DateTime date,
    required int startMinutes,
    required int endMinutes,
    required String? colorId,
    required List<String>? recurrenceRules,
  }) {
    return _run((api) async {
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
    });
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
  }) {
    return _run((api) async {
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
    });
  }

  Future<void> deleteTask(String eventId) {
    return _run((api) => api.events.delete(_kPrimaryCalendarId, eventId));
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
