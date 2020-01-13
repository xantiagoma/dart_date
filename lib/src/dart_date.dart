import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago_lib;

class Interval {
  DateTime _start;
  Duration _duration;

  Interval(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      throw RangeError("Invalid Range");
    }
    _start = start;
    _duration = end.difference(start);
  }

  Duration get duration {
    return this._duration;
  }

  DateTime get start {
    return this._start;
  }

  DateTime get end {
    return this._start.add(this._duration);
  }

  bool includes(DateTime date) {
    return ((date.isAfter(this.start) || date.isAtSameMomentAs(this.start)) &&
        (date.isBefore(this.end) || date.isAtSameMomentAs(this.end)));
  }

  bool contains(Interval interval) {
    return (this.includes(interval.start) && this.includes(interval.end));
  }

  bool cross(Interval other) {
    return (this.includes(other.start) || this.includes(other.end));
  }

  bool equals(Interval other) {
    return (this.start.isAtSameMomentAs(other.start) &&
        this.end.isAtSameMomentAs(other.end));
  }

  Interval union(Interval other) {
    if (this.cross(other)) {
      if (this.end.isAfter(other.start) ||
          this.end.isAtSameMomentAs(other.start)) {
        return Interval(this.start, other.end);
      } else if (other.end.isAfter(this.start) ||
          other.end.isAtSameMomentAs(this.start)) {
        return Interval(other.start, this.end);
      } else {
        throw RangeError("Error this: $this; other: $other");
      }
    } else {
      throw RangeError("Intervals don't cross");
    }
  }

  Interval intersection(Interval other) {
    if (this.cross(other)) {
      if (this.end.isAfter(other.start) ||
          this.end.isAtSameMomentAs(other.start)) {
        return Interval(other.start, this.end);
      } else if (other.end.isAfter(this.start) ||
          other.end.isAtSameMomentAs(this.start)) {
        return Interval(other.start, this.end);
      } else {
        throw RangeError("Error this: $this; other: $other");
      }
    } else {
      throw RangeError("Intervals don't cross");
    }
  }

  Interval difference(Interval other) {
    if (other == this) {
      return null;
    } else if (this <= other) {
      // | this | | other |
      if (this.end.isBefore(other.start)) {
        return this;
      } else {
        return Interval(this.start, other.start);
      }
    } else if (this >= other) {
      // | other | | this |
      if (other.end.isBefore(this.start)) {
        return this;
      } else {
        return Interval(other.end, this.end);
      }
    } else {
      throw RangeError("Error this: $this; other: $other");
    }
  }

  List<Interval> symetricDiffetence(Interval other) {
    List<Interval> list = [null, null];
    try {
      Interval left = this.difference(other);
      list[0] = left;
    } catch (e) {
      list[0] = null;
    }
    try {
      Interval right = other.difference(this);
      list[1] = right;
    } catch (e) {
      list[1] = null;
    }
    return list;
  }

  // Operators
  bool operator <(Interval other) => (this.start.isBefore(other.start));

  bool operator <=(Interval other) => (this.start.isBefore(other.start) ||
      this.start.isAtSameMomentAs(other.start));

  bool operator >(Interval other) => (this.end.isAfter(other.end));

  bool operator >=(Interval other) =>
      (this.end.isAfter(other.end) || this.end.isAtSameMomentAs(other.end));

  String toString() {
    return "<${this.start} | ${this.end} | ${this.duration} >";
  }
}

extension Date on DateTime {
  /// Number of seconds since epoch time / A.K.A Unix timestamp
  ///
  /// The Unix epoch (or Unix time or POSIX time or Unix timestamp) is the number of
  /// seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting
  /// leap seconds (in ISO 8601: 1970-01-01T00:00:00Z).
  /// Literally speaking the epoch is Unix time 0 (midnight 1/1/1970).
  static DateTime fromSecondsSinceEpoch(
    int secondsSinceEpoch, {
    bool isUtc: false,
  }) =>
      DateTime.fromMillisecondsSinceEpoch(
        secondsSinceEpoch * 1000,
        isUtc: isUtc,
      );

  /// Transforms a date that follows a pattern from a [String] representation to a [DateTime] object
  static DateTime parse(
    String dateString, {
    String pattern = null,
    String locale = "en_US",
    bool isUTC = false,
  }) {
    initializeDateFormatting();
    DateTime date = pattern == null
        ? DateTime.parse(dateString)
        : DateFormat(pattern, locale).parse(dateString, isUTC);
    return date;
  }

  /// Create a [Date] object from a Unix timestamp
  static DateTime unix(int seconds) {
    return fromSecondsSinceEpoch(seconds);
  }

