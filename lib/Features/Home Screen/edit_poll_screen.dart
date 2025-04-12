// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Features/Provider/poll_provider.dart';
import 'package:provider/provider.dart';

class EditPollScreen extends StatefulWidget {
  final DocumentSnapshot poll;
  const EditPollScreen({super.key, required this.poll});

  @override
  State<EditPollScreen> createState() => _EditPollScreenState();
}

class _EditPollScreenState extends State<EditPollScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PollProvider>(context, listen: false);
    provider.initializePoll(widget.poll);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(builder: (_, pollProvider, chidl) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Poll"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
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
                        spreadRadius: 1,
                        offset: const Offset(0, 3))
                  ]),
              child: TextFormField(
                controller: pollProvider.titleController,
                decoration: const InputDecoration(labelText: "Poll Title"),
              ),
            ),
            for (int i = 0; i < pollProvider.optionNameControllers.length; i++)
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
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
                          spreadRadius: 1,
                          offset: const Offset(0, 3))
                    ]),
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: pollProvider.optionNameControllers[i],
                      decoration:
                          InputDecoration(labelText: "Option ${i + 1} Name"),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      pollProvider.pickImage(i);
                    },
                    child: pollProvider.optionImages[i] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              pollProvider.optionImages[i]!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : pollProvider.existingImage[i] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  pollProvider.existingImage[i],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                                height: 50,
                                width: 50,
                                child: const Icon(Icons.image),
                              ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ]),
              ),
            pollProvider.loader
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.orange,
                  ))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      pollProvider.updatePoll(widget.poll.id, context);
                    },
                    child: const Text(
                      "Edit Poll",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ))
          ]),
        ),
      );
    });
  }
}
