# Changelog

## 1.3.2
- fix `isWeekend`

## 1.3.1
- Merge [fix: intersection on interval containing the other interval #28](https://github.com/xantiagoma/dart_date/pull/28)

## 1.3.0
- Merge [[BREAKING CHANGE] Fix eachDay function #30](https://github.com/xantiagoma/dart_date/pull/30)

## 1.2.2
- Update dependencies

## 1.2.1
- Merge [Add setWeekDay function #24](https://github.com/xantiagoma/dart_date/pull/24)
- Merge [Fix Interval intersection #22](https://github.com/xantiagoma/dart_date/pull/22)
- Merge [Update README.md #21](https://github.com/xantiagoma/dart_date/pull/21) 

## 1.1.1

- Merge [PR](https://github.com/xantiagoma/dart_date/pull/16) to fix week calculation

## 1.1.0-nullsafety.0

- Add null-safety

## 1.0.9

- Rename `UTC` to `utc` & `Local` to `local` to follow dart analysis
- Changes in [PR #6](https://github.com/xantiagoma/dart_date/pull/6)
- Add optional `ignoreDaylightSavings` to `add*` methods

## 1.0.8

- Fix isMonday, isTuesday, isWednesday, isThursday, isFriday, isSaturday, isSunday

## 1.0.7

- Add getWeekYear, getWeek, getISOWeek, getISOWeeksInYear, startOfWeekYear, startOfISOWeekYear
- Merged PR: //github.com/xantiagoma/dart_date/pull/2

## 1.0.6

- Improve documentation
- Add extension operators on DateTime and Duration

## 1.0.5

- same `1.0.4`

## 1.0.4

- `pub.dev` recommendations

## 1.0.3

- Delete `this` if not needed and convert functions to `=>` if possible

## 1.0.2

- `dartfmt` overwriting

## 1.0.1

- Include recommendations from `pub.dev`

## 1.0.0

- **!!! Broken** API related to 0.x versions
- Using new fancy dart extensions feature
- Use `.method()` or `.property` to access extension methods / getters and `Date.method()` / `Date.property` for new static properties.

## 0.0.9

- Changes `Date.parse` to accept or not a format
- Added `date.isFirstDayOfMonth` getter
- Added `date.isLastDayOfMonth` getter
- Added `date.isLeapYear` getter

## 0.0.8

- Adding documentation and timeago `date.timeago()`
