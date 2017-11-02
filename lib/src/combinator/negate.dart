part of lex.src.combinator;

class _Negate<T> extends Parser<T> {
  final Parser<T> parser;
  final String errorMessage;

  _Negate(this.parser, this.errorMessage);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1).change(parser: this);

    if (!result.successful) {
      return new ParseResult<T>(
        this,
        true,
        [],
        span: result.span ?? scanner.lastSpan ?? scanner.emptySpan,
        value: result.value,
      );
    }

    result = result.change(successful: false);

    if (errorMessage != null) {
      result = result.addErrors([
        new SyntaxError(
          SyntaxErrorSeverity.error,
          errorMessage,
          result.span,
        ),
      ]);
    }

    return result;
  }
}
