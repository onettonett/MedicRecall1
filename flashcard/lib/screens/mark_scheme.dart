import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';

import 'ms_questions.dart';
import 'ms_single.dart';


// first we define our mark scheme info class - DONE
// this is the struct for what we pass to the mark scheme display
// this needs to be taken from the firestore for the mark scheme


class MSInfo {
  final String index;
  final String answer;
  final String explanation;
  final String situation;
  final String action;
  final String type;
  final String id;
  final String bool;

  const MSInfo(this.index, this.answer, this.explanation, this.type, this.id,this.situation,this.action,this.bool);


  @override
  String toString() {
    return "{ index: $index, answer: $answer, explanation: $explanation, type: $type, id: $id, bool: $bool}";

  }
}

class UMS extends StatefulWidget {
  const UMS({super.key});

  @override
  UMSState createState() => UMSState();
}

class UMSState extends State<UMS> {
  List<Map<String, dynamic>> allQuestions = [];
  List<int> multipleChoiceQuestions = [];
  List<int> rankingQuestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchQuestions("multiple choice", multipleChoiceQuestions);
      await fetchQuestions("ranking", rankingQuestions);
      setState(() {});
    });
  }

  Future<void> fetchQuestions(String questionType, List<int> targetList) async {
    if (allQuestions.isEmpty) {
      CollectionReference typeRef = FirebaseWrapper.firestore().collection("markscheme");
      QuerySnapshot typeSnapshot = await typeRef.get();

      for (var doc in typeSnapshot.docs) {
        var question = doc.data() as Map<String, dynamic>;
        var fullNum = question["question"].toString();

        question["question"] =
            fullNum.toString().substring(1, fullNum.indexOf('/', 1));
        question["id"] = doc.reference.id;
        allQuestions.add(question);
      }
      allQuestions.sort(questionComparison);
    }

    for (var i = 0; i < allQuestions.length; i++) {
      if (allQuestions[i]["type"] == questionType) {
        targetList.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        title: "Mark Scheme",
        body: Padding(
          padding: const EdgeInsets.fromLTRB(50, 16, 50, 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExpandablePanel(
                    title: "Multiple Choice Questions (Question 1-${multipleChoiceQuestions.length})",
                    children: QuestionGrid(
                      questions: multipleChoiceQuestions,
                      allQuestions: allQuestions,
                      startingNumber: 0,
                    ),
                  ),
                  SizedBox(height: 16),
                  ExpandablePanel(
                    title: "Ranking Questions (Question ${multipleChoiceQuestions.length+1}-${multipleChoiceQuestions.length+rankingQuestions.length})",
                    children: QuestionGrid(
                      questions: rankingQuestions,
                      allQuestions: allQuestions,
                      startingNumber: multipleChoiceQuestions.length,
                    ),
                  ),
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
  final List<int> questions;
  final List<Map<String, dynamic>> allQuestions;
  final int startingNumber;

  const QuestionGrid({
    super.key,
    required this.questions,
    required this.allQuestions,
    required this.startingNumber
  });

  MSInfo makeMSInfo(int questionIndex, int index) {
    final foundQuestion = allQuestions[questionIndex];
    final answer = foundQuestion['answer'];
    final explanation = foundQuestion['explanation'];
    final type = foundQuestion['type'];
    final id = foundQuestion['id'];
    final situation = foundQuestion['situation'];
    final action = foundQuestion['action'];
    final bool = foundQuestion['bool'];//official or unofficial
    return MSInfo((index + 1).toString(), answer, explanation, type, id,situation,action,bool);
  }

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
        itemCount: questions.length,
        itemBuilder: (context, index) {
          var question = questions[index];
          var questionNumber = startingNumber+int.parse(allQuestions[question]["question"]);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MSSingle(
                    msiSingle: makeMSInfo(questions[index], index),
                    allQuestions: allQuestions,
                    typeQuestions: questions,
                    currentIndex: index,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text('Q${questionNumber.toString()}', style: TextStyle(color: Colors.black)),
              ),
            ),
          );
        },
      ),
    );
  }
}

