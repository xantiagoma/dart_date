import 'package:dart_date/dart_date.dart';
import 'package:test/test.dart';

void main() {
  group('Getters', () {
    test('timestamp', () {
      expect(Date.unix(0).timestamp, 0);
      expect(Date.parse('1996-03-29T11:11:11.011Z').timestamp, 828097871011);
    });

    test('isFirstDayOfMonth', () {
      expect(DateTime(2011, 2, 1, 11).isFirstDayOfMonth, true);
      expect(
          Date.parse('November 01 2018, 9:14:29 PM',
                  pattern: 'MMMM dd y, h:mm:ss a')
              .isFirstDayOfMonth,
          true);
      expect(
          Date.parse('November 30 2011, 0:14:29 PM',
                  pattern: 'MMMM dd y, h:mm:ss a')
              .isFirstDayOfMonth,
          false);
    });

    test('isLastDayOfMonth', () {
      expect(DateTime(2011, 2, 1, 11).isLastDayOfMonth, false);
      expect(
          Date.parse('November 01 2018, 9:14:29 PM',
                  pattern: 'MMMM dd y, h:mm:ss a')
              .isLastDayOfMonth,
          false);
      expect(
          Date.parse('November 30 2011, 0:14:29 PM',
                  pattern: 'MMMM dd y, h:mm:ss a')
              .isLastDayOfMonth,
          true);
    });

    test('isLeapYear', () {
      expect(DateTime(2011, 2, 1, 11).isLeapYear, false);
      expect(Date.parse('September 12 2012', pattern: 'MMMM dd y').isLeapYear,
          true);
    });
  });
}
