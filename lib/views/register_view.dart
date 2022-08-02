import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/services/auth/auth_exceptions.dart';
import 'package:notevault/services/auth/auth_service.dart';
import 'package:notevault/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
          "Register to NoteVault",
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
              // Due to flutter's "Do not use buildcontexts across async gaps" warning we assign the navigator before awaiting
              final navigator = Navigator.of(context);
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase()
                    .createUser(
                      email: email,
                      password: password,
                    )
                    .then((user) async => {
                          await AuthService.firebase().sendEmailVerificaation()
                        });

                navigator.pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "Password is too weak!");
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "Email already exists...");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Please enter a valid email.");
              } on GenericAuthException {
                await showErrorDialog(context, "Authentication failed...");
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Already registered? Login here!"))
        ]));
  }
}
