import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/utils/last_revised.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flashcard_x/screens/dash_screen.dart';

// COLOURS
class AppColours {
  static const Color darkBlue = Color.fromRGBO(20, 35, 52, 1);
  static const Color almostWhite = Color.fromRGBO(230, 230, 230, 1);
  static const Color orange = Color.fromRGBO(221, 117, 67, 1);
}

class Streaks extends StatefulWidget {
  const Streaks({super.key});

  @override
  State<Streaks> createState() => StreaksState();
}


class StreaksState extends State<Streaks> {
  int howManyDaysInARow = 0;
  List<bool> whichDaysRevised = List.filled(7, false);
  DateTime? examDate;
  int numberOfDecksRevised = 0;
  List<DateTime> daysLoggedIn = [];
  int noDaysLoggedIn = 0;
  DateTime todaysDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  bool currentlyLoading = true;
  @override
  void initState() {
    super.initState();
    loadStreakData();
  }

  // FETCHES DATA FROM FIREBASE AND UPDATES THE STATE
  Future<void> loadStreakData() async {
    StreakStats streakStats = await LastRevised.loadStreakStats();
    //TopicStats topicStats = await LastRevised.getStats();
    setState(() {
      numberOfDecksRevised = streakStats.numberOfDecksRevised;
      howManyDaysInARow = streakStats.howManyDaysInARow();
      whichDaysRevised = streakStats.last7Days();
      examDate = streakStats.examDate;
      daysLoggedIn = streakStats.daysLoggedIn;
      noDaysLoggedIn = daysLoggedIn.length;
      todaysDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
      currentlyLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: "Streaks",
      body: currentlyLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 14),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // STREAK COUNT WIDGET
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Calendar()),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 16,
                          child: Card(
                            color: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 14),
                                Padding(
                                  padding: EdgeInsets.only(left: 21),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Streak Count",
                                      style: theme.textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColours.almostWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "$howManyDaysInARow DAYS IN A ROW",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColours.almostWhite,
                                  ),
                                ),
                                Icon(
                                  Icons.local_fire_department,
                                  size: 64,
                                  color: AppColours.orange,
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // COUNTDOWN WIDGET
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Calendar()),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3 - 16,
                          child: Card(
                            color: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 14),
                                Padding(
                                  padding: EdgeInsets.only(left: 21),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Countdown",
                                      style: theme.textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColours.almostWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  examDate == null
                                      ? "No Exam Date Set"
                                      : "${examDate!.difference(DateTime.now()).inDays} DAYS LEFT",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColours.almostWhite,
                                  ),
                                ),
                                Icon(
                                  Icons.timer,
                                  size: 64,
                                  color: AppColours.orange,
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // DECKS REVISED WIDGET
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 16,
                        child: Card(
                          color: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 14),
                              Padding(
                                padding: EdgeInsets.only(left: 21),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Decks Revised",
                                    style: theme.textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      color: AppColours.almostWhite,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "$numberOfDecksRevised DECKS REVISED",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColours.almostWhite,
                                ),
                              ),
                              Icon(
                                Icons.lock_clock,
                                size: 64,
                                color: AppColours.orange,
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // FULL SIZED STREAKS WIDGET 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  color: AppColours.darkBlue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recent Activity",
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColours.almostWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: whichDaysRevised.isNotEmpty 
                            ? Row(
                                children: [
                                  StreakCard(date: todaysDate.day.toString(), isActive: whichDaysRevised[0]),
                                  StreakCard(date: todaysDate.subtract(Duration(days: 1)).day.toString(), isActive: whichDaysRevised[1]), 
                                  StreakCard(date: todaysDate.subtract(Duration(days: 2)).day.toString(), isActive: whichDaysRevised[2]),
                                  StreakCard(date: todaysDate.subtract(Duration(days: 3)).day.toString(), isActive: whichDaysRevised[3]), 
                                  StreakCard(date: todaysDate.subtract(Duration(days: 4)).day.toString(), isActive: whichDaysRevised[4]), 
                                  StreakCard(date: todaysDate.subtract(Duration(days: 5)).day.toString(), isActive: whichDaysRevised[5]),
                                  StreakCard(date: todaysDate.subtract(Duration(days: 6)).day.toString(), isActive: whichDaysRevised[6]),
                                ],
                              ) 
                            : Center(child: CircularProgressIndicator()),     
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // STATISTICS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsets.only(left: 21),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Statistics",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColours.almostWhite,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "$noDaysLoggedIn total days logged in.\n"
                          "$numberOfDecksRevised decks revised.\n"
                          "${examDate == null ? "Exam Date Not Set.\n" : "Your exam is on ${examDate!.day}/${examDate!.month}/${examDate!.year} and you have ${examDate!.difference(DateTime.now()).inDays} days left to revise.\n"}"
                          "This means you have revised an average of ${numberOfDecksRevised / noDaysLoggedIn} decks per day that you logged in.\n",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColours.almostWhite,
                          ),
                        ),
                      ), ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreakCard extends StatefulWidget {

  final String date;
  final bool isActive;

  const StreakCard({
    super.key,
    required this.date,
    this.isActive = false, // False is the default value
  });

  @override
  State<StreakCard> createState() => StreakCardState();
}

class StreakCardState extends State<StreakCard> {
  String getOrdinalEnding(){
    if (widget.date == "1" || widget.date == "31") {
      return "st";
    }
    else if (widget.date == "2" || widget.date == "22") {
      return "nd"; 
    }
    else if (widget.date == "3" || widget.date == "23") {
      return "rd";
    }
    else{
      return "th";
    }
  }
  @override
  Widget build(BuildContext context) {
    String ending = getOrdinalEnding();
    return SizedBox(
      width: 150,
      height: 200,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: AppColours.almostWhite,
          ),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                "${widget.date}$ending",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColours.darkBlue,
                ),
              ),
              const SizedBox(height: 40),
              Icon(
                Icons.local_fire_department,
                size: 90,
                color: widget.isActive ? AppColours.orange : AppColours.darkBlue,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}