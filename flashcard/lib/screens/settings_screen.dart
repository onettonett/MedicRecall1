import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/explanation.dart';
import 'package:flashcard_x/screens/faq.dart';
// import 'package:flashcard_x/screens/feedback_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flashcard_x/screens/user_details_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'calendar_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  bool isNotify = false;

  @override
  void initState() {
    super.initState();
    triggerSignIn('settings');
    checkNotify();
  }

//When the notification option is changed, update the change in the firebase
Future<void> changeNotify() async {
  CollectionReference collectionRef =
  FirebaseWrapper.firestore().collection('users');
  QuerySnapshot querySnapshot =
  await collectionRef.where("userID", isEqualTo: user.uid).get();
  var userID = querySnapshot.docs.last.id;

  collectionRef.doc(userID).update({"notify": isNotify});

}

//Check if the notification field from the firebase for the user is set to true or false and shouw the value in the settings screen
Future<void> checkNotify() async {
  CollectionReference collectionRef =
  FirebaseWrapper.firestore().collection('users');
  QuerySnapshot querySnapshot =
  await collectionRef.where("userID", isEqualTo: user.uid).get();
  var userFromDb = querySnapshot.docs.first;

  Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
  if (data["notify"] == true) {
    isNotify = true;
  } else if (data["notify"] == false) {
    isNotify = false;
  }
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppScaffold(
      title: "Settings",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DARK MODE SWITCH
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  title: Text('Dark Mode', style: theme.textTheme.bodyLarge!.copyWith(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  leading: Icon(Icons.dark_mode, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  trailing: DayNightSwitcher(
                    nightBackgroundColor: Colors.black,
                    isDarkModeEnabled: themeProvider.isDarkMode,
                    onStateChanged: (val) {
                      setState(() {
                        themeProvider.toggleTheme();
                      });
                      onThemeChanged(val, themeProvider);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // EMAIL NOTIFICATIONS SWITCH
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  title: Text('Email Notifications', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  leading: Icon(Icons.notifications, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  trailing: CupertinoSwitch(
                    value: isNotify,
                    onChanged: (val) {
                      setState(() {
                        isNotify = val;
                        changeNotify();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // USER DETAILS
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  title: Text('Make a Revision Plan', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  onTap: () => triggerSignIn('Calendar'),
                ),
              ),
              const SizedBox(height: 10),
              // HOW DOES THE PLATFORM WORK BUTTON
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: Icon(Icons.person, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  title: Text('User Details', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  onTap: () => triggerSignIn('UserDetailsPage'),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_increase_rounded,
                              color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                          SizedBox(width: 16),
                          Text('Font Size',
                              style: theme.textTheme.bodyLarge!.copyWith(
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black
                              )
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 300,
                        child: Slider(
                            value: themeProvider.offset + 5,
                            min: 0,
                            max: 20,
                            divisions: 8,
                            onChanged: (value) => {
                              themeProvider.setFontSize(value - 5)
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // FAQ BUTTON
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: Icon(Icons.question_mark_sharp, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  title: Text('How does the platform work?', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExplanationScreen()),
                    );
                  }
                ),
              ),
              const SizedBox(height: 10),
              // FEEDBACK BUTTON
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: Icon(Icons.question_mark_sharp, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  title: Text('Frequently Asked Questions', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQScreen()),
                    );
                  }
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: themeProvider.isDarkMode ? Color.fromRGBO(20, 35, 52, 1) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: ListTile(
                  leading: Icon(Icons.question_mark_sharp, color: themeProvider.isDarkMode ? Colors.white : theme.primaryColor),
                  title: Text('Give us Feedback', style: theme.textTheme.bodyLarge!.copyWith(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black
                  )),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => FeedbackScreen()),
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
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onThemeChanged(bool value, ThemeProvider themeProvider) async {
    (value)
        ? themeProvider.setDarkTheme()
        : themeProvider.setLightTheme();
  }

  Future<void> triggerSignIn(String screen) async{
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
      if (screen == 'UserDetailsPage'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const UserDetailsPage(),
            )
        );
      }
      else if (screen == 'Calendar'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const Calendar(),
            )
        );
      } else {
        user = auth.currentUser!;
      }
    }
  }
}
