import 'package:flutter/material.dart';
import 'package:flashcard_x/questions/question.dart';

class RankingQuestionPage extends StatefulWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final String? remainingTime;
  // Callback to notify the parent when the ranking order is changed.
  // The callback receives the question index and the new list of option indices (in ranked order).
  final Function(int, List<int>) onRankChanged;
  // Initial ranking order. For example, if there are 4 options, this might be [0, 1, 2, 3].
  final List<int> initialRankOrder;
  // Flag status for the question.
  final bool isFlagged;
  // Callback to toggle the flag status.
  final Function(bool) onFlagToggle;

  const RankingQuestionPage({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onRankChanged,
    required this.initialRankOrder,
    required this.isFlagged,
    required this.onFlagToggle,
    this.remainingTime,
  });

  @override
  State<RankingQuestionPage> createState() => _RankingQuestionPageState();
}

class _RankingQuestionPageState extends State<RankingQuestionPage> {
  late List<int> _rankOrder;

  @override
  void initState() {
    super.initState();
    // Initialize the ranking order to the provided initial order.
    _rankOrder = List<int>.from(widget.initialRankOrder);
  }

  // When an item is reordered, update the local ranking order and notify the parent.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final int movedItem = _rankOrder.removeAt(oldIndex);
      _rankOrder.insert(newIndex, movedItem);
    });
    widget.onRankChanged(widget.questionIndex, _rankOrder);
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = widget.question.options;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          // The reorderable list for ranking options without a dedicated drag handle.
          Expanded(
            child: ReorderableListView(
              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Transform.scale(
                  scale: 1.0,
                  child: Material(
                    type: MaterialType.transparency,
                    child: child,
                  ),
                );
              },
              buildDefaultDragHandles: false,
              onReorder: _onReorder,
              children: List.generate(_rankOrder.length, (i) {
                final optionIndex = _rankOrder[i];
                String optionLetter = String.fromCharCode('A'.codeUnitAt(0) + optionIndex);
                return ReorderableDragStartListener(
                  key: ValueKey(optionIndex),
                  index: i,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Option $optionLetter: ${options[optionIndex]}',
                      style: const TextStyle(color: Colors.black),
                      maxLines: null,
                      softWrap: true,
                    ),
                  ),
                );
              }),
            ),
          ),
          // You can add submission or navigation buttons here if needed.
        ],
      ),
    );
  }
}
