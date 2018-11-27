class Interval {
  DateTime _start;
  Duration _duration;

  Interval(DateTime start, DateTime end) {
    if(start.isAfter(end)) {
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
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0]) : super(year, month, day, hour, minute, second, millisecond, microsecond);

  Date.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch,
      {bool isUtc: false}) : super.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: isUtc);

  // Static
  static Date cast(DateTime date) {
    return Date.fromMicrosecondsSinceEpoch(
      date.microsecondsSinceEpoch,
      isUtc: date.isUtc
    );
  }

  DateTime toDateTime() {
    return DateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch, isUtc: this.isUtc);
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

// Static
  // bool areRangesOverlapping(Date initialRangeStartDate, Date initialRangeEndDate, Date comparedRangeStartDate, Date comparedRangeEndDate) {

  //   if(initialRangeStartDate.isAfter(initialRangeEndDate)) {
  //     throw RangeError("Not valid initial range");
  //   }
    
  //   if(comparedRangeStartDate.isAfter(comparedRangeEndDate)) {
  //     throw RangeError("Not valid compareRange range");
  //   }

  //   return leftStartTime < rightEndTime && rightStartTime < leftEndTime
  // }

  
}


main(List<String> args) {
  Interval first = Interval(
    DateTime(1890, 3, 20, 20, 20, 20, 20, 20),
    DateTime.now()
  );
  Interval last = Interval(
    DateTime(1996, 3, 29, 20, 20, 20, 20, 20),
    DateTime.now().add(Duration(days: 4000))
  );
 // List<Interval> intervals 
  print(first.symetricDiffetence(last));
}