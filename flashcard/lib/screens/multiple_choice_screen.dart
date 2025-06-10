import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/widgets/question_page.dart';
import 'package:flashcard_x/questions/question.dart';
import 'flag_overview_page.dart';
import 'submission_overview_page.dart';
import 'exam_answers.dart'; 
import 'dart:async';

class MultipleChoicePage extends StatefulWidget {
  final DateTime? examEndTime;
  final List<int> rankingCorrectQuestions;
  final int rankingTotalQuestions;
  
  const MultipleChoicePage({
    super.key, 
    this.examEndTime,
    required this.rankingCorrectQuestions,
    required this.rankingTotalQuestions,
  });

  @override
  MultipleChoicePageState createState() => MultipleChoicePageState();
}


class MultipleChoicePageState extends State<MultipleChoicePage> {
  List<Question> questions = [];
  bool isLoading = true;
  String errorMessage = '';

  Map<int, Set<int>> selectedOptions = {};
  // Store the indices of flagged questions
  Set<int> flaggedQuestions = {};

  // New: Map to record submission status for each question, 0 = not submitted, 1 = submitted
  Map<int, int> submissionStatus = {};

  // New: List to store the question numbers that are answered correctly
  List<int> correctQuestions = [];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _countdownTimer;
  String _countdownString = "00:00";
  
  late DateTime examEndTime;

  @override
  void initState() {
    super.initState();
    examEndTime = widget.examEndTime ?? DateTime.now().add(const Duration(minutes: 90));
    _fetchMultipleChoiceData();
    _startCountdown();
  }

  void _startCountdown() {
    _updateCountdown(examEndTime);
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          _updateCountdown(examEndTime);
        });
  }

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

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMultipleChoiceData() async {
    try {
      FirebaseFirestore firestore = FirebaseWrapper.firestore();

      // Query questions based on the defined logic
      QuerySnapshot<Map<String, dynamic>> p2Query = await firestore
          .collection("markscheme")
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'P2 ')
          .where(FieldPath.documentId, isLessThan: 'P3 ')
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = p2Query.docs;

      List<Question> fetchedQuestions =
          allDocs.map((doc) => Question.fromMap(doc.data(), doc.id)).toList();

      // Initialize selected options for each question
      for (int i = 0; i < fetchedQuestions.length; i++) {
        selectedOptions[i] = {};
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

  void _handleOptionSelected(int action, Set<int> selectedValues) {
    if (action >= 0) {
      setState(() {
        // Save the user's selection
        selectedOptions[action] = selectedValues;
      });
    } else if (action == -1) {
      // If on the first question, return to the previous (ranking) page
      if (_currentPage == 0) {
        Navigator.pop(context);
      } else {
        // Otherwise, go to the previous question in the PageView
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    } else if (action == -2) {
      // Go to the next question
      if (_currentPage < questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
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
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(errorMessage)),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('No Questions')),
        body: const Center(child: Text('No available questions.')),
      );
    }

    return AppScaffold(
      title: "Multiple Choice",
      examEndTime: examEndTime,
      body: Column(
        children: [
          // Main area: PageView displays each question
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
                return QuestionPage(
                  question: questions[index],
                  questionIndex: index,
                  totalQuestions: questions.length,
                  selectedOptions: selectedOptions[index] ?? {},
                  onOptionSelected: _handleOptionSelected,
                  isFlagged: flaggedQuestions.contains(index),
                  onFlagToggle: (bool flagStatus) {
                    _toggleFlag(index, flagStatus);
                  },
                  remainingTime: _countdownString,
                );
              },
            ),
          ),
          // Bottom action buttons row with countdown display at the left
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
                    if (_currentPage == 0) {
                      Navigator.pop(context);
                    } else {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  child: const Text("Previous Page"),
                ),
                // Next question button
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
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamAnswersPage(
                        rankingCorrectList: widget.rankingCorrectQuestions,
                        rankingTotalLength: widget.rankingTotalQuestions,
                        mcCorrectList: correctQuestions,
                        mcTotalLength: questions.length,
    ),
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
                    // Get the user's selected options for current question
                    Set<int> userSelected = selectedOptions[_currentPage] ?? {};
                    // Get the correct options from the question model
                    List<int> correctOptions = questions[_currentPage].correctOptions;
                    Set<int> correctSet = correctOptions.toSet();
                    // Compare the user's selected set with the correct set
                    if (userSelected.length == correctSet.length &&
                        userSelected.containsAll(correctSet)) {
                      correctQuestions.add(_currentPage);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Answer Correct!"),
                          duration: const Duration(milliseconds: 500), 
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                        content:  const Text("Answer Incorrect!"),
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
