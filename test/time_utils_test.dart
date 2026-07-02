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

  group('weekdayMaskIncludes', () {
    test('all-days mask includes every weekday', () {
      for (var i = 1; i <= 7; i++) {
        final date = DateTime(2026, 7, 5 + i); // 2026-07-06 is a Monday
        expect(weekdayMaskIncludes(kAllWeekdaysMask, date), isTrue);
      }
    });

    test('mask with only Monday excludes Tuesday', () {
      final monday = DateTime(2026, 7, 6);
      final tuesday = DateTime(2026, 7, 7);
      final mondayOnly = weekdayBit(DateTime.monday);
      expect(weekdayMaskIncludes(mondayOnly, monday), isTrue);
      expect(weekdayMaskIncludes(mondayOnly, tuesday), isFalse);
    });
  });

  group('isSameDate', () {
    test('same calendar day, different time', () {
      expect(
        isSameDate(DateTime(2026, 7, 2, 8), DateTime(2026, 7, 2, 23, 59)),
        isTrue,
      );
    });

    test('different calendar day', () {
      expect(isSameDate(DateTime(2026, 7, 2), DateTime(2026, 7, 3)), isFalse);
    });
  });
}
