
library grill.prompt;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'question.dart';
import 'when.dart';

/// A command-line prompt which can be used to [ask] [Question]s.
///
/// Questions can also be asked synchronously via [askSync].
class Prompt {

  final String prompt = '> ';
  final int maxTries = 3;

  String formatQuestion(Question question) => question.message;
  String formatHint(Question question) {
    var allowed = question.allowed;
    if(allowed is Iterable) {
      if(allowed.every((item) => item.length == 1)) {
        return '(${allowed.join('/')}) ';
      }
      var buffer = new StringBuffer('\n');
      allowed.toList().asMap().forEach((index, value) => buffer.write('  ${index + 1}) $value\n'));
      buffer.write(prompt);
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
  /// [question] can be a [String] (representing [Question.message]) or a [Question].
  askSync(question) => _ask(question, stdin.readLineSync);

  _ask(question, getAnswer, [int tryCount = 1]) {
    var q = _question(question);
    var output = '$prompt${formatQuestion(q)}: ${formatHint(q)}';
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
        if (tryCount < maxTries) {
          return _ask(q, getAnswer, tryCount + 1);
        } else {
          stdout.writeln('error: Max tries ($maxTries) reached.');
        }
      }
      return validated;
    });
  }

  Question _question(question) => question is Question ? question : new Question(question);

  /// Close the prompt.
  ///
  /// Call this when you no longer need to [ask] any more questions.  You do
  /// not need to call this method if you only use [askSync].
  close() => linesIterator.cancel();
}

Future<String> readLine() => linesIterator.moveNext().then((_) => linesIterator.current);
StreamIterator linesIterator = new StreamIterator(_lines);
final _lines = stdin.transform(UTF8.decoder).transform(const LineSplitter());
