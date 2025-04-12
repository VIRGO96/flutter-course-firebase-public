import 'package:flutter/material.dart';
import 'package:flutter_course_app/Features/AuthScreen/auth_services.dart';
import 'package:flutter_course_app/Features/Provider/auth_provider.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final emailCTRL = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Image.asset(
              "assets/images/forget_password_icon.png",
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
            const Text(
              "Forget Password",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 30,
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: emailCTRL,
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.25),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.black,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 20,
            ),
            Consumer<AuthProviderData>(builder: (_, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: authProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (emailCTRL.text.isEmpty) {
                            AuthServices.showSnackBar(
                                "Please Add Email", context);
                          } else if (!isValidEmail(emailCTRL.text)) {
                            AuthServices.showSnackBar(
                                "Please enter a valid Email", context);
                          } else {
                            authProvider.setIsLoading(true);
                            AuthServices.resetForgetPasswordsendEmail(
                                emailCTRL.text, context);
                            authProvider.setIsLoading(false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Send Password Reset Email")),
              );
            })
          ],
        ),
      )),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
