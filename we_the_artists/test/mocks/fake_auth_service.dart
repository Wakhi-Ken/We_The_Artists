import 'package:firebase_auth/firebase_auth.dart';

/// Minimal fake user for testing
class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Completely independent FakeAuthService
class FakeAuthService {
  bool isSignedIn = false;

  /// Simulate login
  Future<User?> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return null;
    isSignedIn = true;
    return FakeUser(uid: '123', email: email, displayName: 'Test User');
  }

  Stream<User?> authStateChanges() {
    return Stream.value(isSignedIn ? FakeUser(uid: '123') : null);
  }

  Future<void> signOut() async {
    isSignedIn = false;
  }
}
