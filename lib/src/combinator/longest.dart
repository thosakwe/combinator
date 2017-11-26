part of lex.src.combinator;

/// Matches any one of the given [parsers].
///
/// You can provide a custom [errorMessage].
Parser<T> longest<T>(Iterable<Parser<T>> parsers,
    {String errorMessage, SyntaxErrorSeverity severity}) {
  return new _Longest(
      parsers, errorMessage, severity ?? SyntaxErrorSeverity.error);
}

class _Longest<T> extends Parser<T> {
  final Iterable<Parser<T>> parsers;
  final String errorMessage;
  final SyntaxErrorSeverity severity;

  _Longest(this.parsers, this.errorMessage, this.severity);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    int replay = scanner.position;
    var errors = <SyntaxError>[];
    var results = <ParseResult<T>>[];

    for (var parser in parsers) {
      var result = parser.parse(scanner, depth + 1);

      if (result.successful)
        results.add(result);
      else if (parser is _Alt) errors.addAll(result.errors);

      scanner.position = replay;
    }

    if (results.isNotEmpty) {
      results.sort((a, b) => b.span.length.compareTo(a.span.length));
      scanner.scan(results.first.span.text);
      return results.first;
    }

    errors.add(
      new SyntaxError(
        severity,
        errorMessage ?? 'No match found for ${parsers.length} alternative(s)',
        scanner.emptySpan,
      ),
    );

    return new ParseResult(this, false, errors);
  }
}
