// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Features/AuthScreen/auth_services.dart';
import 'package:flutter_course_app/Features/Home%20Screen/create_poll_screen.dart';
import 'package:flutter_course_app/Features/Home%20Screen/edit_poll_screen.dart';
import 'package:page_transition/page_transition.dart';

class HomeShowPollScreen extends StatefulWidget {
  const HomeShowPollScreen({super.key});

  @override
  State<HomeShowPollScreen> createState() => _HomeShowPollScreenState();
}

class _HomeShowPollScreenState extends State<HomeShowPollScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("CreatePoll"),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () => AuthServices.signOut(context),
                  icon: const Icon(Icons.logout)),
            ],
            bottom: const TabBar(
                indicatorColor: Colors.orange,
                unselectedLabelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: "All"),
                  Tab(
                    text: "Posted",
                  ),
                  Tab(text: "Voted")
                ]),
          ),
          body: TabBarView(children: [
            _buildAllPolls(),
            _buildPostedPolls(),
            _buildVotedPolls()
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () => {
              Navigator.push(
                  context,
                  PageTransition(
                      child: CreatePollScreen(
                        currentUserId: _currentUserId,
                      ),
                      type: PageTransitionType.fade))
            },
            child: const Icon(Icons.add),
          ),
        ));
  }

  Widget _buildPostedPolls() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .where('creatorId', isEqualTo: _currentUserId)
            .snapshots(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          final polls = snapshot.data!.docs;

          return polls.isEmpty
              ? const Center(
                  child: Text(
                    "No Poll Available",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: polls.length,
                  itemBuilder: ((context, index) {
                    final poll = polls[index];
                    return _buildPollCard(poll, showUserVote: false);
                  }));
        }));
  }

  Widget _buildVotedPolls() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('polls').snapshots(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          final polls = snapshot.data!.docs;

          final votedPolls = polls.where((poll) {
            final options = poll['options'] as List<dynamic>;
            // Check if the current user is in any of the 'voters' lists
            for (var option in options) {
              if (option['voters'] != null &&
                  (option['voters'] as List).contains(_currentUserId)) {
                return true;
              }
            }
            return false;
          }).toList();

          return votedPolls.isEmpty
              ? const Center(
                  child: Text(
                    "No Poll Available",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: votedPolls.length,
                  itemBuilder: ((context, index) {
                    final poll = votedPolls[index];
                    return _buildPollCard(poll, showUserVote: true);
                  }));
        }));
  }

  Widget _buildAllPolls() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('polls')
            .where('creatorId', isNotEqualTo: _currentUserId)
            .snapshots(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          final polls = snapshot.data!.docs;

          return polls.isEmpty
              ? const Center(
                  child: Text(
                    "No Poll Available",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: polls.length,
                  itemBuilder: ((context, index) {
                    final poll = polls[index];
                    return _buildPollCard(poll, showUserVote: true);
                  }));
        }));
  }

  Widget _buildPollCard(DocumentSnapshot poll, {bool showUserVote = false}) {
    final data = poll.data() as Map<String, dynamic>;
    final options = data['options'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['title'],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              )
            ],
          ),
          const Divider(
            color: Colors.orangeAccent,
            thickness: 1,
            height: 20,
          ),
          const SizedBox(
            height: 10,
          ),
          for (int i = 0; i < 3; i++) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ]),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    options[i]["imageUrl"],
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, StackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          options[i]['name'],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        LinearProgressIndicator(
                          value: (options[i]['votes'] ?? 0.0) / 100,
                          color: Colors.orange,
                          backgroundColor: Colors.grey[300],
                        ),
                        if (showUserVote &&
                            options[i]['voters'] != null &&
                            (options[i]['voters'] as List)
                                .contains(_currentUserId))
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "You Voted",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          )
                      ]),
                ),
                const SizedBox(
                  width: 15,
                ),
                if (showUserVote)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        handleVote(poll.id, i, context, _currentUserId);
                      },
                      child: const Text(
                        "Vote",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      )),
              ]),
            ),
          ],
          const SizedBox(
            height: 5,
          ),
          if (!showUserVote)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditPollScreen(poll: poll)));
                    },
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.orange),
                    )),
                const SizedBox(
                  width: 5,
                ),
                TextButton.icon(
                    onPressed: () {
                      deletePoll(poll.id, context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            )
        ]),
      ),
    );
  }

  Future<void> deletePoll(String pollId, BuildContext context) async {
    try {
      DocumentSnapshot pollDoc = await FirebaseFirestore.instance
          .collection("polls")
          .doc(pollId)
          .get();

      if (pollDoc.exists) {
        List<dynamic> options = pollDoc['options'] ?? [];

        for (var option in options) {
          if (option['imageUrl'] != null) {
            String imageUrl = option['imageUrl'];

            String? filepath = Uri.decodeFull(Uri.parse(imageUrl)
                .pathSegments
                .lastWhere((element) => element.contains('poll'),
                    orElse: () => ''));

            if (filepath != null && filepath.isNotEmpty) {
              await FirebaseStorage.instance.ref(filepath).delete();
            }
          }
        }
      }

      await FirebaseFirestore.instance.collection("polls").doc(pollId).delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Poll and assocaited images deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting poll $e')));
    }
  }

  Future<void> handleVote(String pollId, int optionIndex, BuildContext context,
      String currentUserId) async {
    try {
      final pollDoc =
          FirebaseFirestore.instance.collection('polls').doc(pollId);
      final pollSnapshot = await pollDoc.get();

      if (pollSnapshot.exists) {
        final data = pollSnapshot.data() as Map<String, dynamic>;
        final totalvotes = data['total_votes'];
        final options = data['options'] as List<dynamic>;

        for (var option in options) {
          if (option['voters'] != null &&
              (option['voters'] as List).contains(currentUserId)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You have already voted.')),
            );
            return;
          }
        }

        final voters = options[optionIndex]['voters'] ?? [];
        voters.add(currentUserId);

        options[optionIndex]['voters'] = voters;
        options[optionIndex]['votes'] =
            (options[optionIndex]['votes'] ?? 0) + 1;

        await pollDoc.update({'options': options});

        await pollDoc.update({'total_votes': totalvotes + 1});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote submitted successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit vote.')),
      );
    }
  }
}
