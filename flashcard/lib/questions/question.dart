// lib/models/question.dart
class Question {
  final String pNumber;
  final String question;
  final String situation;
  final String explanation;
  final String type;
  final List<String> options;
  final List<int> correctOptions;

  Question({
    required this.pNumber,
    required this.question,
    required this.situation,
    required this.explanation,
    required this.type,
    required this.options,
    required this.correctOptions,
  });

  factory Question.fromMap(Map<String, dynamic> data, String documentId) {
    // Parse the 'action' field to generate options
    List<String> options = _parseOptionsFromAction(data['action'] ?? '');

    // Determine the correct options by parsing the 'answer' field
    List<int> correctOptionIndices = _parseCorrectOptionsFromAnswer(data['answer'] ?? '');

    return Question(
      pNumber: documentId,
      question: data['question'] ?? '',
      situation: data['situation'] ?? '',
      explanation: data['explanation'] ?? '',
      type: data['type'] ?? '',
      options: options,
      correctOptions: correctOptionIndices,
    );
  }

  // get answer
  String get answer {
    return correctOptions
        .map((index) => String.fromCharCode('A'.codeUnitAt(0) + index))
        .join();
  }

  // Method to parse options from the 'action' text
  static List<String> _parseOptionsFromAction(String actionText) {
    RegExp optionPattern = RegExp(
      r'(?:Option\s+)?([A-Z])[:\.]\s*(.*?)\s*(?=(?:Option\s+)?[A-Z][:\.]|$)',
      dotAll: true,
      multiLine: true,
    );

    Iterable<RegExpMatch> matches = optionPattern.allMatches(actionText);

    List<String> options = [];
    Map<String, String> optionMap = {};

    for (var match in matches) {
      String optionLetter = match.group(1)!; // Get the option letter
      String optionText = match.group(2)!;   // Get the option text
      optionMap[optionLetter] = optionText.trim();
    }

    // Sort the options by their letters to ensure correct indexing
    List<String> sortedKeys = optionMap.keys.toList()..sort();

    for (var key in sortedKeys) {
      options.add(optionMap[key]!);
    }

    return options;
  }

  // Method to parse correct options from the 'answer' text
  static List<int> _parseCorrectOptionsFromAnswer(String answerText) {
    // Adjust the regex to match formats like 'Answer: ACH'
    RegExp answerKeyRegex = RegExp(
      r'^(?:Answer Key|Answer key|Answer|Correct Key):\s*([A-Z]+)',
      caseSensitive: false,
      multiLine: true,
    );

    Match? match = answerKeyRegex.firstMatch(answerText.trim());

    if (match != null) {
      String optionsLetters = match.group(1)!;
      List<int> indices = optionsLetters.split('').map((letter) {
        letter = letter.trim();
        int index = letter.toUpperCase().codeUnitAt(0) - 'A'.codeUnitAt(0);
        if (index >= 0 && index < 26) {
          return index;
        } else {
          return -1;
        }
      }).where((index) => index >= 0).toList();
      return indices;
    } else {
      return [];
    }
  }
}
