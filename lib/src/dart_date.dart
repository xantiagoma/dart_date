import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago_lib;

class Interval {
  Date _start;
  Duration _duration;

  Interval(Date start, Date end) {
    if(start.isAfter(end)) {
      throw RangeError("Invalid Range");
    }
    _start = start;
    _duration = end.difference(start);
  }

  Duration get duration {
    return this._duration;
  }

  Date get start {
    return this._start;
  }

  Date get end {
    return this._start.add(this._duration);
  }

  bool includes(Date date) {
    return (
      (date.isAfter(this.start) || date.isAtSameMomentAs(this.start)) &&
      (date.isBefore(this.end) || date.isAtSameMomentAs(this.end))
    );
  }

  bool contains(Interval interval) {
    return (this.includes(interval.start) && this.includes(interval.end));
  }

  bool cross(Interval other) {
    return ( this.includes(other.start) || this.includes(other.end) );
  }

  bool equals(Interval other) {
    return ( this.start.isAtSameMomentAs(other.start) && this.end.isAtSameMomentAs(other.end) );
  }

  Interval union(Interval other) {
    if(this.cross(other)) {
      if(
        this.end.isAfter(other.start) ||
        this.end.isAtSameMomentAs(other.start)
      ) {
        return Interval(this.start, other.end);
      } else if (
        other.end.isAfter(this.start) ||
        other.end.isAtSameMomentAs(this.start)
      ) {
        return Interval(other.start, this.end);
      } else {
        throw RangeError("Error this: $this; other: $other");
      }
    } else {
      throw RangeError("Intervals don't cross");
    }
  }
  
  Interval intersection(Interval other) {
    if(this.cross(other)) {
      if(this.end.isAfter(other.start) || this.end.isAtSameMomentAs(other.start)) {
        return Interval(other.start, this.end);
      } else if (other.end.isAfter(this.start) || other.end.isAtSameMomentAs(this.start)) {
        return Interval(other.start, this.end);
      } else {
        throw RangeError("Error this: $this; other: $other");
      }
    }
    else {
      throw RangeError("Intervals don't cross");
    }
  }

  Interval difference(Interval other) {
    if(other == this) {
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
  bool operator <(Interval other) => ( this.start.isBefore(other.start) );

  bool operator <=(Interval other) => ( this.start.isBefore(other.start) || this.start.isAtSameMomentAs(other.start) );
  
  bool operator >(Interval other) => ( this.end.isAfter(other.end) );
  
  bool operator >=(Interval other) => ( this.end.isAfter(other.end) || this.end.isAtSameMomentAs(other.end) );

  String toString() {
    return "<${this.start} | ${this.end} | ${this.duration} >";
  }

}

class Date extends DateTime {

  /// Default constructor
  Date(int year,
    [
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0
    ]
  ) : super(year, month, day, hour, minute, second, millisecond, microsecond);

  /// Number of microseconds since epoch time
  /// 
  /// The Unix epoch (or Unix time or POSIX time or Unix timestamp) is the number of
  /// seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting
  /// leap seconds (in ISO 8601: 1970-01-01T00:00:00Z).
  /// Literally speaking the epoch is Unix time 0 (midnight 1/1/1970).
  Date.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch,
      {bool isUtc: false}) : super.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: isUtc);

