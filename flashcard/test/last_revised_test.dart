import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/last_revised.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {

  FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();

  // Populate mockFirestore with test data
  DocumentReference userDoc = await fakeFirestore.collection("users").add({"userID": "test"});

  DocumentReference card1 = await fakeFirestore.collection("flashcards").add({
    "owner": "all",
    "topic": "Patients",
    "subtopic": "Sick Patients",
  });

  await fakeFirestore.collection("users/${userDoc.id}/flashcardsSeen").add({
    "cardID": card1.id,
    "lastSeen": Timestamp.fromDate(DateTime(2024, 1, 1)),
    "score": [1],
    "timesSeen": 1,
  });

  group("Test Last Revised Helper Function", () {

    setUp(() {
      FirebaseWrapper.setupForTesting(fakeFirestore);
    });

    test("Test getStats", () async {
      // Call getStats and ensure it completes
      TopicStats stats = await LastRevised.getStats(includeSubtopics: false);
      expect(stats.totalCards["Patients"] == null, false);
      expect(stats.seenCards["Patients"] == null, false);
      expect(stats.dateLastRevised["Patients"], DateTime(2024, 1, 1));
    });

  });

  DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  group("Test nextReviewDateByTopic", () {
    
    test("Seen once 4 days ago; never seen", () {

      TopicStats stats = TopicStats(
        seenCards: {
          "illness": 4,
        },
        timesSeen: {
          "illness": 1,
        },
        totalCards: {
          "illness": 4,
          "medicine": 10
        },
        dateLastRevised: {
          "illness": today.subtract(Duration(days: 4))
        }
      );

      Map<String, DateTime> result = LastRevised.nextReviewDateByTopic(stats);
      expect(result["medicine"], today); // never revised before
      expect(result["illness"], today.add(Duration(days: 1))); // last review date + 3 + (2)

    }); 

    test("More than 2 for a given day", () {

      TopicStats stats = TopicStats(
        seenCards: {
          "illness": 4,
          "medicine": 8,
          "drugs": 10
        },
        timesSeen: {
          "illness": 1,
          "medicine": 2,
          "drugs": 3
        },
        totalCards: {
          "illness": 4,
          "medicine": 8,
          "drugs": 10
        },
        dateLastRevised: {
          "illness": today.subtract(Duration(days: 3 + (8-2))),
          "medicine": today.subtract(Duration(days: 3 + (8-4))),
          "drugs": today.subtract(Duration(days: 3 + (8-0)))
        }
      );

      Map<String, DateTime> result = LastRevised.nextReviewDateByTopic(stats);
      expect(result["illness"], today);
      expect(result["medicine"], today);
      expect(result["drugs"], today.add(Duration(days: 1)));

    });

    test("Checking for nulls", () {

      TopicStats stats = TopicStats(seenCards: {}, totalCards: {}, timesSeen: {}, dateLastRevised: {}); 
      
      Map<String, DateTime> result = LastRevised.nextReviewDateByTopic(stats);
      expect(result["illness"], null);

    });

    test("Loads of revision", () {

      TopicStats stats = TopicStats(
        seenCards: {
          "illness": 20,
        },
        timesSeen: {
          "illness": 10,
        },
        totalCards: {
          "illness": 20,
        },
        dateLastRevised: {
          "illness": today.subtract(Duration(days: 7)),
        }
      );

      Map<String, DateTime> result = LastRevised.nextReviewDateByTopic(stats);
      expect(result["illness"], today.add(Duration(days: 32 + 3 - 7)));

    });

  });

  group("Test recordLogin", () {
    
    setUp(() {
      FakeFirebaseFirestore database = FakeFirebaseFirestore();
      database.collection("users").doc("12345").set({"userID": "test"});

      FirebaseWrapper.setupForTesting(database);
    });

    DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);


    test("Test new data is added to user doc", () async {

      await LastRevised.recordLogin();

      CollectionReference<Map<String, dynamic>> loginsRef = FirebaseWrapper.firestore().collection("users/12345/daysLoggedIn");
      (await loginsRef.get()).docs;

      var document = (await loginsRef.get()).docs.first;
      expect(document.data()["date"], Timestamp.fromDate(today));

    });

    test("Check today can't be added twice", () async {

      await LastRevised.recordLogin();
      await LastRevised.recordLogin();

      CollectionReference<Map<String, dynamic>> loginsRef = FirebaseWrapper.firestore().collection("users/12345/daysLoggedIn");
      (await loginsRef.get()).docs;

      int logins = (await loginsRef.get()).docs.length;
      expect(logins, 1);

    });

  });

  group("Test loading streakStats", () {

    DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    setUp(() {

      FakeFirebaseFirestore database = FakeFirebaseFirestore();
      database.collection("users").doc("12345").set({"userID": "test"});

      database.collection("users/12345/daysLoggedIn").add(
        {"date": Timestamp.fromDate(today)}
      );
      database.collection("users/12345/daysLoggedIn").add(
        {"date": Timestamp.fromDate(today.subtract(Duration(days: 1)))}
      );
      database.collection("users/12345/daysLoggedIn").add(
        {"date": Timestamp.fromDate(today.subtract(Duration(days: 2)))}
      );
      database.collection("users/12345/daysLoggedIn").add(
        {"date": Timestamp.fromDate(today.subtract(Duration(days: 4)))}
      );

      database.doc("users/12345").update({"TestDay" : Timestamp.fromDate(DateTime(25, 7, 8))});

      FirebaseWrapper.setupForTesting(database);

    });

    test("test days logged in", () async {

      StreakStats stats = await LastRevised.loadStreakStats();

      expect(stats.daysLoggedIn, [today, today.subtract(Duration(days: 1)), today.subtract(Duration(days: 2)), today.subtract(Duration(days: 4))]);

    });

    test("test total decks revised", () async {

      StreakStats stats = await LastRevised.loadStreakStats();
      expect(stats.numberOfDecksRevised, 0);

      await LastRevised.logFlashCardDeck();
      await LastRevised.logFlashCardDeck();

      stats = await LastRevised.loadStreakStats();
      expect(stats.numberOfDecksRevised, 2);

    });

    test("test exam date", () async {

      StreakStats stats = await LastRevised.loadStreakStats();

      expect(stats.examDate, DateTime(25, 7, 8));

    });

  });

  group("Test StreakStats methods", () {

    test("howManyDaysInARow", () {

      DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

      StreakStats stats = StreakStats(
        daysLoggedIn: [
          today,
          today.subtract(Duration(days: 2)),
          today.subtract(Duration(days: 3))
        ],
        examDate: DateTime(0),
        numberOfDecksRevised: 10
      );

      expect(stats.howManyDaysInARow(), 1);

      stats = StreakStats(
        daysLoggedIn: [
          today,
          today.subtract(Duration(days: 1)),
          today.subtract(Duration(days: 2)),
          today.subtract(Duration(days: 4)),
        ],
        examDate: DateTime(0),
        numberOfDecksRevised: 10
      );

      expect(stats.howManyDaysInARow(), 3);

    });

    test("7 days", () {
      DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      
      StreakStats stats = StreakStats(
        daysLoggedIn: [
          today,
          today.subtract(Duration(days: 2)),
          today.subtract(Duration(days: 4)),
          today.subtract(Duration(days: 5))
        ],
        examDate: DateTime(0),
        numberOfDecksRevised: 10
      );

      expect(stats.last7Days(), [true,false,true,false,true,true,false]);

    });

  });

}