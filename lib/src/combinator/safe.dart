part of lex.src.combinator;

class _Safe<T> extends Parser<T> {
  final Parser<T> parser;
  final bool backtrack;
  final String errorMessage;
  final SyntaxErrorSeverity severity;
  bool _triggered;

  _Safe(this.parser, this.backtrack, this.errorMessage, this.severity);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    var replay = scanner.position;

    try {
      if (_triggered) throw null;
      return parser.parse(scanner, depth + 1);
    } catch (_) {
      _triggered = true;
      if (backtrack) scanner.position = replay;
      var errors = <SyntaxError>[];

      if (errorMessage != null) {
        // TODO: Custom severity for all errors?
        errors.add(
          new SyntaxError(
            severity,
            errorMessage,
            scanner.lastSpan ?? scanner.emptySpan,
          ),
        );
      }

      return new ParseResult<T>(this, false, errors);
    }
  }
}
