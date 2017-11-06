library lex.src.combinator;

import 'package:matcher/matcher.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';
import '../error.dart';
part 'any.dart';
part 'advance.dart';
part 'cache.dart';
part 'cast.dart';
part 'chain.dart';
part 'check.dart';
part 'compare.dart';
part 'fold_errors.dart';
part 'index.dart';
part 'longest.dart';
part 'map.dart';
part 'match.dart';
part 'max_depth.dart';
part 'negate.dart';
part 'opt.dart';
part 'reduce.dart';
part 'reference.dart';
part 'repeat.dart';
part 'safe.dart';
part 'to_list.dart';
part 'value.dart';

abstract class Parser<T> {
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]);

  /// Skips forward a certain amount of steps after parsing, if it was successful.
  Parser<T> forward(int amount) => new _Advance<T>(this, amount);

  Parser<T> back(int amount) => new _Advance<T>(this, amount * -1);

  Parser<U> cast<U extends T>() => new _Cast<T, U>(this);

  Parser<dynamic> castDynamic() => new _CastDynamic<T>(this);

  Parser<U> change<U>(ParseResult<U> Function(ParseResult<T>) f) {
    return new _Change<T, U>(this, f);
  }

  /// Validates the parse result against a [Matcher].
  ///
  /// You can provide a custom [errorMessage].
  Parser<T> check(Matcher matcher, {String errorMessage}) =>
      new _Check<T>(this, matcher, errorMessage);

  /// Binds an [errorMessage] to a copy of this parser.
  Parser<T> error({String errorMessage}) => new _Alt<T>(this, errorMessage);

  /// Removes multiple errors that occur in the same spot; this can reduce noise in parser output.
  Parser<T> foldErrors() => new _FoldErrors<T>(this);

  Parser<U> map<U>(U Function(ParseResult<T>) f) {
    return new _Mapp<T, U>(this, f);
  }

  /// Prevents recursion past a certain [depth], preventing stack overflow errors.
  Parser<T> maxDepth(int depth) => new _MaxDepth<T>(this, depth);

  /// Ensures this pattern is not matched.
  ///
  /// You can provide an [errorMessage].
  Parser<T> negate({String errorMessage}) => new _Negate<T>(this, errorMessage);

  /// Caches the results of parse attempts at various locations within the source text.
  ///
  /// Use this to prevent excessive recursion.
  Parser<T> cache() => new _Cache<T>(this);

  Parser<T> or<U>(Parser other) => any<T>([this, other]);

  ListParser<T> plus() => times(1, exact: false);

  /// Safely escapes this parser when an error occurs.
  ///
  /// The generated parser only runs once; repeated uses always exit eagerly.
  Parser<T> safe({bool backtrack: true, String errorMessage}) =>
      new _Safe<T>(this, backtrack, errorMessage);

  /// Expects to see an infinite amounts of the pattern, separated by the [other] pattern.
  ///
  /// Use this as a shortcut to parse arrays, parameter lists, etc.
  ListParser<T> separatedBy(Parser other) {
    var trailed = then(other).map<T>((r) => r.value?.isNotEmpty == true ? r.value[0] : null);
    var leading = trailed.star(backtrack: true).opt();
    return leading.then(opt()).map((r) {
      var preceding = r.value[0] ?? [];
      var out = new List<T>.from(preceding);
      if (r.value[1] != null)
        out.add(r.value[1]);
      return out;
    }).toList();
  }

  /// Expects to see the pattern, surrounded by the others.
  ///
  /// If no [right] is provided, it expects to see the same pattern on both sides.
  /// Use this parse things like parenthesized expressions, arrays, etc.
  Parser<T> surroundedBy(Parser left, [Parser right]) {
    return chain([
      left,
      this,
      right ?? left,
    ]).index(1).castDynamic().cast<T>();
  }

  /// Consumes any trailing whitespace.
  Parser<T> space() => trail(new RegExp(r'[ \n\r\t]+'));

  ListParser<T> star({bool backtrack: true}) =>
      times(1, exact: false, backtrack: backtrack);

  ListParser<U> then<U>(Parser other) => chain<U>([this, other]);

  ListParser<T> toList() => new _ToList<T>(this);

  /// Consumes and ignores any trailing occurrences of [pattern].
  Parser<T> trail(Pattern pattern) =>
      then(match(pattern).opt()).first().cast<T>();

  /// Expect this pattern a certain number of times.
  ///
  /// If [exact] is `false` (default: `true`), then the generated parser will accept
  /// an infinite amount of occurrences after the specified [count].
  ///
  /// You can provide custom error messages for when there are [tooFew] or [tooMany] occurrences.
  ListParser<T> times(int count,
      {bool exact: true, String tooFew, String tooMany, bool backtrack: true}) {
    return new _Repeat<T>(this, count, exact, tooFew, tooMany, backtrack);
  }

  /// Produces an optional copy of this parser.
  ///
  /// If [backtrack] is `true` (default), then a failed parse will not
  /// modify the scanner state.
  Parser<T> opt({bool backtrack: true}) => new _Opt(this, backtrack);

  Parser<T> value(T Function(ParseResult<T>) f) {
    return new _Value<T>(this, f);
  }
}

abstract class ListParser<T> extends Parser<List<T>> {
  Parser<T> first() => index(0);

  Parser<T> index(int index) => new _Index<T>(this, index);

  Parser<T> last() => index(-1);

  Parser<T> reduce(T Function(T, T) combine) => new _Reduce<T>(this, combine);

  ListParser<T> sort(Comparator<T> compare) => new _Compare(this, compare);

  @override
  ListParser<T> opt({bool backtrack: true}) => new _ListOpt(this, backtrack);

  ListParser<T> where(bool Function(T) f) => map<List<T>>((r) => r.value.where(f).toList());
}

class ParseResult<T> {
  final Parser<T> parser;
  final bool successful;
  final Iterable<SyntaxError> errors;
  final FileSpan span;
  final T value;

  ParseResult(this.parser, this.successful, this.errors,
      {this.span, this.value});

  ParseResult change(
      {Parser<T> parser,
      bool successful,
      Iterable<SyntaxError> errors,
      FileSpan span,
      T value}) {
    return new ParseResult<T>(
      parser ?? this.parser,
      successful ?? this.successful,
      errors ?? this.errors,
      span: span ?? this.span,
      value: value ?? this.value,
    );
  }

  ParseResult addErrors(Iterable<SyntaxError> errors) {
    return change(
      errors: new List<SyntaxError>.from(this.errors)..addAll(errors),
    );
  }
}