  /// Number of milliseconds since epoch time
  /// 
  /// The Unix epoch (or Unix time or POSIX time or Unix timestamp) is the number of
  /// seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting
  /// leap seconds (in ISO 8601: 1970-01-01T00:00:00Z).
  /// Literally speaking the epoch is Unix time 0 (midnight 1/1/1970).
  Date.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch,
      {bool isUtc: false}) : super.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc: isUtc);

  /// Number of seconds since epoch time / A.K.A Unix timestamp
  /// 
  /// The Unix epoch (or Unix time or POSIX time or Unix timestamp) is the number of
  /// seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting
  /// leap seconds (in ISO 8601: 1970-01-01T00:00:00Z).
  /// Literally speaking the epoch is Unix time 0 (midnight 1/1/1970).
  Date.fromSecondsSinceEpoch(int secondsSinceEpoch,
      {bool isUtc: false}) : super.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000, isUtc: isUtc);
  
  /// Create a date from current moment
  Date.now(): super.now();

  /// Creates a date using as reference UTC (GMT) time instead of local one
  Date.utc(int year,
    [
      int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0
    ]
  ) : super.utc(year, month, day, hour, minute, second, millisecond, microsecond);

  /// Transforms a date from base class [DateTime] to [Date] class. Opposite of [toDateTime]
  static Date cast(DateTime date) {
    return Date.fromMicrosecondsSinceEpoch(
      date.microsecondsSinceEpoch,
      isUtc: date.isUtc
    );
  }

  /// Transforms a date that follows a pattern from a [String] representation to a [Date] object
  static Date parse(String pattern, String dateString, {
    String locale = "en_US",
    bool isUTC = false,
  }) {
    initializeDateFormatting();
    return Date.cast(DateFormat(pattern, locale).parse(dateString, isUTC));
  }

  /// Create a [Date] object from a Unix timestamp
  static Date unix(int seconds) {
    return Date.fromSecondsSinceEpoch(seconds);
  }

  /// Tomorrow at same hour / minute / second than now
  static Date get tomorrow {
    return Date.now().nextDay;
  }

  /// Yesterday at same hour / minute / second than now
  static Date get yesterday {
    return Date.now().previousDay;
  }

  /// Current date (Same as [Date.now])
  static Date get today {
    return Date.now();
  }

  /// Get [DateTime] object representation of current [Date] object. Opposite of [Date.cast]
  DateTime get toDateTime {
    return super.add(Duration(microseconds: 0));
  }

  /// Get [Date] object as UTC of current object.
  Date get toUTC {
    DateTime dt = super.toUtc();
    return Date.fromMicrosecondsSinceEpoch(dt.microsecondsSinceEpoch, isUtc: dt.isUtc);
  }

  /// Get [Date] object in LocalTime of current object.
  Date get toLocalTime {
    DateTime dt = super.toLocal();
    return Date.fromMicrosecondsSinceEpoch(dt.microsecondsSinceEpoch, isUtc: dt.isUtc);
  }

  /// Add a [Duration] to this date
  Date add(Duration duration) {
    return Date.cast(super.add(duration));
  }
  
  /// Substract a [Duration] to this date
  Date subtract(Duration duration) {
    return Date.cast(super.add(Duration.zero - duration));
  }
  
  /// Get the difference between this data and other date as a [Duration]
  Duration diff(Date other) {
    return this.difference(other);
  }

  /// Add a certain amount of days to this date
  Date addDays(int amount) {
    return this.add(Duration(days: amount));
  }
  
  /// Add a certain amount of hours to this date
  Date addHours(int amount) {
    return this.add(Duration(hours: amount));
  }

  // TODO: this
  // Date addISOYears(int amount) {
  //   return this;
  // }

  /// Add a certain amount of milliseconds to this date
  Date addMilliseconds(int amount) {
    return this.add(Duration(milliseconds: amount));
  }

  /// Add a certain amount of microseconds to this date
  Date addMicroseconds(int amount) {
    return this.add(Duration(microseconds: amount));
  }

  /// Add a certain amount of minutes to this date
  Date addMinutes(int amount) {
    return this.add(Duration(minutes: amount));
  }

  /// Add a certain amount of months to this date
  Date addMonths(int amount) {
    return this.setMonth(this.month + amount);
  }

  /// Add a certain amount of quarters to this date
  Date addQuarters(int amount) {
    return this.addMonths(amount * 3);
  }

  /// Add a certain amount of seconds to this date
  Date addSeconds(int amount) {
    return this.add(Duration(seconds: amount));
  }

  /// Add a certain amount of weeks to this date
  Date addWeeks(int amount) {
    return this.addDays(amount * 7);
  }

  /// Add a certain amount of years to this date
  Date addYears(int amount) {
    return this.setYear(this.year + amount);
  }

  /// Know if two ranges of dates overlaps
  static bool areRangesOverlapping(Date initialRangeStartDate, Date initialRangeEndDate, Date comparedRangeStartDate, Date comparedRangeEndDate) {

    if(initialRangeStartDate.isAfter(initialRangeEndDate)) {
      throw RangeError("Not valid initial range");
    }
    
    if(comparedRangeStartDate.isAfter(comparedRangeEndDate)) {
      throw RangeError("Not valid compareRange range");
    }

    Interval initial = Interval(initialRangeStartDate, initialRangeEndDate);
    Interval compared = Interval(comparedRangeStartDate, comparedRangeEndDate);

    return initial.cross(compared) || compared.cross(initial);
  }

  /// Get index of the closest day to current one, returns null if empty [Iterable] is passed as argument
  int closestIndexTo(Iterable<Date> datesArray) {
    var differences  = datesArray.map( (date) {
      return date.difference(this).abs();
    });

    if(datesArray.length == 0) {
      return null;
    }
    
    int index = 0;
    for (var i = 0; i < differences.length; i++) {
      if(differences.elementAt(i) < differences.elementAt(index)) {
        index = i;
      }
    }
    return index;
  }

  /// Get closest day to current one, returns null if empty [Iterable] is passed as argument
  Date closestTo(Iterable<Date> datesArray) {
    if(datesArray.length == 0) {
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
  int compare(Date other) {
    return super.compareTo(other.toDateTime);
  }

  /// Returns true if left [isBefore] than right
  static Date min(Date left, Date right) {
    return (left < right) ? left : right;
  }

  /// Returns true if left [isAfter] than right
  static Date max(Date left, Date right) {
    return (left < right) ? right : left;
  }

  /// Compare the two dates and return 1 if the first date [isAfter] the second,
  /// -1 if the first date [isBefore] the second or 0 first date [isEqual] the second.
  static int compareAsc(Date dateLeft, Date dateRight) {
    if(dateLeft.isAfter(dateRight)) {
      return 1;
    } else if (dateLeft.isBefore(dateRight)) {
      return -1;
    } else {
      return 0;
    }
  }

  /// Compare the two dates and return -1 if the first date [isAfter] the second,
  /// 1 if the first date [isBefore] the second or 0 first date [isEqual] the second.
  static int compareDesc(Date dateLeft, Date dateRight) {
    return (-1)*Date.compareAsc(dateLeft, dateRight);
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
  int differenceInMicroseconds(Date other) {
    return this.diff(other).inMicroseconds;
  }

  /// Difference in milliseconds between this date and other
  int differenceInMilliseconds(Date other) {
    return this.diff(other).inMilliseconds;
  }

  /// Difference in minutes between this date and other
  int differenceInMinutes(Date other) {
    return this.diff(other).inMinutes;
  }

  /// Difference in seconds between this date and other
  int differenceInSeconds(Date other) {
    return this.diff(other).inSeconds;
  }

  /// Difference in hours between this date and other
  int differenceInHours(Date other) {
    return this.diff(other).inHours;
  }

  /// Difference in days between this date and other
  int differenceInDays(Date other) {
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
    return timeago_lib.format(this.toDateTime, locale: locale, clock: clock, allowFromNow: allowFromNow);
  }

  /// Return the array of dates within the specified range.
  Iterable<Date> eachDay(Date date) sync* {
    if(this.isSameDay(date)) {
      yield date.startOfDay;
    } else {
      Duration difference = this.diff(date);
      int days = difference.abs().inDays;
      Date current = date.startOfDay;
      if(difference.isNegative) {
        for( int i = 0; i < days ; i++ ){
          yield current;
          current = current.nextDay;
        }
      } else {
        for( int i = 0; i < days ; i++ ){
          yield current;
          current = current.nextDay;
        }
      }
    }
  }

  /// Return the end of a day for this date. The result will be in the local timezone.
  Date get endOfDay {
    return this.setHour(23, 59, 59, 999, 999);
  }

  /// Return the end of the hour for this date. The result will be in the local timezone.
  Date get endOfHour {
    return this.setMinute(59, 59, 999, 999);
  }

  /// Return the end of ISO week for this date. The result will be in the local timezone.
  Date get endOfISOWeek {
    return this.endOfWeek.nextDay;
  }

  // Date endOfISOYear()

  /// Return the end of the minute for this date. The result will be in the local timezone.
  Date get endOfMinute {
    return this.setSecond(59, 999, 999);
  }

  /// Return the end of the month for this date. The result will be in the local timezone.
  Date get endOfMonth {
    return Date(this.year, this.month + 1).subMicroseconds(1);
  }
  
  // Date endOfQuarter()

  /// Return the end of the second for this date. The result will be in the local timezone.
  Date get endOfSecond {
    return this.setMillisecond(999, 999);
  }

  /// Return the end of today. The result will be in the local timezone.
  static Date get endOfToday {
    return Date.now().endOfDay;
  }

  /// Return the end of tomorrow. The result will be in the local timezone.
  static Date get endOfTomorrow {
    return Date.now().nextDay.endOfDay;
  }

  /// Return the end of yesterday. The result will be in the local timezone.
  static Date get endOfYesterday {
    return Date.now().previousDay.endOfDay;
  }

  /// Return the end of the week for this date. The result will be in the local timezone.
  Date get endOfWeek {
    return this.nextWeek.startOfWeek.subMicroseconds(1);
  }

  /// Return the end of the year for this date. The result will be in the local timezone.
  Date get endOfYear {
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

  // int getTime(date)

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
  bool isSameOrAfter(Date other) {
    return (this == other || this.isAfter(other));
  }
  
  /// Return true if other [isEqual] or [isBefore] to this date
  bool isSameOrBefore(Date other) {
    return (this == other || this.isBefore(other));
  }
  
  /// Check if a Object if a [Date], use for validation purposes
  static bool isDate(argument) {
    return argument is Date;
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

  // bool isFirstDayOfMonth(date)
  
  /// Return true if this date [isAfter] [Date.now]
  bool get isFuture {
    return this.isAfter(Date.now());
  }

  // bool isLastDayOfMonth(date)
  // bool isLeapYear(date)

  /// Return true if this date [isBefore] [Date.now]
  bool get isPast {
    return this.isBefore(Date.now());
  }

  /// Check if this date is in the same day than other
  bool isSameDay(Date other) {
    return this.startOfDay == other.startOfDay;
  }

  /// Check if this date is in the same hour than other
  bool isSameHour(Date other) {
    return this.startOfHour == other.startOfHour;
  }

  // bool isSameISOWeek(dateLeft, dateRight)
  // bool isSameISOYear(dateLeft, dateRight)

  /// Check if this date is in the same minute than other
  bool isSameMinute(Date other) {
    return this.startOfMinute == other.startOfMinute;
  }

  /// Check if this date is in the same month than other
  bool isSameMonth(Date other) {
    return this.startOfMonth == other.startOfMonth;
  }

  // bool isSameQuarter(dateLeft, dateRight)

  /// Check if this date is in the same second than other
  bool isSameSecond(Date other) {
    return this.secondsSinceEpoch == other.secondsSinceEpoch;
  }

  // bool isSameWeek(dateLeft, dateRight, [options])

  /// Check if this date is in the same year than other
  bool isSameYear(Date other) {
    return this.year == other.year;
  }
  
  /// Check if this date is in the same hour than [Date.now]
  bool get isThisHour {
    return this.startOfHour == Date.today.startOfHour;
  }
  // bool isThisISOWeek()
  // bool isThisISOYear()

  /// Check if this date is in the same minute than [Date.now]
  bool get isThisMinute {
    return this.startOfMinute == Date.today.startOfMinute;
  }

  /// Check if this date is in the same month than [Date.now]
  bool get isThisMonth {
    return this.isSameMonth(Date.today);
  }
  
  // bool isThisQuarter()

  /// Check if this date is in the same second than [Date.now]
  bool get isThisSecond {
    return this.isSameSecond(Date.today);
  }

  // bool isThisWeek(, [options])

  /// Check if this date is in the same year than [Date.now]
  bool get isThisYear {
    return this.isSameYear(Date.today);
  }

  // bool isValid()

  /// Check if this date is in the same day than [Date.today]
  bool get isToday {
    return this.isSameDay(Date.today);
  }

  /// Check if this date is in the same day than [Date.tomorrow]
  bool get isTomorrow {
    return this.isSameDay(Date.tomorrow);
  }

  /// Check if this date is in the same day than [Date.yesterday]
  bool get isYesterday {
    return this.isSameDay(Date.yesterday);
  }

  /// Return true if this [Date] is set as UTC.
  bool get isUTC {
    return this.isUtc;
  }

  /// Return true if this [Date] is a saturday or a sunday
  bool get isWeekend {
    return (this.day == DateTime.saturday || this.day == DateTime.sunday);
  }

  /// Checks if a [Date] is within a Rage (two dates that makes an [Interval])
  bool isWithinRange(Date startDate, Date endDate) {
    return Interval(startDate, endDate).includes(this);
  }

  /// Checks if a [Date] is within an [Interval]
  bool isWithinInterval(Interval interval) {
    return interval.includes(this);
  }

  // Date lastDayOfISOWeek(date)
  // Date lastDayOfISOYear(date)
  // Date lastDayOfMonth(date)
  // Date lastDayOfQuarter(date)
  // Date lastDayOfWeek(date, [options])
  // Date lastDayOfYear(date)
  // static Date max(Iterable<Date>)
  // static Date min(Iterable<Date>)
  // static Date parse(any)
  // Date setDate(date, dayOfMonth)
  // Date setDayOfYear(date, dayOfYear)
  // Date setISODay(date, day)
  // Date setISOWeek(date, isoWeek)
  // Date setISOYear(date, isoYear)

  /// Change [year] of this date
  /// 
  /// set [month] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [day] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setYear( int year, [
    int month = null,
    int day = null,
    int hour = null,
    int minute = null,
    int second = null,
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      year,
      month == null ? this.month : month,
      day == null ? this.day : day,
      hour == null ? this.hour : hour,
      minute == null ? this.minute : minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }
  
  /// Change [month] of this date
  /// 
  /// set [day] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setMonth(int month, [
    int day = null,
    int hour = null,
    int minute = null,
    int second = null,
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      this.year,
      month,
      day == null ? this.day : day,
      hour == null ? this.hour : hour,
      minute == null ? this.minute : minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [day] of this date
  /// 
  /// set [hour] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setDay(int day, [
    int hour = null,
    int minute = null,
    int second = null,
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      this.year,
      this.month,
      day,
      hour == null ? this.hour : hour,
      minute == null ? this.minute : minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [hour] of this date
  /// 
  /// set [minute] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setHour(int hour, [
    int minute = null,
    int second = null,
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      this.year,
      this.month,
      this.day,
      hour,
      minute == null ? this.minute : minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [minute] of this date
  /// 
  /// set [second] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setMinute(int minute, [
    int second = null,
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      this.year,
      this.month,
      this.day,
      this.hour,
      minute,
      second == null ? this.second : second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [second] of this date
  /// 
  /// set [millisecond] if you want to change it as well, to skip an change other optional field set it as [null]
  /// set [microsecond] if you want to change it as well
  Date setSecond(int second, [
    int millisecond = null,
    int microsecond = null
  ]) {
    return Date(
      this.year,
      this.month,
      this.day,
      this.hour,
      this.minute,
      second,
      millisecond == null ? this.millisecond : millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [millisecond] of this date
  /// 
  /// set [microsecond] if you want to change it as well
  Date setMillisecond(int millisecond, [
    int microsecond = null
  ]) {
    return Date(
      this.year,
      this.month,
      this.day,
      this.hour,
      this.minute,
      this.second,
      millisecond,
      microsecond == null ? this.microsecond : microsecond
    );
  }

  /// Change [microsecond] of this date
  Date setMicrosecond( int microsecond ) {
    return Date(
      this.year,
      this.month,
      this.day,
      this.hour,
      this.minute,
      this.second,
      this.millisecond,
      microsecond
    );
  }
  // Date setQuarter(quarter)

  /// Get a [Date] representing start of Day of this [Date] in local time.
  Date get startOfDay {
    return this.setHour(0, 0, 0, 0, 0);
  }

  /// Get a [Date] representing start of Hour of this [Date] in local time.
  Date get startOfHour {
    return this.setMinute(0, 0, 0, 0);
  }

  /// Get a [Date] representing start of week (ISO week) of this [Date] in local time.
  Date get startOfISOWeek {
    return this.startOfWeek.nextDay;
  }

  // Date startOfISOYear()
  /// Get a [Date] representing start of minute of this [Date] in local time.
  Date get startOfMinute {
    return this.setSecond(0, 0, 0);
  }
  /// Get a [Date] representing start of month of this [Date] in local time.
  Date get startOfMonth {
    return this.setDay(1, 0, 0, 0, 0, 0);
  }
  // Date startOfQuarter()
  /// Get a [Date] representing start of second of this [Date] in local time.
  Date get startOfSecond {
    return this.setMillisecond(0, 0);
  }

  /// Get a [Date] representing start of today of [Date.today] in local time.
  static Date get startOfToday {
    return Date.today.startOfDay;
  }

  /// Get a [Date] representing start of week of this [Date] in local time.
  Date get startOfWeek {
    return this.subtract(Duration( days: this.weekday )).startOfDay;
  }

  /// Get a [Date] representing start of year of this [Date] in local time.
  Date get startOfYear {
    return this.setMonth(DateTime.january, 1, 0, 0, 0, 0, 0);
  }

  /// Subtracts a [Duration] from this [Date]
  Date sub(Duration duration) {
    return this.add( Duration.zero - duration );
  }

  /// Subtracts an amout of hours from this [Date]
  Date subHours(int amount) {
    return this.addHours(-amount);
  }

  /// Subtracts an amout of days from this [Date]
  Date subDays(int amount) {
    return this.addDays(-amount);
  }

  /// Subtracts an amout of milliseconds from this [Date]
  Date subMilliseconds(amount) {
    return this.addMilliseconds(-amount);
  }

  /// Subtracts an amout of microseconds from this [Date]
  Date subMicroseconds(amount) {
    return this.addMicroseconds(-amount);
  }

  // Date subISOYears(amount)
  /// Subtracts an amout of minutes from this [Date]
  Date subMinutes(amount) {
    return this.addMinutes(-amount);
  }

  /// Subtracts an amout of months from this [Date]
  /// Subtracts an amout of months from this [Date]
  Date subMonths(amount) {
    return this.addMonths(-amount);
  }

  // Date subQuarters(amount)
  /// Subtracts an amout of seconds from this [Date]
  Date subSeconds(amount) {
    return this.addSeconds(-amount);
  }

  // Date subWeeks(amount)
  /// Subtracts an amout of years from this [Date]
  Date subYears(amount) {
    return this.addYears(-amount);
  }
  
  // Check if two dates are [equals]
  bool equals(Date other) {
    return this.isAtSameMomentAs(other);
  }

  bool operator <(Date other) => this.isBefore(other);

  bool operator <=(Date other) => (
    this.isBefore(other) || this.isAtSameMomentAs(other)
  );
  
  bool operator >(Date other) => this.isAfter(other);
  
  bool operator >=(Date other) => (
    this.isAfter(other) || this.isAtSameMomentAs(other)
  );

  String toString() {
    return super.toString();
  }

  String toHumanString() {
    return this.format("E MMM d y H:m:s");
  }

  /// The day after 
  /// The day after this [Date]
  Date get nextDay {
    return this.addDays(1);
  }

  /// The day previous this [Date]
  Date get previousDay {
    return this.addDays(-1);
  }

  /// The month after this [Date]
  Date get nextMonth {
    return this.setMonth(this.month + 1);
  }

  /// The month previous this [Date]
  Date get previousMonth {
    return this.setMonth(this.month - 1);
  }

  /// The year after this [Date]
  Date get nextYear {
    return this.setYear(this.year + 1);
  }

  /// The year previous this [Date]
  Date get previousYear {
    return this.setYear(this.year - 1);
  }

  /// The week after this [Date]
  Date get nextWeek {
    return this.addDays(7);
  }

  /// The week previous this [Date]
  Date get previousWeek {
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

  /// Format this [Date] following the [String pattern]
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
  ///     '        escape for text        (Delimiter)        'Date='
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
    return DateFormat(pattern, locale).format(this.toDateTime);
  }

  /// Get UTC [Date] from this [Date]
  Date get UTC {
    return Date.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch, isUtc: true);
  }

  /// Get Local [Date] from this [Date]
  Date get Local {
    return Date.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch, isUtc: false);
  }
}