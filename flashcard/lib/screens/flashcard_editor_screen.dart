import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/widgets/app_bar_title.dart';
import 'package:flutter/material.dart';

import 'add_flashcard_screen.dart';

class FlashcardEditor extends StatefulWidget {
  const FlashcardEditor({super.key});

  @override
  State<FlashcardEditor> createState() => FlashcardEditorState();
}

class FlashcardEditorState extends State<FlashcardEditor> {
  CollectionReference flashcards =
      FirebaseWrapper.firestore().collection('flashcards');

  late User user;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
        title: "Create New Flashcard",
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 130,
                        margin: const EdgeInsets.only(
                          bottom: 10.0,
                          left: 30.0,
                          right: 30.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Text(
                                "Use the green button to create your own flashcards and have them seamlessly merge with our existing database.",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 500,
                        height: MediaQuery.of(context).size.height,
                        child: Visibility(
                          visible: !loading,
                          child: StreamBuilder<dynamic>(
                            stream: flashcards
                                .where("owner", isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading");
                              }

                              return ListTileTheme.merge(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                iconColor: const Color(0xFFE57373),
                                textColor: const Color(0xFF2E2E2E),
                                tileColor: const Color(0xFFFAFAFA),
                                selectedTileColor: const Color(0xFFF5F5F5),
                                style: ListTileStyle.list,
                                dense: false,

                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data.docs[index];
                                    return Card(
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 6.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        title: Text(
                                          doc['front'],
                                          style: theme.textTheme.bodySmall!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E2E2E),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            doc['back'],
                                            style: theme.textTheme.bodySmall!.copyWith(color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: const Color(0xFFE57373).withValues(alpha: 0.1),
                                                foregroundColor: const Color(0xFFE57373),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              icon: const Icon(Icons.delete_forever, size: 22),
                                              tooltip: 'Delete',
                                              onPressed: () async {
                                                await deleteCard(doc.id);
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: const Color(0xFF64B5F6).withValues(alpha: 0.1),
                                                foregroundColor: const Color(0xFF64B5F6),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              icon: const Icon(Icons.edit, size: 22),
                                              tooltip: 'Edit',
                                              onPressed: () => editCard(context, doc.id),
                                            ),
                                          ],
                                        ),
                                        tileColor: Colors.transparent,
                                        hoverColor: Colors.grey[100]!.withValues(alpha:0.5),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  addCard(context);
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 16), // Add some spacing between FAB and bottom
            ],
          ),
        )
    );
  }

  Future<void> deleteCard(String cardID) {
    return flashcards.doc(cardID).delete();
  }

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth    ///we check to see if the user is already logged in.
          .authStateChanges() ///if the authState has changed, meaning that a user has been found to already be logged in,
          .first;             ///set tmp to be the user.
      if (tmp == null) {
        nav.push(               ///if the user has not yet logged in,
            MaterialPageRoute(  ///send them to the sign in screen
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

  void addCard(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddCard(cardID: "aaa", editCard: false),
        ));
  }

  void editCard(BuildContext context, String cardID) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCard(cardID: cardID, editCard: true),
        ));
  }
}
