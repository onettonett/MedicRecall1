import 'package:flutter/material.dart';
import 'package:flashcard_x/questions/question.dart';

class QuestionPage extends StatefulWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String? remainingTime;
  final Function(int, Set<int>) onOptionSelected;
  final Set<int> selectedOptions;

  // New: two additional parameters for flag functionality
  final bool isFlagged;
  final Function(bool) onFlagToggle;

  const QuestionPage({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.remainingTime,
    required this.onOptionSelected,
    required this.selectedOptions,
    required this.isFlagged,
    required this.onFlagToggle,
  });

  @override
  QuestionPageState createState() => QuestionPageState();
}

class QuestionPageState extends State<QuestionPage> {
  Set<int> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _selectedOptions = Set<int>.from(widget.selectedOptions);
  }

  void _onOptionTapped(int index, bool? value) {
    setState(() {
      if (value == true) {
        _selectedOptions.add(index);
      } else {
        _selectedOptions.remove(index);
      }
      // Notify parent to update the selection state
      widget.onOptionSelected(widget.questionIndex, _selectedOptions);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = widget.question.options;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flag button in the top right corner displaying current flag status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Time: ${widget.remainingTime ?? ''}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.flag,
                  color: widget.isFlagged ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  widget.onFlagToggle(!widget.isFlagged);
                },
              ),
            ],
          ),
          Text(
            'Situation: ${widget.question.situation}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            'Question ${widget.questionIndex + 1}/${widget.totalQuestions}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            widget.question.question,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                String optionLetter = String.fromCharCode('A'.codeUnitAt(0) + index);
                return GestureDetector(
                  onTap: () {
                    bool isSelected = _selectedOptions.contains(index);
                    _onOptionTapped(index, !isSelected);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: _selectedOptions.contains(index)
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _selectedOptions.contains(index),
                          onChanged: (bool? value) {
                            _onOptionTapped(index, value);
                          },
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Option $optionLetter: ${options[index]}',
                            style: const TextStyle(color: Colors.black),
                            maxLines: null,
                            softWrap: true,
                          ),
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
    );
  }
}
