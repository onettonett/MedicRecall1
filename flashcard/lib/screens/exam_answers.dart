import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamAnswersPage extends StatefulWidget {
  // Correct answer list for ranking questions
  final List<int> rankingCorrectList;
  // Total number of ranking questions
  final int rankingTotalLength;
  // Correct answer list for multiple-choice questions
  final List<int> mcCorrectList;
  // Total number of multiple-choice questions
  final int mcTotalLength;

  const ExamAnswersPage({
    super.key,
    required this.rankingCorrectList,
    required this.rankingTotalLength,
    required this.mcCorrectList,
    required this.mcTotalLength,
  });

  @override
  ExamAnswersPageState createState() => ExamAnswersPageState();
}

class ExamAnswersPageState extends State<ExamAnswersPage> {
  double _averageScore = 0; // Average score = total score divided by exam count
  int _totalScore = 0; // Total sum of all exam scores
  int _examCount = 0;  // Total number of exam sessions

  @override
  void initState() {
    super.initState();
    final int calculatedScore = widget.rankingCorrectList.length + widget.mcCorrectList.length;
    // Cache the current exam score and update average score data
    _loadScoreData(calculatedScore);
  }

  Future<void> _loadScoreData(int calculatedScore) async {
    await ScoreCache.addScore(calculatedScore);
    final avgScore = await ScoreCache.getAverageScore();
    final totalScore = await ScoreCache.getTotalScore();
    final examCount = await ScoreCache.getExamCount();
    setState(() {
      _averageScore = avgScore;
      _totalScore = totalScore;
      _examCount = examCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate total correct score and total number of questions
    final int calculatedScore = widget.rankingCorrectList.length + widget.mcCorrectList.length;
    final int calculatedMaxScore = widget.rankingTotalLength + widget.mcTotalLength;

    return AppScaffold(
      title: "Mock Exam: Answers",
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                "Your Performance",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Mock Exam Results",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth > 600
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ScoreWidget(
                                  score: calculatedScore.toDouble(),
                                  maxScore: calculatedMaxScore,
                                  title: "Your Score",
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: ScoreWidget(
                                  score: _averageScore, // Use double average score
                                  maxScore: calculatedMaxScore,
                                  title: "Average Score",
                                  totalScore: _totalScore,
                                  examCount: _examCount,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ScoreWidget(
                                  score: calculatedScore.toDouble(),
                                  maxScore: calculatedMaxScore,
                                  title: "Your Score",
                                ),
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: ScoreWidget(
                                  score: _averageScore, // Use double average score
                                  maxScore: calculatedMaxScore,
                                  title: "Average Score",
                                  totalScore: _totalScore,
                                  examCount: _examCount,
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  final double score; // Changed type from int to double for accurate average calculation
  final int maxScore;
  final String title;
  final int? totalScore; // Total score for average calculation (optional)
  final int? examCount;  // Number of exam sessions (optional)

  const ScoreWidget({
    super.key,
    required this.score,
    required this.maxScore,
    required this.title,
    this.totalScore,
    this.examCount,
  });

  // Percentage is calculated as (score / maxScore) * 100
  double get percentage => (score / maxScore) * 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color correctColor = Colors.green;
    final Color incorrectColor = Colors.red;

    // For Average Score widget, display text layout without chart
if (title == "Average Score" && totalScore != null && examCount != null) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // New text layout for Average Score widget (without chart)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display average percentage based on (total score / exam count) relative to maxScore
              Text(
                "${percentage.toStringAsFixed(0)}%",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Removed the row that shows total and exam count
            ],
          ),
        ],
      ),
    ),
  );
}


    // Original chart layout for non-average score (e.g., Your Score)
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxDimension = constraints.maxHeight < constraints.maxWidth
                      ? constraints.maxHeight
                      : constraints.maxWidth;
                  final double chartSize = maxDimension > 250 ? 250 : maxDimension * 0.8;
                  final double chartThickness = 25;

                  return Center(
                    child: SizedBox(
                      width: chartSize,
                      height: chartSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: percentage,
                                  color: correctColor,
                                  radius: chartThickness,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: 100 - percentage,
                                  color: incorrectColor,
                                  radius: chartThickness,
                                  showTitle: false,
                                ),
                              ],
                              sectionsSpace: 0,
                              centerSpaceRadius: max(chartSize / 2 - chartThickness, 45),
                              startDegreeOffset: 270,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${percentage.toStringAsFixed(0)}%",
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${score.toStringAsFixed(1)}/$maxScore",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsible for storing each exam score in local cache and calculating average score
class ScoreCache {
  static const String _scoresKey = "exam_scores";

  // Add one exam score to local storage
  static Future<void> addScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    scores.add(score.toString());
    await prefs.setStringList(_scoresKey, scores);
  }

  // Calculate average score from all stored scores
  static Future<double> getAverageScore() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    if (scores.isEmpty) return 0;
    int sum = scores.fold(0, (previous, element) => previous + int.parse(element));
    return sum / scores.length;
  }

  // Get total of all scores from local cache
  static Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    int sum = scores.fold(0, (previous, element) => previous + int.parse(element));
    return sum;
  }

  // Get number of exam sessions from local cache
  static Future<int> getExamCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    return scores.length;
  }
}
