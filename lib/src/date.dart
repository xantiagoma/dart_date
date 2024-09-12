import 'package:intl/intl.dart';

import 'dart_date.dart' as dart_date;
import 'dart_date.dart';

/// A class that stores and manages day, month and year.
class Date implements Comparable<Date> {
  /// Creates a [Date] object from day, month and year values. Performs validation.
  Date(int year, [int month = 1, int day = 1])
      : _date = DateTime.utc(year, month, day);

  /// Converts a [DateTime] to a [Date].
  factory Date.fromDateTime(DateTime dateTime) =>
      Date(dateTime.year, dateTime.month, dateTime.day);

  /// Parses a date string and returns a [Date]
  factory Date.fromJson(String json) => Date.parse(json);

  /// Create a [Date] object from the current date
  factory Date.now() => DateTime.now().toDate;

  /// Create a [Date] object from a Unix timestamp
  factory Date.unix(int seconds) =>
      DateTimeExtension.unix(seconds * 1000).toDate;

  /// Parses a date string and returns a [Date]
  factory Date.parse(String date) => DateTime.parse(date).toDate;

  /// Tries to parse a date string and returns a [Date] if successful, otherwise returns null.
  static Date? tryParse(String date) => DateTime.tryParse(date)?.toDate;

  static Date epoch = dart_date.epoch.toDate;

  final DateTime _date;

  /// Tomorrow
  static Date get tomorrow => DateTimeExtension.tomorrow.toDate;

  /// Yesterday
  static Date get yesterday => DateTimeExtension.yesterday.toDate;

  /// Current date (Same as [Date.now])
  static Date get today => Date.now();

  /// Returns this date as a UTC [DateTime]
  DateTime get toDateTimeUtc => _date;

  /// Returns this date as a local [DateTime]
  DateTime get toDateTimeLocal => DateTime(year, month, day);

  /// Subtract a number of days from this date
  Date subDays(int days) => _date.addDays(days).toDate;

  /// Subtract a number of months from this date
  Date subMonths(int months) => _date.addMonths(months).toDate;

  /// Subtract a number of years from this date
  Date subYears(int years) => _date.addYears(years).toDate;

  /// Add a number of days to this date
  Date addDays(int days) => _date.addDays(days).toDate;

  /// Add a number of months to this date
  Date addMonths(int months) => _date.addMonths(months).toDate;

  /// Add a number of years to this date
  Date addYears(int years) => _date.addYears(years).toDate;

  /// Return the end of month for this date
  Date get startOfMonth => _date.startOfMonth.toDate;

  /// Return the end of month for this date
  Date get endOfMonth => _date.endOfMonth.toDate;

  /// Return the start of ISO week for this date
  Date get startOfISOWeek => _date.startOfISOWeek.toDate;

  /// Return the end of ISO week for this date
  Date get endOfISOWeek => _date.endOfISOWeek.toDate;

  @override
  bool operator ==(Object other) => other is Date && _date == other._date;

  @override
  int compareTo(Date other) => _date.compareTo(other._date);

  @override
  int get hashCode => 31 * runtimeType.hashCode ^ _date.hashCode;

  /// Returns true if this date is after [other]
  bool operator >(Date other) => _date > other._date;

  /// Returns true if this date is before [other]
  bool operator <(Date other) => _date < other._date;

  /// Returns true if this date is after or equal to [other]
  bool operator >=(Date other) => _date >= other._date;

  /// Returns true if this date is before or equal to [other]
  bool operator <=(Date other) => _date <= other._date;

  /// Returns true if this date is before [other]
  bool isBefore(Date other) => this < other;

  /// Returns true if this date is after [other]
  bool isAfter(Date other) => this > other;

  /// Returns true if this date is the same day as [other]
  bool isSameDay(Date other) => isSameMonth(other) && other.day == day;

  /// Returns true if this date is the same month as [other]
  bool isSameMonth(Date other) => isSameYear(other) && month == other.month;

  /// Returns true if this date is the same year as [other]
  bool isSameYear(Date other) => year == other.year;

  /// Returns the difference between this date and another date.
  Duration difference(Date other) => _date.difference(other._date);

  /// Subtract a [Duration] from this date
  Date subtract(Duration duration) => add(Duration.zero - duration);

  /// Add a [Duration] to this date
  Date add(Duration duration) => _date.add(duration).toDate;

  /// Returns the year of this date
  int get year => _date.year;

  /// Returns the month of this date
  int get month => _date.month;

  /// Returns the day of this date
  int get day => _date.day;

  /// Returns the weekday of this date
  int get week => _date.getWeek;

  /// Returns the ISO week of this date
  int get isoWeek => _date.getISOWeek;

  /// Returns a copy of this date with any combination of year, month and day replaced.
  Date copyWith({int? year, int? month, int? day}) =>
      Date(year ?? _date.year, month ?? _date.month, day ?? _date.day);

  /// Returns a String representation of this object suitable for JSON encoding.
  String toJson() => _date.toIso8601String();

  static final _formatter = DateFormat('yyyy-MM-dd');
  String toIso8601String() => _formatter.format(_date);

  @override
  String toString() => toIso8601String();

  /// Returns a string representing this [Date], formatted according to [format]
  String format(DateFormat format) => format.format(_date);
}

extension DateTimeDateExtension on DateTime {
  /// Returns a [Date] object from this [DateTime]
  Date get toDate => Date.fromDateTime(this);

  /// Sets the year, month and day of this [DateTime] according to [date]
  DateTime setDate(Date date) => setYear(date.year, date.month, date.day);
}

extension DateFormatExtension on DateFormat {
  /// Returns a formatted string representing [date]
  String formatDate(Date date) => format(date._date);
}