  /// Tomorrow at same hour / minute / second than now
  static DateTime get tomorrow {
    return DateTime.now().nextDay;
  }

  /// Yesterday at same hour / minute / second than now
  static DateTime get yesterday {
    return DateTime.now().previousDay;
  }

  /// Current date (Same as [Date.now])
  static DateTime get today {
    return DateTime.now();
  }

  /// Get [Date] object as UTC of current object.
  DateTime get toUTC {
    return this.toUtc();
  }

  /// Get [Date] object in LocalTime of current object.
  DateTime get toLocalTime {
    return this.toLocal();
  }

  // /// Add a [Duration] to this date
  // DateTime add(Duration duration) {
  //   return this.add(duration);
  // }

  /// Substract a [Duration] to this date
  DateTime subtract(Duration duration) {
    return this.add(Duration.zero - duration);
  }

  /// Get the difference between this data and other date as a [Duration]
  Duration diff(DateTime other) {
    return this.difference(other);
  }

  /// Add a certain amount of days to this date
  DateTime addDays(int amount) {
    return this.add(Duration(days: amount));
  }

  /// Add a certain amount of hours to this date
  DateTime addHours(int amount) {
    return this.add(Duration(hours: amount));
  }

  // TODO: this
  // Date addISOYears(int amount) {
  //   return this;
  // }

  /// Add a certain amount of milliseconds to this date
  DateTime addMilliseconds(int amount) {
    return this.add(Duration(milliseconds: amount));
  }

  /// Add a certain amount of microseconds to this date
  DateTime addMicroseconds(int amount) {
    return this.add(Duration(microseconds: amount));
  }

  /// Add a certain amount of minutes to this date
  DateTime addMinutes(int amount) {
    return this.add(Duration(minutes: amount));
  }

  /// Add a certain amount of months to this date
  DateTime addMonths(int amount) {
    return this.setMonth(this.month + amount);
  }

  /// Add a certain amount of quarters to this date
  DateTime addQuarters(int amount) {
    return this.addMonths(amount * 3);
  }

  /// Add a certain amount of seconds to this date
  DateTime addSeconds(int amount) {
    return this.add(Duration(seconds: amount));
  }

  /// Add a certain amount of weeks to this date
  DateTime addWeeks(int amount) {
    return this.addDays(amount * 7);
  }

  /// Add a certain amount of years to this date
  DateTime addYears(int amount) {
    return this.setYear(this.year + amount);
  }

  /// Know if two ranges of dates overlaps
  static bool areRangesOverlapping(
    DateTime initialRangeStartDate,
    DateTime initialRangeEndDate,
    DateTime comparedRangeStartDate,
    DateTime comparedRangeEndDate,
  ) {
    if (initialRangeStartDate.isAfter(initialRangeEndDate)) {
      throw RangeError("Not valid initial range");
    }

    if (comparedRangeStartDate.isAfter(comparedRangeEndDate)) {
      throw RangeError("Not valid compareRange range");
    }

    Interval initial = Interval(initialRangeStartDate, initialRangeEndDate);
    Interval compared = Interval(comparedRangeStartDate, comparedRangeEndDate);

    return initial.cross(compared) || compared.cross(initial);
  }

  /// Get index of the closest day to current one, returns null if empty [Iterable] is passed as argument
  int closestIndexTo(Iterable<DateTime> datesArray) {
    var differences = datesArray.map((date) {
      return date.difference(this).abs();
    });

    if (datesArray.length == 0) {
      return null;
    }

    int index = 0;
    for (var i = 0; i < differences.length; i++) {
      if (differences.elementAt(i) < differences.elementAt(index)) {
        index = i;
      }
    }
    return index;
  }

  /// Get closest day to current one, returns null if empty [Iterable] is passed as argument
  DateTime closestTo(Iterable<DateTime> datesArray) {
    if (datesArray.length == 0) {
      return null;
    }
    return datesArray.elementAt(this.closestIndexTo(datesArray));
  }

  /**
   * Compares this Date object to [other],
   * returning zero if the values are equal.
   *
   * Returns a negative value if this Date [isBefore] [other]. It returns 0
   * if it [isAtSameMomentAs] [other], and returns a positive value otherwise
   * (when this [isAfter] [other]).
   */
  int compare(DateTime other) {
    return this.compareTo(other);
  }

  /// Returns true if left [isBefore] than right
  static DateTime min(DateTime left, DateTime right) {
    return (left < right) ? left : right;
  }

  /// Returns true if left [isAfter] than right
  static DateTime max(DateTime left, DateTime right) {
    return (left < right) ? right : left;
  }

