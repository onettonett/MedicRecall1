import 'package:flashcard_x/screens/dash_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/mark_scheme.dart';
import 'package:flashcard_x/screens/settings_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/streaks_page.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/exam_declaration.dart';
import 'package:provider/provider.dart';
import '../screens/calendar_screen.dart';
import '../screens/flashcard_editor_screen.dart';

class DrawMain extends StatelessWidget {
  const DrawMain({super.key});

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MoveRightRoute(page: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.dialogTheme.backgroundColor,
      width: 80,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(width: 50, height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerTile(
                      onPressed: () => _navigateToPage(context, Dashboard()),
                      icon: const Icon(Icons.home_outlined),
                      title: "Home",
                    ),
                    DrawerTile(
                      onPressed: () => _navigateToPage(
                          context, const HomePage(title: "Flashcard Tutor")),
                      icon: const Icon(Icons.rate_review_outlined),
                      title: "Flashcard Tutor",
                    ),
                    DrawerTile(
                      onPressed: () => _navigateToPage(context, const UMS()),
                      icon: const Icon(Icons.check_box_outlined),
                      title: "Mark Scheme",
                    ),
                    DrawerTile(
                      onPressed: () =>
                          _navigateToPage(context, ExamDeclaration()),
                      icon: const Icon(Icons.fact_check),
                      title: 'Mock Exam',
                    ),
                    DrawerTile(
                      onPressed: () =>
                          _navigateToPage(context, const FlashcardEditor()),
                      icon: const Icon(Icons.add_box_outlined),
                      title: 'Create Flashcards',
                    ),
                    DrawerTile(
                      onPressed: () =>
                          _navigateToPage(context, const Calendar()),
                      icon: const Icon(Icons.calendar_month_outlined),
                      title: 'Study Schedule',
                    ),
                    DrawerTile(
                      onPressed: () =>
                          _navigateToPage(context, const Streaks()),
                      icon: const Icon(Icons.local_fire_department),
                      title: 'Streaks',
                    ),
                    DrawerTile(
                      onPressed: () =>
                          _navigateToPage(context, const Settings()),
                      icon: const Icon(Icons.settings),
                      title: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
            DrawerTile(
              icon: const Icon(Icons.logout),
              title: 'Logout',
              backgroundColor: Colors.red,
              onPressed: () {
                Authentication.signOut(context: context);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    SignInScreen.id, (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.title,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.hoverColor,
  });

  final void Function() onPressed;
  final Icon icon;
  final String title;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bcolor = backgroundColor ?? theme.colorScheme.primary;
    // The .withGreen() stuff is kinda hacky but actually looks ok...
    final hcolor = hoverColor ?? bcolor.withValues(green: bcolor.g-50);

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(
              height: 35,
              width: 60,
              child: FloatingActionButton(
                heroTag: title,
                elevation: 0,
                onPressed: onPressed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: bcolor,
                foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
                hoverColor: hcolor,
                child: icon,
              ),
            ),
            Text(
              title,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black
              ),
            )
          ],
        )
    );
  }
}

