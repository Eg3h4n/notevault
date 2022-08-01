import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),
      body: Column(children: [
        const Text("A verification email is sent to your email address!"),
        const Text("Please verify your email"),
        TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              await user?.sendEmailVerification();
            },
            child: const Text(
                "Did not recieve the verification email? Click here to receive another one!")),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Verified your email? Login here!"))
      ]),
    );
  }
}
