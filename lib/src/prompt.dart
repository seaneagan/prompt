
library prompt.prompt;

import 'dart:async';
import 'dart:io';

import 'stdio.dart';
import 'question.dart';
import 'util.dart';
import 'when.dart';

/// A command-line prompt used to [ask] (or [askSync]) [Question]s.
class Prompt {

  /// The string used to prompt the user for input.
  final String promptString;

  /// The max attempts a user has to give a valid answer to a question.
  final int maxAttempts;

  Prompt({this.maxAttempts: 3, this.promptString: '> '});

  /// Returns the output a user sees for a given [question].
  String formatQuestion(Question question) =>
      '$promptString${_formatMessage(question)}: ${_formatHint(question)}';

  String _formatMessage(Question question) => question.message;
  String _formatHint(Question question) {
    var allowed = question.allowed;
    if(allowed is Iterable) {
      if(allowed.every((item) => item.length == 1)) {
        return '(${allowed.join('/')}) ';
      }
      var buffer = new StringBuffer('\n');
      allowed.toList().asMap().forEach((index, value) =>
          buffer.write('  ${index + 1}) $value\n'));
      buffer.write(promptString);
      return buffer.toString();
    }
    return '';
  }

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

  _ask(question, getAnswer, [int tryCount = 1]) {
    var q = toQuestion(question);
    var output = '$promptString${_formatMessage(q)}: ${_formatHint(q)}';
    stdout.write(output);
    bool originalEchoMode;
    if(q.secret) {
      originalEchoMode = stdin.echoMode;
      stdin.echoMode = false;
    }
    return when(getAnswer, (answer) {
      if (answer == null) {
        stdout.writeln('error: No answer received.');
      }

      if (q.secret) {
        stdin.echoMode = originalEchoMode;
        stdout.writeln();
      }
      var validated;
      try {
        validated = q.validateAnswer(answer);
      } catch (e) {
        stdout.writeln('error: $e');
        if (tryCount < maxAttempts) {
          return _ask(q, getAnswer, tryCount + 1);
        } else {
          stdout.writeln('error: Max tries ($maxAttempts) reached.');
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
