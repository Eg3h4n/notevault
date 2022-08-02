import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/services/auth/auth_exceptions.dart';
import 'package:notevault/services/auth/auth_service.dart';
import 'package:notevault/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          "Login to NoteVault",
        )),
        body: Column(children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: "Enter your email here"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter your password here"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase()
                    .logIn(
                  email: email,
                  password: password,
                )
                    .then((value) {
                  if (value.isEmailVerified) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  } else {
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                });
              } on UserNotFoundAuthException {
                await showErrorDialog(
                    context, "Email or password is incorrect...");
              } on WrongPasswordAuthException {
                await showErrorDialog(
                    context, "Email or password is incorrect...");
              } on GenericAuthException {
                await showErrorDialog(context, "Authentication failed...");
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Don't have an account? Register here!"))
        ]));
  }
}
