import 'package:dart_date/dart_date.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

main(List<String> args) {
  var n = Date.now();
  var d = Date.now().format("dd-MMMM-yyyy", "es_ES");
  var x = Date.parse("dd-MMMM-yyyy", d, locale: "es_ES");
  print("$d - $x");

  print(Date.now().format("hh:mm:ss"));
  print(Date.now().startOfWeek.toHumanString());
  print(Date.now().endOfWeek.toHumanString());
  print(Date.now().startOfISOWeek.toHumanString());
  print(Date.now().endOfISOWeek.toHumanString());
  print(Date.now().closestTo( [
    n.nextWeek,
    n.previousDay.previousDay,
    n.previousWeek.nextDay,
    n.nextMonth,
    n.nextDay,
    //n,
    n.nextYear
  ] ));
}
