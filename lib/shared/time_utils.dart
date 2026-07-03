import 'dart:math';

/// Converts minutes-since-midnight (0-1439) into an angle in radians, with
/// 0 (midnight) at the top of the dial and increasing clockwise.
double minutesToAngle(int minutes) {
  final fraction = (minutes % 1440) / 1440;
  return -pi / 2 + fraction * 2 * pi;
}

/// Sweep (in minutes) from [startMinutes] to [endMinutes], wrapping past
/// midnight when the task ends before it starts (e.g. an overnight task).
int sweepMinutes(int startMinutes, int endMinutes) {
  return ((endMinutes - startMinutes) % 1440 + 1440) % 1440;
}

/// A weekly recurrence bitmask with every day (Mon-Sun) set.
const int kAllWeekdaysMask = 127;

/// The bit for [weekday] (`DateTime.weekday`: 1=Mon..7=Sun) in a recurrence
/// bitmask.
int weekdayBit(int weekday) => 1 << (weekday - 1);

/// RFC 5545 `BYDAY` day codes, in bitmask order (index 0 = Mon .. 6 = Sun).
const List<String> _byDayCodes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

/// Builds a weekly Google Calendar RRULE string from a weekday bitmask
/// (bit0=Mon..bit6=Sun), e.g. `RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR`.
String rruleForWeekdaysMask(int weekdaysMask) {
  final days = [
    for (var i = 0; i < 7; i++)
      if ((weekdaysMask & (1 << i)) != 0) _byDayCodes[i],
  ];
  return 'RRULE:FREQ=WEEKLY;BYDAY=${days.join(',')}';
}

/// Parses a weekday bitmask back out of a recurring event's RRULE strings
/// (as returned by the Calendar API), defaulting to every day if absent or
/// unparseable.
int weekdaysMaskFromRecurrence(List<String>? recurrenceRules) {
  final rrule = recurrenceRules?.firstWhere(
    (r) => r.startsWith('RRULE:'),
    orElse: () => '',
  );
  if (rrule == null || rrule.isEmpty) return kAllWeekdaysMask;
  final byDayMatch = RegExp('BYDAY=([A-Z,]+)').firstMatch(rrule);
  if (byDayMatch == null) return kAllWeekdaysMask;
  var mask = 0;
  for (final code in byDayMatch.group(1)!.split(',')) {
    final index = _byDayCodes.indexOf(code);
    if (index != -1) mask |= 1 << index;
  }
  return mask == 0 ? kAllWeekdaysMask : mask;
}
