part of lex.src.combinator;

class _Reduce<T> extends Parser<T> {
  final ListParser<T> parser;
  final T Function(T, T) combine;

  _Reduce(this.parser, this.combine);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);

    if (!result.successful)
      return new ParseResult<T>(
        this,
        false,
        result.errors,
      );

    result = result.change(
        value: result.value?.isNotEmpty == true ? result.value : []);
    return new ParseResult<T>(
      this,
      result.successful,
      [],
      span: result.span,
      value: result.value.isEmpty ? null : result.value.reduce(combine),
    );
  }
}
