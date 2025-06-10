library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flashcard scoring system', () {
    late Map<String, dynamic> a;
    late Map<String, dynamic> b;

    setUp(() {
      a = {
        "cardValue": 1,
        "score": 2,
        "lastSeen": 1,
        "timesSeen": 3
      };

      b = {
        "cardValue": 0,
        "score": 4,
        "lastSeen": 2,
        "timesSeen": 2
      };
    });

    int howDoTheyFeel(Map<String, dynamic> card) {
      if (card["cardValue"] == 1) {
        return card["score"] + 1;
      }
      return card["score"];
    }

    double whenToShowNext(Map<String, dynamic> card) {
      var score = howDoTheyFeel(card);
      var whenToShow = ((score / 2) * ((2 * score) + ((score - 1) * 2)));

      if (whenToShow > 6) {
        return 6;
      }
      return whenToShow;
    }

    int sort(Map<String, dynamic> a, Map<String, dynamic> b) {
      var ratioA = whenToShowNext(a);
      var ratioB = whenToShowNext(b);

      if (ratioA > ratioB) {
        return -1;
      } else if (ratioA < ratioB) {
        return 1;
      } else {
        return 0;
      }
    }

    test('Sorting function works correctly', () {
      if (whenToShowNext(a) == whenToShowNext(b)) {
        expect(sort(a, b), 0);
      } else if (whenToShowNext(a) < whenToShowNext(b)) {
        expect(sort(a, b), -1);
      } else {
        expect(sort(a, b), 1);
      }
    });

    test('whenToShowNext returns positive values', () {
      expect(whenToShowNext(a) >= 0, true);
      expect(whenToShowNext(b) >= 0, true);
    });

    test('whenToShowNext equation outputs valid values', () {
      var validValues = {1, 2, 4, 6};
      expect(validValues.contains(whenToShowNext(a)), true);
      expect(validValues.contains(whenToShowNext(b)), true);
    });
  });
}
