import 'package:flashcard_x/screens/flag_overview_page.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Flag Overview Page Tests', () {
    testWidgets('FlagOverviewPage shows flagged questions and total questions',
            (WidgetTester tester) async {
          final Set<int> flaggedQuestions = {0, 2, 4};
          final int totalQuestions = 10;

          await tester.pumpWidget(
            ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(testing: true),
              child: MaterialApp(
                home: Scaffold(
                  body: Row(
                    children: [
                      Expanded(
                        child: FlagOverviewPage(
                          flaggedQuestions: flaggedQuestions,
                          totalQuestions: totalQuestions,
                          onQuestionSelected: (questionNumber) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );


          expect(find.text('Mock Exam: Review Screen'), findsOneWidget);
          expect(find.text('Multiple Choice Questions (Question 1-10)'), findsOneWidget);
          expect(find.byType(GestureDetector), findsAtLeastNWidgets(10));
          expect(find.byIcon(Icons.flag), findsNWidgets(3));
        });

    testWidgets('QuestionGrid layout and text styles', (WidgetTester tester) async {
      final Set<int> flaggedQuestions = {0, 2};
      final int totalQuestions = 5;

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(testing: true),
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: FlagOverviewPage(
                      flaggedQuestions: flaggedQuestions,
                      totalQuestions: totalQuestions,
                      onQuestionSelected: (questionNumber) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );


      final gridView = tester.widget<GridView>(find.byType(GridView));
      final gridDelegate =
      gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, 10);
      expect(gridDelegate.crossAxisSpacing, 8);
      expect(gridDelegate.mainAxisSpacing, 8);
      expect(gridDelegate.childAspectRatio, 2);


      final textFinder = find.text('Q1');
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style!.color, Colors.black);
    });

    testWidgets('Custom expandable question grid expands and retracts correctly',
            (WidgetTester tester) async {
          final Set<int> flaggedQuestions = {};
          final int totalQuestions = 5;

          await tester.pumpWidget(
            ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(testing: true),
              child: MaterialApp(
                home: Scaffold(
                  body: Row(
                    children: [
                      Expanded(
                        child: FlagOverviewPage(
                          flaggedQuestions: flaggedQuestions,
                          totalQuestions: totalQuestions,
                          onQuestionSelected: (questionNumber) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          expect(find.byIcon(Icons.remove), findsOneWidget);

          await tester.tap(find.byIcon(Icons.remove).first);
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.add), findsOneWidget);

          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.remove), findsOneWidget);
        });
  });
}