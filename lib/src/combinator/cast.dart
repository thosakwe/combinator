part of lex.src.combinator;

class _Cast<T, U extends T> extends Parser<U> {
  final Parser<T> parser;

  _Cast(this.parser);

  @override
  ParseResult<U> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);
    return new ParseResult<U>(
      this,
      result.successful,
      result.errors,
      span: result.span,
      value: result.value,
    );
  }
}

class _CastDynamic<T> extends Parser<dynamic> {
  final Parser<T> parser;

  _CastDynamic(this.parser);

  @override
  ParseResult<dynamic> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);
    return new ParseResult<dynamic>(
      this,
      result.successful,
      result.errors,
      span: result.span,
      value: result.value,
    );
  }
}
