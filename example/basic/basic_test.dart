
library prompt.example.basic.test;

import 'package:mock/mock.dart';
import 'package:prompt/testing.dart';
import 'package:unittest/unittest.dart';

import 'basic.dart';

main() {
  group('add3', () {
    test('should not allow doubters to ask any furthers questions', () {
      var mockPrompt = new MockPrompt((question) {
        if (question == Add3Questions.confident) return false;
        if (question == Add3Questions.addend) throw 'Asked doubter for addends';
        throw 'Unrecognized question';
      });

      var sum = add3(mockPrompt);

      expect(sum, isNull);
    });

    test('should calculate sum for believers', () {
      var mockPrompt = new MockPrompt((question) {
        if (question == Add3Questions.confident) return true;
        if (question == Add3Questions.addend) return 5;
        throw 'Unrecognized question';
      });

      var sum = add3(mockPrompt);

      mockPrompt.askLogs(Add3Questions.addend).verify(happenedExactly(3));
      expect(sum, 15);
    });
  });
}
