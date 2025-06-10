import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddCard extends StatefulWidget {
  static final navKey = GlobalKey<NavigatorState>();

  final String cardID;
  final bool editCard;

  const AddCard({Key? navKey, required this.cardID, required this.editCard})
      : super(key: navKey);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _AddCardState(cardID, editCard);
}

class _AddCardState extends State<AddCard> {
  late User user;

  late TextEditingController front;
  late TextEditingController back;
  String topic = "";
  late TextEditingController resource;
  String subtopic = "";

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<String> topics = [];
  List<String> subtopics = [];
  Map<String, List<String>> subtopicsMap = {};

  bool loading = true;
  CollectionReference flashcards =
  FirebaseWrapper.firestore().collection('flashcards');


  String cardID;
  bool editCard;

  _AddCardState(this.cardID, this.editCard);

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getCard() async {
    await FirebaseWrapper.firestore()
        .collection('flashcards') // suppose you have a collection named "Users"
        .doc(cardID)
        .get()
        .then((value) {
      front.text = value["front"];
      back.text = value["back"];
      resource.text = value["resource"];
      topic = value["topic"];
      subtopic = value["subtopic"];
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    if (editCard) {
      getCard();
    }
    getTopics();
    front = TextEditingController();
    back = TextEditingController();
    //topic = TextEditingController();
    resource = TextEditingController();
    // subtopic = TextEditingController();
  }

  Future<void> getTopics() async {
    CollectionReference topicRef =
    FirebaseWrapper.firestore().collection("topics");

    QuerySnapshot topicSnapshot = await topicRef.get();
    for (var doc in topicSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String topicName = data["topic"];
      if (!topics.contains(topicName)) {
        topics.add(topicName);
      }
      
      List<String> tmp = [];
      if (data["subtopics"] != null) {
        for (var topic in data["subtopics"]) {
          tmp.add(topic.toString());
        }
      }
      subtopicsMap[data["topic"]] = tmp;
    }

    if (topics.isNotEmpty) {
      topic = topics.contains(topic) ? topic : topics[0];
    }

    subtopics = subtopicsMap[topic] ?? [];
    if (subtopics.isNotEmpty) {
      subtopic = subtopics.contains(subtopic) ? subtopic : subtopics[0];
    }
    if (kDebugMode) {
      print(topics);
    }
    setState(() {});
  }

  void editCardDB() {
    //print(front.text + back.text + topic.text + resource.text);
    //flashcards.add({"front":front.text, "back":back.text, "resource":resource.text, "topic":topic.text});
    flashcards.doc(cardID).update({
      "front": front.text,
      "back": back.text,
      "resource": resource.text,
      "topic": topic,
      "subtopic": subtopic
    });
  }

  void addCardDB() {
    flashcards.add({
      "front": front.text,
      "back": back.text,
      "resource": resource.text,
      "topic": topic,
      "subtopic": subtopic,
      "owner": user.uid
    });
  }

  void uploadCard() {
    if (editCard) {
      editCardDB();
    } else {
      addCardDB();
    }
    homepage();
  }

  get key =>
      null; // no clue if this is the appropriate thing to do, just did so because it made it work

  @override
  Widget build(BuildContext context) {
    AddCard.navKey;
    return AppScaffold(
      body: Visibility(
        visible: !loading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardTextField(controller: front, label: 'Question...'),
              const SizedBox(height: 16),
              CardTextField(controller: back, label: 'Answer...'),
              const SizedBox(height: 20),
              CardDropdownButton(
                value: topic,
                label: 'Topic',
                items: topics,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      topic = newValue;
                      subtopics = subtopicsMap[topic]!;
                      subtopic = subtopics.isNotEmpty ? subtopics[0] : "";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CardDropdownButton(
                value: subtopic,
                label: 'Subtopic',
                items: subtopics,
                onChanged: (String? newValue) {
                  setState(() {
                    subtopic = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: uploadCard,
                    label: Text(editCard ? "Edit" : "Create", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), 
      title: editCard ? 'Edit Flashcard' : 'Add Flashcard',
    );

  }

  void homepage() {
    Navigator.pop(context);
    }
}

class CardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CardTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}

class CardDropdownButton extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CardDropdownButton({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      items: items.toSet().map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}