import 'package:notevault/services/auth/auth_exceptions.dart';
import 'package:notevault/services/auth/auth_user.dart';
import 'package:test/test.dart';
// lib imports
import 'package:notevault/services/auth/auth_provider.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized at the beginning", () {
      expect(
        provider.isInitialized,
        false,
      );
    });
    test("Cannot log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });
    test("Should initialize in less than 2 seconds", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    test("Create user should delegate to login", () async {
      final emailUser = provider.createUser(
        email: "foo@bar.com",
        password: "testpwd",
      );
      expect(
          emailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final pwdUser = provider.createUser(
        email: "legit@mail.com",
        password: "123456",
      );
      expect(pwdUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: "legit@mail.com",
        password: "legitpwd",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user is expected to be verified", () {
      provider.sendEmailVerificaation();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("Expected to be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "foo@bar.com") throw UserNotFoundAuthException();
    if (password == "123456") throw WrongPasswordAuthException();
    const user =
        AuthUser(id: "test_id", email: "test@test.com", isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerificaation() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(id: "test_id", email: "test@test.com", isEmailVerified: true);
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    throw UnimplementedError();
  }
}
