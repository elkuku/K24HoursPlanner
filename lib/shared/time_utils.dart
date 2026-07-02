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

/// Whether a weekly recurrence bitmask (bit0=Mon..bit6=Sun) includes the
/// weekday of [date].
bool weekdayMaskIncludes(int weekdaysMask, DateTime date) {
  return (weekdaysMask & weekdayBit(date.weekday)) != 0;
}

/// Whether [a] and [b] fall on the same calendar day.
bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
