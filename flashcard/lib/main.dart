import 'package:firebase_core/firebase_core.dart';
import 'package:flashcard_x/firebase_options.dart';
import 'package:flashcard_x/screens/dash_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/sign_up_screen.dart';
import 'package:flashcard_x/screens/verify_email_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'utils/theme_provider.dart';

Future<void> main() async {
  /// For disabling landscape view in mobile & tablet devices
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseWrapper.setup();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive).then((_) {
    // full screen mode
      runApp(
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(),
            child: const Flashcard()),
        // child: Login(), //run to log into the app
        // child: SignInScreen()), //run to log into the app
      );
    
  });
}

class Flashcard extends StatelessWidget {
  const Flashcard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Consumer<ThemeProvider>(builder: (context, appState, child) {
      return MaterialApp(
          title: 'MedicRecall',
          theme: themeProvider.theme,
          debugShowCheckedModeBanner: false,
          // Remove the debug banner
          // home: const SignInScreen(),
          initialRoute: SignInScreen.id,
          routes: {
            VerifyEmailScreen.id: (context) => const VerifyEmailScreen(),
            SignInScreen.id: (context) => const SignInScreen(),
            SignUpScreen.id: (context) => const SignUpScreen(),
            HomePage.id: (context) => const HomePage(title: "Medicine Upload"),
            Dashboard.id: (context) => const Dashboard(),
          }
          );
    });
  }
}
