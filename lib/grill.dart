
library grill;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

Prompt get prompt => _prompt;
Prompt _prompt = new Prompt();

/// Ask the user a [question].
///
/// [question] can be a [String] or [Question].
Future ask(question) => prompt.ask(question);

/// Ask the user a [question] synchronously.
///
/// [question] can be a [String] or [Question].
askSync(question) => prompt.askSync(question);

/// Confirm a [question] with the user.
Future<bool> confirm(String question, {bool defaultValue}) =>
    prompt.ask(new Question.confirm(question, defaultValue: defaultValue));

/// Confirm a [question] with the user synchronously.
bool confirmSync(String question, {bool defaultValue}) =>
    prompt.askSync(new Question.confirm(question, defaultValue: defaultValue));

class Question {

  final String message;
  final allowed;
  final String defaultValue;
  final bool secret;

  Question(this.message, {this.allowed, this.defaultValue, this.secret: false});

  factory Question.confirm(String message, {bool defaultValue}) = _Confirm;

  bool get required => defaultValue == null;

  parse(String answer) {
    if(allowed is List) {
      badAnswer() {
        throw 'Answer "$answer" is not an integer in (1..${allowed.length})';
      }
      var choice;
      try {
        choice = int.parse(answer);
      }
      catch (e) {
        badAnswer();
      }
      if(choice < 1 || choice > allowed.length) badAnswer();
      return allowed[choice - 1];
    }

    return answer;
  }

  validateAnswer(String answer) {
    if(answer == '' && required) {
      throw 'Response is required';
    }

    return parse(answer);
  }
}

class _Confirm extends Question {
  _Confirm(String message, {bool defaultValue: false}) : super(message, allowed: const ['y', 'n'], defaultValue: defaultValue == null ? null : (defaultValue ? 'y' : 'n'));

  bool parse(String answer) => ['y', 'yes'].contains(answer.toLowerCase());
}

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

  ask(question) => _ask(question, _readLine);

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

  close() => _linesIterator.cancel();
}

Future<String> _readLine() => _linesIterator.moveNext().then((hasCurrent) {
  print('hasCurrent: $hasCurrent, current: ${_linesIterator.current}');
  return _linesIterator.current;
});
StreamIterator _linesIterator = new StreamIterator(_lines);
final _lines = stdin.transform(UTF8.decoder).transform(const LineSplitter());

when(callback, onSuccess, [onError, onComplete]) {
  var result, hasResult = false;
  try {
    result = callback();
    hasResult = true;
  } catch (e) {
    if (onError) result = onError(e);
  }

  if (result is Future) {
    result = result.then(onSuccess, onError: onError);
    if (onComplete != null) result = result.whenComplete(onComplete);
  } else {
    if (hasResult) {
      result = onSuccess(result);
    }
    if (onComplete != null) onComplete();
  }

  return result;
}
