
import 'dart:async';

import 'package:grill/grill.dart';

main() {
  print('Sync:\n');
  displayAnswers(questions.map(askSync).toList());

  print('Async:\n');
  new Stream.fromIterable(questions)
      .asyncMap(ask)
      .toList()
      .whenComplete(prompt.close)
      .then(displayAnswers);
}

var questions = [
  'Name',
  new Question('Password', secret: true),
  new Question.confirm('Like kittens'),
  new Question('Favorite color', allowed: ['red', 'green', 'blue'])
];

displayAnswers(List answers) {
  print('');
  for(int i = 0; i < answers.length; i++) {
    var q = questions[i];
    var a = answers[i];
    var message = q is Question ? q.message : q;
    print('$message: $a');
  }
  print('');
}
