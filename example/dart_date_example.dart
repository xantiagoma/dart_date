import 'package:dart_date/dart_date.dart';
import 'package:intl/intl.dart';

main(List<String> args) {
  var n = Date.now();
  // (() async {
  //   var d = await Date.now().asyncFormat("dd-MMMM-yyyy", "es_ES");
  //   var x = await Date.asyncParse("dd-MMMM-yyyy", d, locale: "es_ES");
  //   print("$d - $x");
  // })();
  // print(Date.now().startOfWeek.toHumanString());
  // print(Date.now().endOfWeek.toHumanString());
  // print(Date.now().startOfISOWeek.toHumanString());
  // print(Date.now().endOfISOWeek.toHumanString());
  // print(Date.now().closestTo( [
  //   n.nextWeek,
  //   n.previousDay.previousDay,
  //   n.previousWeek.nextDay,
  //   n.nextMonth,
  //   n.nextDay,
  //   //n,
  //   n.nextYear
  // ] ));
  print(Date.utc(2020).local);
}
