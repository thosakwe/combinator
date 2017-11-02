part of lex.src.combinator;

/// Expects to parse a sequence of [parsers].
///
/// If [failFast] is `true` (default), then the first failure to parse will abort the parse.
ListParser<T> chain<T>(Iterable<Parser> parsers, {bool failFast: true}) {
  return new _Chain<T>(parsers, failFast != false);
}

class _Alt<T> extends Parser<T> {
  final Parser<T> parser;
  final String errorMessage;

  _Alt(this.parser, this.errorMessage);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    return parser.parse(scanner, depth + 1);
  }
}

class _Chain<T> extends ListParser<T> {
  final Iterable<Parser<T>> parsers;
  final bool failFast;

  _Chain(this.parsers, this.failFast);

  @override
  ParseResult<List<T>> parse(SpanScanner scanner, [int depth = 1]) {
    var errors = <SyntaxError>[];
    var results = <T>[];
    var spans = <FileSpan>[];
    bool successful = true;

    for (var parser in parsers) {
      var result = parser.parse(scanner, depth + 1);

      if (!result.successful) {
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
          } else
            errors.addAll(result.errors);
        }

        if (failFast) {
          return new ParseResult(this, false, result.errors);
        }

        successful = false;
      }

      results.add(result.value);

      if (result.span != null) spans.add(result.span);
    }

    FileSpan span;

    if (spans.isNotEmpty) {
      span = spans.reduce((a, b) => a.expand(b));
    }

    return new ParseResult<List<T>>(
      this,
      successful,
      errors,
      span: span,
      value: new List<T>.unmodifiable(results),
    );
  }
}
