part of lex.src.combinator;

class _Value<T> extends Parser<T> {
  final Parser<T> combinator;
  final T Function(ParseResult<T>) f;

  _Value(this.combinator, this.f);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var result = combinator.parse(scanner, depth + 1).change(parser: this);
    return result.successful ? result.change(value: f(result)) : result;
  }
}