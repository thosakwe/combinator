import 'package:combinator/combinator.dart';
import 'package:test/test.dart';
import 'common.dart';

main() {
  test('negate', () {
    var parser = match('hello').negate(errorMessage: 'world');
    expect(parser.parse(scan('goodbye world')).successful, isTrue);
    expect(parser.parse(scan('hello world')).successful, isFalse);
    expect(parser.parse(scan('hello world')).errors.first.message, 'world');
  });

  group('opt', () {
    var single = match('hello').opt(backtrack: true);
    var list = match('hel').then(match('lo')).opt();

    test('succeeds if present', () {
      expect(single.parse(scan('hello')).successful, isTrue);
      expect(list.parse(scan('hello')).successful, isTrue);
    });

    test('succeeds if not present', () {
      expect(single.parse(scan('goodbye')).successful, isTrue);
      expect(list.parse(scan('goodbye')).successful, isTrue);
    });

    test('backtracks if not present', () {
      for (var parser in [single, list]) {
        var scanner = scan('goodbye');
        var pos = scanner.position;
        parser.parse(scanner);
        expect(scanner.position, pos);
      }
    });
  });
}
