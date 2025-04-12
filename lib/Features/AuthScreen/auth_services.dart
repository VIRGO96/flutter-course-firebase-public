// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_app/Features/AuthScreen/signin_screen.dart';
import 'package:flutter_course_app/Features/Home%20Screen/home_show_poll_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class AuthServices {
  static Future<String> signUpwithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      return "Sign-Up successful!";
    } catch (e) {
      return "Error during sign-up : ${e.toString()}";
    }
  }

  static handleSignUp(
      String email, String password, BuildContext context) async {
    String message = await signUpwithEmail(email, password);

    if (message == "Sign-Up successful!") {}
  }

  static Future<String> signInwithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Sign-In successful!";
    } catch (e) {
      return "Error during sign-In : ${e.toString()}";
    }
  }

  static handleSignIn(
      String email, String password, BuildContext context) async {
    String message = await signInwithEmail(email, password);

    if (message == "Sign-In successful!") {
      Navigator.push(
          context,
          PageTransition(
              child: const HomeShowPollScreen(),
              type: PageTransitionType.fade));
    }
  }

  static void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<Map<String, dynamic>?> signInWithGoogle(
      BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      log(userCredential.user!.email!);

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();

      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              child: const SignInScreen(), type: PageTransitionType.fade),
          (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      log('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  static Future<void> resetForgetPasswordsendEmail(
      String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showSnackBar("Reset password Email send successfully!", context);
    } catch (e) {
      showSnackBar("Error in Reset password ${e.toString()}", context);
    }
  }

  static Future<bool> userLogin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }
}
