part of lex.src.combinator;

/// Expects to match a given [pattern]. If it is not matched, you can provide a custom [errorMessage].
Parser<T> match<T>(Pattern pattern, {String errorMessage}) =>
    new _Match<T>(pattern, errorMessage);

class _Match<T> extends Parser<T> {
  final Pattern pattern;
  final String errorMessage;

  _Match(this.pattern, this.errorMessage);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    if (!scanner.scan(pattern))
      return new ParseResult(this, false,  [
        new SyntaxError(
          SyntaxErrorSeverity.error,
          errorMessage ?? 'Expected "$pattern".',
          scanner.emptySpan,
        ),
      ]);
    return new ParseResult<T>(
      this,
      true,
      [],
      span: scanner.lastSpan,
    );
  }
}
