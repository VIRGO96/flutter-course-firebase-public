import 'package:flutter/material.dart';
import 'package:flutter_course_app/Features/AuthScreen/auth_services.dart';
import 'package:flutter_course_app/Features/Provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailCTRL = TextEditingController();
  TextEditingController passwordCTRL = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/images/login_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  "SignUp",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
                Consumer<AuthProviderData>(
                    builder: (_, authPrvoiderData, child) {
                  return TextFormField(
                    controller: passwordCTRL,
                    obscureText: authPrvoiderData.showPassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.25),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          authPrvoiderData
                              .setShowPassword(!authPrvoiderData.showPassword);
                        },
                        child: Icon(
                          authPrvoiderData.showPassword
                              ? Icons.remove_red_eye
                              : Icons.remove_red_eye_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  );
                }),
                const SizedBox(
                  height: 32,
                ),
                Consumer<AuthProviderData>(
                    builder: (_, authProviderData, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: authProviderData.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Colors.orange,
                          ))
                        : ElevatedButton(
                            onPressed: () async {
                              if (emailCTRL.text.isEmpty) {
                                AuthServices.showSnackBar(
                                    "Please add an email.", context);
                              } else if (!isValidEmail(emailCTRL.text)) {
                                AuthServices.showSnackBar(
                                    "Please enter a valid email address.",
                                    context);
                              } else if (passwordCTRL.text.isEmpty) {
                                AuthServices.showSnackBar(
                                    "Please enter your password.", context);
                              } else if (passwordCTRL.text.length < 8) {
                                AuthServices.showSnackBar(
                                    "Password must be at least 8 characters long.",
                                    context);
                              } else {
                                authProviderData.setIsLoading(true);

                                await AuthServices.handleSignUp(
                                  emailCTRL.text.trim(),
                                  passwordCTRL.text.trim(),
                                  context,
                                );
                                authProviderData.setIsLoading(false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                  );
                }),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }

  void validateEmail(String email, BuildContext contextEmail) {
    if (isValidEmail(email)) {
    } else {
      AuthServices.showSnackBar(
          "Please enter a valid email address", contextEmail);
    }
  }

  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
