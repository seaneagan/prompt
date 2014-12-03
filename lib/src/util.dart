
library prompt.util;

import 'package:ansicolor/ansicolor.dart';
import 'package:supports_color/supports_color.dart';

import 'question.dart';

Question toQuestion(question) => question is Question ? question :
    new Question(question);

initAnsicolor() {
  color_disabled = !supportsColor;
}
