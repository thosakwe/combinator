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

  // Parse a string (no escapes supported, because lazy).
  var string =
      match(new RegExp(r'"[^"]*"'), errorMessage: 'Expected a string.').value(
    (r) => r.span.text.substring(1, r.span.text.length - 1),
  );

  // Parse an array
  var arrayMembers = chain([
    expr.then(match(',').space()).map((r) => r.value[0]).star(),
    expr,
  ]);

  var array = chain([
    match('[').space(),
    arrayMembers.opt(),
    match(']').space(),
  ]).value((r) => r.value[1]);

  // KV pair
  var keyValuePair = chain([
    string.space(),
    match(':').space(),
    expr.error(errorMessage: 'Missing expression.'),
  ]).castDynamic().cast<Map>().value((r) => {r.value[0]: r.value[2]});

  // Parse an object
  var object = chain([
    match('{').space(),
    keyValuePair.space().error(errorMessage: 'Missing key-value pair.'),
    match('}').space().error(),
  ]).value((r) => [r.value[1]]);

  expr.parser = any(
    [
      array,
      number,
      string,
      object.error(),
    ],
    errorMessage: false,
  ).space();

  return expr.foldErrors();
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
