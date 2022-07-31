import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        const Text("Please verify your email"),
        TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              await user?.sendEmailVerification();
            },
            child: const Text("Send email verification")),
        TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login/", (route) => false);
            },
            child: const Text("Verified your email? Login here!"))
      ]),
    );
  }
}
