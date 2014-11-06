
import 'package:grill/grill.dart';

main() {

  print('Sync:');

  displayAnswers(
    askSync('Name'),
    askSync(new Question('Password', secret: true)),
    confirmSync('Like kittens'),
    askSync(new Question('Favorite color', allowed: ['red', 'green', 'blue']))
  );

  print('Async:');

  ask('Name').then((name) {
    return ask(new Question('Password', secret: true)).then((password) {
      return confirm('Like kittens').then((likeKittens) {
        return ask(new Question('Favorite color', allowed: ['red', 'green', 'blue'])).then((favoriteColor) {
          displayAnswers(name, password, likeKittens, favoriteColor);
        });
      });
    });
  }).whenComplete(prompt.close);
}


displayAnswers(name, password, likeKittens, favoriteColor) {
  print('''
name: $name
password: $password
like kittens: $likeKittens
favorite color: $favoriteColor''');
}
