import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/widgets/ranking_question.dart';
import 'package:flashcard_x/questions/question.dart';
import 'flag_overview_page.dart';
import 'package:flashcard_x/screens/multiple_choice_screen.dart'; 
import 'submission_overview_page.dart';
import 'dart:async';

class MocktestrankePage extends StatefulWidget {
  final DateTime? examEndTime;
  const MocktestrankePage({super.key, this.examEndTime});

  @override
  MocktestrankePageState createState() => MocktestrankePageState();
}

class MocktestrankePageState extends State<MocktestrankePage> {
  List<Question> questions = [];
  bool isLoading = true;
  String errorMessage = '';
  // Use a Map to store the ranking order for each question (List<int>)
  Map<int, List<int>> rankingOrders = {};
  
  // New: Map to record submission status for each question, 0 = not submitted, 1 = submitted
  Map<int, int> submissionStatus = {};

  // New: List to store the question numbers that are answered correctly
  List<int> correctQuestions = [];

  // Store the indices of flagged questions
  Set<int> flaggedQuestions = {};

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Timer? _countdownTimer;
  String _countdownString = "00:00";
  

  late DateTime examEndTime;

  @override
  void initState() {
    super.initState();
    examEndTime = widget.examEndTime ?? DateTime.now().add(const Duration(minutes: 90));
    _fetchMocktestChoiceData();
    _startCountdown();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMocktestChoiceData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query questions based on the defined logic
      QuerySnapshot<Map<String, dynamic>> p1Query = await firestore
          .collection("markscheme")
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'P3 ')
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = p1Query.docs;

      List<Question> fetchedQuestions =
          allDocs.map((doc) => Question.fromMap(doc.data(), doc.id)).toList();

      // Randomly select 30 questions if more than 30 are available
      if (fetchedQuestions.length > 30) {
        fetchedQuestions.shuffle();
        fetchedQuestions = fetchedQuestions.take(30).toList();
      }

      // Initialize the ranking order for each question (default order based on original options order)
      for (int i = 0; i < fetchedQuestions.length; i++) {
        rankingOrders[i] = List<int>.generate(
            fetchedQuestions[i].options.length, (index) => index);
        // Initialize submission status for each question: 0 means not submitted
        submissionStatus[i] = 0;
      }

      setState(() {
        questions = fetchedQuestions;
        isLoading = false;
      });
    } catch (e, _) {
      setState(() {
        errorMessage = 'Data retrieval error: $e';
        isLoading = false;
      });
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      });
    }
  }

  // Start the countdown timer
  void _startCountdown() {
    _updateCountdown(examEndTime);
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          _updateCountdown(examEndTime);
        });
  }

  // Update the countdown timer
  void _updateCountdown(DateTime examEndTime) {
    final diff = examEndTime.difference(DateTime.now());
    setState(() {
      if (diff.inSeconds <= 0) {
        _countdownString = "00:00";
        _countdownTimer?.cancel();
      } else {
        final minutes = diff.inMinutes.toString().padLeft(2, '0');
        final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
        _countdownString = "$minutes:$seconds";
      }
    });
  }

  // Callback: Handle ranking order change
  void _handleRankChanged(int questionIndex, List<int> newRankOrder) {
    setState(() {
      rankingOrders[questionIndex] = newRankOrder;
    });
  }

  // Toggle the flagged state for a question
  void _toggleFlag(int questionIndex, bool isFlagged) {
    setState(() {
      if (isFlagged) {
        flaggedQuestions.add(questionIndex);
      } else {
        flaggedQuestions.remove(questionIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppScaffold(
        title: 'Loading...',
        examEndTime: examEndTime, 
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return AppScaffold(
        title: 'Error',
        examEndTime: examEndTime, 
        body: Center(child: Text(errorMessage)),
      );
    }

    if (questions.isEmpty) {
      return AppScaffold(
        title: 'No Questions',
        examEndTime: examEndTime, 
        body: const Center(child: Text('No available questions.')),
      );
    }

    return AppScaffold(
      title: "Ranking Question",
      examEndTime: examEndTime, 
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return RankingQuestionPage(
                  question: questions[index],
                  questionIndex: index,
                  totalQuestions: questions.length,
                  // Pass the current ranking order for this question
                  initialRankOrder: rankingOrders[index] ?? [],
                  onRankChanged: _handleRankChanged,
                  isFlagged: flaggedQuestions.contains(index),
                  onFlagToggle: (bool flagStatus) {
                    _toggleFlag(index, flagStatus);
                  },
                  remainingTime: _countdownString,
                );
              },
            ),
          ),
          // Bottom action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous question button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: const Text("Previous Page"),
                ),
                // Next question button: If it's the last question, navigate to MultipleChoicePage
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (_currentPage < questions.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      // After finishing ranking questions, navigate to MultipleChoicePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultipleChoicePage(examEndTime: examEndTime,
                          rankingCorrectQuestions: correctQuestions,
                          rankingTotalQuestions: questions.length,),
                        ),
                      );
                    }
                  },
                  child: const Text("Next Page"),
                ),
                // Submit answer button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    // Update submission status for the current question to submitted (1)
                    setState(() {
                      submissionStatus[_currentPage] = 1;
                    });
                    // use questions anwers 
                    String correctAnswer = questions[_currentPage].answer;
                    // Convert user's ranking order (list of indices) to a letter sequence
                    List<int> userOrder = rankingOrders[_currentPage] ?? [];
                    String userAnswer = userOrder
                        .map((index) => String.fromCharCode('A'.codeUnitAt(0) + index))
                        .join();
                    
                    // Compare answers (ignoring case)
                    if (userAnswer.toUpperCase() == correctAnswer.toUpperCase()) {
                      // Add the current question number to the correctQuestions list
                      correctQuestions.add(_currentPage);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Answer Correct!"),
                          duration: const Duration(milliseconds: 500),
                          )
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Answer Incorrect!"),
                          duration: const Duration(milliseconds: 500),
                          )
                      );
                    }
                  },
                  child: const Text("Submit Answer"),
                ),
                // Flag question button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlagOverviewPage(
                          flaggedQuestions: flaggedQuestions,
                          totalQuestions: questions.length,
                          onQuestionSelected: (selectedIndex) {
                            // Close the flag overview and jump to the selected question
                            Navigator.pop(context);
                            _pageController.jumpToPage(selectedIndex);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Flag Question"),
                ),
                // New: Submission Overview button to show unsubmitted questions
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionOverviewPage(
                          submissionStatus: submissionStatus,
                          totalQuestions: questions.length,
                          onQuestionSelected: (selectedIndex) {
                            // Close the submission overview and jump to the selected question
                            Navigator.pop(context);
                            _pageController.jumpToPage(selectedIndex);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Submission Overview"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
