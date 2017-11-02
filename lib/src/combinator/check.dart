part of lex.src.combinator;

class _Check<T> extends Parser<T> {
  final Parser<T> parser;
  final Matcher matcher;
  final String errorMessage;

  _Check(this.parser, this.matcher, this.errorMessage);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var matchState = {};
    var result = parser.parse(scanner, depth + 1).change(parser: this);
    if (!result.successful)
      return result;
    else if (!matcher.matches(result.value, matchState)) {
      return result.change(successful: false).addErrors([
        new SyntaxError(
          SyntaxErrorSeverity.error,
          errorMessage ??
              matcher.describe(new StringDescription('Expected ')).toString() +
                  '.',
          result.span,
        ),
      ]);
    } else
      return result;
  }
}
