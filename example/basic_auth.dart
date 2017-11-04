// Run this with "Basic QWxhZGRpbjpPcGVuU2VzYW1l"

import 'dart:convert';
import 'dart:io';
import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';

final Parser string =
    match(new RegExp(r'[^:$]+'), errorMessage: 'Expected a string.')
        .value((r) => r.span.text);
final Parser credentials = chain([
  string.opt(),
  match(':'),
  string.opt(),
]).map((r) => {'username': r.value[0], 'password': r.value[2]});

// A parser nested within another?
final Parser credentialString =
    match(new RegExp(r'([^\n$]+)'), errorMessage: 'Expected a credential string.')
        .value((r) {
  var decoded = UTF8
      .decode(BASE64URL.decode(r.span.text));
  var scanner = new SpanScanner(decoded);
  return credentials.parse(scanner).value;
});

final Parser basic = match('Basic').space();

final Parser basicAuth = basic.then(credentialString).index(1);

main() {
  while (true) {
    stdout.write('Enter a basic auth value: ');
    var line = stdin.readLineSync();
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var result = basicAuth.parse(scanner);

    if (!result.successful) {
      for (var error in result.errors) {
        print(error.toolString);
        print(error.span.highlight(color: true));
      }
    } else
      print(result.value);
  }
}