  /// Compare the two dates and return 1 if the first date [isAfter] the second,
  /// -1 if the first date [isBefore] the second or 0 first date [isEqual] the second.
  static int compareAsc(DateTime dateLeft, DateTime dateRight) {
    if (dateLeft.isAfter(dateRight)) {
      return 1;
    } else if (dateLeft.isBefore(dateRight)) {
      return -1;
    } else {
      return 0;
    }
  }

  /// Compare the two dates and return -1 if the first date [isAfter] the second,
  /// 1 if the first date [isBefore] the second or 0 first date [isEqual] the second.
  static int compareDesc(DateTime dateLeft, DateTime dateRight) {
    return (-1) * compareAsc(dateLeft, dateRight);
  }

  // int differenceInCalendarDays(dateLeft, dateRight)
  // int differenceInCalendarISOWeeks(dateLeft, dateRight)
  // int differenceInCalendarISOYears(dateLeft, dateRight)
  // int differenceInCalendarMonths(dateLeft, dateRight)
  // int differenceInCalendarQuarters(dateLeft, dateRight)
  // int differenceInCalendarWeeks(dateLeft, dateRight, [options])
  // int differenceInCalendarYears(dateLeft, dateRight)
  // int differenceInISOYears(dateLeft, dateRight)

  /// Difference in microseconds between this date and other
  int differenceInMicroseconds(DateTime other) {
    return this.diff(other).inMicroseconds;
  }

  /// Difference in milliseconds between this date and other
  int differenceInMilliseconds(DateTime other) {
    return this.diff(other).inMilliseconds;
  }

  /// Difference in minutes between this date and other
  int differenceInMinutes(DateTime other) {
    return this.diff(other).inMinutes;
  }

  /// Difference in seconds between this date and other
  int differenceInSeconds(DateTime other) {
    return this.diff(other).inSeconds;
  }

  /// Difference in hours between this date and other
  int differenceInHours(DateTime other) {
    return this.diff(other).inHours;
  }

  /// Difference in days between this date and other
  int differenceInDays(DateTime other) {
    return this.diff(other).inDays;
  }

  // int differenceInMonths(dateLeft, dateRight)
  // int differenceInQuarters(dateLeft, dateRight)
  // int differenceInWeeks(dateLeft, dateRight)
  // int differenceInYears(dateLeft, dateRight)

  /// Formats provided [date] to a fuzzy time like 'a moment ago' (use timeago package to change locales)
  ///
  /// - If [locale] is passed will look for message for that locale, if you want
  ///   to add or override locales use [setLocaleMessages]. Defaults to 'en'
  /// - If [clock] is passed this will be the point of reference for calculating
  ///   the elapsed time. Defaults to DateTime.now()
  /// - If [allowFromNow] is passed, format will use the From prefix, ie. a date
  ///   5 minutes from now in 'en' locale will display as "5 minutes from now"
  /// If locales was not loaded previously en would be used use timeago.setLocaleMessages to set them
  String timeago({String locale, DateTime clock, bool allowFromNow}) {
    return timeago_lib.format(
      this,
      locale: locale,
      clock: clock,
      allowFromNow: allowFromNow,
    );
  }

  /// Return the array of dates within the specified range.
  Iterable<DateTime> eachDay(DateTime date) sync* {
    if (this.isSameDay(date)) {
      yield date.startOfDay;
    } else {
      Duration difference = this.diff(date);
      int days = difference.abs().inDays;
      DateTime current = date.startOfDay;
      if (difference.isNegative) {
        for (int i = 0; i < days; i++) {
          yield current;
          current = current.nextDay;
        }
      } else {
        for (int i = 0; i < days; i++) {
          yield current;
          current = current.nextDay;
        }
      }
    }
  }

  /// Return the end of a day for this date. The result will be in the local timezone.
  DateTime get endOfDay {
    return this.setHour(23, 59, 59, 999, 999);
  }

  /// Return the end of the hour for this date. The result will be in the local timezone.
  DateTime get endOfHour {
    return this.setMinute(59, 59, 999, 999);
  }

  /// Return the end of ISO week for this date. The result will be in the local timezone.
  DateTime get endOfISOWeek {
    return this.endOfWeek.nextDay;
  }

  // DateTime endOfISOYear()

  /// Return the end of the minute for this date. The result will be in the local timezone.
  DateTime get endOfMinute {
    return this.setSecond(59, 999, 999);
  }

  /// Return the end of the month for this date. The result will be in the local timezone.
  DateTime get endOfMonth {
    return DateTime(this.year, this.month + 1).subMicroseconds(1);
  }

