part of lex.src.combinator;

class _Cache<T> extends Parser<T> {
  final Map<int, ParseResult<T>> _cache = {};
  final Parser<T> parser;

  _Cache(this.parser);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    return _cache.putIfAbsent(scanner.position, () {
      return parser.parse(scanner, depth + 1);
    }).change(parser: this);
  }
}
