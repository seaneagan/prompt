
library grill.testing;

import 'dart:async';

import 'prompt.dart';
import 'question.dart';
import 'util.dart';

class MockPrompt extends Prompt {

  bool _closed = false;
  final Answerer _answerer;

  MockPrompt(this._answerer);
  factory MockPrompt.map(Map<Question, dynamic> answerMap) =>
      new MockPrompt((Question question) => answerMap[question]);

  Future ask(question) => new Future(() {
    if (_closed) throw new StateError('The prompt is already closed');
    return _ask(question);
  });

  askSync(question) => _ask(question);

  _ask(question) => _answerer(toQuestion(question));

  close() => _closed = true;
}

typedef Answerer(Question question);
