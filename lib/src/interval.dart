import 'package:dart_date/src/dart_date.dart';

class Interval {
  late final DateTime _referenceDate;
  late final Duration _duration;

  Interval(DateTime start, DateTime end) {
    _referenceDate = start;
    _duration = end.difference(start);
  }

  Interval.fromStart(DateTime start, Duration duration)
      : _referenceDate = start,
        _duration = duration;

  Interval.fromEnd(DateTime end, Duration duration)
      : _referenceDate = end,
        _duration = -duration;

  Interval.fromMiddle(DateTime middle, Duration duration) {
    _referenceDate = middle.subtract(duration ~/ 2);
    _duration = duration;
  }

  DateTime get start =>
      _duration.isNegative ? _referenceDate.add(_duration) : _referenceDate;
  DateTime get end =>
      _duration.isNegative ? _referenceDate : _referenceDate.add(_duration);
  Duration get duration => end.difference(start);

  DateTime get middle => start.add(duration ~/ 2);

  Interval setStart(DateTime val) => Interval(val, end);
  Interval setEnd(DateTime val) => Interval(start, val);

  Interval setDurationFromStart(Duration val) => Interval.fromStart(start, val);

  Interval setDurationFromEnd(Duration val) => Interval.fromEnd(end, val);

  Interval setDurationFromMiddle(Duration val) =>
      Interval.fromMiddle(middle, val);

  bool includes(DateTime date) =>
      date.isSameOrAfter(start) && date.isSameOrBefore(end);

  bool contains(Interval interval) =>
      includes(interval.start) && includes(interval.end);

  bool cross(Interval other) => includes(other.start) || includes(other.end);

  bool equals(Interval other) =>
      start.isAtSameMomentAs(other.start) && end.isAtSameMomentAs(other.end);

  Interval union(Interval other) {
    if (cross(other)) {
      if (end.isAfter(other.start) || end.isAtSameMomentAs(other.start)) {
        return Interval(start, other.end);
      } else if (other.end.isAfter(start) ||
          other.end.isAtSameMomentAs(start)) {
        return Interval(other.start, end);
      } else {
        throw RangeError('Error this: $this; other: $other');
      }
    } else {
      throw RangeError('Intervals don\'t cross');
    }
  }

  Interval? intersection(Interval other) {
    if (this.end.isBefore(other.start) || other.end.isBefore(this.start)) {
      // No overlap
      return null;
    }

    DateTime intersectionStart =
        this.start.isAfter(other.start) ? this.start : other.start;
    DateTime intersectionEnd =
        this.end.isBefore(other.end) ? this.end : other.end;

    return Interval(intersectionStart, intersectionEnd);
  }

  Interval? difference(Interval other) {
    if (other == this) {
      return null;
    } else if (this <= other) {
      // | this | | other |
      if (end.isBefore(other.start)) {
        return this;
      } else {
        return Interval(start, other.start);
      }
    } else if (this >= other) {
      // | other | | this |
      if (other.end.isBefore(start)) {
        return this;
      } else {
        return Interval(other.end, end);
      }
    } else {
      throw RangeError('Error this: $this; other: $other');
    }
  }

  List<Interval> symmetricDifference(Interval other) {
    final first = this.start.isBefore(other.start) ? this : other;
    final second = this.start.isBefore(other.start) ? other : this;

    if (first.end.isBefore(other.start) || second.end.isBefore(first.start)) {
      // No overlap, return both intervals
      return [first, second];
    }

    List<Interval> result = [];

    if (first.start.isBefore(second.start)) {
      result.add(Interval(first.start, second.start));
    } else if (second.start.isBefore(first.start)) {
      result.add(Interval(second.start, first.start));
    }

    if (first.end.isAfter(second.end)) {
      result.add(Interval(second.end, first.end));
    } else if (second.end.isAfter(first.end)) {
      result.add(Interval(first.end, second.end));
    }

    return result;
  }

  /**
   * @deprecated use [symmetricDifference] instead
   */
  @Deprecated('use symmetricDifference instead')
  List<Interval?> symetricDifference(Interval other) {
    return this.symmetricDifference(other);
  }

  // Operators
  bool operator <(Interval other) => start.isBefore(other.start);

  bool operator <=(Interval other) =>
      start.isBefore(other.start) || start.isAtSameMomentAs(other.start);

  bool operator >(Interval other) => end.isAfter(other.end);

  bool operator >=(Interval other) =>
      end.isAfter(other.end) || end.isAtSameMomentAs(other.end);

  bool operator ==(Object other) =>
      other is Interval && start == other.start && end == other.end;

  @override
  String toString() => '<${start} | ${end} | ${duration} >';
}
