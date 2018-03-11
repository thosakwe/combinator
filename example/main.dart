import 'dart:io';
import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';

final Parser minus = match('-');

final Parser<int> digit = match(
  new RegExp(r'[0-9]'),
  errorMessage: 'Expected a number',
);

final Parser digits = digit.plus();

final Parser separator = match('.');

final Parser decimal = digits.then((separator.then(digits)).opt());

final Parser number =
    minus.opt().then(decimal).map<num>((r) => num.parse(r.span.text));

main() {
  print(number);

  while (true) {
    stdout.write('Enter a number: ');
    var line = stdin.readLineSync();
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var result = number.parse(scanner);

    if (!result.successful) {
      for (var error in result.errors) {
        stderr.writeln(error.toolString);
        stderr.writeln(error.span.highlight(color: true));
      }
    } else
      print(result.value);
  }
}
