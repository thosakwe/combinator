part of lex.src.combinator;

class _Repeat<T> extends ListParser<T> {
  final Parser<T> parser;
  final int count;
  final bool exact, backtrack;
  final String tooFew, tooMany;
  final SyntaxErrorSeverity severity;

  _Repeat(this.parser, this.count, this.exact, this.tooFew, this.tooMany,
      this.backtrack, this.severity);

  @override
  ParseResult<List<T>> parse(SpanScanner scanner, [int depth = 1]) {
    var errors = <SyntaxError>[];
    var results = <T>[];
    var spans = <FileSpan>[];
    int success = 0, replay = scanner.position;
    ParseResult<T> result;

    do {
      result = parser.parse(scanner, depth + 1);
      if (result.successful) {
        success++;
        results.add(result.value);
        replay = scanner.position;
      } else if (backtrack) scanner.position = replay;

      if (result.span != null) spans.add(result.span);
    } while (result.successful);

    if (success < count) {
      errors.addAll(result.errors);
      errors.add(
        new SyntaxError(
          severity,
          tooFew ?? 'Expected at least $count occurence(s).',
          result.span ?? scanner.emptySpan,
        ),
      );

      if (backtrack) scanner.position = replay;

      return new ParseResult<List<T>>(this, false, errors);
    } else if (success > count && exact) {
      if (backtrack) scanner.position = replay;

      return new ParseResult<List<T>>(this, false, [
        new SyntaxError(
          severity,
          tooMany ?? 'Expected no more than $count occurence(s).',
          result.span ?? scanner.emptySpan,
        ),
      ]);
    }

    var span = spans.reduce((a, b) => a.expand(b));
    return new ParseResult<List<T>>(
      this,
      true,
      [],
      span: span,
      value: results,
    );
  }

  @override
  void stringify(CodeBuffer buffer) {
    var r = new StringBuffer('{$count');
    if (!exact) r.write(',');
    r.write('}');
    buffer..writeln('repeat($r) (')..indent();
    parser.stringify(buffer);
    buffer..outdent()..writeln(')');
  }
}
