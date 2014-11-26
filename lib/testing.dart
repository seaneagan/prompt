
library grill.testing;

import 'dart:async';

import 'package:mock/mock.dart';

import 'src/prompt.dart';
import 'src/question.dart';
import 'src/util.dart';

class MockPrompt extends Mock implements Prompt {
  factory MockPrompt(answerer(Question question)) {
    var _mockPrompt = new _MockPrompt(answerer);
    var mockPrompt = new MockPrompt._(_mockPrompt);
    _mockPrompt.spy = mockPrompt;
    return mockPrompt;
  }

  factory MockPrompt.map(Map<Question, dynamic> answerMap) =>
      new MockPrompt((Question question) => answerMap[question]);

  MockPrompt._(_MockPrompt _mockPrompt)
      : super.spy(_mockPrompt);

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  LogEntryList askLogs([question]) => getLogs(question == null ?
      callsTo('_mockAsk') : callsTo('_mockAsk', question));
}

class _MockPrompt extends Prompt {

  bool _closed = false;
  final _Answerer _answerer;
  MockPrompt spy;

  _MockPrompt(answerer(Question question)) : _answerer = answerer;

  Future ask(question) => new Future(() {
    if (_closed) throw new StateError('The prompt is already closed');
    return _ask(question);
  });

  askSync(question) => _ask(question);

  _ask(question) {
    spy._mockAsk(question);
    return _answerer(toQuestion(question));
  }

  _mockAsk(question) {}

  close() => _closed = true;
}

typedef _Answerer(Question question);
