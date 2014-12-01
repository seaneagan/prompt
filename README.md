prompt [![pub package](http://img.shields.io/pub/v/prompt.svg)](https://pub.dartlang.org/packages/prompt) [![Build Status](https://drone.io/github.com/seaneagan/prompt/status.png)](https://drone.io/github.com/seaneagan/prompt/latest)
======

Command-line prompting that is easy to data-drive, customize, and test.

`Question`s represent a request for a particular piece of user input.
`Prompt`s allow you to `ask` (or `askSync`) these questions, and customize the 
UX for them.  There are top-level functions exposed to use the default prompt.
You can also use a `MockPrompt` for testing purposes.

##Install

```shell
pub global activate den
den install prompt
```

##Usage

This and other examples can be found in the [example folder][example].
[example]: https://github.com/seaneagan/prompt/tree/master/example

```
import 'package:prompt/prompt.dart';

main() async {
  // Synchronously get a String from the user:
  var name = askSync('Name');

  // Asynchronously:
  var asyncName = await ask('Name');

  // The [Question] interface allows for more control.
  
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
```

###Testing

```
import 'package:mock/mock.dart';
import 'package:prompt/testing.dart';
import 'package:unittest/unittest.dart';

import 'basic.dart';

main() {
  group('add3', () {
    test('should not allow doubters to ask any furthers questions', () {
      var mockPrompt = new MockPrompt((question) {
        if (question == Add3Questions.confident) return false;
        if (question == Add3Questions.addend) throw 'Asked doubter for addends';
        throw 'Unrecognized question';
      });

      var sum = add3(mockPrompt);

      expect(sum, isNull);
    });

    test('should calculate sum for believers', () {
      var mockPrompt = new MockPrompt((question) {
        if (question == Add3Questions.confident) return true;
        if (question == Add3Questions.addend) return 5;
        throw 'Unrecognized question';
      });

      var sum = add3(mockPrompt);

      mockPrompt.askLogs(Add3Questions.addend).verify(happenedExactly(3));
      expect(sum, 15);
    });
  });
}
```
