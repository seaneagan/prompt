
library prompt.example.barista.test;

import 'package:prompt/testing.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart';

import 'barista.dart';
import 'coffee_order.dart';

main() {
  group('takeOrder', () {
    test('should ask extra questions when needed', () {
      var answers = {
        Questions.item: 'Espresso',
        Questions.double: false,
        Questions.size: 'Tall',
        Questions.iced: true,
        Questions.straw: false,
        Questions.name: 'Bob'
      };

      var mockPrompt = new MockPrompt.map(answers);

      var order = takeOrder(mockPrompt);

      answers.keys.map(mockPrompt.askLogs).forEach((logs) =>
          logs.verify(happenedOnce));

      expect(order, new CoffeeOrder(item: 'Espresso', double: false,
          size: 'Tall', iced: true, straw: false, name: 'Bob'));
    });

    test('should not ask extra questions when not needed', () {
      var answers = {
        Questions.item: 'Coffee',
        Questions.size: 'Tall',
        Questions.iced: false,
        Questions.name: 'Bob'
      };

      var mockPrompt = new MockPrompt.map(answers);

      var order = takeOrder(mockPrompt);

      answers.keys.map(mockPrompt.askLogs).forEach((logs) =>
          logs.verify(happenedOnce));
      [Questions.double, Questions.straw]
          .map(mockPrompt.askLogs).forEach((logs) =>
              logs.verify(neverHappened));

      expect(order, new CoffeeOrder(item: 'Coffee', double: false,
          size: 'Tall', iced: false, straw: false, name: 'Bob'));
    });
  });
}
