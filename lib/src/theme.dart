
library prompt.theme;

import 'package:ansicolor/ansicolor.dart';

import 'question.dart';
import 'util.dart';

class PromptTheme {
  final _allowedPen = new AnsiPen();
  final _allowedHelpPen = new AnsiPen();
  final _errorPen = new AnsiPen()..red(bold: true);
  final _inputPromptPen = new AnsiPen()..white(bold: true);
  final _messagePen = new AnsiPen()..white(bold: true);
  final _prefixPen = new AnsiPen()..green();

  /// The prefix before the question's message.
  String get prefix {
    if (_prefix == null) {
      _prefix = _prefixPen('?');
    }
    return _prefix;
  }
  String _prefix;

  /// The string used to prompt the user for input.
  String get inputPrompt {
    if (_inputPrompt == null) {
      _inputPrompt = _inputPromptPen('>');
    }
    return _inputPrompt;
  }
  String _inputPrompt;

  String get _fullInputPrompt => '$inputPrompt ';

  PromptTheme({String prefix, String inputPrompt})
      : _prefix = prefix,
        _inputPrompt = inputPrompt {
    initAnsicolor();
  }

  /// Returns the output a user sees for a given [question].
  String formatQuestion(Question question, int tryCount) =>
      tryCount > 1 ?
          _fullInputPrompt :
          '$prefix ${_messagePen(formatMessage(question))}${formatHint(question)}';

  String formatMessage(Question question) {
    var message = question.message;

    return (new RegExp(r'([a-z1-9])$', caseSensitive: false).hasMatch(message) ? message + ":" : message).trim() + " ";
  }

  String formatHint(Question question) {
    var allowed = question.allowed;

    if (allowed is Iterable) {
      allowed = allowed.map((v) => v.toString());
      if (allowed.every((item) => item.length == 1)) {
        return '(${allowed.map(_allowedPen).join('/')}) ';
      }

      var allowedAsMap = {};
      allowed.toList().asMap().forEach((index, value) {
        allowedAsMap[(index + 1).toString()] = value;
      });
      allowed = allowedAsMap;
    }

    if (allowed is Map) {
      var buffer = new StringBuffer('\n');
      allowed.forEach((key, value) =>
          buffer.write('  ${_allowedPen(key.toString())}) ${_allowedHelpPen(value.toString())}\n'));
      buffer.write(_fullInputPrompt);
      return buffer.toString();
    }
    return '';
  }

  String formatError(String error) => '${_errorPen('X')} $error';
}
