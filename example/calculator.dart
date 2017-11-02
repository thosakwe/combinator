import 'dart:io';
import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';

final Parser<num> calculator = calculatorGrammar();

Parser<num> calculatorGrammar() {
  var expr = reference<num>();
  var number = match(new RegExp(r'-?[0-9]+(\.[0-9]+)?')).value((r) => num.parse(r.span.text));
  var binaryOperator = any([
    match('*'),
    match('/'),
    match('+'),
    match('-'),
  ]).value((r) => r.span.text);
  var parenthesizedExpression = chain([
    match('('),
    expr,
    match(')'),
  ]).index(1).cast<num>();

  var binaryExpression = chain([
    expr.maxDepth(100), // Use maxDepth(...) to prevent stack overflows on left-recursive rules
    binaryOperator,
    expr,
  ]).map((r) {
    var left = r.value[0], right = r.value[2];

    switch (r.value[1]) {
      case '*':
        return left * right;
      case '/':
        return left / right;
      case '+':
        return left + right;
      case '-':
        return left - right;
    }

    throw new UnsupportedError('Unknown operator: "${r.value[1]}".');
  });

  expr.parser = longest([
    number,
    parenthesizedExpression,
    binaryExpression,//.safe(errorMessage: 'wtf lol'),
  ]);

  return expr;
}

main() {
  while (true) {
    stdout.write('Enter an expression: ');
    var line = stdin.readLineSync();
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var result = calculator.parse(scanner);

    if (!result.successful) {
      for (var error in result.errors) {
        stderr.writeln(error.toolString);
        stderr.writeln(error.span.highlight(color: true));
      }
    } else
      print(result.value);
  }
}
