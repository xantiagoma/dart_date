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
    )  ;
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

  bool operator ==(other) {
    if(other is! Interval) return false;
    return this.equals(other);
  }

  String toString() {
    return "<${this.start} | ${this.end} | ${this.duration} >";
  }

}

class Date extends DateTime {
  
  // Constructos
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

  Date.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch,
      {bool isUtc: false}) : super.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: isUtc);

  Date.fromMillisecondsSinceEpoch(int millisecondsSinceEpoch,
      {bool isUtc: false}) : super.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc: isUtc);
  
  Date.now(): super.now();

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

  // Static
  static Date cast(DateTime date) {
    return Date.fromMicrosecondsSinceEpoch(
      date.microsecondsSinceEpoch,
      isUtc: date.isUtc
    );
  }

  DateTime toDateTime() {
    //return DateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch, isUtc: this.isUtc);
    return super.add(Duration(microseconds: 0));
  }

  // Override
  Date add(Duration duration) {
    return Date.cast(super.add(duration));
  }
  

  // date-fns methods
  Date addDays(int amount) {
    return this.add(Duration(days: amount));
  }
  
  Date addHours(int amount) {
    return this.add(Duration(hours: amount));
  }

  // TODO: this
  Date addISOYears(int amount) {
    return this;
  }

  Date addMilliseconds(int amount) {
    return this.add(Duration(milliseconds: amount));
  }

  Date addMinutes(int amount) {
    return this.add(Duration(minutes: amount));
  }

  // TODO: this
  Date addMonths(int amount) {
    return this; //.add(Duration(: amount));
  }

  // TODO: this
  Date addQuarters(int amount) {
    return this; //.add(Duration(: amount));
  }

  Date addSeconds(int amount) {
    return this.add(Duration(seconds: amount));
  }

  // TODO: this
  Date addWeeks(int amount) {
    return this; //.add(Duration());
  }

  // TODO: this
  Date addYears(int amount) {
    return this; //.add(Duration());
  }


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

  // int closestIndexTo(dateToCompare, datesArray)
  // Date closestTo(dateToCompare, datesArray)

  int compare(Date other) {
    super.compareTo(other.toDateTime());
  }

  int compareAsc(Date dateLeft, Date dateRight) {
    if(dateLeft.isAfter(dateRight)) {
      return 1;
    } else if (dateLeft.isBefore(dateRight)) {
      return -1;
    } else {
      return 0;
    }
  }

  int compareDesc(Date dateLeft, Date dateRight) {
    return (-1)*this.compareAsc(dateLeft, dateRight);
  }

  // int differenceInCalendarDays(dateLeft, dateRight)
  // int differenceInCalendarISOWeeks(dateLeft, dateRight)
  // int differenceInCalendarISOYears(dateLeft, dateRight)
  // int differenceInCalendarMonths(dateLeft, dateRight)
  // int differenceInCalendarQuarters(dateLeft, dateRight)
  // int differenceInCalendarWeeks(dateLeft, dateRight, [options])
  // int differenceInCalendarYears(dateLeft, dateRight)
  // int differenceInDays(dateLeft, dateRight)
  // int differenceInHours(dateLeft, dateRight)
  // int differenceInISOYears(dateLeft, dateRight)
  // int differenceInMilliseconds(dateLeft, dateRight)
  // int differenceInMinutes(dateLeft, dateRight)
  // int differenceInMonths(dateLeft, dateRight)
  // int differenceInQuarters(dateLeft, dateRight)
  // int differenceInSeconds(dateLeft, dateRight)
  // int differenceInWeeks(dateLeft, dateRight)
  // int differenceInYears(dateLeft, dateRight)
  // String distanceInWords(dateToCompare, date, [options])
  // String distanceInWordsStrict(dateToCompare, date, [options])
  // static String distanceInWordsToNow(date, [options])
  // Iterable<Date> eachDay(startDate, endDate, [step])
  // Date endOfDay()
  // Date endOfHour()
  // Date endOfISOWeek()
  // Date endOfISOYear()
  // Date endOfMinute()
  // Date endOfMonth()
  // Date endOfQuarter()
  // Date endOfSecond()
  // static Date endOfToday()
  // static Date endOfTomorrow()
  // Date endOfWeek(date, [options])
  // Date endOfYear(date)
  // static Date endOfYesterday()
  // String format(date, [format], [options])

  /// Get the day of the month of the given date.
  /// The day of the month 1..31.
  int getDate() {
    return this.day;
  }

  // int getDay(date)
  // int getDayOfYear(date)
  // int getDaysInMonth(date)
  // int getDaysInYear(date)

  /// Get the hours of the given date.
  /// The hour of the day, expressed as in a 24-hour clock 0..23.
  int getHours() {
    return this.hour;
  }

  // int getISODay(date)
  // int getISOWeek(date)
  // int getISOWeeksInYear(date)
  // int getISOYear(date)

  /// Get the milliseconds of the given date.
  /// The millisecond 0...999.
  int getMilliseconds() {
    return this.millisecond;
  }

  /// Get the microseconds of the given date.
  /// The microsecond 0...999.
  int getMicroseconds() {
    return this.microsecond;
  }

  /// Get the milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int getMillisecondsSinceEpoch() {
    return this.millisecondsSinceEpoch;
  }

  /// Get the microseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  int getMicrosecondsSinceEpoch() {
    return this.microsecondsSinceEpoch;
  }

  /// Get the minutes of the given date.
  /// The minute 0...59.
  int getMinutes() {
    return this.minute;
  }

  /// Get the month of the given date.
  /// The month 1..12.
  int getMonth() {
    return this.month;
  }
  // int getOverlappingDaysInRanges(initialRangeStartDate, initialRangeEndDate, comparedRangeStartDate, comparedRangeEndDate)
  // int getQuarter(date)

  /// Get the seconds of the given date.
  /// The second 0...59.
  int getSeconds(date) {
    return this.second;
  }

  // int getTime(date)

  /// The year
  int getYear(date) {
    return this.year;
  }

  /// The time zone name.
  /// This value is provided by the operating system and may be an abbreviation or a full name.
  /// In the browser or on Unix-like systems commonly returns abbreviations, such as "CET" or "CEST".
  /// On Windows returns the full name, for example "Pacific Standard Time".
  String getTimeZoneName() {
    return this.timeZoneName;
  }

  /// The time zone offset, which is the difference between local time and UTC.
  /// The offset is positive for time zones east of UTC.
  /// Note, that JavaScript, Python and C return the difference between UTC and local time.
  /// Java, C# and Ruby return the difference between local time and UTC.
  Duration getTimeZoneOffset() {
    return this.timeZoneOffset;
  }

  /// The day of the week monday..sunday.
  /// In accordance with ISO 8601 a week starts with Monday, which has the value 1.
  int getWeekday() {
    return this.weekday;
  }

  bool isSameOrAfter(Date other) {
    return (this == other || this.isAfter(other));
  }
  
  bool isSameOrBefore(Date other) {
    return (this == other || this.isBefore(other));
  }
  
  static bool isDate(argument) {
    return argument is Date;
  }

  bool isEqual(other) {
    return this.equals(other);
  }

  bool get isMonday {
    return this.day == DateTime.monday;
  }

  bool get isTuesday {
    return this.day == DateTime.tuesday;
  }
  
  bool get isWednesday {
    return this.day == DateTime.wednesday;
  }
  
  bool get isThursday {
    return this.day == DateTime.thursday;
  }
  
  bool get isFriday {
    return this.day == DateTime.friday;
  }
  
  bool get isSaturday {
    return this.day == DateTime.saturday;
  }
  
  bool get isSunday {
    return this.day == DateTime.sunday;
  }

  // bool isFirstDayOfMonth(date)
  
  bool get isFuture {
    return this.isAfter(Date.now());
  }

  // bool isLastDayOfMonth(date)
  // bool isLeapYear(date)

  bool get isPast {
    return this.isBefore(Date.now());
  }


  // bool isSameDay(dateLeft, dateRight)
  // bool isSameHour(dateLeft, dateRight)
  // bool isSameISOWeek(dateLeft, dateRight)
  // bool isSameISOYear(dateLeft, dateRight)
  // bool isSameMinute(dateLeft, dateRight)
  // bool isSameMonth(dateLeft, dateRight)
  // bool isSameQuarter(dateLeft, dateRight)
  // bool isSameSecond(dateLeft, dateRight)
  // bool isSameWeek(dateLeft, dateRight, [options])
  // bool isSameYear(dateLeft, dateRight)
  // bool isThisHour(date)
  // bool isThisISOWeek(date)
  // bool isThisISOYear(date)
  // bool isThisMinute(date)
  // bool isThisMonth(date)
  // bool isThisQuarter(date)
  // bool isThisSecond(date)
  // bool isThisWeek(date, [options])
  // bool isThisYear(date)
  // bool isToday(date)
  // bool isTomorrow(date)
  // bool isValid(date)

  /// True if this Date is set to UTC time.
  bool get isUTC {
    return this.isUtc;
  }

  // bool isWeekend(date)
  // bool isWithinRange(date, startDate, endDate)
  // bool isYesterday(date)
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
  // Date setDay(date, day, [options])
  // Date setDayOfYear(date, dayOfYear)
  // Date setISODay(date, day)
  // Date setISOWeek(date, isoWeek)
  // Date setISOYear(date, isoYear)

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
  // Date setQuarter(date, quarter)
  // Date setSeconds(date, seconds)
  // Date startOfDay(date)
  // Date startOfHour(date)
  // Date startOfISOWeek(date)
  // Date startOfISOYear(date)
  // Date startOfMinute(date)
  // Date startOfMonth(date)
  // Date startOfQuarter(date)
  // Date startOfSecond(date)
  // static Date startOfToday()
  // Date startOfWeek(date, [options])
  // Date startOfYear(date)
  // Date subHours(date, amount)
  // Date subISOYears(date, amount)
  // Date subMilliseconds(date, amount)
  // Date subMinutes(date, amount)
  // Date subMonths(date, amount)
  // Date subQuarters(date, amount)
  // Date subSeconds(date, amount)
  // Date subWeeks(date, amount)
  // Date subYears(date, amount)

    // Operators
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

  bool operator ==(other) {
    if(other is! Date) return false;
    return this.equals(other);
  }

  String toString() {
    return "[${super.toString()}]";
  }

  //Additional
  Date get nextDay {
    return this.addDays(1);
  }

  Date get previousDay {
    return this.addDays(-1);
  }
}


main(List<String> args) {
  // Interval first = Interval(
  //   Date(1890, 3, 20, 20, 20, 20, 20, 20),
  //   Date.now()
  // );
  // Interval last = Interval(
  //   Date(1996, 3, 29, 20, 20, 20, 20, 20),
  //   Date.now().add(Duration(days: 4000))
  // );
  DateTime date = DateTime(1996, 3, 29, 20, 20, 20, 20, 20);
  var d = Date.cast(date);
  d = d.setMonth(6).setHour(12);
 // List<Interval> intervals 
  print(d);
}