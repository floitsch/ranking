// Copyright 2019 Florian Loitsch
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "dart:math" as math;

/// Simplified Elo rating.
///
/// Similar to FIDE (Chess), just takes an `n` value, implying that a player
/// that has `n` more points is 10 times stronger.
///
/// The `k` factor determines how aggressively a rating is changed after new
/// results.
/// FIDE uses different ratings for new and old players (allowing bigger
/// changes in the beginning, and then slowing down the changes). This class
/// does not support changes.
///
/// Also, there is no way to use a different initial rating. FIDE, for example,
/// computes the initial rating out of the first games.
///
/// See https://blog.mackie.io/the-elo-algorithm for a good description of the
/// algorithm.
class Elo<T> {
  final double _n;
  final double _kFactor;
  final double _defaultInitialRating;

  Map<T, double> _ratings = {};

  /// Creates a new Elo class.
  ///
  /// The [defaultInitialRating] is assigned as initial rating for new
  /// players, unless they are initialized with a given rating.
  ///
  /// The [n] value determines the spread of the ratings. A difference of
  /// [n] points makes it 10 times more likely that the higher-rated player
  /// wins. (Assuming the ratings have converged to the true skill level).
  ///
  /// The [kFactor] tunes the scale at which ratings are adjusted after a
  /// result has been recorded. The maximum a rating can change is [kFactor],
  /// and players of equal strength will move each by [kFactor]/2 points, if
  /// the score is `0` or `1`.
  ///
  /// The following values may make sense for your application:
  /// ```
  /// // Somehow inspired by Chess and Soccer (http://www.eloratings.net)
  /// defaultInitialRating = 1200
  /// n = 400
  /// kFactor = 30
  ///
  /// // Aggressive (for shorter tournaments).
  /// defaultInitialRating = 100
  /// n = 100
  /// kFactor = 50
  /// ```
  Elo({double defaultInitialRating, double n, double kFactor})
      : _defaultInitialRating = defaultInitialRating,
        _n = n,
        _kFactor = kFactor;

  void addPlayer(T player, [double rating]) {
    if (_ratings.containsKey(player)) {
      throw "player already exists";
    }
    _ratings[player] = rating ?? _defaultInitialRating;
  }

  /// Records the result of a game.
  ///
  /// The [score] should be a value satisfying `0 <= score <= 1`.
  /// Generally [score] is:
  /// - 1.0, if [player1] won the game.
  /// - 0.5, if there was a draw.
  /// - 0.0, if [player2] won the game.
  void recordResult(T player1, T player2, double score) {
    var oldRating1 = _ratings[player1];
    var oldRating2 = _ratings[player2];
    if (oldRating1 == null) {
      throw ArgumentError("player1 not registered: $player1");
    }
    if (oldRating2 == null) {
      throw ArgumentError("player2 not registered: $player2");
    }
    var diff = oldRating1 - oldRating2;
    var exponent = -(diff / _n);

    var expected1 = 1.0 / (1.0 + math.pow(10.0, exponent));
    _ratings[player1] = oldRating1 + _kFactor * (score - expected1);

    var expected2 = 1.0 / (1.0 + math.pow(10.0, -exponent));
    _ratings[player2] = oldRating2 + _kFactor * ((1.0 - score) - expected2);
  }

  /// Returns the current ratings for all players.
  Map<T, double> get ratings => Map<T, double>()..addAll(_ratings);
}
