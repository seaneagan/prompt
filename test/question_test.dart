
library prompt.test;

import 'package:prompt/src/question.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Question', () {

    group('required', () {
      test('should be true if when optional parameter is set', () {
        expect(new Question('foo').optional, isFalse);
        expect(new Question('foo', optional: true).optional, isTrue);
      });
    });

    group('validateAnswer', () {

      group('when allowed', () {

        group('is a List', () {

          var question = new Question('foo', allowed: [0.5, 3.14, 2.71]);

          test('should return corresponding element for an int in range', () {
            expect(question.validateAnswer('1'), 0.5);
            expect(question.validateAnswer('2'), 3.14);
            expect(question.validateAnswer('3'), 2.71);
          });

          test('should throw if not parseable as an int in range', () {
            expect(() => question.validateAnswer('0'), throws);
            expect(() => question.validateAnswer('4'), throws);
            expect(() => question.validateAnswer('0.5'), throws);
          });
        });

        group('is a Map', () {

          var question = new Question('foo', allowed: {'x': 1, 'y': 2, 'z': 3});

          test('should return corresponding value for a valid key', () {
            expect(question.validateAnswer('x'), 1);
            expect(question.validateAnswer('y'), 2);
            expect(question.validateAnswer('z'), 3);
          });

          test('should throw if not parseable as an int in range', () {
            expect(() => question.validateAnswer('a'), throws);
          });
        });
      });

      group('when answer empty', () {

        test('should return defaultsTo if not required (defaultsTo not null)', () {
          var question = new Question('foo', defaultsTo: 5);
          expect(question.validateAnswer(''), 5);
        });

        test('should throw if required (defaultsTo null)', () {
          var question = new Question('foo');
          expect(() => question.validateAnswer(''), throws);
        });
      });

      test('when answer not empty should not return defaultsTo', () {
        var question = new Question('foo', defaultsTo: 5);
        expect(question.validateAnswer('x'), 'x');
      });

      group('when parser provided', () {

        test('should return parser result', () {
          var question = new Question('foo', parser: int.parse);
          expect(question.validateAnswer('3'), 3);
        });

        test('should not catch parser error', () {
          var question = new Question('foo', parser: int.parse);
          expect(() => question.validateAnswer('x'), throwsFormatException);
        });
      });
    });
  });
}
