A simple library to rank players.

This package contains functions to rank players, given the results
of their games.

For static rankings, where players don't change their skill-level,
the Bradley-Terry model computes a score for each player that
predicts the probability at which one player would win against another.

For dynamic rankings, where players change their skill-level over time,
the ELO ranking system provides a score that dynamically adjust with
the results of the players.

## Usage

A simple usage example for Bradley-Terry:

```dart
import 'package:ranking/ranking.dart';

main() {
  // In the following list the first entry in the pair (representing a game)
  // won that game.
  var games = [
    ["Player 2", "Player 1"],  // Player 2 won over Player 1.
    ["Player 2", "Player 3"],
    ["Player 3", "Player 2"],
    ["Player 3", "Player 2"],
  ];
  var scores = computeBradleyTerryScores(games);
  // The `scores` map contains a score for each player:
  //   Player 1 -> 0.000
  //   Player 2 -> 0.333
  //   Player 3 -> 0.667
}
```

A simple usage example for ELO:
```dart
import 'package:ranking/ranking.dart';

main() {
  var players = [
    "Player 1",
    "Player 2",
    "Player 3"
  ];

  // The game-scope (3rd column) indicates the result of the game:
  //   * 1.0: the first player won decisively.
  //   * 0.5: a draw.
  //   * 0.0: the second player won decisively.
  var games = [
    ["Player 2", "Player 1", 1.0],
    ["Player 3", "Player 2", 0.5],
    ["Player 3", "Player 1", 0.0],
    ["Player 3", "Player 2", 1.0],
    ["Player 2", "Player 3", 1.0],
  ];

  var elo = new Elo(
      defaultInitialRating: 100,
      // With an `n` of 30, a difference of 30 in score means that the
      // stronger player is 10 times more likely to win.
      n:  30,
      // How much new game-results move the score. With 10, players with
      // the same score will have a difference of 10 after a decisive
      // victory/loss.
      kFactor: 10
  );

  players.forEach(elo.addPlayer);
  games.forEach((list) { elo.recordResult(list[0], list[1], list[2]); });

  var ratings = elo.ratings;
  // The `rating` map contains a rating for each player:
  //   Player 1 -> 101
  //   Player 2 -> 103
  //   Player 3 ->  95
}
```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
