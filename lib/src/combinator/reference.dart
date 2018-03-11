part of lex.src.combinator;

Reference<T> reference<T>() => new Reference<T>._();

class Reference<T> extends Parser<T> {
  Parser<T> _parser;
  bool printed = false;

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
      throw new StateError('There is no parser assigned to this reference.');
    return _parser.parse(scanner, depth + 1);
  }

  @override
  void stringify(CodeBuffer buffer) {
    if (_parser == null)
      buffer.writeln('(undefined reference <$T>)');
    else if (!printed)
      _parser.stringify(buffer);
    printed = true;
    buffer.writeln('(previously printed reference)');
  }
}
