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

import "package:ranking/ranking.dart";

var players = [
  "Novak",
  "Rafael",
  "Roger",
  "Dominic",
  "Alexander",
  "Stefanos",
];

var games = [
  ["Stefanos", "Dominic", 0.0, "2018-01-01"], // quarter
  ["Stefanos", "Dominic", 0.0, "2018-03-05"], // ro64
  ["Alexander", "Rafael", 0.0, "2018-04-02"], // round robin.
  ["Dominic", "Novak", 1.0, "2018-04-16"],
  ["Stefanos", "Dominic", 1.0, "2018-04-16"], // quarter
  ["Dominic", "Rafael", 0.0, "2018-04-16"],
  ["Stefanos", "Rafael", 0.0, "2018-04-23"], // final
  ["Dominic", "Rafael", 1.0, "2018-05-07"],
  ["Alexander", "Dominic", 1.0, "2018-05-07"],
  ["Rafael", "Novak", 1.0, "2018-05-14"],
  ["Alexander", "Rafael", 0.0, "2018-05-14"],
  ["Stefanos", "Dominic", 0.0, "2018-05-28"], // ro64
  ["Alexander", "Dominic", 0.0, "2018-05-28"], // quarter
  ["Dominic", "Rafael", 0.0, "2018-05-28"],
  ["Rafael", "Novak", 0.0, "2018-07-02"],
  ["Stefanos", "Alexander", 0.0, "2018-07-30"], // semi
  ["Stefanos", "Dominic", 1.0, "2018-08-06"], // ro32
  ["Stefanos", "Novak", 1.0, "2018-08-06"], // round of 16
  ["Stefanos", "Alexander", 1.0, "2018-08-06"], // quarter
  ["Stefanos", "Rafael", 0.0, "2018-08-06"], // final
  ["Roger", "Novak", 0.0, "2018-08-13"],
  ["Dominic", "Rafael", 0.0, "2018-08-27"],
  ["Alexander", "Novak", 0.0, "2018-10-08"],
  ["Roger", "Novak", 0.0, "2018-10-29"],
  ["Alexander", "Novak", 0.0, "2018-11-12"], // Earlier round robin.
  ["Dominic", "Roger", 0.0, "2018-11-12"], // round robin
  ["Alexander", "Roger", 1.0, "2018-11-12"],
  ["Alexander", "Novak", 1.0, "2018-11-12"],
  ["Roger", "Rafael", 1.0, "2019-03-04"],
  ["Dominic", "Roger", 1.0, "2019-03-04"],
  ["Stefanos", "Roger", 1.0, "2019-01-14"], // round of 16
  ["Stefanos", "Rafael", 0.0, "2019-01-14"], // semi
  ["Rafael", "Novak", 0.0, "2019-01-14"], // final
  ["Stefanos", "Roger", 0.0, "2019-02-25"], // final
  ["Dominic", "Rafael", 1.0, "2019-04-22"],
  ["Stefanos", "Alexander", 1.0, "2019-05-06"], // quarter
  ["Dominic", "Roger", 1.0, "2019-05-06"],
  ["Stefanos", "Rafael", 1.0, "2019-05-06"], // semi
  ["Dominic", "Novak", 0.0, "2019-05-06"], // semi
  ["Stefanos", "Novak", 0.0, "2019-05-06"], // final
  ["Stefanos", "Roger", 1.0, "2019-05-13"], // quarter
  ["Stefanos", "Rafael", 0.0, "2019-05-13"], // semi
  ["Rafael", "Novak", 1.0, "2019-05-13"], // final
];

void bradleyTerryExample() {
  // Bradley-Terry is better suited for players that don't change their skill
  // level. As such, using the data of Tennis games isn't great, since
  // Tennis players change their skill level over time.
  // However, it's still interesting to compare the result to the ELO algorithm.
  var input = games.map((list) {
    if (list[2] == 1.0) return [list[0], list[1]];
    return [list[1], list[0]];
  }).toList();

  var scores = computeBradleyTerryScores(input);

  var ranked = players.toList()
    ..sort((a, b) => -scores[a].compareTo(scores[b]));
  print("Bradley-Terry Scores:");
  for (var player in ranked) {
    print("  $player: ${scores[player]}");
  }
}

void eloExample() {
  // The data we are using is from Tennis.
  //
  // The ranking changes over time, whenever a new game has been played.
  // Players are naturally changing their skills (relative to others) over time
  // and as such order matters. This means that `ELO` is a good model to
  // rank the players. (At least, if we used all played games, and not just
  // a tiny subset of them).

  var elo = Elo(defaultInitialRating: 100, n: 70, kFactor: 15);

  players.forEach(elo.addPlayer);
  for (var game in games) {
    elo.recordResult(game[0], game[1], game[2]);
  }
  var ratings = elo.ratings;
  var ranked = players.toList()
    ..sort((a, b) => -ratings[a].compareTo(ratings[b]));
  print("ELO Scores:");
  for (var player in ranked) {
    print("  $player: ${ratings[player]}");
  }
}

void main() {
  eloExample();
  print("");
  bradleyTerryExample();
}