import 'dart:io';
import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';

Parser jsonGrammar() {
  var expr = reference();

  // Parse a number
  var number = match<num>(new RegExp(r'-?[0-9]+(\.[0-9]+)?'),
          errorMessage: 'Expected a number.')
      .value(
    (r) => num.parse(r.span.text),
  );

  // Parse a string (no escapes supported yet)
  var string =
      match(new RegExp(r'"[^"]*"'), errorMessage: 'Expected a string.').value(
    (r) => r.span.text.substring(1, r.span.text.length - 1),
  );

  // Parse an array
  var arrayMembers = chain([
    expr.then(match(',')).map((r) => r.value[0]).star(),
    expr,
  ]);

  var array = chain([
    match('['),
    arrayMembers.opt(),
    match(']'),
  ]).value((r) => r.value[1]);

  // KV pair
  var keyValuePair = chain([
    string,
    match(':'),
    expr.error(errorMessage: 'Missing expression.'),
  ]).castDynamic().cast<Map>().value((r) => {r.value[0]: r.value[2]});

  // Parse an object
  var object = chain([
    match('{'),
    keyValuePair.error(errorMessage: 'Missing key-value pair.'),
    match('}').error(),
  ]).value((r) => [r.value[1]]);

  expr.parser = any([
    object,
    array,
    number,
    string,
  ], errorMessage: 'Expected a JSON expression.');

  return expr;
}

main() {
  var JSON = jsonGrammar();

  while (true) {
    stdout.write('Enter some JSON: ');
    var line = stdin.readLineSync();
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var result = JSON.parse(scanner);

    if (!result.successful) {
      for (var error in result.errors) {
        print(error.toolString);
        print(error.span.highlight(color: true));
      }
    } else
      print(result.value);
  }
}
