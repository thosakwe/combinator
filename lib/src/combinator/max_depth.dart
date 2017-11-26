part of lex.src.combinator;

class _MaxDepth<T> extends Parser<T> {
  final Parser<T> parser;
  final int cap;

  _MaxDepth(this.parser, this.cap);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    if (depth > cap) {
      return new ParseResult<T>(this, false, []);
    }

    return parser.parse(scanner, depth + 1);
  }
}
