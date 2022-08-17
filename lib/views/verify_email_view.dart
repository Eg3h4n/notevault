import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib imports
import 'package:notevault/services/auth/bloc/auth_bloc.dart';
import 'package:notevault/services/auth/bloc/auth_event.dart';

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
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
            },
            child: const Text(
                "Did not recieve the verification email? Click here to receive another one!")),
        TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text("Verified your email? Login here!"))
      ]),
    );
  }
}
