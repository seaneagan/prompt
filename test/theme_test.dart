
library prompt.test;

import 'package:prompt/src/question.dart';
import 'package:prompt/src/theme.dart';
import 'package:unittest/unittest.dart';
import 'package:ansicolor/ansicolor.dart';

main() {
  group('PromptTheme', () {

    var theme;
    setUp(() {
      color_disabled = true;
      theme = new PromptTheme();
    });

    group('formatQuestion', () {

      test('should have have full output on first try', () {
        var q = new Question('foo');
        expect(theme.formatQuestion(q, 1), '? foo: ');
      });

      test('should merely prompt for more input on retries', () {
        var q = new Question('foo');
        expect(theme.formatQuestion(q, 2), '> ');
        expect(theme.formatQuestion(q, 3), '> ');
      });

      test('should show hints for confirmations', () {
        var q = new Question.confirm('agree');
        expect(theme.formatQuestion(q, 1), '? agree: (y/N) ');
      });

      test('should show inline hints for allowed List of single chars', () {
        var q = new Question('foo', allowed: ['x', 'y', 'z']);
        expect(theme.formatQuestion(q, 1), '? foo: (x/y/z) ');
      });

      test('should show indexed menu for allowed List with at least one multi-char element', () {
        var q = new Question('choose one', allowed: ['foo', 'bar', 'baz']);
        expect(theme.formatQuestion(q, 1), '''
? choose one: 
  1) foo
  2) bar
  3) baz
> ''');
      });

      test('should show menu of keys to values for allowed Map', () {
        var q = new Question('choose one', allowed: {'x': 1, 'y': 2, 'z': 3});
        expect(theme.formatQuestion(q, 1), '''
? choose one: 
  x) 1
  y) 2
  z) 3
> ''');
      });

      test('should omit : if message does not end with an alpha-numeric', () {
        expect(theme.formatQuestion(new Question('name *'), 1), '? name * ');
      });
    });

    test('formatError', () {
      expect(theme.formatError('e'), 'X e');
    });
  });
}
