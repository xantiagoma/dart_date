import 'package:dart_date/dart_date.dart';
import 'package:test/test.dart';

void main() {
  group('Interval', () {
    group("constructors", () {
      test('default constructor', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        expect(interval.start, DateTime(2022));
        expect(interval.end, DateTime(2024));
      });
      test('from start', () {
        final interval =
            Interval.fromStart(DateTime(2022), Duration(days: 365));
        expect(interval.start, DateTime(2022));
        expect(interval.end, DateTime(2023));
      });
      test('from end', () {
        final interval = Interval.fromEnd(DateTime(2022), Duration(days: 365));
        expect(interval.start, DateTime(2021));
        expect(interval.end, DateTime(2022));
      });
      test('from middle', () {
        final interval =
            Interval.fromMiddle(DateTime(2022), Duration(days: 365));
        expect(interval.start, DateTime(2021, 7, 2, 12));
        expect(interval.end, DateTime(2022, 7, 2, 12));
      });

      test('from start and negative duration', () {
        final interval =
            Interval.fromStart(DateTime(2022), Duration(days: -365));
        expect(interval.start, DateTime(2021));
        expect(interval.end, DateTime(2022));
      });
      test('from end and negative duration', () {
        final interval = Interval.fromEnd(DateTime(2022), Duration(days: -365));
        expect(interval.start, DateTime(2022));
        expect(interval.end, DateTime(2023));
      });
      test('from middle and negative duration', () {
        final interval =
            Interval.fromMiddle(DateTime(2022), Duration(days: -365));
        expect(interval.start, DateTime(2021, 7, 2, 12));
        expect(interval.end, DateTime(2022, 7, 2, 12));
      });
    });

    group("start", () {
      test('first before second', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        expect(interval.start, DateTime(2022));
      });
      test('second before first', () {
        final interval = Interval(DateTime(2023), DateTime(2025));
        expect(interval.start, DateTime(2023));
      });

      test("first and second is same day", () {
        final interval = Interval(DateTime(2022), DateTime(2022));
        expect(interval.start, DateTime(2022));
        expect(interval.end, DateTime(2022));
        expect(interval.duration, Duration.zero);
      });
    });

    group("end", () {
      test('first before second', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        expect(interval.end, DateTime(2024));
      });
      test('second before first', () {
        final interval = Interval(DateTime(2023), DateTime(2025));
        expect(interval.end, DateTime(2025));
      });

      test("first and second is same day", () {
        final interval = Interval(DateTime(2022), DateTime(2022));
        expect(interval.start, DateTime(2022));
        expect(interval.end, DateTime(2022));
        expect(interval.duration, Duration.zero);
      });
    });

    group("duration", () {
      test('first before second', () {
        final interval = Interval(DateTime(2022), DateTime(2023));
        expect(interval.duration, Duration(days: 365));
      });
      test('second before first', () {
        final interval = Interval(DateTime(2023), DateTime(2022));
        expect(interval.duration, Duration(days: 365));
      });
    });

    group("setStart", () {
      test('new start is before old start', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setStart(DateTime(2023));
        expect(newInterval.start, DateTime(2023));
        expect(newInterval.end, DateTime(2024));
      });

      test('new start is after old start', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setStart(DateTime(2021));
        expect(newInterval.start, DateTime(2021));
        expect(newInterval.end, DateTime(2024));
      });

      test('new start is same as old start', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setStart(DateTime(2022));
        expect(newInterval.start, DateTime(2022));
        expect(newInterval.end, DateTime(2024));
      });

      test('new start is same as old end', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setStart(DateTime(2024));
        expect(newInterval.start, DateTime(2024));
        expect(newInterval.end, DateTime(2024));
      });

      test('new start if after old end', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setStart(DateTime(2025));
        expect(newInterval.start, DateTime(2024));
        expect(newInterval.end, DateTime(2025));
      });
    });

    group("setEnd", () {
      test('new end is after old end', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setEnd(DateTime(2025));
        expect(newInterval.start, DateTime(2022));
        expect(newInterval.end, DateTime(2025));
      });

      test('new end is before old end', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setEnd(DateTime(2023));
        expect(newInterval.start, DateTime(2022));
        expect(newInterval.end, DateTime(2023));
      });

      test('new end is same as old end', () {
        final interval = Interval(DateTime(2022), DateTime(2025));
        final newInterval = interval.setEnd(DateTime(2025));
        expect(newInterval.start, DateTime(2022));
        expect(newInterval.end, DateTime(2025));
      });

      test('new end is before old start', () {
        final interval = Interval(DateTime(2022), DateTime(2024));
        final newInterval = interval.setEnd(DateTime(2021));
        expect(newInterval.start, DateTime(2021));
        expect(newInterval.end, DateTime(2022));
      });
    });

    group("intersection", () {
      test('first before second', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2024));
        final secondInterval = Interval(DateTime(2023), DateTime(2025));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2023), DateTime(2024)));
      });
      test('second before first', () {
        final firstInterval = Interval(DateTime(2023), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2024));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2023), DateTime(2024)));
      });
      test('start is equal', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2024));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2022), DateTime(2024)));
      });
      test('end is equal', () {
        final firstInterval = Interval(DateTime(2023), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2023), DateTime(2025)));
      });

      test("return null if the intervals don't cross", () {
        final firstInterval = Interval(DateTime(2023), DateTime(2025));
        final secondInterval = Interval(DateTime(2026), DateTime(2027));

        expect(
          firstInterval.intersection(secondInterval),
          null,
        );
      });

      test('first is inside second', () {
        final firstInterval = Interval(DateTime(2023), DateTime(2024));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2023), DateTime(2024)));
      });

      test('second is inside first', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2023), DateTime(2024));

        expect(firstInterval.intersection(secondInterval),
            Interval(DateTime(2023), DateTime(2024)));
      });
    });
    group("symmetricDifference", () {
      test('first is inside second', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2023), DateTime(2024));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [
          Interval(DateTime(2022), DateTime(2023)),
          Interval(DateTime(2024), DateTime(2025))
        ]);
      });

      test('second is inside first', () {
        final firstInterval = Interval(DateTime(2023), DateTime(2024));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [
          Interval(DateTime(2022), DateTime(2023)),
          Interval(DateTime(2024), DateTime(2025))
        ]);
      });

      test('first and second starts same day, second ends before first', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2024));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [Interval(DateTime(2024), DateTime(2025))]);
      });

      test('first and second starts same day, second ends after first', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2024));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [Interval(DateTime(2024), DateTime(2025))]);
      });

      test('first and second ends same day, second starts before first', () {
        final firstInterval = Interval(DateTime(2024), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [Interval(DateTime(2022), DateTime(2024))]);
      });

      test('first and second ends same day, second starts after first', () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2023), DateTime(2025));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [Interval(DateTime(2022), DateTime(2023))]);
      });

      test("first and second are equal", () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2022), DateTime(2025));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, []);
      });

      test("first and second are equal, but one is reversed", () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2025), DateTime(2022));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, []);
      });

      test("date don't overlap", () {
        final firstInterval = Interval(DateTime(2022), DateTime(2025));
        final secondInterval = Interval(DateTime(2026), DateTime(2027));

        final symmetricDifference =
            firstInterval.symmetricDifference(secondInterval);

        expect(symmetricDifference, [
          Interval(DateTime(2022), DateTime(2025)),
          Interval(DateTime(2026), DateTime(2027))
        ]);
      });

      /////
    });
  });
}
