import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/auth/google_auth_service.dart';
import '../../../data/calendar/calendar_service.dart';
import '../models/planner_task.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// Ensures [GoogleAuthService.initialize] has run exactly once before any
/// sign-in/authorization call is made.
final authInitProvider = FutureProvider<void>((ref) {
  return ref.watch(googleAuthServiceProvider).initialize();
});

/// The currently signed-in Google account, or null when signed out.
final authStateProvider = StreamProvider<GoogleSignInAccount?>((ref) async* {
  await ref.watch(authInitProvider.future);
  final auth = ref.watch(googleAuthServiceProvider);
  yield await auth.attemptLightweightSignIn();
  yield* auth.accountEvents;
});

/// A [CalendarService] bound to the current account, or null when signed
/// out.
final calendarServiceProvider = Provider<CalendarService?>((ref) {
  final account = ref.watch(authStateProvider).value;
  if (account == null) return null;
  return CalendarService(account);
});

/// Which day's tasks are currently displayed on the home screen.
enum PlannerDay {
  today,
  tomorrow;

  DateTime toDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      PlannerDay.today => today,
      PlannerDay.tomorrow => today.add(const Duration(days: 1)),
    };
  }
}

class SelectedDayNotifier extends Notifier<PlannerDay> {
  @override
  PlannerDay build() => PlannerDay.today;

  void select(PlannerDay day) => state = day;
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, PlannerDay>(
  SelectedDayNotifier.new,
);

/// Recurring tasks scheduled on [selectedDayProvider]'s date, plus one-off
/// tasks whose date matches — fetched fresh from Google Calendar (recurrence
/// expansion happens server-side). There's no live stream like the old
/// Drift-backed version, so callers must `ref.invalidate(todayTasksProvider)`
/// after any create/update/delete to refresh.
final todayTasksProvider = FutureProvider<List<PlannerTask>>((ref) async {
  final calendarService = ref.watch(calendarServiceProvider);
  if (calendarService == null) return const [];
  final date = ref.watch(selectedDayProvider).toDate();
  return calendarService.fetchForDate(date);
});
