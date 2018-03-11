import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:test/test.dart';

void main() {
  var number = match(new RegExp(r'-?[0-9]+(\.[0-9]+)?'))
      .map<num>((r) => num.parse(r.span.text));

  var term = reference<num>();

  var r = new Recursion<num>();

  r.prefix = [number];

  r.infix = {
    match('-'): (a, r, s) => a - term.parse(s).value,
    match('+'): (a, r, s) => a + term.parse(s).value,
    match('/'): (a, r, s) => a / term.parse(s).value,
    match('*'): (a, r, s) => a * term.parse(s).value,
  };

  term.parser = r.precedence(0);

  num parse(String text) {
    var scanner = new SpanScanner(text);
    var result = term.parse(scanner);
    return result.value;
  }

  test('prefix', () {
    expect(parse('24'), 24);
  });

  test('infix', () {
    expect(parse('24+23'), 47);
  });

  test('precedence', () {
    expect(parse('2+3*5-2'), 15);
  });
}
