
library prompt.prompt;

import 'dart:async';
import 'dart:io';

import 'question.dart';
import 'stdio.dart';
import 'theme.dart';
import 'util.dart';
import 'package:when/when.dart';

/// A command-line prompt used to [ask] (or [askSync]) [Question]s.
class Prompt {

  /// The max attempts a user has to give a valid answer to a question.
  final int maxTries;

  final _theme = new PromptTheme();

  Prompt({this.maxTries: 3});

  /// Ask a [question] asynchronously.
  ///
  /// [question] can be a [String] (representing [Question.message]) or a
  /// [Question].
  ///
  /// You must call [close] to close [stdin] when you are done asking
  /// questions with this method.  This is not required when using only
  /// [askSync].
  Future ask(question) => _ask(question, readLine);

  /// Ask a [question] ssynchronously.
  ///
  /// [question] can be a [String] (representing [Question.message]) or a
  /// [Question].
  askSync(question) => _ask(question, stdin.readLineSync);

  _ask(question, getAnswer, {int tryCount: 1}) {
    var q = toQuestion(question);
    var output = _theme.formatQuestion(q, tryCount: tryCount);
    stdout.write(output);
    bool originalEchoMode;
    if(q.secret) {
      originalEchoMode = stdin.echoMode;
      stdin.echoMode = false;
    }
    return when(getAnswer, onSuccess: (answer) {
      if (answer == null) {
        stdout.writeln(_theme.formatError('No answer received.'));
      }

      if (q.secret) {
        stdin.echoMode = originalEchoMode;
        stdout.writeln();
      }
      var validated;
      try {
        validated = q.validateAnswer(answer);
      } catch (e) {
        stdout.writeln(_theme.formatError(e));
        if (tryCount < maxTries) {
          return _ask(q, getAnswer, tryCount: tryCount + 1);
        } else {
          stdout.writeln(_theme.formatError('Max tries ($maxTries) reached.'));
        }
      }
      return validated;
    });
  }

  /// Close the prompt.
  ///
  /// Call this when you no longer need to [ask] any more questions.  You do
  /// not need to call this method if you only use [askSync].
  close() => linesIterator.cancel();
}
