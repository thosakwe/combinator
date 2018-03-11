part of lex.src.combinator;

/// Handles left recursion in a grammar using the Pratt algorithm.
class Recursion<T> {
  Iterable<Parser<T>> prefix;
  Map<Parser, T Function(T, ParseResult, SpanScanner)> infix;
  Map<Parser, T Function(T, ParseResult, SpanScanner)> postfix;

  Recursion(
      {this.prefix, this.infix, this.postfix}) {
        prefix ??= [];
        infix ??= {};
        postfix ??= {};
  }

  Parser<T> precedence(int p) => new _Precedence(this, p);

  void stringify(CodeBuffer buffer) {
    buffer
      ..writeln('recursion (')
      ..indent()
      ..writeln('prefix(${prefix.length}')
      ..writeln('infix(${infix.length}')
      ..writeln('postfix(${postfix.length}')
      ..outdent()
      ..writeln(')');
  }
}

class _Precedence<T> extends Parser<T> {
  final Recursion r;
  final int precedence;

  _Precedence(this.r, this.precedence);

  @override
  ParseResult<T> parse(SpanScanner scanner, [int depth = 1]) {
    int replay = scanner.position;
    var errors = <SyntaxError>[];
    var start = scanner.state;

    for (var pre in r.prefix) {
      var result = pre.parse(scanner, depth + 1);

      if (!result.successful) {
        if (pre is _Alt) errors.addAll(result.errors);
        scanner.position = replay;
      } else {
        var left = result.value;
        replay = scanner.position;

        while (true) {
          bool matched = false;

          for (int i = 0; i < r.infix.length; i++) {
            var fix = r.infix.keys.elementAt(i);

            if (precedence < i) {
              var result = fix.parse(scanner, depth + 1);
              if (!result.successful) {
                if (fix is _Alt) errors.addAll(result.errors);
                scanner.position = replay;
              } else {
                matched = true;
                left = r.infix[fix](left, result, scanner);
                break;
              }
            }
          }

          if (!matched) break;
        }

        replay = scanner.position;

        for (var post in r.postfix.keys) {
          var result = pre.parse(scanner, depth + 1);

          if (!result.successful) {
            if (post is _Alt) errors.addAll(result.errors);
            scanner.position = replay;
          } else {
            left = r.infix[post](left, result, scanner);
          }
        }

        return new ParseResult(
          this,
          true,
          errors,
          value: left,
          span: scanner.spanFrom(start),
        );
      }
    }

    return new ParseResult(
      this,
      false,
      errors,
      span: scanner.spanFrom(start),
    );
  }

  @override
  void stringify(CodeBuffer buffer) {
    buffer
      ..writeln('precedence($precedence) (')
      ..indent();
    r.stringify(buffer);
    buffer
      ..outdent()
      ..writeln(')');
  }
}
