import 'package:flashcard_x/screens/sign_up_screen.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flashcard_x/widgets/google_sign_in_button.dart';
import 'package:flashcard_x/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/reset_password_screen.dart';

class SignInScreen extends StatefulWidget {
  static String id = 'login';

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app_logo4.png',
                // this file doesn't exist and generates error
                height: 130,
              ),
              const SizedBox(height: 20),
              Text("MedicRecall",
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )),
              const SizedBox(height: 20),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return LoginForm(
                      emailFocusNode: _emailFocusNode,
                      passwordFocusNode: _passwordFocusNode,
                    );
                  }
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPassword()));
                },
                child: Text(
                  "Forgot Password?",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Don't have an account? Click here to ",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 19,
                        color: Colors.white
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, SignUpScreen.id);
                    },
                    child: Text(
                      "Sign Up",
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              const GoogleSignInButton(),
            ],
          )
        ],
      ),
    );
  }
}
