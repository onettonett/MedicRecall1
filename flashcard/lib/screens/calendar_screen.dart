import 'package:flashcard_x/screens/feed_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/last_revised.dart';
import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/calendar_column.dart' as cc;
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
Important note for devs

testDay is a dateTime object
testDayString is the same, but stored as a string
this is so that it can be stored and retrieved from the database, there was an error where dateTime couldnt be pulled
as a result, both are used:
testDay for the calendar on the app
testDayString for database purposes.

 */
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<Calendar> {

  final Color _dark = Color.fromRGBO(44, 44, 44, 1);

  bool loading = true;

  Map<DateTime, List<cc.Event>> eventsByDate = {};

  Future<void> _loadReviseDatesForEachTopic() async {
    TopicStats topicStats = await LastRevised.getStats(includeSubtopics: false);
    Map<String, DateTime> reviewDatesByTopic = LastRevised.nextReviewDateByTopic(topicStats);

    for (String topicID in topicStats.totalCards.keys) {

      if (reviewDatesByTopic[topicID] != null) {

        cc.Event event = cc.Event(time: reviewDatesByTopic[topicID]!, title: "Flashcard deck:\n$topicID", link: () {
          // Load up the flashcard page for the specified topic
          FirebaseWrapper.firestore().collection("topics").where("topic", isEqualTo: topicID).get().then((snapshot) {
            
            // This avoids casting issues as technically the items of the subtopic list can be anything
            List<dynamic> subtopicData = snapshot.docs.first["subtopics"];
            List<String> subtopics = [];
            for (dynamic x in subtopicData) {
              subtopics.add(x.toString());
            }

            if (mounted && subtopics.isNotEmpty) {
              Navigator.push(
                context,
                ExpandRoute(
                    page: AboveEverything(
                      subtopics: subtopics,
                      count: 1,
                      // choice: choice,
                    )),
              );
            }

          });
          
        });

        if (eventsByDate[reviewDatesByTopic[topicID]] == null) {
          eventsByDate.addAll({reviewDatesByTopic[topicID]!: [event]});
        } else {
          eventsByDate[reviewDatesByTopic[topicID]]!.add(event);
        }
      
      }

    }

  }

  void _populateColumns() {

    days = [];
    DateTime day = DateTime(first.year, first.month, first.day); // remove minutes and seconds

    for (int i = 0; i < 7; i++) {
      days.add(cc.CalendarColumn(day: day, events: eventsByDate[day] ?? []));
      day = day.add(Duration(days: 1));
    }

    last = day.subtract(Duration(days: 1));

    if (mounted) {
      setState(() {});
    }

  }

  @override
  void initState() {
    _populateColumns();
    _loadReviseDatesForEachTopic().then((x) {
      _populateColumns();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    super.initState();
  }

  // The list of days currently on the screen. This gets dynamically updated when the next and previous buttons are pressed
  List<cc.CalendarColumn> days = [];
  DateTime first = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime last = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0).add(Duration(days: 6));

  void _previous() {
    setState(() {
      first = first.subtract(Duration(days: 7));
      last = last.subtract(Duration(days: 7));
      _populateColumns();
    });
  }

  void _next() {
    setState(() {
      last = last.add(Duration(days: 7));
      first = first.add(Duration(days: 7));
      _populateColumns();
    });
  }

  // List of all events and the days they take place on

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
        title: "Study Planner",
        body: loading ? Center(child:  CircularProgressIndicator()) : Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                children: [
                  
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: days
                      )
                    )
                  ),

                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _previous,
                          child: Row(children: [
                            Icon(Icons.keyboard_arrow_left, size: 30, color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : _dark),
                            Text("Previous", style: theme.textTheme.titleLarge!.copyWith(color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : _dark)),
                          ])
                      ),
                      SizedBox(width: 15),
                      GestureDetector(
                          onTap: _next,
                          child: Row(children: [
                            Text("Next", style:  theme.textTheme.titleLarge!.copyWith(color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : _dark)),
                            Icon(Icons.keyboard_arrow_right, size: 30, color: Provider.of<ThemeProvider>(context).isDarkMode ? Colors.white : _dark)
                          ])
                        )
                      ],
                    )
                  )

                ]
            )
        )
    );
  }
}
