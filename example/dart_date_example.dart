import 'package:dart_date/dart_date.dart';
import 'package:intl/intl.dart';

main(List<String> args) {
  (() async {
    var d = await Date.now().asyncFormat("dd-MMMM-yyyy", "es_ES");
    var x = await Date.asyncParse("dd-MMMM-yyyy", d, locale: "es_ES");
    print("$d - $x");
  })();
}
