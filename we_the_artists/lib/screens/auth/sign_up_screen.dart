import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<SignUpScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
            const SizedBox(height: 20),
            if (message != null) Text(message!, style: const TextStyle(color: Colors.green)),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);
                      try {
                        await authService.signUp(
                          emailCtrl.text.trim(),
                          passwordCtrl.text.trim(),
                          nameCtrl.text.trim(),
                        );
                        setState(() => message =
                            'Verification email sent. Please check your inbox before logging in.');
                      } on FirebaseAuthException catch (e) {
                        setState(() => message = e.message);
                      } finally {
                        setState(() => loading = false);
                      }
                    },
              child: loading ? const CircularProgressIndicator() : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
