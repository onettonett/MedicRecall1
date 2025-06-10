import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';

class DesignMain {
  static AppBar appBarMain(String title, BuildContext context) {
    return AppBar(
      title: Align(
        alignment: const Alignment(-0.06, 0),
        child: Stack(
          children: [
            Positioned(
              top: 2.3,
              child: Image.asset(
                'assets/app_logo4.png',
                fit: BoxFit.cover,
                height: 34,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 32),
              padding: const EdgeInsets.all(8.0),
              child: Text(title),
            ),
          ],
        ),
      ),

      centerTitle: true,
      leading: Builder(
          builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(
                  Icons.menu,
                ),
              )),
    );
  }
}

class RefreshDesignMain {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  //AppBar where the back button pops entire stack and goes back to flashcard page. Also, back button updates calendar revision events in database.
  AppBar appBarMain(String title, BuildContext context) {

    void home() {
      Navigator.of(context).popUntil((route) => false);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage(title: 'Home')));
    }

    return AppBar(
      title: Align(
        alignment: const Alignment(-0.06, 0),
        child: Stack(
          children: [
            Positioned(
              top: 2.3,
              child: Image.asset(
                'assets/app_logo4.png',
                fit: BoxFit.cover,
                height: 34,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 32),
              padding: const EdgeInsets.all(8.0),
              child: Text(title),
            ),
          ],
        ),
      ),

      centerTitle: true,
      leading: GestureDetector(
        key: const ValueKey('HomePage'),
        onTap: () => home(),
        child: const Icon(
          Icons.arrow_back, // add custom icons also
        ),
      ),
    );
  }
}