  // Date endOfQuarter()

  /// Return the end of the second for this date. The result will be in the local timezone.
  DateTime get endOfSecond {
    return this.setMillisecond(999, 999);
  }

  /// Return the end of today. The result will be in the local timezone.
  static DateTime get endOfToday {
    return DateTime.now().endOfDay;
  }

  /// Return the end of tomorrow. The result will be in the local timezone.
  static DateTime get endOfTomorrow {
    return DateTime.now().nextDay.endOfDay;
  }

  /// Return the end of yesterday. The result will be in the local timezone.
  static DateTime get endOfYesterday {
    return DateTime.now().previousDay.endOfDay;
  }

  /// Return the end of the week for this date. The result will be in the local timezone.
  DateTime get endOfWeek {
    return this.nextWeek.startOfWeek.subMicroseconds(1);
  }

  /// Return the end of the year for this date. The result will be in the local timezone.
  DateTime get endOfYear {
    return this.setYear(this.year, DateTime.december).endOfMonth;
  }

  /// Get the day of the month of the given date.
  /// The day of the month 1..31.
  int get getDate {
    return this.day;
  }

  /// Get the day of the week of the given date.
  int get getDay {
    return this.weekday;
  }

  /// Days since year started. The result will be in the local timezone.
  int get getDayOfYear {
    return this.diff(this.startOfYear).inDays + 1;
  }

  /// Days since month started. The result will be in the local timezone.
  int get getDaysInMonth {
    return this.endOfMonth.diff(this.startOfMonth).inDays + 1;
  }

  /// Number of days in current year
  int get getDaysInYear {
    return this.endOfYear.diff(this.startOfYear).inDays + 1;
  }

  /// Get the hours of the given date.
  /// The hour of the day, expressed as in a 24-hour clock 0..23.
  int get getHours {
    return this.hour;
  }

  // int getISODay(date)
  // int getISOWeek(date)
  // int getISOWeeksInYear(date)
  // int getISOYear(date)

  /// Get the milliseconds of the given date.
  /// The millisecond 0...999.
  int get getMilliseconds {
    return this.millisecond;
  }

  /// Get the microseconds of the given date.
  /// The microsecond 0...999.
  int get getMicroseconds {
    return this.microsecond;
  }

