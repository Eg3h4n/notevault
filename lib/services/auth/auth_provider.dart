// lib imports
import 'package:notevault/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> sendEmailVerificaation();
  Future<void> logOut();
  Future<void> sendPasswordReset({required String email});
}
