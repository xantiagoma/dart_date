import 'package:dart_date/dart_date.dart';
import 'package:test/test.dart';

void main() {
  group('First', () {
    test('Second', () {
      Date d = Date.today;
      expect(d, d.add(Duration(days: 0)));
    });
  });
}