
library grill.example.barista;

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