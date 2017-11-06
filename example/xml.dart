// For some reason, this cannot be run in checked mode???

import 'dart:io';
import 'package:combinator/combinator.dart';
import 'package:string_scanner/string_scanner.dart';

Parser xmlGrammar() {
  final Parser<String> key = match(new RegExp(r'([A-Za-z]+-)*[A-Za-z]+'),
          errorMessage: 'Expected a key.')
      .value((r) => r.span.text);

  final Parser<String> string =
      match(new RegExp(r'"[^"]*"'), errorMessage: 'Expected a string.').value(
    (r) => r.span.text.substring(1, r.span.text.length - 1),
  );

  final Parser<Attribute> attribute = chain([key, match('='), string])
      .map<Attribute>((r) => new Attribute(r.value[0], r.value[2]));

  final Parser leadingTag = chain([
    match('<'),
    key.space(),
    attribute.space().star().opt(),
    match('>'),
  ]);

  Parser closingTag = chain([
    match('<'),
    match('/'),
    key,
    match('>'),
  ]);

  final Reference tag = reference();

  var fullTag = chain([leadingTag.space(), closingTag]).change((r) {
    var openingKey = r.value[0][1];
    var attrs = r.value[0][2];
    var closingKey = r.value[1][2];

    if (closingKey != openingKey) {
      return r.change(successful: false).addErrors([
        new SyntaxError(
          SyntaxErrorSeverity.warning,
          'Mismatched opening/closing tags: $openingKey and $closingKey',
          r.span,
        ),
      ]);
    }

    return r;
  }).map<Tag>((r) {
    var key = r.value[0][1];
    var attrs = r.value[0][2] ?? [];
    return new Tag(key, attrs);
  });

  tag.parser = fullTag;

  return tag.foldErrors();
}

main() {
  var xml = xmlGrammar();

  while (true) {
    stdout.write('Enter an XML string: ');
    var line = stdin.readLineSync();
    var scanner = new SpanScanner(line, sourceUrl: 'stdin');
    var result = xml.foldErrors().parse(scanner);

    if (!result.successful) {
      for (var error in result.errors) {
        print(error.toolString);
        print(error.span.highlight(color: true));
      }
    } else
      print(result.value);
  }
}

class Attribute {
  final String key, value;
  Attribute(this.key, this.value);

  @override
  String toString() => '$key=$value';
}

class Tag {
  final String key;
  final List<Attribute> attributes;
  Tag(this.key, this.attributes);

  @override
  String toString() {
    if (attributes.isEmpty) return key;
    var selector = key + '[' + attributes.join(',') + ']';
    return selector;
  }
}
