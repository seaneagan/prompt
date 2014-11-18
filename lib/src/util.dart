
library grill.util;

import 'question.dart';

Question toQuestion(question) => question is Question ? question : new Question(question);
