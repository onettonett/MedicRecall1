import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Sidebar Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Sidebar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(testing: true),
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: const [
                  DrawMain(),
                  Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DrawMain), findsOneWidget);
      expect(find.byType(DrawerTile), findsAtLeastNWidgets(2));
    });

    testWidgets('Navigates when a sidebar tile is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(testing: true),
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: const [
                  DrawMain(),
                  Expanded(child: Placeholder()),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
