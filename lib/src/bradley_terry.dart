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

// Player1 wins against Player2.
class Game<T> {
  final T player1;
  final T player2;
  Game(this.player1, this.player2);
}

/// Bradley-Terry Ranking.
///
/// The Bradley-Terry model is a model that predicts the outcome of a paired
/// comparison. The model is transitive, and as such provides a complete
/// ranking.
///
/// Contrary to ELO, the Bradley-Terry ranking is _static_. It does *not*
/// consider the variation in time of the strengths of players.
///
/// See https://en.wikipedia.org/wiki/Bradley–Terry_model.
/// http://personal.psu.edu/drh20/papers/bt.pdf
///
/// https://github.com/bjlkeng/Bradley-Terry-Model/blob/master/update_model.py
/// https://github.com/seanhagen/bradleyterry/blob/master/model.go
class BradleyTerry<T> {
  Map<T, double> computeRanking(List<Game<T>> games) {
    var players = Set<T>();
    for (var game in games) {
      players.add(game.player1);
      players.add(game.player2);
    }
    int playerCount = players.length;
    var playerToIndex = <T, int>{};
    var indexToPlayer = List<T>(playerCount);
    var index = 0;
    for (var player in players) {
      playerToIndex[player] = index;
      indexToPlayer[index] = player;
      index++;
    }

    var winsForPlayer = List.filled(playerCount, 0);
    var playedAgainstCount = Map<int, Map<int, int>>();
    for (var game in games) {
      var player1Index = playerToIndex[game.player1];
      var player2Index = playerToIndex[game.player2];
      winsForPlayer[player1Index]++;
      playedAgainstCount
          .putIfAbsent(player1Index, () => {})
          .update(player2Index, (old) => old + 1, ifAbsent: () => 1);
      playedAgainstCount
          .putIfAbsent(player2Index, () => {})
          .update(player1Index, (old) => old + 1, ifAbsent: () => 1);
    }

    var parameterVector = List.filled(playerCount, 1.0 / playerCount);
    // The new vector is the one we update in the loop.
    var newParameterVector = parameterVector.toList(growable: false);
    for (int i = 0; i < 10000000; i++) {
      double sumParameters = 0.0;
      for (int player = 0; player < playerCount; player++) {
        var sum = 0.0;
        playedAgainstCount[player].forEach((otherPlayer, count) {
          // TODO(florian): might be faster to use a matrix instead of a map.
          // Depends on how sparse the matrix is...
          sum += count / (parameterVector[player] + parameterVector[otherPlayer]);
        });
        var newPlayerParameter = winsForPlayer[player] / sum;
        newParameterVector[player] = newPlayerParameter;
        sumParameters += newPlayerParameter;
      }
      // Scale the vector and accumulate error sum.
      double errorSum = 0.0;
      for (int player = 0; player < playerCount; player++) {
        var newScaledParameter = newParameterVector[player] / sumParameters;
        newParameterVector[player] = newScaledParameter;
        errorSum += math.pow(parameterVector[player] - newScaledParameter, 2);
      }

      // Switch vectors.
      var tmp = newParameterVector;
      newParameterVector = parameterVector;
      parameterVector = tmp;

      if (errorSum < 1e-15) break;
    }
    var result = Map<T, double>();
    for (int i = 0; i < playerCount; i++) {
      result[indexToPlayer[i]] = parameterVector[i];
    }
    return result;
  }
}