  /// Get the milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int get getMillisecondsSinceEpoch {
    return this.millisecondsSinceEpoch;
  }

  /// Get the microseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int get getMicrosecondsSinceEpoch {
    return this.microsecondsSinceEpoch;
  }

  /// Get the minutes of the given date.
  /// The minute 0...59.
  int get getMinutes {
    return this.minute;
  }

  /// Get the month of the given date.
  /// The month 1..12.
  int get getMonth {
    return this.month;
  }

  // int getOverlappingDaysInRanges(initialRangeStartDate, initialRangeEndDate, comparedRangeStartDate, comparedRangeEndDate)
  // int getQuarter(date)

  /// Get the seconds of the given date.
  /// The second 0...59.
  int get getSeconds {
    return this.second;
  }

  /// get the numer of milliseconds since epoch
  int get timestamp {
    return this.millisecondsSinceEpoch;
  }

  /// get the numer of milliseconds since epoch
  int get getTime {
    return this.millisecondsSinceEpoch;
  }

  /// The year
  int get getYear {
    return this.year;
  }

  /// The time zone name.
  /// This value is provided by the operating system and may be an abbreviation or a full name.
  /// In the browser or on Unix-like systems commonly returns abbreviations, such as "CET" or "CEST".
  /// On Windows returns the full name, for example "Pacific Standard Time".
  String get getTimeZoneName {
    return this.timeZoneName;
  }

  /// The time zone offset, which is the difference between local time and UTC.
  /// The offset is positive for time zones east of UTC.
  /// Note, that JavaScript, Python and C return the difference between UTC and local time.
  /// Java, C# and Ruby return the difference between local time and UTC.
  Duration get getTimeZoneOffset {
    return this.timeZoneOffset;
  }

  /// The day of the week monday..sunday.
  /// In accordance with ISO 8601 a week starts with Monday, which has the value 1.
  int get getWeekday {
    return this.weekday;
  }

  /// Return true if other [isEqual] or [isAfter] to this date
  bool isSameOrAfter(DateTime other) {
    return (this == other || this.isAfter(other));
  }

  /// Return true if other [isEqual] or [isBefore] to this date
  bool isSameOrBefore(DateTime other) {
    return (this == other || this.isBefore(other));
  }

  /// Check if a Object if a [DateTime], use for validation purposes
  static bool isDate(argument) {
    return argument is DateTime;
  }

  /// Check if a date is [equals] to other
  bool isEqual(other) {
    return this.equals(other);
  }

  /// Return true if this date day is monday
  bool get isMonday {
    return this.day == DateTime.monday;
  }

  /// Return true if this date day is tuesday
  bool get isTuesday {
    return this.day == DateTime.tuesday;
  }

  /// Return true if this date day is wednesday
  bool get isWednesday {
    return this.day == DateTime.wednesday;
  }

  /// Return true if this date day is thursday
  bool get isThursday {
    return this.day == DateTime.thursday;
  }

  /// Return true if this date day is friday
  bool get isFriday {
    return this.day == DateTime.friday;
  }

  /// Return true if this date day is saturday
  bool get isSaturday {
    return this.day == DateTime.saturday;
  }

  /// Return true if this date day is sunday
  bool get isSunday {
    return this.day == DateTime.sunday;
  }

  /// Is the given date the first day of a month?
  bool get isFirstDayOfMonth {
    final firstDate = this.startOfMonth;
    return this.isSameDay(firstDate);
  }

  /// Return true if this date [isAfter] [Date.now]
  bool get isFuture {
    return this.isAfter(DateTime.now());
  }

  /// Is the given date the last day of a month?
  bool get isLastDayOfMonth {
    final lastDay = this.nextMonth.startOfMonth.subHours(12).startOfDay;
    return this.isSameDay(lastDay);
  }

  /// Is the given date in the leap year?
  bool get isLeapYear {
    final year = this.year;
    return ((year % 400 == 0) || (year % 4 == 0 && year % 100 != 0));
  }

  /// Return true if this date [isBefore] [Date.now]
  bool get isPast {
    return this.isBefore(DateTime.now());
  }

  /// Check if this date is in the same day than other
  bool isSameDay(DateTime other) {
    return this.startOfDay == other.startOfDay;
  }

  /// Check if this date is in the same hour than other
  bool isSameHour(DateTime other) {
    return this.startOfHour == other.startOfHour;
  }

  // bool isSameISOWeek(dateLeft, dateRight)
  // bool isSameISOYear(dateLeft, dateRight)

  /// Check if this date is in the same minute than other
  bool isSameMinute(DateTime other) {
    return this.startOfMinute == other.startOfMinute;
  }

  /// Check if this date is in the same month than other
  bool isSameMonth(DateTime other) {
    return this.startOfMonth == other.startOfMonth;
  }

  // bool isSameQuarter(dateLeft, dateRight)

  /// Check if this date is in the same second than other
  bool isSameSecond(DateTime other) {
    return this.secondsSinceEpoch == other.secondsSinceEpoch;
  }

  // bool isSameWeek(dateLeft, dateRight, [options])

  /// Check if this date is in the same year than other
  bool isSameYear(DateTime other) {
    return this.year == other.year;
  }

  /// Check if this date is in the same hour than [DateTime.now]
  bool get isThisHour {
    return this.startOfHour == today.startOfHour;
  }
  // bool isThisISOWeek()
  // bool isThisISOYear()

  /// Check if this date is in the same minute than [DateTime.now]
  bool get isThisMinute {
    return this.startOfMinute == today.startOfMinute;
  }

  /// Check if this date is in the same month than [DateTime.now]
  bool get isThisMonth {
    return this.isSameMonth(today);
  }

  // bool isThisQuarter()

  /// Check if this date is in the same second than [DateTime.now]
  bool get isThisSecond {
    return this.isSameSecond(today);
  }

  // bool isThisWeek(, [options])

  /// Check if this date is in the same year than [DateTime.now]
  bool get isThisYear {
    return this.isSameYear(today);
  }

  // bool isValid()

  /// Check if this date is in the same day than [DateTime.today]
  bool get isToday {
    return this.isSameDay(today);
  }

  /// Check if this date is in the same day than [DateTime.tomorrow]
  bool get isTomorrow {
    return this.isSameDay(tomorrow);
  }

  /// Check if this date is in the same day than [DateTime.yesterday]
  bool get isYesterday {
    return this.isSameDay(yesterday);
  }

  /// Return true if this [DateTime] is set as UTC.
  bool get isUTC {
    return this.isUtc;
  }

  /// Return true if this [DateTime] is a saturday or a sunday
  bool get isWeekend {
    return (this.day == DateTime.saturday || this.day == DateTime.sunday);
  }

  /// Checks if a [DateTime] is within a Rage (two dates that makes an [Interval])
  bool isWithinRange(DateTime startDate, DateTime endDate) {
    return Interval(startDate, endDate).includes(this);
  }

  /// Checks if a [DateTime] is within an [Interval]
  bool isWithinInterval(Interval interval) {
    return interval.includes(this);
  }

  // DateTime lastDayOfISOWeek(date)
  // DateTime lastDayOfISOYear(date)
  // DateTime lastDayOfMonth(date)
  // DateTime lastDayOfQuarter(date)
  // DateTime lastDayOfWeek(date, [options])
  // DateTime lastDayOfYear(date)
  // static DateTime max(Iterable<DateTime>)
  // static DateTime min(Iterable<DateTime>)
  // static DateTime parse(any)
  // DateTime setDate(date, dayOfMonth)
  // DateTime setDayOfYear(date, dayOfYear)
  // DateTime setISODay(date, day)
  // DateTime setISOWeek(date, isoWeek)
  // DateTime setISOYear(date, isoYear)

  /// Change [year] of this date
  ///
  /// set [month] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [day] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setYear(int year,
      [int month = null,
      int day = null,
      int hour = null,
      int minute = null,
      int second = null,
      int millisecond = null,
      int microsecond = null]) {
    return DateTime(
        year,
        month == null ? this.month : month,
        day == null ? this.day : day,
        hour == null ? this.hour : hour,
        minute == null ? this.minute : minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [month] of this date
  ///
  /// set [day] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setMonth(int month,
      [int day = null,
      int hour = null,
      int minute = null,
      int second = null,
      int millisecond = null,
      int microsecond = null]) {
    return DateTime(
        this.year,
        month,
        day == null ? this.day : day,
        hour == null ? this.hour : hour,
        minute == null ? this.minute : minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [day] of this date
  ///
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setDay(int day,
      [int hour = null,
      int minute = null,
      int second = null,
      int millisecond = null,
      int microsecond = null]) {
    return DateTime(
        this.year,
        this.month,
        day,
        hour == null ? this.hour : hour,
        minute == null ? this.minute : minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [hour] of this date
  ///
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setHour(int hour,
      [int minute = null,
      int second = null,
      int millisecond = null,
      int microsecond = null]) {
    return DateTime(
        this.year,
        this.month,
        this.day,
        hour,
        minute == null ? this.minute : minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [minute] of this date
  ///
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setMinute(int minute,
      [int second = null, int millisecond = null, int microsecond = null]) {
    return DateTime(
        this.year,
        this.month,
        this.day,
        this.hour,
        minute,
        second == null ? this.second : second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [second] of this date
  ///
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  DateTime setSecond(int second,
      [int millisecond = null, int microsecond = null]) {
    return DateTime(
        this.year,
        this.month,
        this.day,
        this.hour,
        this.minute,
        second,
        millisecond == null ? this.millisecond : millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [millisecond] of this date
  ///
  /// set [microsecond] if you want to change it as well
  DateTime setMillisecond(int millisecond, [int microsecond = null]) {
    return DateTime(
        this.year,
        this.month,
        this.day,
        this.hour,
        this.minute,
        this.second,
        millisecond,
        microsecond == null ? this.microsecond : microsecond);
  }

  /// Change [microsecond] of this date
  DateTime setMicrosecond(int microsecond) {
    return DateTime(this.year, this.month, this.day, this.hour, this.minute,
        this.second, this.millisecond, microsecond);
  }
  // DateTime setQuarter(quarter)

  /// Get a [DateTime] representing start of Day of this [DateTime] in local time.
  DateTime get startOfDay {
    return this.setHour(0, 0, 0, 0, 0);
  }

  /// Get a [DateTime] representing start of Hour of this [DateTime] in local time.
  DateTime get startOfHour {
    return this.setMinute(0, 0, 0, 0);
  }

  /// Get a [DateTime] representing start of week (ISO week) of this [DateTime] in local time.
  DateTime get startOfISOWeek {
    return this.startOfWeek.nextDay;
  }

  // DateTime startOfISOYear()
  /// Get a [DateTime] representing start of minute of this [DateTime] in local time.
  DateTime get startOfMinute {
    return this.setSecond(0, 0, 0);
  }

  /// Get a [DateTime] representing start of month of this [DateTime] in local time.
  DateTime get startOfMonth {
    return this.setDay(1, 0, 0, 0, 0, 0);
  }

  // DateTime startOfQuarter()
  /// Get a [DateTime] representing start of second of this [DateTime] in local time.
  DateTime get startOfSecond {
    return this.setMillisecond(0, 0);
  }

  /// Get a [DateTime] representing start of today of [DateTime.today] in local time.
  static DateTime get startOfToday {
    return today.startOfDay;
  }

  /// Get a [DateTime] representing start of week of this [DateTime] in local time.
  DateTime get startOfWeek {
    return this.subtract(Duration(days: this.weekday)).startOfDay;
  }

  /// Get a [DateTime] representing start of year of this [DateTime] in local time.
  DateTime get startOfYear {
    return this.setMonth(DateTime.january, 1, 0, 0, 0, 0, 0);
  }

  /// Subtracts a [Duration] from this [DateTime]
  DateTime sub(Duration duration) {
    return this.add(Duration.zero - duration);
  }

  /// Subtracts an amout of hours from this [DateTime]
  DateTime subHours(int amount) {
    return this.addHours(-amount);
  }

  /// Subtracts an amout of days from this [DateTime]
  DateTime subDays(int amount) {
    return this.addDays(-amount);
  }

  /// Subtracts an amout of milliseconds from this [DateTime]
  DateTime subMilliseconds(amount) {
    return this.addMilliseconds(-amount);
  }

  /// Subtracts an amout of microseconds from this [DateTime]
  DateTime subMicroseconds(amount) {
    return this.addMicroseconds(-amount);
  }

  // DateTime subISOYears(amount)
  /// Subtracts an amout of minutes from this [DateTime]
  DateTime subMinutes(amount) {
    return this.addMinutes(-amount);
  }

  /// Subtracts an amout of months from this [DateTime]
  /// Subtracts an amout of months from this [DateTime]
  DateTime subMonths(amount) {
    return this.addMonths(-amount);
  }

  // DateTime subQuarters(amount)
  /// Subtracts an amout of seconds from this [DateTime]
  DateTime subSeconds(amount) {
    return this.addSeconds(-amount);
  }

  // DateTime subWeeks(amount)
  /// Subtracts an amout of years from this [DateTime]
  DateTime subYears(amount) {
    return this.addYears(-amount);
  }

  // Check if two dates are [equals]
  bool equals(DateTime other) {
    return this.isAtSameMomentAs(other);
  }

  bool operator <(DateTime other) => this.isBefore(other);

  bool operator <=(DateTime other) =>
      (this.isBefore(other) || this.isAtSameMomentAs(other));

  bool operator >(DateTime other) => this.isAfter(other);

  bool operator >=(DateTime other) =>
      (this.isAfter(other) || this.isAtSameMomentAs(other));

  String toHumanString() {
    return this.format("E MMM d y H:m:s");
  }

  /// The day after
  /// The day after this [DateTime]
  DateTime get nextDay {
    return this.addDays(1);
  }

  /// The day previous this [DateTime]
  DateTime get previousDay {
    return this.addDays(-1);
  }

  /// The month after this [DateTime]
  DateTime get nextMonth {
    return this.setMonth(this.month + 1);
  }

  /// The month previous this [DateTime]
  DateTime get previousMonth {
    return this.setMonth(this.month - 1);
  }

  /// The year after this [DateTime]
  DateTime get nextYear {
    return this.setYear(this.year + 1);
  }

  /// The year previous this [DateTime]
  DateTime get previousYear {
    return this.setYear(this.year - 1);
  }

  /// The week after this [DateTime]
  DateTime get nextWeek {
    return this.addDays(7);
  }

  /// The week previous this [DateTime]
  DateTime get previousWeek {
    return this.subDays(7);
  }

  /// Number of seconds since epoch time
  ///
  /// The Unix epoch (or Unix time or POSIX time or Unix timestamp) is the number of
  /// seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting
  /// leap seconds (in ISO 8601: 1970-01-01T00:00:00Z).
  /// Literally speaking the epoch is Unix time 0 (midnight 1/1/1970).
  int get secondsSinceEpoch {
    return this.millisecondsSinceEpoch ~/ 1000;
  }

  /// Format this [DateTime] following the [String pattern]
  ///
  ///      ICU Name                   Skeleton
  ///      --------                   --------
  ///      DAY                          d
  ///      ABBR_WEEKDAY                 E
  ///      WEEKDAY                      EEEE
  ///      ABBR_STANDALONE_MONTH        LLL
  ///      STANDALONE_MONTH             LLLL
  ///      NUM_MONTH                    M
  ///      NUM_MONTH_DAY                Md
  ///      NUM_MONTH_WEEKDAY_DAY        MEd
  ///      ABBR_MONTH                   MMM
  ///      ABBR_MONTH_DAY               MMMd
  ///      ABBR_MONTH_WEEKDAY_DAY       MMMEd
  ///      MONTH                        MMMM
  ///      MONTH_DAY                    MMMMd
  ///      MONTH_WEEKDAY_DAY            MMMMEEEEd
  ///      ABBR_QUARTER                 QQQ
  ///      QUARTER                      QQQQ
  ///      YEAR                         y
  ///      YEAR_NUM_MONTH               yM
  ///      YEAR_NUM_MONTH_DAY           yMd
  ///      YEAR_NUM_MONTH_WEEKDAY_DAY   yMEd
  ///      YEAR_ABBR_MONTH              yMMM
  ///      YEAR_ABBR_MONTH_DAY          yMMMd
  ///      YEAR_ABBR_MONTH_WEEKDAY_DAY  yMMMEd
  ///      YEAR_MONTH                   yMMMM
  ///      YEAR_MONTH_DAY               yMMMMd
  ///      YEAR_MONTH_WEEKDAY_DAY       yMMMMEEEEd
  ///      YEAR_ABBR_QUARTER            yQQQ
  ///      YEAR_QUARTER                 yQQQQ
  ///      HOUR24                       H
  ///      HOUR24_MINUTE                Hm
  ///      HOUR24_MINUTE_SECOND         Hms
  ///      HOUR                         j
  ///      HOUR_MINUTE                  jm
  ///      HOUR_MINUTE_SECOND           jms
  ///      HOUR_MINUTE_GENERIC_TZ       jmv
  ///      HOUR_MINUTE_TZ               jmz
  ///      HOUR_GENERIC_TZ              jv
  ///      HOUR_TZ                      jz
  ///      MINUTE                       m
  ///      MINUTE_SECOND                ms
  ///      SECOND                       s
  /// Examples Using the US Locale:
  ///
  ///      Pattern                           Result
  ///      ----------------                  -------
  ///      new DateFormat.yMd()             -> 7/10/1996
  ///      new DateFormat("yMd")            -> 7/10/1996
  ///      new DateFormat.yMMMMd("en_US")   -> July 10, 1996
  ///      new DateFormat.jm()              -> 5:08 PM
  ///      new DateFormat.yMd().add_jm()    -> 7/10/1996 5:08 PM
  ///      new DateFormat.Hm()              -> 17:08 // force 24 hour time
  ///
  /// Explicit patterns
  ///
  ///     Symbol   Meaning                Presentation       Example
  ///     ------   -------                ------------       -------
  ///     G        era designator         (Text)             AD
  ///     y        year                   (Number)           1996
  ///     M        month in year          (Text & Number)    July & 07
  ///     L        standalone month       (Text & Number)    July & 07
  ///     d        day in month           (Number)           10
  ///     c        standalone day         (Number)           10
  ///     h        hour in am/pm (1~12)   (Number)           12
  ///     H        hour in day (0~23)     (Number)           0
  ///     m        minute in hour         (Number)           30
  ///     s        second in minute       (Number)           55
  ///     S        fractional second      (Number)           978
  ///     E        day of week            (Text)             Tuesday
  ///     D        day in year            (Number)           189
  ///     a        am/pm marker           (Text)             PM
  ///     k        hour in day (1~24)     (Number)           24
  ///     K        hour in am/pm (0~11)   (Number)           0
  ///     z        time zone              (Text)             Pacific Standard Time
  ///     Z        time zone (RFC 822)    (Number)           -0800
  ///     v        time zone (generic)    (Text)             Pacific Time
  ///     Q        quarter                (Text)             Q3
  ///     '        escape for text        (Delimiter)        'DateTime='
  ///     ''       single quote           (Literal)          'o''clock'
  ///
  /// Examples Using the US Locale:
  ///
  ///     Format Pattern                    Result
  ///     --------------                    -------
  ///     "yyyy.MM.dd G 'at' HH:mm:ss vvvv" 1996.07.10 AD at 15:08:56 Pacific Time
  ///     "EEE, MMM d, ''yy"                Wed, Jul 10, '96
  ///     "h:mm a"                          12:08 PM
  ///     "hh 'o''clock' a, zzzz"           12 o'clock PM, Pacific Daylight Time
  ///     "K:mm a, vvv"                     0:00 PM, PT
  ///     "yyyyy.MMMMM.dd GGG hh:mm aaa"    01996.July.10 AD 12:08 PM
  String format(String pattern, [String locale = "en_US"]) {
    initializeDateFormatting();
    return DateFormat(pattern, locale).format(this);
  }

  /// Get UTC [DateTime] from this [DateTime]
  DateTime get UTC {
    return DateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch,
        isUtc: true);
  }

  /// Get Local [DateTime] from this [DateTime]
  DateTime get Local {
    return DateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch,
        isUtc: false);
  }
}
