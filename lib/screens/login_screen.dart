import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'register_screen.dart';
import 'navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String error = '';

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavigationScreen()),
      );
    } catch (e) {
      setState(() => error = 'Erreur de connexion : ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Se connecter')),
            if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text("Pas de compte ? Créer un compte"),
            )
          ],
        ),
      ),
    );
  }
}
