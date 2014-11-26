
library prompt.question;

/// A question.
class Question {

  final String message;
  final allowed;
  final String defaultValue;
  final bool secret;
  final parser;

  Question(this.message, {this.allowed, this.defaultValue,
      this.secret: false, this.parser});

  factory Question.confirm(String message, {bool defaultValue}) = _Confirm;

  bool get required => defaultValue == null;

  parse(String answer) {
    if (parser != null) {
      return parser(answer);
    }

    if (allowed is List) {
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

typedef _Unary(_);
