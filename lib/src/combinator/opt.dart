part of lex.src.combinator;

class _Opt<T> extends Parser<T> {
  final Parser<T> parser;
  final bool backtrack;

  _Opt(this.parser, this.backtrack);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var replay = scanner.position;
    var result = parser.parse(scanner, depth + 1);

    if (!result.successful) scanner.position = replay;

    return result.change(parser: this, successful: true);
  }

  @override
  void stringify(CodeBuffer buffer) {
    buffer..writeln('optional (')..indent();
    parser.stringify(buffer);
    buffer..outdent()..writeln(')');
  }
}

class _ListOpt<T> extends ListParser<T> {
  final ListParser<T> parser;
  final bool backtrack;

  _ListOpt(this.parser, this.backtrack);

  @override
  ParseResult<List<T>> parse(SpanScanner scanner, [int depth = 1]) {
    var replay = scanner.position;
    var result = parser.parse(scanner, depth + 1);

    if (!result.successful) scanner.position = replay;

    return result.change(parser: this, successful: true);
  }

  @override
  void stringify(CodeBuffer buffer) {
    buffer..writeln('optional (')..indent();
    parser.stringify(buffer);
    buffer..outdent()..writeln(')');
  }
}
