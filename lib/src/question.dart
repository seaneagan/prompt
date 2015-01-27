
library prompt.question;

/// An information request to the user.
class Question {

  /// The question text.
  final String message;

  /// The allowed answers.
  ///
  /// Must be one of:
  ///
  /// * `Iterable`
  /// * `Map<String, dynamic>` from abbreviations (preferably 1-letter) to
  ///   corresponding answers.
  /// * `null`
  final allowed;

  /// The default if no answer is provided.
  final defaultsTo;

  /// Whether to keep the answer secret by masking the typed keys.
  ///
  /// Useful for passwords.
  final bool secret;

  /// Custom answer text parser.
  final parser;

  Question(this.message, {this.allowed, this.defaultsTo,
      this.secret: false, this.parser});

  factory Question.confirm(String message, {bool defaultsTo}) = _Confirm;

  bool get required => defaultsTo == null;

  parse(String answer) {
    if (parser != null) {
      return parser(answer);
    }

    if (allowed is List) {
      badIndex() {
        throw 'Please enter an integer in (1..${allowed.length})';
      }
      var choice;
      try {
        choice = int.parse(answer);
      }
      catch (e) {
        badIndex();
      }
      if(choice < 1 || choice > allowed.length) badIndex();
      return allowed[choice - 1];
    }

    if (allowed is Map) {
      if (allowed.containsKey(answer)) {
        return allowed[answer];
      } else {
        throw 'Please enter one of (${allowed.keys.join(', ')})';
      }
    }

    return answer;
  }

  validateAnswer(String answer) {
    if (answer.isEmpty) {
      if (required) {
        throw 'Response is required';
      }

      return defaultsTo;
    }

    return parse(answer);
  }
}

class _Confirm extends Question {
  _Confirm(String message, {bool defaultsTo: false}) : super(message, allowed: const ['y', 'n'], defaultsTo: defaultsTo);

  bool parse(String answer) => ['y', 'yes'].contains(answer.toLowerCase());
}
