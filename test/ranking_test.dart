import 'package:ranking/ranking.dart';
import 'package:test/test.dart';

void main() {
  double roundTo3(double x) => (x * 1000).round() / 1000;

  group('mackie tests', () {
    // Tests that the implementation has similar results as the examples at
    // https://blog.mackie.io/the-elo-algorithm

    test('Ping Pong', () {
      var pingPong = Elo<String>(defaultInitialRating: 100, n: 50, kFactor: 5);

      pingPong.recordResult("Amy", "Brad", 1.0);
      expect(pingPong.ratings["Amy"], equals(102.5));
      expect(pingPong.ratings["Brad"], equals(97.5));
      pingPong.recordResult("Dirk", "Cindy", 1.0);
      expect(pingPong.ratings["Dirk"], equals(102.5));
      expect(pingPong.ratings["Cindy"], equals(97.5));
      pingPong.recordResult("Amy", "Cindy", 1.0);
      expect(pingPong.ratings["Amy"], equals(104.71344183118853));
      expect(pingPong.ratings["Cindy"], equals(95.28655816881147));
      pingPong.recordResult("Dirk", "Cindy", 1.0);
      // The values are slighty different, because we don't round the ratings.
      expect(pingPong.ratings["Dirk"], equals(104.58853774249278));
      expect(pingPong.ratings["Cindy"], equals(93.19802042631869));
    });

    test('Ping Pong inversed', () {
      // Same as "Ping Pong", but where the second player wins.
      var pingPong = Elo<String>(defaultInitialRating: 100, n: 50, kFactor: 5);

      pingPong.recordResult("Brad", "Amy", 0.0);
      expect(pingPong.ratings["Amy"], equals(102.5));
      expect(pingPong.ratings["Brad"], equals(97.5));
      pingPong.recordResult("Cindy", "Dirk", 0.0);
      expect(pingPong.ratings["Dirk"], equals(102.5));
      expect(pingPong.ratings["Cindy"], equals(97.5));
      pingPong.recordResult("Cindy", "Amy", 0.0);
      expect(pingPong.ratings["Amy"], equals(104.71344183118853));
      expect(pingPong.ratings["Cindy"], equals(95.28655816881147));
      pingPong.recordResult("Cindy", "Dirk", 0.0);
      // The values are slighty different, because we don't round the ratings.
      expect(pingPong.ratings["Dirk"], equals(104.58853774249278));
      expect(pingPong.ratings["Cindy"], equals(93.19802042631869));
    });
  });

  group('Bradley Terry', () {
    test('Ping Pong', () {
      var pingPongScores = computeBradleyTerryScores([
        ["Amy", "Brad"],
        ["Dirk", "Cindy"],
        ["Amy", "Cindy"],
        ["Dirk", "Cindy"],
        ["Amy", "Dirk"],
        ["Brad", "Cindy"],
        ["Dirk", "Brad"],
      ]);
      expect(pingPongScores["Amy"] > pingPongScores["Dirk"], isTrue);
      expect(pingPongScores["Dirk"] > pingPongScores["Brad"], isTrue);
      expect(pingPongScores["Brad"] > pingPongScores["Cindy"], isTrue);
    });

    test('Handball', () {
      // Scraped from https://www.handball.no/system/kamper/turnering/?turnid=368157#allmatches.
      // Expected values from https://opisthokonta.net/?p=1589
      var scraped = <List<dynamic>>[
        ["Storhamar Håndball Elite", "Glassverket", 22 - 26],
        ["Vipers Kristiansand (Våg Elite)", "Sola", 36 - 25],
        ["Stabæk", "Rælingen", 25 - 19],
        ["Gjerpen HK Skien", "Tertnes Håndball Elite", 19 - 22],
        ["Oppsal", "Larvik", 21 - 31],
        ["Tertnes Håndball Elite", "Vipers Kristiansand (Våg Elite)", 18 - 19],
        ["Sola", "Byåsen Elite", 28 - 38],
        ["Stabæk", "Larvik", 17 - 32],
        ["Rælingen", "Gjerpen HK Skien", 18 - 29],
        ["Glassverket", "Stabæk", 25 - 23],
        ["Byåsen Elite", "Vipers Kristiansand (Våg Elite)", 25 - 26],
        ["Oppsal", "Sola", 34 - 23],
        ["Larvik", "Storhamar Håndball Elite", 28 - 24],
        ["Tertnes Håndball Elite", "Rælingen", 27 - 16],
        ["Gjerpen HK Skien", "Glassverket", 25 - 27],
        ["Larvik", "Gjerpen HK Skien", 36 - 21],
        ["Glassverket", "Rælingen", 31 - 22],
        ["Byåsen Elite", "Tertnes Håndball Elite", 33 - 27],
        ["Sola", "Storhamar Håndball Elite", 20 - 25],
        ["Vipers Kristiansand (Våg Elite)", "Oppsal", 26 - 23],
        ["Tertnes Håndball Elite", "Glassverket", 19 - 19],
        ["Rælingen", "Larvik", 18 - 30],
        ["Oppsal", "Byåsen Elite", 26 - 25],
        [
          "Storhamar Håndball Elite",
          "Vipers Kristiansand (Våg Elite)",
          26 - 32
        ],
        ["Stabæk", "Sola", 31 - 29],
        ["Byåsen Elite", "Storhamar Håndball Elite", 31 - 24],
        ["Oppsal", "Tertnes Håndball Elite", 20 - 27],
        ["Vipers Kristiansand (Våg Elite)", "Stabæk", 27 - 28],
        ["Larvik", "Glassverket", 40 - 25],
        ["Sola", "Gjerpen HK Skien", 31 - 26],
        ["Storhamar Håndball Elite", "Oppsal", 25 - 20],
        ["Tertnes Håndball Elite", "Larvik", 18 - 23],
        ["Gjerpen HK Skien", "Vipers Kristiansand (Våg Elite)", 18 - 38],
        ["Rælingen", "Sola", 22 - 22],
        ["Stabæk", "Byåsen Elite", 27 - 31],
        ["Sola", "Glassverket", 24 - 33],
        ["Byåsen Elite", "Gjerpen HK Skien", 42 - 30],
        ["Storhamar Håndball Elite", "Tertnes Håndball Elite", 21 - 20],
        ["Oppsal", "Stabæk", 31 - 23],
        ["Vipers Kristiansand (Våg Elite)", "Rælingen", 27 - 10],
        ["Gjerpen HK Skien", "Oppsal", 31 - 31],
        ["Stabæk", "Storhamar Håndball Elite", 21 - 32],
        ["Rælingen", "Byåsen Elite", 23 - 23],
        ["Glassverket", "Vipers Kristiansand (Våg Elite)", 23 - 22],
        ["Stabæk", "Tertnes Håndball Elite", 19 - 25],
        ["Oppsal", "Rælingen", 29 - 18],
        ["Storhamar Håndball Elite", "Gjerpen HK Skien", 45 - 30],
        ["Byåsen Elite", "Glassverket", 28 - 21],
        ["Vipers Kristiansand (Våg Elite)", "Larvik", 25 - 29],
        ["Larvik", "Sola", 31 - 25],
        ["Rælingen", "Storhamar Håndball Elite", 22 - 30],
        ["Tertnes Håndball Elite", "Sola", 22 - 23],
        ["Gjerpen HK Skien", "Stabæk", 30 - 26],
        ["Glassverket", "Oppsal", 29 - 23],
        ["Larvik", "Byåsen Elite", 31 - 22],
        ["Larvik", "Oppsal", 39 - 22],
        ["Sola", "Vipers Kristiansand (Våg Elite)", 22 - 35],
        ["Rælingen", "Stabæk", 23 - 32],
        ["Tertnes Håndball Elite", "Gjerpen HK Skien", 26 - 29],
        ["Glassverket", "Storhamar Håndball Elite", 33 - 32],
        ["Storhamar Håndball Elite", "Larvik", 23 - 26],
        ["Stabæk", "Glassverket", 21 - 28],
        ["Byåsen Elite", "Sola", 32 - 20],
        ["Gjerpen HK Skien", "Rælingen", 27 - 25],
        ["Vipers Kristiansand (Våg Elite)", "Tertnes Håndball Elite", 29 - 23],
        ["Larvik", "Stabæk", 34 - 24],
        ["Vipers Kristiansand (Våg Elite)", "Byåsen Elite", 27 - 22],
        ["Glassverket", "Gjerpen HK Skien", 35 - 24],
        ["Sola", "Oppsal", 25 - 24],
        ["Rælingen", "Tertnes Håndball Elite", 16 - 25],
        ["Rælingen", "Glassverket", 16 - 32],
        ["Oppsal", "Vipers Kristiansand (Våg Elite)", 14 - 25],
        ["Tertnes Håndball Elite", "Byåsen Elite", 20 - 23],
        ["Storhamar Håndball Elite", "Sola", 28 - 25],
        ["Gjerpen HK Skien", "Larvik", 21 - 38],
        ["Sola", "Stabæk", 31 - 26],
        ["Byåsen Elite", "Oppsal", 29 - 25],
        ["Larvik", "Rælingen", 25 - 16],
        [
          "Vipers Kristiansand (Våg Elite)",
          "Storhamar Håndball Elite",
          30 - 26
        ],
        ["Glassverket", "Tertnes Håndball Elite", 25 - 22],
        ["Glassverket", "Larvik", 25 - 31],
        ["Storhamar Håndball Elite", "Byåsen Elite", 28 - 32],
        ["Gjerpen HK Skien", "Sola", 28 - 28],
        ["Stabæk", "Vipers Kristiansand (Våg Elite)", 26 - 31],
        ["Tertnes Håndball Elite", "Oppsal", 25 - 23],
        ["Byåsen Elite", "Stabæk", 33 - 26],
        ["Larvik", "Tertnes Håndball Elite", 40 - 23],
        ["Sola", "Rælingen", 30 - 16],
        ["Oppsal", "Storhamar Håndball Elite", 26 - 34],
        ["Vipers Kristiansand (Våg Elite)", "Gjerpen HK Skien", 38 - 21],
        ["Tertnes Håndball Elite", "Storhamar Håndball Elite", 30 - 24],
        ["Glassverket", "Sola", 28 - 27],
        ["Stabæk", "Oppsal", 27 - 32],
        ["Gjerpen HK Skien", "Byåsen Elite", 28 - 35],
        ["Rælingen", "Vipers Kristiansand (Våg Elite)", 24 - 38],
        ["Byåsen Elite", "Rælingen", 33 - 26],
        ["Sola", "Larvik", 27 - 37],
        ["Oppsal", "Gjerpen HK Skien", 23 - 20],
        ["Vipers Kristiansand (Våg Elite)", "Glassverket", 40 - 20],
        ["Storhamar Håndball Elite", "Stabæk", 24 - 33],
        ["Tertnes Håndball Elite", "Stabæk", 34 - 31],
        ["Glassverket", "Byåsen Elite", 30 - 24],
        ["Larvik", "Vipers Kristiansand (Våg Elite)", 30 - 32],
        ["Gjerpen HK Skien", "Storhamar Håndball Elite", 26 - 30],
        ["Rælingen", "Oppsal", 25 - 21],
        ["Byåsen Elite", "Larvik", 29 - 34],
        ["Sola", "Tertnes Håndball Elite", 24 - 26],
        ["Stabæk", "Gjerpen HK Skien", 33 - 32],
        ["Oppsal", "Glassverket", 27 - 27],
        ["Storhamar Håndball Elite", "Rælingen", 34 - 15],
      ];
      var games = <List>[];
      for (var recorded in scraped) {
        String player1 = recorded[0];
        String player2 = recorded[1];
        int diff = recorded[2];
        if (diff == 0) continue;
        if (diff > 0) {
          games.add([player1, player2]);
        } else {
          games.add([player2, player1]);
        }
      }
      var scores = computeBradleyTerryScores(games);

      expect(roundTo3(scores["Larvik"]), equals(0.624));
      expect(
          roundTo3(scores["Vipers Kristiansand (Våg Elite)"]), equals(0.187));
      expect(roundTo3(scores["Glassverket"]), equals(0.110));
      expect(roundTo3(scores["Byåsen Elite"]), equals(0.047));
      expect(roundTo3(scores["Storhamar Håndball Elite"]), equals(0.011));
      expect(roundTo3(scores["Tertnes Håndball Elite"]), equals(0.008));
      expect(roundTo3(scores["Oppsal"]), equals(0.004));
      expect(roundTo3(scores["Sola"]), equals(0.004));
      expect(roundTo3(scores["Gjerpen HK Skien"]), equals(0.002));
      expect(roundTo3(scores["Stabæk"]), equals(0.003));
      expect(roundTo3(scores["Rælingen"]), equals(0.000));
    });

    test('Go', () {
      // https://github.com/seanhagen/bradleyterry/blob/master/model_test.go
      var games = [
        ["Player 2", "Player 1"],
        ["Player 2", "Player 3"],
        ["Player 3", "Player 2"],
        ["Player 3", "Player 2"],
      ];
      var scores = computeBradleyTerryScores(games);
      expect(roundTo3(scores["Player 1"]), equals(0.000));
      expect(roundTo3(scores["Player 2"]), equals(0.333));
      expect(roundTo3(scores["Player 3"]), equals(0.667));
    });
  });
}
