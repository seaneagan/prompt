
library prompt.example.basic;

import 'package:prompt/prompt.dart';

main() async {
  // Synchronously get a String from the user:
  var name = askSync('Name');

  // Asynchronously:
  var asyncName = await ask('Name');

  // Get a secret value:
  String password = askSync(new Question('Password', secret: true));

  // Get a boolean:
  bool likeCats = askSync(new Question.confirm('Like cats'));

  // Get an answer from a list of choices.
  String favoriteColor = askSync(new Question('Favorite color', allowed:
      ['red', 'green', 'blue']));

  // Get an `int` (custom validation):
  int favoriteNumber = askSync(new Question('Favorite number',
      parser: int.parse));

  // Custom Prompt/UI (extend Prompt for further customization):
  var myPrompt = new Prompt(maxAttempts: 1, promptString: 'prompt: ');

  var likeMyPrompt = myPrompt.askSync(new Question.confirm('Like my prompt'));

  // Make a function with prompting logic testable by passing it a prompt.
  // [prompt] is the default prompt.
  var sum = add3(prompt);

  // If you use [ask] anywhere, you must close stdin when done.
  close();
}

num add3(Prompt prompt) {
  var confident = prompt.askSync(Add3Questions.confident);
  if (!confident) {
    print('No sum for you!');
    return null;
  }
  num getNum() => prompt.askSync(Add3Questions.addend);
  return getNum() + getNum() + getNum();
}

class Add3Questions {
  static final confident = new Question.confirm('Do you think this will work');
  static final addend = new Question('Enter a number', parser: num.parse);
}
