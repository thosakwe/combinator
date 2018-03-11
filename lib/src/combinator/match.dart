part of lex.src.combinator;

/// Expects to match a given [pattern]. If it is not matched, you can provide a custom [errorMessage].
Parser<T> match<T>(Pattern pattern,
        {String errorMessage, SyntaxErrorSeverity severity}) =>
    new _Match<T>(pattern, errorMessage, severity ?? SyntaxErrorSeverity.error);

class _Match<T> extends Parser<T> {
  final Pattern pattern;
  final String errorMessage;
  final SyntaxErrorSeverity severity;

  _Match(this.pattern, this.errorMessage, this.severity);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    if (!scanner.scan(pattern))
      return new ParseResult(this, false, [
        new SyntaxError(
          severity,
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

  @override
  void stringify(CodeBuffer buffer) {
    buffer.writeln('match($pattern)');
  }
}
