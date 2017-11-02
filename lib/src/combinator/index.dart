part of lex.src.combinator;

class _Index<T> extends Parser<T> {
  final ListParser<T> parser;
  final int index;

  _Index(this.parser, this.index);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);
    var value;

    if (result.successful)
      value = index == -1 ? result.value.last : result.value.elementAt(index);

    return new ParseResult<T>(
      this,
      result.successful,
      result.errors,
      span: result.span,
      value: value,
    );
  }
}
