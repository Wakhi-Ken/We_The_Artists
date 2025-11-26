import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool loading = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      // appBar: AppBar(title: const Text('Register')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 124, 168, 243), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to We The Artists',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Let\'s setup your account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                TextField(
                  controller: confirmPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 26),
                const SizedBox(height: 20),
                if (message != null)
                  Text(
                    message!,
                    style: TextStyle(
                      color: message!.startsWith('Account created')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (passwordCtrl.text != confirmPasswordCtrl.text) {
                              setState(
                                () => message = 'Passwords do not match',
                              );
                              return;
                            }

                            setState(() => loading = true);
                            try {
                              // Sign up user
                              User? user = await authService.signUp(
                                emailCtrl.text.trim(),
                                passwordCtrl.text.trim(),
                                nameCtrl.text.trim(),
                              );

                              if (user != null) {
                                // Create Firestore profile (optional fields)
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user.uid)
                                    .set({
                                      'name': nameCtrl.text.trim(),
                                      'role': '',
                                      'location': '',
                                      'bio': '',
                                      'avatarUrl': '',
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                setState(
                                  () => message =
                                      'Account created! Verification email sent. Please check your inbox.',
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() => message = e.message);
                            } finally {
                              setState(() => loading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B62FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
