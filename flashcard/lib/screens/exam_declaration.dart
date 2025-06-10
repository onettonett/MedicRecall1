import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/mock_test_rank_question.dart';


class ExamDeclaration extends StatefulWidget {
  const ExamDeclaration({super.key});

  @override
  ExamDeclarationState createState() => ExamDeclarationState();
}

class ExamDeclarationState extends State<ExamDeclaration> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        title: "Mock Exam",
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "MedicRecall Full-sized Mock Exam:",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "In this test, you will be presented with typical scenarios that Foundation Year Two (FY2) Doctors encounter, and you will be asked questions about dealing with them. "
                "When answering the questions, please consider yourself to be a FY2 Doctor unless stated otherwise and answer based on what you should do in each scenario.",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          const SizedBox(height: 25),
          const Text(
            "The paper contains 50 questions in total. You have 90 minutes to complete the exam. This is to simulate the amount of time you will have to complete the exam on the day.",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          const SizedBox(height: 30),


          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 25, color: Colors.black),
              children: [
                TextSpan(
                  text: "Part 1: Ranking Questions (Q1-30).",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),

              ],
            ),
          ),

          const Text(
            "In this part you are presented with scenarios followed by a number of possible options. "
                "For each scenario select the 3 options which together are the most appropriate responses to the situation given the circumstances described.",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          const SizedBox(height: 25),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 25, color: Colors.black),
              children: [
                TextSpan(
                  text: "Part 2: Multiple Choice Questions (Q31-50).",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            " In this part, you are presented with scenarios followed by a number of possible options. "
                "For each scenario, select the 3 options which together are the most appropriate responses to the situation given the circumstances described.",
            style: TextStyle(fontSize: 25, color: Colors.black),
          ),
          const SizedBox(height: 25),



          // Begin Exam Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MocktestrankePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "Begin Exam",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}
