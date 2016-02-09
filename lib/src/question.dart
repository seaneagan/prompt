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

  /// Choice formatter.
  final formatter;

  // Optional flag
  final bool optional;

  Question(this.message,
      {this.allowed,
      this.defaultsTo,
      this.secret: false,
      this.parser,
      this.formatter,
      this.optional: false});

  factory Question.confirm(String message, {bool defaultsTo}) = _Confirm;

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
      } catch (e) {
        badIndex();
      }
      if (choice < 1 || choice > allowed.length) badIndex();
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
      if (!optional && defaultsTo == null) {
        throw 'Response is required';
      }

      return (defaultsTo == null) ? "" : defaultsTo;
    }

    return parse(answer);
  }
}

class _Confirm extends Question {
  _Confirm(String message, {bool defaultsTo: false})
      : super(message, allowed: const [true, false], defaultsTo: defaultsTo,
            formatter: (v) {
          var letter = v ? 'y' : 'n';
          return defaultsTo == v ? letter.toUpperCase() : letter;
        });

  bool parse(String answer) => ['y', 'yes'].contains(answer.toLowerCase());
}
