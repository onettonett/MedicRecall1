import 'package:flutter/material.dart';
import '../widgets/app_bar_title.dart';

class SubmissionOverviewPage extends StatelessWidget {
  final Map<int, int> submissionStatus;
  final int totalQuestions;
  final ValueChanged<int> onQuestionSelected;

  const SubmissionOverviewPage({
    super.key,
    required this.submissionStatus,
    required this.totalQuestions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    Set<int> unsubmittedQuestions = {};
    for (int i = 0; i < totalQuestions; i++) {
      if (submissionStatus[i] != 1) {
        unsubmittedQuestions.add(i);
      }
    }
    return AppScaffold(
      title: "Submission Overview",
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 16, 50, 16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpandablePanel(
                  title:
                      "Unsubmitted Questions (Question 1-$totalQuestions)",
                  children: SubmissionGrid(
                    unsubmittedQuestions: unsubmittedQuestions,
                    onQuestionSelected: onQuestionSelected,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class SubmissionGrid extends StatelessWidget {
  final Set<int> unsubmittedQuestions;
  final ValueChanged<int> onQuestionSelected;

  const SubmissionGrid({
    super.key,
    required this.unsubmittedQuestions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 将未提交的题号转换为有序列表
    List<int> questions = unsubmittedQuestions.toList()..sort();
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2,
        ),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          int questionNumber = questions[index];
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
                child: Text(
                  'Q${(questionNumber + 1).toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
