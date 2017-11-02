part of lex.src.combinator;

class _Compare<T> extends ListParser<T> {
  final ListParser<T> parser;
  final Comparator<T> compare;

  _Compare(this.parser, this.compare);

  @override
  ParseResult<List<T>> parse(SpanScanner scanner, [int depth = 1]) {
    var result = parser.parse(scanner, depth + 1);
    if (!result.successful) return result;

    result = result.change(
        value: result.value?.isNotEmpty == true ? result.value : []);
    result = result.change(value: new List<T>.from(result.value));
    return new ParseResult<List<T>>(
      this,
      true,
      [],
      span: result.span,
      value: result.value..sort(compare),
    );
  }
}
