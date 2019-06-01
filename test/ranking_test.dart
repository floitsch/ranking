import 'package:ranking/ranking.dart';
import 'package:test/test.dart';

void main() {
  group('mackie tests', () {
    // Tests that the implementation has similar results as the examples at
    // https://blog.mackie.io/the-elo-algorithm

    test('Ping Pong', () {
      var pingPong = Elo<String>(defaultInitialRating: 100, n: 50, kFactor: 5);
      var players = ["Amy", "Brad", "Dirk", "Cindy"];
      players.forEach(pingPong.addPlayer);

      var initialRatings = pingPong.ratings;
      expect(initialRatings.length, equals(players.length));
      for (var player in players) {
        expect(initialRatings[player], equals(100));
      }

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
      var players = ["Amy", "Brad", "Dirk", "Cindy"];
      players.forEach(pingPong.addPlayer);

      var initialRatings = pingPong.ratings;
      expect(initialRatings.length, equals(players.length));
      for (var player in players) {
        expect(initialRatings[player], equals(100));
      }

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
}
