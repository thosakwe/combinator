part of lex.src.combinator;

Reference<T> reference<T>() => new Reference<T>._();

class Reference<T> extends Parser<T> {
  Parser<T> _parser;

  Reference._();

  void set parser(Parser<T> value) {
    if (_parser != null)
      throw new StateError(
          'There is already a parser assigned to this reference.');
    _parser = value;
  }

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    if (_parser == null)
      throw new StateError(
          'There is no parser assigned to this reference.');
    return _parser.parse(scanner, depth + 1);
  }
}
