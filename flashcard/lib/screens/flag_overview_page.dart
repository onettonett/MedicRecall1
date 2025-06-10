import 'package:flutter/material.dart';

import '../widgets/app_bar_title.dart';

class FlagOverviewPage extends StatelessWidget {
  final Set<int> flaggedQuestions;
  final int totalQuestions;
  final ValueChanged<int> onQuestionSelected;

  const FlagOverviewPage({
    super.key,
    required this.flaggedQuestions,
    required this.totalQuestions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        title: "Mock Exam: Review Screen",
        body: Padding(
          padding: const EdgeInsets.fromLTRB(50, 16, 50, 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExpandablePanel(
                    title: "Multiple Choice Questions (Question 1-$totalQuestions)",
                    children: QuestionGrid(
                      questions: totalQuestions,
                      startingNumber: 0,
                      flaggedQuestions: flaggedQuestions,
                      onQuestionSelected: onQuestionSelected,
                    ),
                  ),
                  // Uncomment once we implement ranking questions
                  // SizedBox(height: 16),
                  // ExpandablePanel(
                  //   title: "Ranking Questions (Question ${multipleChoiceQuestions.length+1}-${multipleChoiceQuestions.length+rankingQuestions.length})",
                  //   children: QuestionGrid(
                  //     questions: rankingQuestions,
                  //     allQuestions: allQuestions,
                  //     startingNumber: multipleChoiceQuestions.length,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

class ExpandablePanel extends StatefulWidget {
  final String title;
  final Widget children;

  const ExpandablePanel({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  ExpandablePanelState createState() => ExpandablePanelState();
}

class ExpandablePanelState extends State<ExpandablePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _togglePanel,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: Colors.black,
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionGrid extends StatelessWidget {
  final int questions;
  final int startingNumber;
  final Set<int> flaggedQuestions;
  final ValueChanged<int> onQuestionSelected;

  const QuestionGrid({
    super.key,
    required this.questions,
    required this.startingNumber,
    required this.flaggedQuestions,
    required this.onQuestionSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.blue.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2,
        ),
        itemCount: questions,
        itemBuilder: (context, index) {
          var questionNumber = startingNumber + index;
          bool isFlagged = flaggedQuestions.contains(questionNumber);
          return GestureDetector(
            onTap: () {
              onQuestionSelected(questionNumber);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFlagged) ...[
                      SizedBox(width: 5),
                      Icon(Icons.flag, color: Colors.red, size: 16),
                    ],
                    Text(
                      'Q${(questionNumber+1).toString()}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


