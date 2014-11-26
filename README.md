grill
=====

Grill your ~~suspects~~ users for answers at the ~~stand~~ command-line prompt.

##Install

```shell
pub global activate den
den install grill
```

##Usage

```dart
// barista_test.dart

import 'package:grill/grill.dart';

import 'coffee_order.dart';
import 'serve.dart';

main() {
  var order = takeOrder(prompt);
  print(serve(order));
}

CoffeeOrder takeOrder(Prompt prompt) {
  var item = prompt.askSync(Questions.item);
  var double = (item == 'Espresso') ?
      prompt.askSync(Questions.double) : false;
  var size = prompt.askSync(Questions.size);
  var iced = prompt.askSync(Questions.iced);
  var straw = iced ?
      prompt.askSync(Questions.straw) : false;
  var name = prompt.askSync(Questions.name);

  return new CoffeeOrder(item: item, size: size, iced: iced, name: name,
      double: double, straw: straw);
}

class Questions {
  static final item = new Question('What can I get for you', allowed:
      ['Coffee', 'Espresso', 'Cappucino', 'Mocha', 'Chai']);
  static final double = new Question.confirm('Double', defaultValue: false);
  static final size = new Question('What size', allowed:
      ['Short', 'Tall', 'Grande']);
  static final iced = new Question.confirm('Iced', defaultValue: false);
  static final straw = new Question.confirm('Straw', defaultValue: false);
  static final name = new Question('Name');

  static final List<Question> all = [item, double, size, iced, straw, name];
}
```

```
// barista_test.dart

import 'package:grill/testing.dart';
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

```