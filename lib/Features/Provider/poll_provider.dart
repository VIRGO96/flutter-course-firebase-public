import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PollProvider extends ChangeNotifier {
  final titleController = TextEditingController();
  final List<TextEditingController> optionNameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<File?> optionImages = [null, null, null];
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> existingImage = [];
  bool loader = false;

  Future<void> pickImage(int i) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      optionImages[i] = File(pickedFile.path);
      notifyListeners();
    }
  }

  void initializePoll(DocumentSnapshot poll) {
    final data = poll.data() as Map<String, dynamic>;
    titleController.text = data['title'];

    optionNameControllers.clear();
    optionImages.clear();
    existingImage.clear();

    final options = List<Map<String, dynamic>>.from(data['options']);
    for (var option in options) {
      optionNameControllers.add(TextEditingController(text: option['name']));
      existingImage.add(option['imageUrl'] ?? "");
      optionImages.add(null);
    }
  }

  Future<void> updatePoll(String pollId, BuildContext context) async {
    if (!validateForm2(context)) return;

    loader = true;

    notifyListeners();
    try {
      final List<Map<String, dynamic>> options = [];

      for (int i = 0; i < 3; i++) {
        String? imageUrl = existingImage[i];

        if (optionImages[i] != null) {
          imageUrl = await uploadImage(optionImages[i]!, pollId, i);
        }

        options.add({
          'name': optionNameControllers[i].text,
          "imageUrl": imageUrl,
        });
      }

      await FirebaseFirestore.instance
          .collection('polls')
          .doc(pollId)
          .update({"title": titleController.text, 'options': options});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poll Edit Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to edit Poll!")));
    } finally {
      loader = false;
      notifyListeners();
      Navigator.pop(context);
    }
  }

  Future<void> submitPoll(String userId, BuildContext context) async {
    if (!validateForm(context)) return;

    loader = true;
    notifyListeners();

    try {
      final pollDoc = FirebaseFirestore.instance.collection("polls").doc();

      final pollId = pollDoc.id;

      final List<Map<String, dynamic>> options = [];

      for (int i = 0; i < 3; i++) {
        final imageUrl = await uploadImage(optionImages[i]!, pollId, i);

        if (imageUrl == null) throw Exception("Image Upload fialed");

        options.add({
          'name': optionNameControllers[i].text,
          "imageUrl": imageUrl,
          'votes': 0
        });
      }

      await pollDoc.set({
        "pollId": pollId,
        "title": titleController.text.toString(),
        "options": options,
        "createdAt": FieldValue.serverTimestamp(),
        "creatorId": userId,
        "total_votes": 0
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poll Created Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create Poll!")));
    } finally {
      loader = false;
      notifyListeners();
      Navigator.pop(context);
    }
  }

  bool validateForm(BuildContext context) {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Title is required")));
      return false;
    }
    for (int i = 0; i < optionNameControllers.length; i++) {
      if (optionNameControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Option ${i + 1} name is required")));
        return false;
      } else if (optionImages.contains(null)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please Select an Image for all options")));
        return false;
      }
    }
    return true;
  }

  bool validateForm2(BuildContext context) {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Title is required")));
      return false;
    }
    for (int i = 0; i < optionNameControllers.length; i++) {
      if (optionNameControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Option ${i + 1} name is required")));
        return false;
      }
    }
    return true;
  }

  Future<String?> uploadImage(File optionImage, String pollId, int i) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('poll/$pollId/${i.toString()}_$pollId.jpg');
      final imageData = await storageRef.putFile(optionImage);

      return await imageData.ref.getDownloadURL();
    } catch (e) {
      log("Error uploading Image :$e");
      return null;
    }
  }
}
