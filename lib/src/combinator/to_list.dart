part of lex.src.combinator;

class _ToList<T> extends ListParser<T> {
  final Parser<T> parser;

  _ToList(this.parser);

  @override
  ParseResult<List<T>> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);

    if (result.value is List) {
      return (result as ParseResult<List<T>>).change(parser: this);
    }

    return new ParseResult(
      this,
      result.successful,
      result.errors,
      span: result.span,
      value: [result.value],
    );
  }
}
