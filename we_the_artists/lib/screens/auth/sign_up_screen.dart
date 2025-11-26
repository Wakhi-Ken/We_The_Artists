// ignore_for_file: use_super_parameters

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

    // Local theme for this screen
    final customTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF3B62FF),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B62FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B62FF)),
      ),
    );

    return Theme(
      data: customTheme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 124, 168, 243), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to We The Artists',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Mini caption / subtitle
                  Text(
                    'Step into a world where creativity meets community',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 26),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                  ),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (passwordCtrl.text !=
                                  confirmPasswordCtrl.text) {
                                setState(
                                  () => message = 'Passwords do not match',
                                );
                                return;
                              }

                              setState(() => loading = true);
                              try {
                                User? user = await authService.signUp(
                                  emailCtrl.text.trim(),
                                  passwordCtrl.text.trim(),
                                  nameCtrl.text.trim(),
                                );

                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(user.uid)
                                      .set({
                                        'name': nameCtrl.text.trim(),
                                        'role': '',
                                        'location': '',
                                        'bio': '',
                                        'avatarUrl': '',
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });

                                  setState(
                                    () => message =
                                        'Account created! Verification email sent.',
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                setState(() => message = e.message);
                              } finally {
                                setState(() => loading = false);
                              }
                            },
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Register'),
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
      ),
    );
  }
}
