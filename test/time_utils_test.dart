import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:k24_planner/shared/time_utils.dart';

void main() {
  group('minutesToAngle', () {
    test('midnight points to the top (-pi/2)', () {
      expect(minutesToAngle(0), closeTo(-pi / 2, 1e-9));
    });

    test('noon points to the bottom (pi/2)', () {
      expect(minutesToAngle(12 * 60), closeTo(pi / 2, 1e-9));
    });

    test('wraps minutes >= 1440', () {
      expect(minutesToAngle(1440), closeTo(minutesToAngle(0), 1e-9));
    });
  });

  group('sweepMinutes', () {
    test('same-day range', () {
      expect(sweepMinutes(9 * 60, 17 * 60), 8 * 60);
    });

    test('overnight range wraps past midnight', () {
      expect(sweepMinutes(23 * 60, 7 * 60), 8 * 60);
    });

    test('zero-length range', () {
      expect(sweepMinutes(8 * 60, 8 * 60), 0);
    });
  });

  group('rruleForWeekdaysMask', () {
    test('all-days mask lists every BYDAY code', () {
      expect(
        rruleForWeekdaysMask(kAllWeekdaysMask),
        'RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU',
      );
    });

    test('single weekday mask', () {
      expect(
        rruleForWeekdaysMask(weekdayBit(DateTime.monday)),
        'RRULE:FREQ=WEEKLY;BYDAY=MO',
      );
    });
  });

  group('weekdaysMaskFromRecurrence', () {
    test('round-trips through rruleForWeekdaysMask', () {
      final mask = weekdayBit(DateTime.monday) | weekdayBit(DateTime.friday);
      final rrule = rruleForWeekdaysMask(mask);
      expect(weekdaysMaskFromRecurrence([rrule]), mask);
    });

    test('defaults to every day when null or unparseable', () {
      expect(weekdaysMaskFromRecurrence(null), kAllWeekdaysMask);
      expect(weekdaysMaskFromRecurrence(['RDATE:20260101']), kAllWeekdaysMask);
    });
  });
}
