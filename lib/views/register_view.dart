import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib imports
import 'package:notevault/services/auth/auth_exceptions.dart';
import 'package:notevault/services/auth/bloc/auth_bloc.dart';
import 'package:notevault/services/auth/bloc/auth_event.dart';
import 'package:notevault/services/auth/bloc/auth_state.dart';
import 'package:notevault/utilities/dialogs/error_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Password is too weak!");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email already exists...");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Please enter a valid email.");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication failed...");
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
              title: const Text(
            "Register to NoteVault",
          )),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
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
                  context
                      .read<AuthBloc>()
                      .add(AuthEventRegister(email, password));
                },
                child: const Text("Register"),
              ),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text("Already registered? Login here!"))
            ]),
          )),
    );
  }
}
