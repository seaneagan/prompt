
library prompt;

import 'dart:async';

import 'src/prompt.dart';
export 'src/prompt.dart';
import 'src/question.dart';
export 'src/question.dart';

/// The default [Prompt] used by [ask], [askSync], and [close].
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

/// Close the prompt.
///
/// Call this when you no longer need to [ask] any more questions.  You do
/// not need to call this method if you only use [askSync].
Future close() => prompt.close();
