part of lex.src.combinator;

/// Matches any one of the given [parsers].
///
/// If [backtrack] is `true` (default), a failed parse will not modify the scanner state.
///
/// You can provide a custom [errorMessage].
Parser<T> any<T>(Iterable<Parser<T>> parsers,
    {bool backtrack: true, String errorMessage}) {
  return new _Any(parsers, backtrack != false, errorMessage);
}

class _Any<T> extends Parser<T> {
  final Iterable<Parser<T>> parsers;
  final bool backtrack;
  final String errorMessage;

  _Any(this.parsers, this.backtrack, this.errorMessage);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var errors = <SyntaxError>[];
    int replay = scanner.position;

    for (var parser in parsers) {
      var result = parser.parse(scanner, depth + 1);

      if (result.successful)
        return result;
      else {
        if (backtrack) scanner.position = replay;

        if (parser is _Alt) {
          var alt = parser as _Alt;

          if (alt.errorMessage != null) {
            errors.add(
              new SyntaxError(
                SyntaxErrorSeverity.error,
                alt.errorMessage,
                result.span ?? scanner.lastSpan ?? scanner.emptySpan,
              ),
            );
          }
            errors.addAll(result.errors);
        }
      }
    }

    errors.add(
      new SyntaxError(
        SyntaxErrorSeverity.error,
        errorMessage ?? 'No match found for ${parsers.length} alternative(s)',
        scanner.emptySpan,
      ),
    );

    return new ParseResult(this, false, errors);
  }
}
