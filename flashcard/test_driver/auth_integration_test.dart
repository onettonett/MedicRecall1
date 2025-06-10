import 'package:firebase_core/firebase_core.dart';
import 'package:flashcard_x/firebase_options.dart';
import 'package:flashcard_x/main.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform
      );
      FirebaseWrapper.setupForIntegrationTesting();
  });

  testWidgets('User can log in from UI', (WidgetTester tester) async {
    final auth = FirebaseWrapper.auth();
    await FirebaseWrapper.auth().signOut();
    await auth.createUserWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    );

    runApp(
      ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
        child: const Flashcard(),
      ),
    );

    await tester.pumpAndSettle();

    Finder loginScreenFinder = find.byKey(Key('emailSignUpField'));
    int retries = 0;
    while (loginScreenFinder.evaluate().isEmpty && retries < 10) {
      await tester.pump(const Duration(milliseconds: 500));
      retries++;
    }
    expect(loginScreenFinder, findsOneWidget);

    await tester.enterText(find.byKey(Key('emailSignUpField')), 'test@example.com');
    await tester.enterText(find.byKey(Key('passwordSignUpField')), 'password123');
    await tester.tap(find.byKey(Key('Log In Button')));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text("A verification email has been sent to your email."), findsOneWidget);
    await auth.currentUser?.delete();
  });
}
