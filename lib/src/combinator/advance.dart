part of lex.src.combinator;

class _Advance<T> extends Parser<T> {
  final Parser<T> parser;
  final int amount;

  _Advance(this.parser, this.amount);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1).change(parser: this);
    if (result.successful) scanner.position += amount;
    return result;
  }

  @override
  void stringify(CodeBuffer buffer) {
    buffer..writeln('advance($amount) (')..indent();
    parser.stringify(buffer);
    buffer..outdent()..writeln(')');
  }
}
