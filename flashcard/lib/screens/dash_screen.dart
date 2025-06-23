import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/exam_declaration.dart';
import 'package:flashcard_x/screens/explanation.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/flashcard_editor_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/last_revised.dart';
import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Dashboard extends StatefulWidget {
  static String id = 'dashboard';

  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  String? nextTopicForReview;
  String? daysUntilExam;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? stream;

  int howManyDaysInARow = 0;
  List<bool> whichDaysRevised = [];
  DateTime? examDate;
  int numberOfDecksRevised = 0;
  List<DateTime> daysLoggedIn = [];
  int noDaysLoggedIn = 0;
  DateTime todaysDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);


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
    });

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // This 'final localExamDate' avoids null safety issues & can be removed in versions >= Flutter 3.2 
    final localExamDate = examDate; 
    return AppScaffold(
      title: "User Dashboard",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DashboardBoxLeft(
                      title: 'Flashcard Tutor',
                      //subtitle: "Next topic for review: ${nextTopicForReview}",
                      subtitle: nextTopicForReview != null
                          ? "Next topic for review: ${nextTopicForReview}"
                          : "No topics scheduled.",
                      buttonText: 'Start Now',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MoveRightRoute(page: const HomePage(title: "Flashcard Tutor")),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DashboardBoxRight(
                      title: 'Next Mock Exam:',
                      button1Text: 'Full-Sized Mock',
                      button2Text: 'Mini Mocks',
                      subtitle: 'Official Paper 1',
                      on1Pressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExamDeclaration())
                        );
                      },
                      on2Pressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExamDeclaration())
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(children: [
                BottomButton(
                    label: 'Study Schedule',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MoveRightRoute(page: const Calendar()),
                      );
                    },
                  ),
                  BottomButton(
                    label: 'Create New Flashcards',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MoveRightRoute(page: const FlashcardEditor()),
                      );
                    },
                  )
              ],),
              SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Card(
                    color: AppColours.darkBlue,
                    child: Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(children: [
                      Text(
                        "Statistics",
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: AppColours.almostWhite),
                      ),
                      SizedBox(height: 2),
                      Row(children: [
                        StatisticsWidget1(title: "Streak Count", iconFilePath: 'fire.png', displayedValue: howManyDaysInARow),
                        // SvgPicture.asset(
                        //   'assets/Calendar.svg',
                        //   width: 100,
                        //   height: 100,
                        //   placeholderBuilder: (context) => CircularProgressIndicator(),
                        // ),
                        SizedBox(width: 10),
                        StatisticsWidget1(title: "Total Decks Revised", iconFilePath: 'clock.png', displayedValue: numberOfDecksRevised),
                        SizedBox(width: 10),
                        StatisticsWidget1(
                          title: "Exam Countdown", iconFilePath: 'calendar.png',
                          displayedValue: localExamDate != null
                          ? localExamDate.difference(DateTime.now()).inDays
                          : -1
                        ),
                      ],
                    )]
                    )
                  )
                ))
              ],),

              /// ---DEPRECATED STREAKS CARD CODE ---
              // Row(
              //   children: [
              //     Expanded(
              //       child: Card(
              //         color: AppColours.darkBlue,
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              //           child: Column(
              //             children: [
              //               Align(
              //                 alignment: Alignment.centerLeft,
              //                 child: Text(
              //                   "Streaks",
              //                   style: theme.textTheme.titleMedium!.copyWith(
              //                     color: AppColours.almostWhite,
              //                   ),
              //                 ),
              //               ),
              //               const SizedBox(height: 10),
              //               SingleChildScrollView(
              //                 scrollDirection: Axis.horizontal,
              //                 child: whichDaysRevised.isNotEmpty 
              //                   ? Row(
              //                       children: [
              //                         MiniStreakCard(date: todaysDate.day.toString(), isActive: whichDaysRevised[0]),
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 1)).day.toString(), isActive: whichDaysRevised[1]), 
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 2)).day.toString(), isActive: whichDaysRevised[2]),
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 3)).day.toString(), isActive: whichDaysRevised[3]), 
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 4)).day.toString(), isActive: whichDaysRevised[4]), 
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 5)).day.toString(), isActive: whichDaysRevised[5]),
              //                         MiniStreakCard(date: todaysDate.subtract(Duration(days: 6)).day.toString(), isActive: whichDaysRevised[6]),
              //                       ],
              //                     ) 
              //                   : Center(child: CircularProgressIndicator()),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ]
              // ),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomButton(
                    label: 'How does the platform work?',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MoveRightRoute(page: const ExplanationScreen()),
                      );
                    },
                  ),
                  BottomButton(
                    label: 'Frequently asked Questions',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MoveRightRoute(page: const FAQScreen()),
                      );
                    },
                  ),
                  BottomButton(
                    label: 'Give us Feedback',
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MoveRightRoute(page: const FeedbackScreen()),
                      // );
                      () async {
                        //on tap code here, you can navigate to other page or URL
                        String url =
                            "https://docs.google.com/forms/d/e/1FAIpQLSf10CDlLeFpaONtjS1pU0qcEsdQPfngeXh70-hhZpXUGCQDqA/viewform?usp=sf_link";
                        var urllaunchable =
                            await canLaunchUrlString(
                            url); //canLaunch is from url_launcher package
                        if (urllaunchable) {
                          await launchUrlString(
                              url); //launch is from url_launcher package to launch URL
                        }
                      }();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUser().then((_) {
      LastRevised.recordLogin();
      getNextTopicForReview();
      getExamDate();
    });
    setState(() {});
    loadStreakData();
  }

  @override
  void dispose() {
    super.dispose();
    if (stream != null) {
      stream!.cancel();
    }
  }


  // ----- Retrieve information for the dashboard -----
  Future<void> getNextTopicForReview() async {
    TopicStats stats = await LastRevised.getStats(includeSubtopics: false);
    Map<String, DateTime> nextReviewDatesMap = LastRevised.nextReviewDateByTopic(stats);
    String nextTopic = nextReviewDatesMap.keys.first;
    DateTime nextReviewDate = nextReviewDatesMap.values.first;

    for (String topicID in nextReviewDatesMap.keys) {
      if (nextReviewDatesMap[topicID]!.isBefore(nextReviewDate)) {
        nextTopic = topicID;
        nextReviewDate = nextReviewDatesMap[topicID]!;
      }
    }

    if (mounted) {
      setState(() {
        nextTopicForReview = nextTopic;
      });
    }

  }

  Future<void> getExamDate() async {

    if (FirebaseWrapper.auth().currentUser == null) {
      return;
    }

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    var snapshots =  FirebaseWrapper.firestore().doc("users/$userID").snapshots();

    if (mounted) {
      stream = snapshots.listen((snapshot) {
        Timestamp? testDay = (snapshot.data()??{})["TestDay"];
        if (mounted) {
          if (testDay != null) {
            setState(() {
              daysUntilExam = "${testDay.toDate().difference(DateTime.now()).inDays} days";
            });
          } else {
            setState(() {
              daysUntilExam = "Date Not Set";
            });
          }
        }
      });

      setState(() {});
    }

  }

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
  }
}

