import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/services/auth/auth_service.dart';

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
              await AuthService.firebase().sendEmailVerificaation();
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
