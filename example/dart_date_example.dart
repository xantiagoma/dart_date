import 'package:dart_date/dart_date.dart';

main(List<String> args) {
  const pattern = "'Heute ist' dd-MMMM-yyyy";
  final n = DateTime.now();
  final d = DateTime.now().format(pattern, "de_DE");
  final x = Date.parse(d, pattern: pattern, locale: "de_DE");
  print("$d ($x)"); // Heute ist 30-November-2018 (2018-11-30 00:00:00.000)

  // ES language is pre-configured;
  print(DateTime.now().subDays(100).timeago(locale: 'es')); // hace 3 meses
  print(DateTime.now()
      .format('MMMM dd y, h:mm:ss a')); // November 30 2018, 9:14:29 PM
  print(DateTime(
      2006, 6, 6, 6, 6, 6, 6, 6)); // 2006-06-06 06:06:06.006006 // UTC-5
  print(DateTime(2006, 6, 6, 6, 6, 6, 6, 6)
      .UTC); // 2006-06-06 11:06:06.006006Z // UTC
  var now = DateTime.now(); // 2018-11-30 21:25:21.092647
  var closest = now.closestTo([
    //2018-11-28 21:25:21.025275
    n.nextWeek,
    n.previousDay.previousDay,
    n.previousWeek.nextDay,
    n.nextMonth,
    //n.nextDay,
    //n,
    n.nextYear
  ]);
  print("Closest to now ($now): $closest (${closest.timeago()})");
  // Closest to now (2018-11-30 21:25:21.092647): 2018-11-28 21:25:21.025275 (2 days ago)
  print(Date.today is DateTime);

  print(DateTime.parse("2014-11-20T16:51:30.000Z").toHumanString());
}