class DashboardBoxLeft extends StatelessWidget {
  const DashboardBoxLeft({super.key, 
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.subtitle,
    this.height,
  });

  final String title;
  final String buttonText;
  final Null Function() onPressed;
  final String? subtitle;
  final double? height;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SizedBox(
      height: height ?? 160,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue[50],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black
              ),
            ),
            SizedBox(height: 10),
            subtitle == null ? CircularProgressIndicator(color: themeProvider.isDarkMode ? Colors.white : Colors.black) : Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Color.fromRGBO(44, 44, 44, 1),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBoxRight extends StatelessWidget {
  const DashboardBoxRight({super.key, 
    required this.title,
    required this.button1Text,
    required this.button2Text,
    required this.on1Pressed,
    required this.on2Pressed,
    this.subtitle,
    this.height,
  });

  final String title;
  final String button1Text;
  final String button2Text;
  final Null Function() on1Pressed;
  final Null Function() on2Pressed;
  final String? subtitle;
  final double? height;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SizedBox(
      height: height ?? 160,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.blueGrey : Colors.blue[50],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ElevatedButton(
               onPressed: on1Pressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Color.fromRGBO(44, 44, 44, 1),
              ),
              child: Text(
                button1Text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: on2Pressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Color.fromRGBO(44, 44, 44, 1),
              ),
              child: Text(
                button2Text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white
                ),
              ),
            ),
            ],),
            SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black
              ),
            ),
            SizedBox(height: 10),
            subtitle == null ? CircularProgressIndicator(color: themeProvider.isDarkMode ? Colors.white : Colors.black) : Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class StatisticsWidget1 extends StatelessWidget {
  const StatisticsWidget1({super.key, 
    required this.title,
    required this.iconFilePath,
    required this.displayedValue,
  });

  final String title;
  final String iconFilePath;
  final int displayedValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: Color.fromRGBO(44,44,44,1),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10,15,10,10),
          child: Column(
            children: [
              Column(children: [
                SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.left,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: AppColours.almostWhite
                    ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    "$displayedValue days",
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: AppColours.almostWhite,
                        fontWeight: FontWeight.w200,
                        fontSize: 40
                      )
                    ),
                    SizedBox(width: 20),
                    Container(
                      height: 40,
                      child: Image.asset(
                        iconFilePath,
                        //'trending_up.png',
                      )
                    ),
                ])
              ])
            ],
          ),
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton({super.key, 
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Null Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Color.fromRGBO(44, 44, 44, 1),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white
            )
          ),
        ),
      ),
    );
  }
}

class AppColours {
  static const Color darkBlue = Color.fromRGBO(20, 35, 52, 1);
  static const Color almostWhite = Color.fromRGBO(230, 230, 230, 1);
  static const Color orange = Color.fromRGBO(221, 117, 67, 1);
}

class MiniStreakCard extends StatefulWidget {

  final String date;
  final bool isActive;

  const MiniStreakCard({
    super.key,
    required this.date,
    this.isActive = false, // False is the default value
  });

  @override
  State<MiniStreakCard> createState() => MiniStreakCardState();
}

class MiniStreakCardState extends State<MiniStreakCard> {
  String getOrdinalEnding(){
    if (widget.date == "2" || widget.date == "22") {
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
      width: 100,
      height: 150,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: AppColours.almostWhite,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 12),
              Text(
                "${widget.date}$ending",
                style: const TextStyle(
                  fontSize: 18,
                  //fontWeight: FontWeight.bold,
                  color: AppColours.darkBlue,
                ),
              ),
              const SizedBox(height: 28),
              Icon(
                Icons.local_fire_department,
                size: 70,
                color: widget.isActive ? AppColours.orange : AppColours.darkBlue,
              ),
              const SizedBox(height: 5)
            ],
          ),
        ),
      ),
    );
  }
}