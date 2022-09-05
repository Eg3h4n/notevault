import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// lib imports
import 'package:notevault/constants/routes.dart';
import 'package:notevault/helpers/loading/loading_screen.dart';
import 'package:notevault/services/auth/bloc/auth_bloc.dart';
import 'package:notevault/services/auth/bloc/auth_event.dart';
import 'package:notevault/services/auth/bloc/auth_state.dart';
import 'package:notevault/services/auth/firebase_auth_provider.dart';
import 'package:notevault/views/forgot_password_view.dart';
import 'package:notevault/views/login_view.dart';
import 'package:notevault/views/notes/create_update_note_view.dart';
import 'package:notevault/views/notes/notes_view.dart';
import 'package:notevault/views/register_view.dart';
import 'package:notevault/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Note Vault',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const LandingPage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView()
    },
  ));
}

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen()
            .show(context: context, text: state.loadingText ?? "Loading...");
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator.adaptive(),
        );
      }
    });
  }
}
