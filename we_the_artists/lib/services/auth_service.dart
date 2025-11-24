import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Stream for auth state
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Register new user with email verification
  Future<User?> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    await user.updateDisplayName(displayName);
    await user.sendEmailVerification();

    // Save profile to Firestore
    await _db.collection('Users').doc(user.uid).set({
      'name': displayName,
      'email': email,
      'role': '',
      'bio': '',
      'avatarUrl': '', // default avatar can be added here
      'createdAt': FieldValue.serverTimestamp(),
      'verified': false,
    });

    return user;
  }

  // Login — only allow if verified
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!cred.user!.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before logging in.',
      );
    }

    // Ensure Firestore profile exists
    final userDoc = await _db.collection('Users').doc(cred.user!.uid).get();
    if (!userDoc.exists) {
      await _db.collection('Users').doc(cred.user!.uid).set({
        'name': cred.user!.displayName ?? '',
        'email': email,
        'role': '',
        'bio': '',
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'verified': true,
      });
    }

    return cred.user;
  }

  // Logout
  Future<void> signOut() => _auth.signOut();

  // Send verification email again
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
